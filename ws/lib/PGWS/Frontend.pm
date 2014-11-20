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
use PGWS::Core;
use PGWS::DBConfig;

use Template 2.24;
use Template::Exception;

use SOAP::Transport::HTTP;
#use SOAP::Transport::HTTP::CGI;
use PGWS::Proxy;
#use PGWS::Serializer;

use strict;

# проверка зависимостей
use Locale::Maketext::Lexicon;

use Cwd;
our $dir;
BEGIN {
    $dir = getcwd;
}

use constant ROOT               => ($ENV{PGWS_ROOT} || '');   # PGWS root dir
use constant POGC               => 'fe';                      # Property Owner Group Code

use constant REALM_UPLOAD       => ($ENV{PGWS_FE_REALM_UPLOAD} || '');
use constant REALM_FE           => ($ENV{PGWS_FE_REALM} || 'fe_only');

use constant FILE_URI           => ($ENV{PGWS_FILE_URI});
use constant FILE_STORE_PATH    => ($ENV{PGWS_FILE_STORE_PATH});

use constant DEBUG_IFACE        => ($ENV{PGWS_FE_DEBUG_IFACE} || 0);

use constant CACHE_STORE        => ($ENV{PGWS_FE_CACHE_STORE_DIR} || 'www-cache');
use constant CACHE_MODE         => ($ENV{PGWS_FE_CACHE_MODE} || 0);  # 0 - Nope, 1 - R, 2 - W, 3 - RW
use constant CACHE_TTL          => ($ENV{PGWS_FE_CACHE_TTL} || 0);   # 0 - Nope, -1 - Forever, else - given seconds

use constant LAYOUTS             => ($ENV{PGWS_FE_LAYOUTS});

use Locale::Maketext::Simple('Path' => ROOT.'/var/i18n');


# Доступный извне номер версии
our $VERSION = $PGWS::VERSION;

#----------------------------------------------------------------------
sub ws        { $_[0]->{'_ws'}       }
sub proxy     { $_[0]->{'_proxy'}    }
sub template  { $_[0]->{'template'} }

sub dbc       { $_[0]->{'_dbc'} }
sub const     { $_[0]->{'_const'} }
sub layout    { $_[0]->{'_layout'} }

use Data::Dumper;
#----------------------------------------------------------------------
# Конструктор, вызывается при старте сервера
sub new {
  my ($class, $cfg) = @_;
  my $self = $cfg ? { %{$cfg} } : {};
  bless $self, $class;
  my $dbc =  $self->{'_dbc'} = PGWS::DBConfig->new({
    'pogc' => POGC
  , 'poid' => $self->{'frontend_poid'}
  , 'data_set' => 1
  });
  my $ext      = $dbc->config('fe.tmpl.ext');
  my @layouts  = split /\s+/,(LAYOUTS);
  my @includes = map { ROOT.'var/tmpl/layout/'.$_ } @layouts;
  $self->{'_layout'} = $layouts[0];
  my %template_config = (
    INCLUDE_PATH  => [ @includes, ROOT.'var/tmpl' ],
    COMPILE_DIR   => ROOT.'var/tmpc',
    PRE_PROCESS   => 'config'.$ext,
    %{$dbc->config('fe.tt2')}
  );

  $self->{'template'} = Template->new(%template_config);
  {
    no warnings 'once';
    $Template::Stash::PRIVATE = undef;   # now you can thing._private
  }

  $self->{'_ws'} = PGWS::Core->new({ 'poid' => $self->{'core_poid'}, _dbh => $self->{'_dbh'} });

  return $self;
}

#----------------------------------------------------------------------
# Обработка запроса
sub run {
  my ($self, $req) = @_;

  my $meta_cfg = $self->dbc->config('log');
  my $meta = PGWS::Meta->new($meta_cfg);
  $meta->debug_iface_allowed(DEBUG_IFACE);
  if ($req->method eq 'JOB') {
    $self->process_job($meta, $req);
  } else {
    $meta->{'sid_arg'} = $self->dbc->config('fe.sid_arg');
    $meta->setip($req->user_ip);
    $meta->setcook($req->cookie); # $cookie ...
    if ($req->method eq 'OPTIONS') {
      $req->options_header;
    } elsif ($req->method eq 'POST' and $req->type =~m |application/json|) {
      $self->process_post($meta, $req);
    } elsif ($req->method eq 'SOAP') {
      $self->process_xml($meta, $req);
    } elsif($req->uri =~ m|^_(.+)\.json$|) {
      $self->process_direct($meta, $req, $1);
    } else {
      $self->process_get($meta, $req);
    }
  }
}

