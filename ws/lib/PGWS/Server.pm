#
#    Copyright (c) 2010, 2012 Tender.Pro http://tender.pro.

#    This file is part of PGWS - Postgresql WebServices.

#    PGWS is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    PGWS is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.

#    You should have received a copy of the GNU Affero General Public License
#    along with PGWS.  If not, see <http://www.gnu.org/licenses/>.

# PGWS::Server - API server

package PGWS::Server;

use PGWS;
use PGWS::Meta;
use PGWS::Utils;

use DBI;
use Cache::FastMmap;

# Доступный извне номер версии
our $VERSION = $PGWS::VERSION;

#----------------------------------------------------------------------

sub cfg   { $_[0]->{'cfg'} }
sub db    { $_[0]->{'db'} }
sub dbwr  { $_[0]->{'dbwr'} }  # TODO: use set of db tags
sub cache { $_[0]->{'cache'} } # TODO: check set of cache tags

sub def_mtd      { $_[0]->{'def'}{'mtd'} } # super def
sub def_acl      { $_[0]->{'def'}{'acl'} || 'acl'}
sub def_sid      { $_[0]->{'def'}{'sid'} || 'sid'}
sub def_err      { $_[0]->{'def'}{'err'} || 'err'}
sub def_acl_eff  { $_[0]->{'def'}{'acl_eff'} || 'acl_eff'}
sub def_class    { $_[0]->{'def'}{'class'} || 'class'}
sub def_cache    { $_[0]->{'def'}{'cache'} || 'cache'}
sub def_dt       { $_[0]->{'def'}{'dt'} || 'dt'}
sub def_dt_part  { $_[0]->{'def'}{'dt_part'} || 'dt_part'}
sub def_dt_facet { $_[0]->{'def'}{'dt_facet'} || 'dt_facet'}
sub def_facet    { $_[0]->{'def'}{'facet'} || 'facet'}

sub class_list  { $_[0]->{'class_list'} }
sub cache_list  { $_[0]->{'cache_list'} }
sub facet_list  { $_[0]->{'facet_list'} }

#----------------------------------------------------------------------
sub new {
  my ($class, $self) = @_;
  bless $self, $class;

  my $ret = $self->_cfg_load();
  return ($self, $ret);
}

#----------------------------------------------------------------------
sub _cfg_load {
  my $self = shift;

  $self->{'def'} = {}; # сброс всех описаний методов

  my $file = $self->{'root'}.($ENV{'PGWS_SRV'} || '/conf/server.json');
  $self->{'cfg'} = PGWS::Utils::data_load($file);

  foreach my $tag (qw(rpc db cache)) {
    $file = $self->{'root'}.($ENV{'PGWS_'.uc($tag)} || '/conf/'.$tag.'.json');
    $self->{'cfg'}{$tag} = PGWS::Utils::data_load($file);
  }

  my %meta = %{$self->cfg->{'rpc'}};
  my $meta = PGWS::Meta->new(\%meta);
  $meta->stage_in('init');
  $meta->setlang($self->{'cfg'}{'lang'}{'default'});
  my $ret;
  $ret = $self->_init_dbs($meta);
  # TODO: учесть случай, когда работаем из кэша, без БД
  unless ($ret->{'result'}) { $meta->stage_out; return $ret; }

  my $def = $self->_call_cached($self->cfg->{'def_method'}, $meta, [$self->cfg->{'def_method'}{'code'}]);
  $self->{'def'}{'mtd'} = $def->{'result'}{'data'} or die 'No access to system def.';

  $self->{'class_list'} = $self->_call_meta($self->def_class, $meta, 0) or die 'No access to class_list.';
  $self->{'cache_list'} = $self->_call_meta($self->def_cache, $meta, 0) or die 'No access to cache_list.';
  $self->{'facet_list'} = $self->_call_meta($self->def_facet, $meta, 0) or die 'No access to facet_list.';

  $ret = $self->_init_cache('cache');
  unless ($ret->{'result'}) { $meta->stage_out; return $ret; }
  $self->{'cache'} = $ret->{'result'}{'data'};

  return;
}

