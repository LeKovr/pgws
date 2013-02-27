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

# PGWS::Daemon - daemon base class

package PGWS::Daemon;

# Code based on:
# http://wiki.nginx.org/SimpleCGI
# http://m-ivanov.livejournal.com/4957.html
# http://www.realcoding.net/article/view/4749
# http://wiki.opennet.ru/Nginx#Perl_.2B_FastCGI_.2B_nginx

use FCGI;
use PGWS::ProcManager;
use POSIX qw(setsid);

use Fcntl qw(:DEFAULT :flock);
use File::Basename;

use Data::Dumper;

use PGWS; # imports: use strict; use warnings;
use PGWS::DBConfig;

use constant ROOT               => ($ENV{PGWS_ROOT} || '');   # PGWS root dir

#----------------------------------------------------------------------
sub help {
  print <<TEXT
  Usage:
    $0 (start|status|check|restart|reload|stop)

  Where
    start   - run daemon if not running or raise error
    status  - print daemon status
    check   - run daemon if not running or exit
    restart - restart daemon
    reload  - restart workers
    stop    - stop daemon
TEXT
}

sub dbc     { $_[0]->{'_dbc'}     } # child config
sub mgr_dbc { $_[0]->{'_mgr_dbc'} } # mgr config
#----------------------------------------------------------------------

#----------------------------------------------------------------------
sub new {
  my ($class, $self) = @_;
  $self ||= {};
  bless $self, $class;
  $self->init;
  return $self;
}

#----------------------------------------------------------------------
sub init {
  my $self = shift;

  my $dbc = $self->{'_mgr_dbc'} = PGWS::DBConfig->new({
    'pogc' => $self->{'pogc'}
  , 'poid' => $self->{'poid'}
  , 'data_set' => 1
  });
  my $startup = $dbc->config('startup');
  my $name = $dbc->proc_name;

  $self->{'proc_name'}            = $name;
  $startup->{'pm'}{'pm_title'}    = $name.'-pm';
  $startup->{'pm'}{'pid_fname'} ||= ROOT.'var/run/'.$name.'.pid';
  $startup->{'sock'}            ||= ROOT.'var/run/'.$name.'.sock';
  $startup->{'log_file'}        ||= ROOT.'var/log/'.$name.'.log';
  $self->{'mgr_start'}          ||= \&mgr_start;
  $self->{'mgr_init'}           ||= \&mgr_init;
  $self->{'proc_init'}          ||= \&proc_init;
  $self->{'proc_loop'}          ||= \&proc_loop unless ($self->{'proc_main'}); # FCGI loop used
}

#----------------------------------------------------------------------
sub start {
  my $self = shift;
  my $silent = shift; # Don't print "started"
  my $dbc = $self->mgr_dbc;

  &{$self->{'mgr_start'}}($self);

  $self->daemonize($silent);

  open my $NULL, '+>', '/dev/null' or die "Can't open /dev/null: $!"; # no nginx stderr
  reopen_std($dbc->config('startup.log_file'));

  my $proc_manager = PGWS::ProcManager->new($dbc->config('startup.pm'));

  &{$self->{'mgr_init'}}($self, $proc_manager);

  my ($req_env, $socket, $request);
  unless ($self->{'proc_main'}) {
    # FCGI loop used
    $req_env = {};
    $socket  = FCGI::OpenSocket($self->{'socket'}, $dbc->config('startup.sock_wait'));
    $request = FCGI::Request(\*STDIN, \*STDOUT, $NULL, $req_env, $socket, &FCGI::FAIL_ACCEPT_ON_INTR);
  }

  print STDERR '*'x20,' '.localtime().' ','*'x20,"\n";

  $proc_manager->pm_manage();
  # we're in child now

  reopen_std($dbc->config('startup.log_file'));

  eval {
    &{$self->{'proc_init'}}($self, $proc_manager);

    unless ($self->{'proc_main'}) {
      # FCGI loop used
      proc_main($self, $proc_manager, $request, $req_env);
      FCGI::CloseSocket($socket);
    } else {
      &{$self->{'proc_main'}}($self, $proc_manager);
    }
  };
  if ($@) {
    sleep 2;
    die $@;
  }
}

#----------------------------------------------------------------------
# run before STDERR detach
sub mgr_start {
  my ($self) = @_;
}

#----------------------------------------------------------------------
sub mgr_init {
  my ($self, $proc_manager) = @_;
}

#----------------------------------------------------------------------
sub proc_init {
  my ($self, $proc_manager) = @_;
  $proc_manager->pm_change_process_name($self->{'proc_name'});
}