#----------------------------------------------------------------------
# Обработка POST запроса JSON-RPC
sub process_post {
  my ($self, $meta, $req) = @_;

  my $data = $req->params;
  $meta->setsource('post');
  $meta->keyoff; # основной запрос - не от имени фронтенда
  #TODO: брать enc из входящей строки "application/json; charset=UTF-8"

  my $ret = $self->ws->run($meta, $data);

  $req->header('application/json; '.$meta->charset, '200 OK');
  $req->print(PGWS::Utils::json_out_utf8($ret)); # mod_perl иначе портит utf
}


#----------------------------------------------------------------------
# Обработка POST запроса SOAP / XML-RPC
sub process_xml {
  my ($self, $meta, $req) = @_;

  $meta->setsource('post');
  $meta->keyoff; # основной запрос - не от имени фронтенда
  my $map = {};
  
  #print STDERR '===============',Dumper(\%ENV);
  SOAP::Transport::HTTP::CGI
    -> on_action(sub { 
      my ($action, $uri, $name) = @_;
      # any action mapped to Proxy
      $map->{$action} = PGWS::Proxy->new({
        'ws'    => $self->ws, 
        'meta'  => $meta, 
        'req'   => $req, 
        'class' => $uri, 
      })
    })
   # -> serializer(PGWS::Serializer->new)
    -> dispatch_with($map) 
    # enable compression support
    -> options({compress_threshold => 10000})
    -> handle
  ;

}

#----------------------------------------------------------------------
# Обработка вызова метода по HTTP
sub process_direct {
  my ($self, $meta, $req, $method) = @_;

  my $params = $req->params;
  $meta->setsource('post'); # dir
  $meta->debug('Direct req to %s', $method);
  $meta->dump($req);

  my $ws = $self->ws;
  my $session = $self->load_session($ws, $meta, $params);
  $meta->keyoff; # остальные запросы - не от имени фронтенда
  my $status = ($session->{'sid_error'})?'409 Conflict':'200 OK';
  my $realm = $params->{'_realm'};
  if ($realm) {
    my ($code, $key) = split /:/, $realm;
    $params->{'_realm'} = $code if ($realm eq REALM_UPLOAD);
    if ($params->{'_realm'} eq 'upload') {
      # nginx upload
      my $prefix = FILE_STORE_PATH;
      $params->{'_path'} =~ s/^$prefix// if ($params->{'_path'});
    }
  }
#print STDERR Dumper($method, $params);
  my $ret = $ws->run_prepared($meta, $method, $params);
  my $is_pretty;
  if ($req->accept =~ m|application/json|) {
    $req->header('application/json; '.$meta->charset, $status);
  } else {
    $req->header('text/plain; '.$meta->charset, $status);
    $is_pretty = 1;
  }
  my $json = PGWS::Utils::json_out_utf8($ret, $is_pretty);
  if ($params->{'callback'}) {
    # JSONP request
    $json=$params->{'callback'}."($json)";
  }
  $req->print($json);
}