#----------------------------------------------------------------------
# TODO: открывать кэш при старте apache
# In mod_perl, just open the cache at the global level in the appropriate module, which is executed as the server is starting and before it starts forking children, but you’ll probably want to chmod or chown the file to the permissions of the apache process.

sub _init_cache {
  my ($self, $tag) = @_;

  my $cfg = $self->{'cfg'}{$tag};
  return unless $cfg;
  my $caches = $self->cache_list;
  my $cache = {};
  foreach my $id (keys %$caches) {
    next unless ($caches->{$id}{'is_active'});
    my $c = $cfg->{$caches->{$id}{'code'}};
    my $f = $c->{'share_file'};
    if ($f !~ /^\//) {
      $c->{'share_file'} = $self->{'root'}.'/var/cache/'.$f;
    }
    $cache->{$id} = Cache::FastMmap->new($c);
    chmod 0666, $c->{'share_file'};
  }
  return { 'result' => { 'data' => $cache } };
}

#----------------------------------------------------------------------
sub _init_db {
  my ($self, $meta, $tag) = @_;
  my $dbh = $self->{'_dbh'}; # конструктору может передаваться хэндл для запуска тестов внутри транзакции
  unless ($dbh) {
    # no  prepared handle
    my $cfg = $self->{'cfg'}{$tag};
    $dbh = DBI->connect(@{$cfg->{'connect'}}) or return $self->_rpc_error($meta, 'db_error', $DBI::errstr);
    $dbh->{'pg_enable_utf8'} = 1;
    if ($cfg->{'init'}) {
      foreach my $sql (@{$cfg->{'init'}}) {
        $dbh->do($sql) or return $self->_rpc_error($meta, 'db_error', $DBI::errstr)
      }
    }
  }
  return { 'result' => { 'data' => $dbh } };
}
#  $dbh->do("SET search_path TO my_schema, public");

#----------------------------------------------------------------------
sub _init_dbs {
  my ($self, $meta) = @_;
  my $ret = $self->_init_db($meta, 'db');
  unless ($ret->{'result'}) { return $ret; }
  $self->{'db'} = $ret->{'result'}{'data'};
  unless ($self->{'dbwr'}) {
    if ($self->cfg->{'dbwr'}) {
      $ret = $self->_init_db($meta, 'dbwr');
      unless ($ret->{'result'}) { return $ret; }
      $self->{'dbwr'} = $ret->{'result'}{'data'};
    } else {
      $self->{'dbwr'} = $self->{'db'};
    }
  }
  return $ret;
}

