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

# PGWS::Frontend - http request processor & html generator

package PGWS::Frontend;

use PGWS;
use PGWS::Utils;
use PGWS::Meta;
use PGWS::Server;

use Template;
use strict;

# проверка зависимостей
use Locale::Maketext::Lexicon;

use Cwd;
our $dir;
BEGIN {
    $dir = getcwd;
}

use Locale::Maketext::Simple('Path' => $dir.'/var/i18n');

# Доступный извне номер версии
our $VERSION = $PGWS::VERSION;

#----------------------------------------------------------------------
sub root      { $_[0]->{'root'}     }
sub cfg       { $_[0]->{'cfg'}      }
sub ws        { $_[0]->{'ws'}       }
sub template  { $_[0]->{'template'} }

sub def_sid   { $_[0]->{'cfg'}{'def'}{'sid'} }
sub def_uri   { $_[0]->{'cfg'}{'def'}{'uri'} }
sub def_acl   { $_[0]->{'cfg'}{'def'}{'acl'} }
sub def_code  { $_[0]->{'cfg'}{'def'}{'code'} }

#----------------------------------------------------------------------
# Конструктор, вызывается при старте сервера
sub new {
  my ($class, $self) = @_;
  bless $self, $class;

  $self->{'root'} ||= $ENV{'PGWS_ROOT'} ; # or die

  my $root = $self->{'root'}; # or die
  my $PGWS_root = $root;
  my $file = $PGWS_root.($ENV{'PGWS_FE'} || '/conf/frontend.json');
  my $cfg = $self->{'cfg'} = PGWS::Utils::data_load($file);

  $file = $PGWS_root.($ENV{'PGWS_RPC'} || '/conf/rpc.json');
  $self->{'cfg'}{'rpc'} = PGWS::Utils::data_load($file);

  my %template_config = (
    INCLUDE_PATH  => "$PGWS_root/var/tmpl",
    COMPILE_DIR   => "$PGWS_root/var/tmpc",
    PRE_PROCESS   => 'config.tt2',
    CACHE_SIZE    => '100',
    COMPILE_EXT   => '.pm',
    EVAL_PERL     => 0,
    ENCODING      => 'utf-8',
    PRE_CHOMP     => 1,
    POST_CHOMP    => 1,
    %{$cfg->{'tmpl'}{'config'}}
  );
  $self->{'template'} = Template->new(%template_config);
  {
    no warnings 'once';
    $Template::Stash::PRIVATE = undef;   # now you can thing._private
  }
  return $self;
}

#----------------------------------------------------------------------
# Обработка запроса
sub run {
  my ($self, $req) = @_;

  $req->fetch_cook($self->cfg->{'cookie_mask'});
  my %meta = %{$self->cfg->{'rpc'}};
  my $meta = PGWS::Meta->new(\%meta);
  $meta->setip($req->user_ip);
  $meta->setcook($req->cookie); # $cookie ...
  if ($req->method eq 'OPTIONS') {
    $req->options_header;
  } elsif ($req->method eq 'POST' and $req->type =~m |application/json|) {
    $self->process_post($meta, $req);
  } elsif($req->uri =~ m|^_(.+)\.json$|) {
    $self->process_direct($meta, $req, $1);
  } else {
    $self->process_get($meta, $req);
  }
}

#----------------------------------------------------------------------
# Обработка POST запроса JSON-RPC
sub process_post {
  my ($self, $meta, $req) = @_;

  my $data = $req->post_data;
  $meta->setsource('post');
  $meta->setenc('UTF-8'); # required for ajax
  $meta->keyoff; # основной запрос - не от имени фронтенда
  #TODO: брать enc из строки "application/json; charset=UTF-8"

  my ($ws, $ret) = PGWS::Server->new({ root => $self->{'root'}, _dbh => $req->{'_dbh'} });
  $ret = $ws->run($meta, $data) unless ($ret);

  $req->header('application/json; charset=utf-8', '200 OK');
  $req->print(PGWS::Utils::json_out_utf8($ret)); # mod_perl иначе портит utf
}