#----------------------------------------------------------------------
# Обработка запроса от сервера Job
sub process_job {
  my ($self, $meta, $req) = @_;

  my $ws = $self->ws;
  my $dbc = $self->dbc;
  $meta->setsource('job');
  $meta->dump($req->params);

  $meta->keyoff; # остальные запросы - не от имени фронтенда
  $meta->setsid(delete $req->params->{'REQUEST_SID'});
  $meta->setip('0.0.0.0');
  $meta->setlang($dbc->config('lang.default'));
  loc_lang($meta->{'lang'});

  my $resp_meta = {
     status => '200',
     status_note => 'OK'
  };
  my $errors = [];
  my $resp;
  my $call;
  unless ($req->prefix) {
    #internal call (login/logout)
    $meta->debug('internal call for %s', $req->uri);
    $call = $dbc->config('fe.def.'.$req->uri);
    $resp = $self->api($ws, $errors, $meta, undef, $call, $req->params);
    $resp ||= { 'errors' => $errors };
  } else {
    # call job template
    $meta->debug('call %s.%s', $req->prefix, $req->uri);
    my $vars = {
      'resp'    => {},
      'meta'    => $resp_meta,
      'params'  => $req->params,
      'plugin'   => {
        'root' => ROOT,
#        'config' => $dbc,
      },
      %{$self->tmpl_vars($ws, $errors, $meta, 'http', '/api', '', $dbc->config('fe.def.code'))}
    }; # TODO: get from dbc values of 'http', '/api'
    #$meta->setsource('tmpl');
    my $jobs   = $dbc->config('fe.tmpl.jobs');
    my $ext     = $dbc->config('fe.tmpl.ext');
    my $call = $req->prefix.'/'.$req->uri;
    my $out = '';
    unless ($self->template->process($jobs.$call.$ext, $vars, \$out)) {
      $resp_meta->{'status'} = '500';
      $resp_meta->{'status_note'} = $self->template->error();
    }
    $resp = $vars->{'resp'};
    $meta->dump({ 'vars' => $vars, 'out' => $out});
  }
  my $status_line = $resp_meta->{'status'}.' '.$resp_meta->{'status_note'};
  $meta->debug('request status: %s', $status_line);
  $meta->dump({'resp' => $resp});
  my $json = PGWS::Utils::json_out_utf8({'result' => $resp});
  $req->print($status_line."\n\n");
  $req->print($json);
}
#----------------------------------------------------------------------
# Обработка GET запроса на вывод страницы
sub process_get {
  my ($self, $meta, $req) = @_;

  my $dbc = $self->dbc;
  $meta->setsource('get');
  $meta->debug('page start');
  my $errors = [];

  my $css = $self->load_cookie($req, 'css');
  my $resp = {
    post_uri => $req->prefix, # TODO: для CGI реализовать подмену api_cgi => /cgi-bin/pwl.pl
    layout   => $self->layout,
    frame    => $dbc->config('fe.tmpl.frame_default'),
    css      => $css,
    enc      => $meta->charset,
    ctype    => 'text/html',
    title    => '',
    errors   => $errors,
  };

  my $ws = $self->ws;
  $meta->debug('resp start');
  my ($status, $note, $vars, $file) = $self->response($meta, $req, $resp, $ws);
  if ($status eq '201') {
    my $file_def = $vars->{'meta'}{'redirect_file'};
    my $path = $file_def->{'path'}; # TODO: or die
    $meta->debug('Send responce from cache: '.$path);
    $file_def->{'path'} = join '/', FILE_URI, CACHE_STORE, $req->server_name . $path;
    $req->header($resp->{'ctype'}.'; '.$meta->charset, "200 OK", $file_def);
    return;
  }
  my $pages   = $dbc->config('fe.tmpl.pages');
  my $erfile  = $dbc->config('fe.tmpl.error');
  my $ext     = $dbc->config('fe.tmpl.ext');
  unless ($file) {
    $file = $erfile;
    $vars->{'status'} = $status;
  }
  $meta->dump({'file' =>$file, 'vars' => $vars}); #, 'env' => \%ENV });
  my ($body, $top, $btm) = ('', '', '');
  $meta->setsource('tmpl');
  my $resp_page = $self->template->process($pages.$file.$ext, $vars, \$body);
  if ($vars->{'meta'}{'status'} ne '200') {
    $file = $erfile;
    $note = $vars->{'meta'}{'status_note'};
    $status = $vars->{'status'} = $vars->{'meta'}{'status'};
    $meta->debug('Error status: '.$status);
    $resp_page = $self->template->process($pages.$file.$ext, $vars, \$body);
  }
  unless($resp_page) {
    my $error = $self->template->error();
    push @$errors, { 'type' => $error->type(), 'data' => $error->info()};
    $meta->sys_error('template error (%s)', $error->info());
    ($status, $note) = ('500', 'Server error');
    $vars->{'status'} = $status;
    if ($file ne $erfile) {
      $self->template->process($pages.$erfile.$ext, $vars, \$body) or die 'error processing error page: '.$self->template->error();
    }
  }
  $meta->debugN('get', 'page ready');

  if ($vars->{'meta'}{'redirect'}) {
    $meta->debug('Redirect: '.$vars->{'meta'}{'redirect'});
    return $req->redirect($vars->{'meta'}{'redirect'});
  } elsif ($vars->{'meta'}{'redirect_file'}) {
    my $path = $vars->{'meta'}{'redirect_file'}{'path'}; # TODO: or die
    $meta->debug('Send file: '.$path);
    $vars->{'meta'}{'redirect_file'}{'path'} = FILE_URI.'/'.$path;
    return $req->send_file($vars->{'meta'}{'redirect_file'});
  }

  $req->header($resp->{'ctype'}.'; '.$meta->charset, "$status $note");

  $file = 'frame/'.$resp->{'frame'}.$ext;
  $vars->{'layout_head'} = 1;
  $self->template->process($file, $vars, \$top) or die 'error processing header ('.$file.'): '.$self->template->error();
  $req->print($top, $body);
  $vars->{'layout_head'} = 0;
  $meta->dump({'vars' => $vars});
  $meta->debug('at footer after %s with %i hits and %i db calls', $meta->elapsed, $meta->stat_hit, $meta->stat_db);
  $vars->{'debug_data'} = $meta->data if ($meta->has_data);

  $self->template->process($file, $vars, \$btm) or die 'error processing footer ('.$file.'): '.$self->template->error();
  $req->print($btm);
  if ($status eq '200' and $resp->{'ctype'} eq 'text/html'
    and (CACHE_MODE & 2) == 2 and !$vars->{'session'}{'sid'}) { 
    $self->response_cache($vars, $meta, $top, $body, $btm); 
  }
  $meta->debugN('get', 'exit after %s with %i hits and %i db calls', $meta->elapsed, $meta->stat_hit, $meta->stat_db);
}