#----------------------------------------------------------------------
sub run {
  my ($self, $meta, $data) = @_;
  my $res = { 'jsonrpc' => '2.0', 'server' => 'PGWS v'.$PGWS::VERSION}; #, 'version' => '1.1'

  # TODO: в серверной версии
  # %meta будет извлекаться из конверта запроса
  # будет проверяться валидность $meta->{key} для ip клиента
  # и этим определяться доверие к остальным полям хэша %meta
  # если $meta->{key} не задан, $meta->{ip} = ip клиента
  # $meta->{'enc'} ||= $self->cfg->{'default_encoding'};
  # my $meta = PGWS::Meta->new($self->cfg->{'rpc'});
  # $meta->setip($req->user_ip);
  $meta->{'syslog'} ||= $self->cfg->{'rpc'}{'syslog'};

  unless($data) {
    return $self->_rpc_error($meta, 'no_data');
  }

  my $call;
  eval {
    $call = PGWS::Utils::json_in($data);
  };

  if ($@) {
    $meta->dump({'call' => $data});
    return $self->_rpc_error($meta, 'bad_json', $@);
  } elsif (!$call->{'method'} or !$call->{'id'} or !$call->{'jsonrpc'} or $call->{'jsonrpc'} != '2.0') {
    $meta->dump({'call' => $data});
    return $self->_rpc_error($meta, 'bad_req');
  }
  $meta->{'debug'}{$meta->{'source'}} = $call->{'debug'} if ($call->{'debug'});

  $meta->dump({'call' => $call, 'meta' => $meta});

  $res->{'id'} = $call->{'id'};

  # проверить sid и получить параметры сессии
  # sid валидируем здесь, т.к. run_prepared вызывается фронтендом (и шаблонизатором) десятки раз на страницу для одного и того же sid.
  # т.е. можем разгрузить кэш
  $meta->stage_in('sid');

  my $lang = $call->{'lang'}; # передан клиентом, не проверен
  $lang = PGWS::Utils::lang_mk($self->{'cfg'}{'lang'}, $lang);
  $meta->setlang($lang || $self->{'cfg'}{'lang'}{'default'});

  my $sid = $call->{'sid'}; # передан клиентом, не проверен
  my $session = {};
  if ($sid) {
    $session = $self->_call_meta($self->def_sid, $meta, $sid, $meta->{'ip'});
  }
  $meta->setsid($session->{'sid'}); # sid после валидации or undef
  if (!$lang and $session->{'lang'}) {
    # не задан явно - берем из сессии
    $lang = $session->{'lang'};
    $meta->setlang($lang);
  }

  $meta->stage_out;

  my $ret = $self->run_prepared($meta, $call->{'method'}, $call->{'params'});
  %$res = (%$res, %$ret);
  $meta->dump({'res' => $res});
  $res->{'debug'} = $meta->data if ($call->{'debug'});
  return $res;
}

#----------------------------------------------------------------------
sub run_prepared {
  my ($self, $meta, $method, $params) = @_;
  $meta->{'syslog'} ||= $self->cfg->{'rpc'}{'syslog'};
  $meta->debug('call for %s', $method);
  $meta->stage_in('call');
  my $ret = $self->_process($meta, $method, $params);
  $meta->stage_out;
  $meta->debug('finished after %.3f sec with %i hits and %i db calls', $meta->elapsed, $meta->stat_hit, $meta->stat_db);
  return $ret;
}