#----------------------------------------------------------------------
# Обработка вызова метода по HTTP
sub process_direct {
  my ($self, $meta, $req, $method) = @_;

  my $params = $req->get_data;
  $meta->setsource('post'); # dir
  $meta->debug('Direct req to %s', $method);

  my ($ws, $ret) = PGWS::Server->new({ root => $self->{'root'}, _dbh => $req->{'_dbh'} });
  unless ($ret) {
    $self->load_session($ws, $meta, $params);
    $meta->keyoff; # основной запрос - не от имени фронтенда
    $ret = $ws->run_prepared($meta, $method, $params);
  }
  my $is_pretty;
  if ($req->accept =~ m|application/json|) {
    $req->header('application/json; charset=utf-8', '200 OK');
  } else {
    $req->header('text/plain; charset=utf-8', '200 OK');
    $is_pretty = 1;
  }
  my $json = PGWS::Utils::json_out_utf8($ret, $is_pretty);
  if ($params->{'callback'}) {
    # JSONP request
    $json=$params->{'callback'}."($json)";
  }
  $req->print($json); # _utf8, иначе mod_perl портит utf
}

#----------------------------------------------------------------------
# Обработка GET запроса на вывод страницы
sub process_get {
  my ($self, $meta, $req) = @_;

  my $cfg = $self->cfg;
  $meta->setsource('get');
  $meta->debug('page start');
  my $errors = [];
  my $resp = {
    post_uri => $cfg->{'post'}{$req->prefix},
    layout   => $cfg->{'tmpl'}{'layout_default'},
    skin     => $cfg->{'tmpl'}{'skin_default'},
    enc      => $cfg->{'tmpl'}{'enc'},
    ctype    => 'text/html',
    title    => '',
    errors   => $errors,
  };

  my ($ws, $ret) = PGWS::Server->new({ root => $self->{'root'}, _dbh => $req->{'_dbh'} });
  if ($ret) {
    return $req->redirect($cfg->{'error_500'}) if ($cfg->{'error_500'});
    die $ret; #TODO: say something?
  }

  $meta->debug('resp start');
  my ($status, $note, $vars, $file) = $self->response($meta, $req, $resp, $ws);

  my $pages = $cfg->{'tmpl'}{'pages'};
  my $erfile = $cfg->{'tmpl'}{'error'};
  my $ext = $cfg->{'tmpl'}{'ext'};
  unless ($file) {
    $file = $erfile;
    $vars->{'status'} = $status;
  }
  $meta->dump({'file' =>$file, 'vars' => $vars}); #, 'env' => \%ENV });
  my $out = '';
  $meta->setsource('tmpl');
  my $resp_page = $self->template->process($pages.$file.$ext, $vars, \$out);
  if ($vars->{'meta'}{'status'} ne '200') {
    $file = $erfile;
    $note = $vars->{'meta'}{'status_note'};
    $status = $vars->{'status'} = $vars->{'meta'}{'status'};
    $meta->debug('Error status: '.$status);
    $resp_page = $self->template->process($pages.$file.$ext, $vars, \$out);
  }
  unless($resp_page) {
    my $error = $self->template->error();
    push @$errors, { 'type' => $error->type(), 'data' => $error->info()};
    $meta->sys_error('template error (%s)', $error->info());
    ($status, $note) = ('500', 'Server error');
    $vars->{'status'} = $status;
    if ($file ne $erfile) {
      $self->template->process($pages.$erfile.$ext, $vars, \$out) or die 'error processing error page: '.$self->template->error();
    }
  }
  $meta->debugN('get', 'page ready');

  if ($vars->{'meta'}{'redirect'}) {
    $meta->debug('Redirect: '.$vars->{'meta'}{'redirect'});
    return $req->redirect($vars->{'meta'}{'redirect'});
  } elsif ($vars->{'meta'}{'redirect_file'}) {
    my $path = $vars->{'meta'}{'redirect_file'}{'path'}; # TODO: or die
    $path =~ s|^(.+)(/generated/files)|/file1|; # TODO: хранить относительный путь и не обрезать
    $meta->debug('Send file: '.$path);
    $vars->{'meta'}{'redirect_file'}{'path'} = $path;
    return $req->send_file($vars->{'meta'}{'redirect_file'});
  }

  $req->header($resp->{'ctype'}.'; '.$cfg->{'tmpl'}{'enc'}, "$status $note");

  $file = 'layout/'.$resp->{'layout'}.'/'.$resp->{'skin'}.$ext;
  $vars->{'layout_head'} = 1;
  $self->template->process($file, $vars, $req) or die 'error processing header ('.$file.'): '.$self->template->error();
  $req->print($out);
  $vars->{'layout_head'} = 0;
  $meta->dump({'vars' => $vars});
  $meta->debug('at footer after %s with %i hits and %i db calls', $meta->elapsed, $meta->stat_hit, $meta->stat_db);
  $vars->{'debug_data'} = $meta->data if ($meta->has_data);

  $self->template->process($file, $vars, $req) or die 'error processing footer ('.$file.'): '.$self->template->error();
  $meta->debugN('get', 'exit after %s with %i hits and %i db calls', $meta->elapsed, $meta->stat_hit, $meta->stat_db);

}