#----------------------------------------------------------------------
# Файл кэша страницы
sub _response_cache_prefix {
  my $server = shift;
  return join '/', FILE_STORE_PATH, CACHE_STORE, $server;
}

#----------------------------------------------------------------------
# Сохранить страницу в кэше
sub response_cache {
  my ($self, $vars, $meta, @content) = @_;
  my $path = PGWS::Utils::uri_cache_name($vars->{'page'}{'req'}, $vars->{'get'});
  $meta->debug('Going to set cache: '.$path);
  PGWS::Utils::data_set(join ('', @content), _response_cache_prefix($vars->{'server_name'}).$path);
}

#----------------------------------------------------------------------
# Получить страницу из кэша, если она там есть
sub response_cached {
  my ($self, $vars, $meta) = @_;
  my $found = 0;
  my $path = PGWS::Utils::uri_cache_name($vars->{'page'}{'req'}, $vars->{'get'});
  my $path_abs = _response_cache_prefix($vars->{'server_name'}).$path;
  $meta->debug('Going to get cache: '.$path);
  if (PGWS::Utils::data_is_actual($path_abs, CACHE_TTL)) {
    $vars->{'meta'}{'redirect_file'} = {
      'path' => $path,
      'mtime' => (stat ($path_abs))[9]
    };
    return 1;
  }
  return 0;
}