#----------------------------------------------------------------------
sub _process {
  my ($self, $meta, $method, $params) = @_;

  $params ||= {};
  $meta->dump({'method' => $method, 'params' => $params});

  my $res = { 'success' => 'false' };
  my $ret;
  my $check_mode = 0;
  my $rvf;

  my $che1 = $self->cfg->{'check_prefix'};
  my $che2 = $self->cfg->{'acl_prefix'};
  my $che3 = $self->cfg->{'nocache_prefix'};
  if ($method =~ /^$che1(.+)$/) {
    $method = $1;
    $check_mode = 1;
  } elsif ($method =~ /^$che2(.+)$/) {
    $method = $1;
    $check_mode = 2;
  } elsif ($method =~ /^$che3(.+)$/) {
    $method = $1;
    $check_mode = 3;
  }
  if ($method =~ /(.+):(\d)$/) {
    $method = $1;
    $rvf = $2; # TODO: валидировать... или добавить поддержку кода 9
  }

  unless ($method =~ /^[a-z\d_][a-z\d\.\-_]*$/) { # можно бы и валидатор вызвать, но будет дольше
    return $self->_rpc_error($meta, 'bad_args');
  }

  my $mtd_def = $self->_call_meta($self->def_mtd, $meta, $method);
  unless ($mtd_def and ref $mtd_def eq 'ARRAY' and $mtd_def->[0]{'code'}) {
    return $self->_rpc_error($meta, 'no_mtd',$method);
  } else {
    $mtd_def = $mtd_def->[0];
  }

  # системные аргументы
  my $info = {
    '_ip'   => $meta->{'ip'},
    '_sid'  => $meta->{'sid'},
    '_lang' => $meta->{'lang'},
  };
  my %params = (%$params, %$info);
  # получить acl
  my $acl;
  # валидировать ключевые аргументы, которые нужны для определения acl
  my %acl_params = (%$mtd_def, %$info);
  # определить class.code и class.id_count
  my $class = $self->class_list->{$mtd_def->{'class_id'}};
  # выбрать только те id, которые нужны для идентификации экземпляра
  if ($class->{'id_count'}) {
    for my $i (0..$class->{'id_count'} - 1) {
      my $k = 'id'.($i || '');
      $acl_params{$k} = $params->{$k};
    }
  }

  my ($errors, $args, $args_hash) = $self->_validate($meta, $self->def_acl, \%acl_params);
  if (ref($errors) eq 'ARRAY' and scalar(@$errors)) {
    $res->{'result'} = { 'error' => $errors };
    return $res;
  } elsif (ref(\$errors) eq 'SCALAR' and $errors) {
    return $errors; # system error;
  }
  $acl = $self->_call_meta($self->def_acl, $meta, @$args);
  # TODO: добавить acl в res->{'meta'}

  unless(defined($acl) or $check_mode == 2) {
    return $self->_rpc_error($meta, 'ws_no_acc', $args);
  } elsif (defined($acl) and $acl == 0) {
    # нет такого объекта
    $res->{'result'} = { 'error' => [ $self->_app_error($meta, 'Y0010') ] };
    return $res;
  } elsif ($check_mode == 2) {
    $res->{'result'}{'data'} = $acl?1:0;
    $res->{'success'} = 'true' if ($acl);
    $meta->dump({'acl_check' => $res});
    return $res;
  }
  # текущий список acl
  my @acls = keys %$acl;
  $params{'_acl'} = \@acls;

  # валидировать все аргументы метода
  ($errors, $args, $args_hash) = $self->_validate($meta, $mtd_def, \%params);
  if ($check_mode != 1 and scalar(@$errors)) {
    $res->{'result'} = { 'error' => $errors, 'args' => $args_hash };
    $meta->dump({'acl_error' => $res});
    return $res;
  }
  if ($check_mode == 1) {
    # TODO: если метод имеет аргумент "a__chk" - его можно вызвать с этим флагом
    $res->{'result'} = {};
    $res->{'result'}{'data'} = (scalar(@$errors))?0:1;
    $res->{'result'}{'error'} = $errors if (scalar(@$errors));
  } else {
    eval {
      $res = $self->_call_cached($mtd_def, $meta, $args, $rvf, ($check_mode == 3));
    };
    if ($@) {
      if (ref $@ eq 'HASH' and $@->{'code'}) {
        $res->{'error'} = $@;
      } else {
        $res = $self->_rpc_error($meta, 'srv_error', $@);
      }
    }
  }

  $res->{'result'}{'args'} = $args_hash; # аргументы, прошедшие валидацию
  if (exists($res->{'result'}) and exists($res->{'result'}{'data'})) {
    $res->{'success'} = 'true';
    $meta->dump({'call_ok' => $res });
  } else {
    $meta->dump({'call_error' => $res });
  }
  return $res;
}

#----------------------------------------------------------------------
sub _call_meta {
  my ($self, $mtd_def, $meta, @args) = @_;
  $mtd_def = $self->_explain_def($mtd_def, $meta);
  my $ret = $self->_call_cached($mtd_def, $meta, \@args);
  return $ret->{'result'}{'data'};
}