#----------------------------------------------------------------------
sub proc_main {
  my ($self, $proc_manager, $request, $req_env) = @_;

  while($request->Accept() >= 0) {
    $proc_manager->pm_pre_dispatch();
    &{$self->{'proc_loop'}}($self, $proc_manager, $req_env);
    $proc_manager->pm_post_dispatch();
  }
}

#----------------------------------------------------------------------
sub proc_loop {
  my ($self, $req_env) = @_;
  print STDERR 'sub proc_loop must be redefined';
  sleep 60;
}

#----------------------------------------------------------------------
sub daemonize {
  my ($self, $silent) = @_;
  chdir '/' or die "Can't chdir to /: $!";
  defined( my $pid = fork ) or die "Can't fork: $!";
  exit if $pid;
  setsid() or die "Can't start a new session: $!";
  umask 0;
  $self->log(-1, $$, 'started') unless ($silent);

}

#----------------------------------------------------------------------
sub reopen_std {
  my $stderr = shift;
  ## no critic
  open(STDIN,  "+>/dev/null") or die "Can't open STDIN: $!";
  open(STDOUT, "+>&STDIN") or die "Can't open STDOUT: $!";
  ## use critic
  open STDERR, '>>', $stderr or die "Can't redirect STDERR to $stderr: $!";
}

#----------------------------------------------------------------------
sub run {
  my $self = shift;
  $_ = shift || 'help';

  my $pid;
  my $file = $self->mgr_dbc->config('startup.pm.pid_fname');
  if (-f $file) {
    open my $FILE, '<', $file or die "Can't open pidfile $file:".$!;
    $pid = <$FILE>;
    chomp $pid;
    flock($FILE, LOCK_EX|LOCK_NB) and $pid = undef;
    close $FILE;
  }
  if (/^start/) {
    $self->log(1, $pid, 'already running') if ($pid);
    $self->start;
  } elsif (/check/) {
    exit(1) if ($pid);
    $self->start;
  } elsif (/status/) {
    if ($pid) {
      $self->log(1, $pid, 'running');
    } else {
      $self->log(2, undef, 'not running');
    }
  } elsif (/restart/) {
    if ($pid) {
      kill TERM => $pid;
      $self->log(-1, $pid, 'terminated');
    }
    sleep 1; # wait some for unlisten
    $self->start;
  } elsif (/reload/) {
    $self->log(2,undef,'not running') unless ($pid);
    kill HUP => $pid;
    $self->log(-1, $pid, 'reloaded');
  } elsif (/stop/) {
    $self->log(2,undef,'not running') unless ($pid);
    kill TERM => $pid;
    $self->log(-1, $pid, 'terminated');
  } else {
    help();
  }
  exit(0);
}

#----------------------------------------------------------------------
sub log {
  my ($self, $exit_code, $pid, $msg) = @_;
  my $name = $self->{'proc_name'};
  if ($pid) {
    printf "%s pid %i: %s\n", $name, $pid, $msg;
  } else {
    printf "%s: %s\n", $name, $msg;
  }
  exit($exit_code) unless ($exit_code == -1);
}


#----------------------------------------------------------------------
# Вспомогательный метод для демонов, использующих LISTEN (Postgresql)
sub dbc_ping_and_listen {
  my $self = shift;
  my $debug = shift;

  my $dbc = $self->dbc;
  return if ($dbc and $dbc->dbh and $dbc->dbh->ping);

  # нет объекта или пропал коннект

  if ($dbc) {
    # пропал коннект
    $self->dbc->init;
  } else {
    # нет объекта
    $self->{'_dbc'} ||= PGWS::DBConfig->new({
      'pogc' => $self->{'pogc'}
    , 'poid' => $self->{'poid'}
    , 'keep_db' => 1
    });
  }

  my $dbh = $self->dbc->dbh;

  my $listen = $self->dbc->config('mgr.listen');
  $self->{'listen'} = {};
  foreach my $key (keys %{$listen}) {
    my $event = $listen->{$key};
    $self->{'listen'}{$event} = $key; # при получениии уведомления надо определять event -> key
    $dbh->do(qq{listen "$event";}) or PGWS::bye "Listen $event error: ".$dbh->errstr;
  }
  my $lt = localtime;
  printf STDERR ("[%s] [%i]: DB INIT (%s)\n", $lt, $$, join (', ', keys %{$self->{'listen'}}))  if ($debug);
  return 1;
}

#----------------------------------------------------------------------


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