#----------------------------------------------------------------------
# Определение параметров ответа на GET запрос на вывод страницы
sub response {
  my ($self, $meta, $req, $resp, $ws) = @_;

  my $cfg = $self->cfg;

  my $params = $req->get_data;
  my $errors = $resp->{'errors'};

  my $session = $self->load_session($ws, $meta, $params, $errors);
  my $sid = $session->{'sid'}; # value or undef
  my $sid_name = $self->{'cfg'}{'sid_arg'};
  my $have_sid_arg = ($sid_name and $sid);

  $session->{'sid_arg'} = $have_sid_arg?"?$sid_name=$sid":'';
  $session->{'sid_pre'} = $have_sid_arg?"?$sid_name=$sid&":'?';

  my $page = $self->api($ws, $errors, $meta, 'uri', $self->def_uri, {'uri' => $req->uri });

  my $acl;

  if ($page) {
    if ($page->{'id_source'}) {
      $page->{'args'}->[0] = $session->{$page->{'id_source'}};
      $meta->debug('setup id %s from session field %s', $page->{'args'}[0], $page->{'id_source'});
    }
    $acl = $self->acl($ws, $errors, $meta, $session, $page, $params);
    $page->{'req'} = $req->prefix.'/'.$page->{'req'} if($page and $page->{'req'});
    $page->{'is_hidden'} ||= $cfg->{'site_is_hidden'}; # закрываем незакрытое если весь сайт закрыт (не production)
  }
  my $stg_args = $have_sid_arg?"$sid_name=$sid":'';
  if ($session->{'lang_used'}) {
    $stg_args = ($have_sid_arg?$stg_args.'&':'').'lang='.$session->{'lang'};
    $session->{'sid_arg'} .= ($have_sid_arg?'&':'?').'lang='.$session->{'lang'};
    $session->{'sid_pre'} .= 'lang='.$session->{'lang'}.'&';
  }
  my $tmpl_meta = { 'status' => '200', 'html_headers' => [] };
  my $vars = {
    'api'         => sub { api($self, $ws, $errors, $meta, undef, @_) },
    'uri'         => sub { api($self, $ws, $errors, $meta, undef, $self->def_code, @_); },
    'uri_allowed' => sub { acl($self, $ws, $errors, $meta, $session, @_) },
    'l'           => sub { i18n($self, $ws, $errors, $meta->{'lang'}, @_) },
    'uri_mk'      => sub { PGWS::Utils::uri_mk($req->proto, $req->prefix, $stg_args, @_) },
    'uri_mk_form' => sub { PGWS::Utils::uri_mk_form($req->proto, $req->prefix, $stg_args, @_) },
    'json'        => sub { PGWS::Utils::json_out(@_) },
    'is_bit_set'  => sub { my ($a,$b) = @_; return ($a & $b) == $b; },
    'req'  => $req->attrs,
    'resp'  => $resp,
    'page' => $page,
    'get'  => $params,
    'acl'  => $acl,
    'meta' => $tmpl_meta,
    'debug' => $cfg->{'tmpl'}{'debug'}?($cfg->{'rpc'}{'debug'}{'post'}||$cfg->{'rpc'}{'debug'}{'default'}):0,
    'session' => $session,
  };

  unless ($req->method eq 'GET' or $req->method eq 'HEAD') {
    return ('405', 'Method Not Allowed', $vars);
  } elsif (!$page or !$page->{'tmpl'}) {
    return ('404', 'Not Found', $vars);
  } elsif (!$acl) {
    return ('403', 'Forbidden', $vars); # необходимость авторизации определяется по !$acl
  }
  return ('200', 'OK', $vars, $page->{'tmpl'});
}