#----------------------------------------------------------------------
sub _explain_def {
  my ($self, $mtd_def, $meta) = @_;
  if (ref \$mtd_def eq 'SCALAR') {
    my $code = $self->cfg->{'def'}{$mtd_def} || $mtd_def; # имени нет в конфиге, если оно генерится автоматом
    $meta->debug('load meta for %s via %s', $mtd_def, $code);
    my $def = $self->_call_cached($self->def_mtd, $meta, [$code]);
    $self->{'def'}{$mtd_def} = $def->{'result'}{'data'}[0]; # даже не надо сохранять, если используем кэш, а не память процесса
    $mtd_def = $self->{'def'}{$mtd_def} or die 'ERROR: No def data for '.$code;
  }
  return $mtd_def;
}
#----------------------------------------------------------------------
sub _call_cached {
  my ($self, $mtd_def, $meta, $args, $rvf, $nc) = @_;
  my ($cache, $key, $value, $res);


  my $cache_id = $mtd_def->{'cache_id'};
  if ($self->cache and exists($self->cache->{$cache_id})) { # and $mtd_def->{'cache_id'} > 1) {
    my $prekey = [lc($meta->{'enc'}), $mtd_def->{'code'}, $rvf, @$args];
    if ($mtd_def->{'is_i18n'}) {
      unshift @$prekey, $meta->{'lang'};
    }
    $cache = $self->cache->{$cache_id};
    if ($cache) {
      $key = PGWS::Utils::json_out($prekey);
      $value = $cache->get($key) unless ($nc);
    }
  }
  if (!defined $value) {
    # TODO: поместить в кэш флаг начала обработки (для повторных вызовов)
    # $Cache->set($key1, {meta=>{cache_start => time(), cache_pid => $$}});
    $meta->dump({'call args' => $args});
    if ($mtd_def->{'is_sql'}) {
      $meta->stat_db_inc;
      $res = $self->_call_db($mtd_def, $meta, $args, $rvf);
    } else {
      $res = $self->_call_plugin($mtd_def, $meta, $args);
    }
    $meta->stage_in('cache');
    if ($cache and !defined($res->{'error'})) {   # no cache for system errors
      unless ($cache->set($key, $res)) {
      $meta->debug('[set cache %s]', $key);
        $meta->dump({'bad_key' => $key, 'bad_data' => $res});
        $meta->sys_error('CACHE SET FAIL: '.$key);
      }
      $meta->debug('[set cache %s]', $key);
    } else {
      $meta->debug('[no cache]');
    }
  } else {
    $res = $value;
    $meta->stage_in('cache');
    $meta->stat_hit_inc;
    $meta->debug('[hit cache %s]', $key);
    $meta->dump({'from_cache' => $res});
  }
  $meta->stage_out;

  # TODO: если в результате стоит флаг начала обработки - ожидать появления данных в кэше
  return $res;
}