#----------------------------------------------------------------------
# Определение параметров ответа на GET запрос на вывод страницы
sub response {
  my ($self, $meta, $req, $resp, $ws) = @_;

  my $dbc = $self->dbc;

  my $params = $req->params;
  my $errors = $resp->{'errors'};

  my $session = $self->load_session($ws, $meta, $params, $errors);
  my $sid = $session->{'sid'}; # value or undef
  my $sid_name = $meta->{'sid_arg'};
  my $have_sid_arg = ($sid_name and $sid);

  $session->{'sid_arg'} = $have_sid_arg?"?$sid_name=$sid":'';
  $session->{'sid_pre'} = $have_sid_arg?"?$sid_name=$sid&":'?';

  my $page = $self->api($ws, $errors, $meta, 'uri', $dbc->config('fe.def.uri'), {'uri' => $req->uri });

  my $acl;

  if ($page) {
    if ($page->{'id_fixed'}) {
      unshift @{$page->{'args'}}, $page->{'id_fixed'};
      $meta->debug('setup id %s from fixed %s', $page->{'args'}[0], $page->{'id_fixed'});
    } elsif ($page->{'id_session'}) {
      unshift @{$page->{'args'}}, $session->{$page->{'id_session'}};
      $meta->debug('setup id %s from session field %s', $page->{'args'}[0], $page->{'id_session'});
    }
    $acl = $self->acl($ws, $errors, $meta, $session, $page, $params);
    # TODO: убрать "добавление префикса для всех кроме главной"
    $page->{'req'} = $req->prefix.'/'.$page->{'req'}; ## if($page); ## and $page->{'req'});
    $page->{'is_hidden'} ||= $dbc->config('fe.site_is_hidden'); # закрываем незакрытое если весь сайт закрыт (не production)
  }
  my $stg_args = $have_sid_arg?"$sid_name=$sid":'';
  if ($session->{'lang_used'}) {
    $stg_args = ($have_sid_arg?$stg_args.'&':'').'lang='.$session->{'lang'};
    $session->{'sid_arg'} .= ($have_sid_arg?'&':'?').'lang='.$session->{'lang'};
    $session->{'sid_pre'} .= 'lang='.$session->{'lang'}.'&';
  }
  my $tmpl_meta = { 'status' => '200', 'html_headers' => [], 'head' => {}, 'js' => [], 'todo' => {}};

  my $vars = {
    'uri_allowed' => sub { acl($self, $ws, $errors, $meta, $session, @_) },
    'req'         => $req->attrs,
    'page'        => $page,
    'get'         => $params,
    'acl'         => $acl,
    'meta'        => $tmpl_meta,
    'debug'       => DEBUG_IFACE ? $meta->debug_level : 0,
    'session'     => $session,
    'resp'        => $resp,
    'server_name' => $req->server_name,
    %{$self->tmpl_vars($ws, $errors, $meta, $req->proto, $req->prefix, $stg_args, $dbc->config('fe.def.code'))}
  };
  unless ($req->method eq 'GET' or $req->method eq 'HEAD') {
    return ('405', 'Method Not Allowed', $vars);
  } elsif (!$page or !$page->{'tmpl'} or (defined($acl) and $acl == 0)) {
    return ('404', 'Not Found', $vars);
  } elsif ($session->{'sid_error'}) {
    # некорректный идентификатор сессии
    if ($sid_name and $session->{'sid_error'} eq 'sid') {
      # TODO: redirect на тот же url, но без sid
      # my $u = PGWS::Utils::uri_mk($req->proto, $req->prefix, undef, $req->uri, $params);
    } else {
        return ('409', 'Conflict', $vars); #
    }
  } elsif (!$acl) {
    return ('403', 'Forbidden', $vars); # необходимость авторизации определяется по !$acl
  } elsif (!$sid and ((CACHE_MODE & 1) == 1) and $self->response_cached($vars, $meta)) {
    return ('201', 'Created', $vars);
  } #!$sid and  and
  return ('200', 'OK', $vars, $page->{'tmpl'});
}

#----------------------------------------------------------------------
# вызов метода из темплейта
sub api {
  my ($self, $ws, $errors, $meta, $type, $method, $params) = @_;
  delete $params->{'_realm'}; # used only in process_direct
  my $ret = $ws->run_prepared($meta, $method, $params);
  return _api_result($errors, $type, $method, $params, $ret);
}
#----------------------------------------------------------------------
# вызов системного метода из темплейта
sub sysapi {
  my ($self, $ws, $errors, $meta, $type, $method, $params) = @_;
  $params->{'_realm'} = REALM_FE;
  my $ret = $ws->run_prepared($meta, $method, $params);
  return _api_result($errors, $type, $method, $params, $ret);
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
  if ($page->{'id_fixed'}) {
    $acl_params->{'id'} = $page->{'id_fixed'}; # TODO: если id уже занят - сдвинуть на id2
  } elsif ($page->{'id_session'}) {
    $acl_params->{'id'} = $session->{$page->{'id_session'}}; # TODO: если id уже занят - сдвинуть на id2
  }

  $meta->dump({'page' => $page, 'acl_params' => $acl_params});
  return $self->api($ws, $errors, $meta, 'acl', $self->dbc->config('fe.def.acl'), $acl_params);
}