#----------------------------------------------------------------------
# вызов метода из темплейта
sub api {
  my ($self, $ws, $errors, $meta, $type, $method, $params) = @_;

  my $ret = $ws->run_prepared($meta, $method, $params);

  if (defined ($ret->{'result'}{'data'})) {
    return $ret->{'result'}{'data'};
  }
  if (defined($errors)) {
    if ($type) {
      push @$errors, { 'type' => $type, 'data' => $ret };
    } else {
      push @$errors, { 'method' => $method, 'params' => $params, 'data' => $ret};
    }
  }
  return;
}

#----------------------------------------------------------------------
# посчитать acl
sub acl {
  my ($self, $ws, $errors, $meta, $session, $page, $params) = @_;
  return 0 unless ($page);
  $params ||= {};
  my $acl_params = {
    class_id => $page->{'class_id'},
    action_id => $page->{'action_id'},
    id => $page->{'args'}[0] || $params->{'id'},
    id1 => $page->{'args'}[1] || $params->{'id1'},
    id2 => $page->{'args'}[2] || $params->{'id2'},
  };
  if ($page->{'id_source'}) {
    $acl_params->{'id'} = $session->{$page->{'id_source'}};
  }
  $meta->dump({'page' => $page, 'acl_params' => $acl_params});
  return $self->api($ws, $errors, $meta, 'acl', $self->def_acl, $acl_params);
}

#----------------------------------------------------------------------
# Получение атрибутов страницы, если к ней есть доступ
sub uri {
  my ($self, $ws, $errors, $meta, @a) = @_;
  my $page = $self->api($ws, $errors, $meta, undef, $self->def_code, @a);
  return $page if ($self->acl($ws, $errors, $meta, $page));
  return;
}

#----------------------------------------------------------------------
# Локализация строки
sub i18n {
  my ($self, $ws, $errors, $lang, $s, @a) = @_;
  if ($lang and $lang ne $self->{'cfg'}{'tmpl'}{'lang'}{'default'}) {
    utf8::encode($s);
    $s = loc($s, map {utf8::encode($_); $_ } @a);
    utf8::decode($s);
  } else {
    utf8::decode($s);
    if (scalar(@a)) { for my $i (1..scalar(@a)) { $s =~s /\[_$i\]/$a[$i-1]/ge; } }
  }
  return $s;
}

#----------------------------------------------------------------------
# Валидация sid и загрузка сессии, определение lang
sub load_session {
  my ($self, $ws, $meta, $params, $errors) = @_;

  $meta->stage_in('sid');
  my $sid;
  if ($self->{'cfg'}{'sid_arg'}) {
    $sid = delete $params->{$self->{'cfg'}{'sid_arg'}}; # sid - только в session.sid
  } else {
    $sid = $meta->{'cook'}; # TODO: геттер или иначе брать
  }
  $meta->setsid($sid); # sid до валидации

  my $lang = delete $params->{'lang'}; # lang - всегда в meta.lang и в session.lang если нужен в ссылках
  $lang = PGWS::Utils::lang_mk($self->{'cfg'}{'tmpl'}{'lang'}, $lang);
  $lang = undef if ($lang and $lang eq $self->{'cfg'}{'tmpl'}{'lang'}{'default'});
  $meta->setlang($lang || $self->{'cfg'}{'tmpl'}{'lang'}{'default'});

  my $session;
  if ($sid) {
    $session = $self->api($ws, $errors, $meta, 'sid', $self->def_sid);
  } else {
    $session = { 'sid' => undef };
  }
  $meta->debug('sid %s verified as %s', $sid, $session->{'sid'});

  $meta->setsid($session->{'sid'}); # sid после валидации

  if (!$lang and $session->{'lang'}) {
    # не задан явно - берем из сессии
    $lang = $session->{'lang'}; # в ссылках не нужен
    $meta->setlang($lang);
  } else {
    $session->{'lang'} = $lang || $self->{'cfg'}{'tmpl'}{'lang'}{'default'};
    $session->{'lang_used'} = 1 if ($lang); # задан lang  - нужен в ссылках
  }
  loc_lang($meta->{'lang'});

  $meta->stage_out;
  return $session;
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