#----------------------------------------------------------------------
sub _call_db {
  my ($self, $mtd_def, $meta, $args, $rvf) = @_;

  my $str = join ',', map { '?' } @$args;
  my $sql = sprintf 'select * from %s(%s)', $mtd_def->{'code_real'}, $str;
  my $ret;
  my @errors;
  my $res = {};
  $rvf = $mtd_def->{'rvf_id'} unless ($rvf);
  my $need_hash = ($rvf % 2)?1:0; # нечетные хотят хэш

  my $lang_sql;
  if ($meta->{'lang'} eq $self->{'cfg'}{'lang'}{'default'} or !$mtd_def->{'is_i18n'}) {
    $lang_sql = $self->{'cfg'}{'lang'}{'sql'}{'default'};
    $meta->debug('Database call for %s with default lang', $mtd_def->{'code_real'});
  } else {
    $lang_sql = sprintf $self->{'cfg'}{'lang'}{'sql'}{'other'}, $meta->{'lang'};
    $meta->debug('Database call for %s with lang %s', $mtd_def->{'code_real'}, $meta->{'lang'});
  }

  eval {
    my $dbh = $self->{$mtd_def->{'is_rw'}?'dbwr':'db'};
    $dbh->{RaiseError} = 1;
    $dbh->{PrintError} = 0;

    $dbh->do(sprintf "set client_encoding to '%s'", $meta->{'enc'});
    $dbh->do($lang_sql);
    $ret = $dbh->selectall_arrayref($sql, $need_hash?{'Slice' => {} }:undef, @$args);
  };
  if ($@) {
    # if ($@ =~ /ERROR:  (\[.+\]) at /) { # TODO: check "ERROR..at" with real database locale
    if ($@ =~ /ERROR:  (\[.+\])/) { # TODO: check "ERROR..at" with real database locale
      # got errors
      my $e = PGWS::Utils::json_in($1);

      foreach my $ee (@$e) {
        $meta->dump({'db_exception' => $ee });
        if ($ee->{'code'} eq $self->{'cfg'}{'db_noacc_code'}) {
          return $self->_rpc_error($meta, 'db_no_acc');
        }
        $ee->{'message'} = $self->_error_fmt($meta, $ee->{'code'}, $ee);
      }
      push @errors, @$e;
    } else {
      return $self->_rpc_error($meta, 'db_error', $@);
    }
  } else {
# (1, 'нет');
# (2, 'скаляр');
# (3, 'хэш');
# (4, 'хэш {[i][0] -> [i][1]}');
# (5, 'хэш {[i]{id} -> %[i]}');
# (6, 'массив [i][0]');
# (7, 'массив хэшей');
# (8, 'массив массивов');

    if ($rvf < 4) {;
      $ret = $ret->[0]; # берем 1ю строку
      $ret = $ret->[0] unless ($need_hash); # массив из 1го элемента
    } elsif ($rvf == 4) {
      my $ret2 = {};
      foreach my $i (@$ret) {
        $ret2->{$i->[0]} = $i->[1];
      }
      $ret = (%$ret2)?$ret2:undef;
    } elsif ($rvf == 5) {
      my $ret2 = {};
      my $key = (scalar(@$ret) > 0 and exists($ret->[0]{'id'}))?'id':'code';
      foreach my $i (@$ret) {
        $ret2->{$i->{$key}} = $i;
      }
      $ret = (%$ret2)?$ret2:undef;
    } elsif ($rvf == 6) {
      my $ret2 = [];
      foreach my $i (@$ret) {
        push @$ret2, $i->[0];
      }
      $ret = scalar(@$ret2)?$ret2:undef;
    }
    if (defined($ret)) {
      $res->{'result'} = { 'data' => $ret };
    } else {
      push @errors, $self->_app_error($meta, 'Y0010', $mtd_def->{'code'}) # no data;
      # TODO: check other way: $res->{'result'} = { 'data' => undef }; # no data
    }
  }
  if (scalar(@errors)) {
    $res->{'result'} = { 'error' => \@errors };
  } elsif ($mtd_def->{'is_rw'}) {
    $meta->changed({ 'def' => $mtd_def, 'res' => $res });
  } else {
    $meta->dump({ 'def' => $mtd_def, 'res' => $res });
  }
  return $res;
}

#----------------------------------------------------------------------
sub _call_plugin {
  my ($self, $mtd_def, $meta, $args) = @_;

  my $mtd = 'plugin_'.$mtd_def->{'code_real'};
  my $obj = $self;

  my $class = $self->cfg->{'plugin_pefix'};
  my $mtg = $self->cfg->{'plugin_handler'};

  if ($mtd_def->{'code_real'} =~ /^(.+)::([a-z_\d]+)$/) {
    # внешний метод
    $class = $class.'::'.$1;
    $mtd = $2;
  } else {
    $class = $class.'::'.$mtd_def->{'code_real'};
  }

  my $cfg = (ref $self->cfg->{'plugin'} eq 'HASH')?$self->cfg->{'plugin'}{$class}:$self->cfg->{'plugin'};
  my $res;
  $meta->debug('Loading plugin class %s for %s', $class, $mtd);
  eval {
    ## no critic
    eval "require $class" or die "require $class error: ".$!;
    ## use critic
    $obj = $class->new($cfg);
    $res = $obj->$mtd($self, $meta, $args);
  };
  if ($@) {
    my $s = $@;
    utf8::decode($s);
    return $self->_rpc_error($meta, 'pl_error', $s);
  }
  return $res;
}