#----------------------------------------------------------------------
# Получение атрибутов страницы, если к ней есть доступ
sub uri {
  my ($self, $ws, $errors, $meta, @a) = @_;
  my $page = $self->api($ws, $errors, $meta, undef, $self->dbc->config('fe.def.code'), @a);
  return $page if ($self->acl($ws, $errors, $meta, $page));
  return;
}

#----------------------------------------------------------------------
# Локализация строки
sub i18n {
  my ($self, $ws, $errors, $lang, $s, @a) = @_;
  if ($lang and $lang ne $self->dbc->config('lang.default')) {
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
  my $dbc = $self->dbc;
  my $lang_default = $dbc->config('lang.default');
  my $sid;
  if ($meta->{'sid_arg'}) {
    $sid = delete $params->{$meta->{'sid_arg'}}; # sid - только в session.sid
  } else {
    $sid = $meta->{'cook'}; # TODO: геттер или иначе брать
  }
  $meta->setsid($sid); # sid до валидации

  my $lang = delete $params->{'lang'}; # lang - всегда в meta.lang и в session.lang если нужен в ссылках
  $lang = PGWS::Utils::lang_mk($dbc->config('lang'), $lang);
  $lang = undef if ($lang and $lang eq $lang_default);
  $meta->setlang($lang || $lang_default);

  my $session;
  if ($sid) {
    $session = $self->api($ws, $errors, $meta, 'sid', $dbc->config('fe.def.sid'));
    $session->{'sid_error'} = (!$session->{'sid'} and $meta->{'sid_arg'}); # был передан некорректный sid и он сброшен
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
    $session->{'lang'} = $lang || $lang_default;
    $session->{'lang_used'} = 1 if ($lang); # задан lang  - нужен в ссылках
  }
  loc_lang($meta->{'lang'});

  $meta->stage_out;
  return $session;
}

#----------------------------------------------------------------------
sub load_cookie {
  my ($self, $req, $tag) = @_;
  my $dbc = $self->dbc;

  my $data = $dbc->config('fe.tmpl.'.$tag);
  my $user_data = $req->fetch_cook($data->{'cookie'}.'=([\\w]+)');
  #print STDERR '===',Dumper($data);
  return $data;
}

#----------------------------------------------------------------------
sub tmpl_vars {
  my ($self, $ws, $errors, $meta, $proto, $prefix, $stg_args, $def_code) = @_;
  return {
    'l'           => sub { i18n($self, $ws, $errors, $meta->{'lang'}, @_) },
    'uri_mk'      => sub { PGWS::Utils::uri_mk($proto, $prefix, $stg_args, @_) },
    'uri_mk_form' => sub { PGWS::Utils::uri_mk_form($proto, $prefix, $stg_args, @_) },
    'uri_escape'  => sub { PGWS::Utils::uri_esc(@_) },
    'json'        => sub { PGWS::Utils::json_out(@_) },
    'is_bit_set'  => sub { my ($a,$b) = @_; return ($a & $b) == $b; },
    'api'         => sub { api($self, $ws, $errors, $meta, undef, @_) },
    'sysapi'      => sub { sysapi($self, $ws, $errors, $meta, undef, @_) },
    'uri'         => sub { api($self, $ws, $errors, $meta, undef, $def_code, @_); },
    'ref'         => sub { ref($_[0]) },
    'const'       => sub { 
      my $ret = $self->dbc->const($_[0], 1);
      unless (defined($ret)) {
        my ($package, $filename, $line) = caller;
        my $r = ROOT.'var/tmpl'; # INCLUDE_PATH
        $filename =~s /^$r//;
        $meta->sys_error('template error: Requested const (%s) does not exists at %s line %i', $_[0], $filename, $line); 
      }
      return $ret;
    },
  }
}

#----------------------------------------------------------------------
sub _api_result {
  my ($errors, $type, $method, $params, $ret) = @_;
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