#----------------------------------------------------------------------
#$self->_validate_field($adef, $errors, $params->{$adef->{'code'}});
sub _validate_field {
  my ($self, $meta, $method, $arg_def, $errors, $value, $code, $anno, $facets) = @_;

  my $is_top = $code?0:1;
  my $is_base = ($arg_def->{'parent_id'} == $arg_def->{'id'});

  $code ||= $arg_def->{'code'};
  $anno ||= $arg_def->{'anno'};
  $facets ||= [];

  # пустое значение - не заданное значение
  $value = undef if (ref \$value eq 'SCALAR' and defined($value) and $value eq '');

  if (!defined($value)) {
    if (defined($arg_def->{'def_val'})) {
      my $v = $arg_def->{'def_val'};
      if ($v =~ /^\('now'::text\)/i) {
        my (@lt) = (localtime)[0..5]; #$sec,$min,$hour,$mday,$mon,$year
        $lt[4]++; $lt[5]+=1900;
        if ($arg_def->{'code'} eq 'date') {
          $v = sprintf('%04i-%02i-%02i', reverse(@lt[3..5]));
        } elsif ($arg_def->{'code'} eq 'time') {
          $v = sprintf('%02i:%02i:%02i', reverse(@lt[0..2]));
        } else {
          $v = sprintf('%04i-%02i-%02i %02i:%02i:%02i', reverse(@lt));
        }
      }
      return $v;
    }
    unless ($arg_def->{'allow_null'}) {
      push @$errors, $self->_app_error($meta,'Y0001', $code);
      return;
    } elsif ($is_base) {
      return;
    }
  } elsif (!$is_top) {
    # сохранить ограничения
    my $f = $self->_call_meta($self->def_dt_facet, $meta, $arg_def->{'id'});
    unshift (@$facets, @$f) if (scalar(@$f)); # чем выше уровень, тем раньше будет проверка
  }

  if ($arg_def->{'is_list'}) {
    # массив
    # my $val = (ref \$value eq 'SCALAR')?[$value]:$value;
    my $val;
    if (ref \$value eq 'SCALAR') {
      @$val = split(/,\s+/, $value); # TODO: отменить передачу массива в таком виде
    } else {
      $val = $value;
    }
    my $ret = [];
    my $adef = $self->_call_meta($self->def_dt, $meta, $arg_def->{'parent_id'});

    foreach my $v (@$val) {
      my $x = $self->_validate_field($meta, $method, $adef->[0], $errors, $v, $code, $anno, $facets);
      push @$ret, $x; # push прямого вызова не производится при undef
    }
    return $ret;
  }

  if ($is_base) {
    # TODO: провести валидацию по $arg_def->{'code'}
    # $meta->debug('cast "%s" as %s', $value, $arg_def->{'code'});
    #my $ip = new Net::IP ('193.0.1/24') or die (Net::IP::Error());

    if (scalar(@$facets)) {
      # провести валидацию по ограничениям
      $meta->debug('check_facets');
      $meta->dump({'facets' => $facets });
      my $def = $self->facet_list;
      foreach my $f (@$facets) {
        my $facet = $def->{$f->{'facet_id'}}{'code'};
        my $f_value = $f->{'value'};
        if ($facet eq 'pattern' and $value !~ /$f_value/) {
          push @$errors, $self->_app_error($meta,'Y0003', $code, { arg => $f->{'anno'} || $f_value, 'mtd' => $method, 'value' => $value });
          # TODO: можем вывести и все нарушения, а не только первое
          return;
        } elsif ($facet eq 'minInclusive' and $value < $f_value) {
          push @$errors, $self->_app_error($meta,'Y0002', $code,
            { arg => $def->{$f->{'facet_id'}}{'anno'}, arg1 => $f->{'anno'} || $f_value, 'mtd' => $method });
          return;
        } elsif ($facet eq 'maxInclusive' and $value > $f_value) {
          push @$errors, $self->_app_error($meta,'Y0002', $code,
            { arg => $def->{$f->{'facet_id'}}{'anno'}, arg1 => $f->{'anno'} || $f_value, 'mtd' => $method });
          return;
        } elsif ($facet eq 'minExclusive' and $value <= $f_value) {
          push @$errors, $self->_app_error($meta,'Y0002', $code,
            { arg => $def->{$f->{'facet_id'}}{'anno'}, arg1 => $f->{'anno'} || $f_value, 'mtd' => $method });
          return;
        } elsif ($facet eq 'maxExclusive' and $value >= $f_value) {
          push @$errors, $self->_app_error($meta,'Y0002', $code,
            { arg => $def->{$f->{'facet_id'}}{'anno'}, arg1 => $f->{'anno'} || $f_value, 'mtd' => $method });
          return;
        } elsif ($facet eq 'whiteSpace') {
          # сжать пробелы
        }
        # TODO: остальные проверки
      }
    }
  } else {
    # провести валидацию по $arg_def->{'parent_id'}
    my $adef = $self->_call_meta($self->def_dt, $meta, $arg_def->{'parent_id'});
    return $self->_validate_field($meta, $method, $adef->[0], $errors, $value, $code, $anno, $facets);
  }
  return $value;
}

#----------------------------------------------------------------------
sub _validate {
  my ($self, $meta, $mtd_def, $params) = @_;

  $meta->stage_in('validate');
  my (@errors, @args, %args);
  $mtd_def = $self->_explain_def($mtd_def, $meta);
  if ($mtd_def->{'arg_dt_id'}) {
    my $arg_def = $self->_call_meta($self->def_dt_part, $meta, $mtd_def->{'arg_dt_id'}, 0);
    foreach my $a (@$arg_def) {
      my $value = $self->_validate_field($meta, $mtd_def->{'code'}, $a, \@errors, $params->{$a->{'code'}});
      push @args, $value;
      $args{$a->{'code'}} = $value if (defined($value));
    }
  }
  $meta->stage_out;
  return (\@errors, \@args, \%args);
}

#----------------------------------------------------------------------
sub _app_error {
  my ($self, $meta, $code, $id, $arg) = @_;
  $id ||= '_';
  my $ret = { 'id' => $id, 'code' => $code, 'message' => $self->_error_fmt($meta, $code, $arg)};
  if ($code eq 'Y0010') {
    $meta->app_nodata('%s (%s)', $ret->{'message'}, $id);
  } else {
    $meta->app_error('%s (%s)', $ret->{'message'}, $id);
  }
  $meta->dump({'app_err_ret' => $ret, 'app_err_arg' => $arg });
  return $ret;
}

#----------------------------------------------------------------------
sub _rpc_error {
  my ($self, $meta, $tag, $data) = @_;

  $meta->rpc_error({ 'code' => $tag, 'data' => $data});
  my %def = %{$self->cfg->{'error'}{$tag}};

  $def{'data'} = { 'note' => $def{'data'} };

  if ($data) {
    $def{'data'}{'info'} = $data;
  }
  return { 'error' => \%def };
}

#----------------------------------------------------------------------
sub _error_fmt {
  my ($self, $meta, $code, $arg) = @_;
  my $def = $self->_call_meta($self->def_err, $meta, $code);

  if ($def->{'id_count'}) {
    # message - это строка формата
    my @a;
    for my $i (0..$def->{'id_count'} - 1) {
      push @a, defined($arg->{'arg'.($i || '')})?$arg->{'arg'.($i || '')} : '';
    }
    return sprintf $def->{'message'}, @a;
  }
  return $def->{'message'};
}

1;

__END__

=head1 NAME

PGWS - Postgresql Web Services

=head1 DESCRIPTION

PGWS is a gateway between Perl or stored Postgresql code and client side Javascript or server side templates

=head1 SEE ALSO

http://rm2.tender.pro/projects/pgws/wiki

=head1 AUTHOR

Alexey Kovrizhkin <lekovr@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2010, 2012 Tender.Pro.

This module is free software; you can redistribute it and/or modify it under the terms of the AGPL.

=cut

#######################################################################