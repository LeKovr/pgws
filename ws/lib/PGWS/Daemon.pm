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

use PGWS; # imports: use strict; use warnings;
use PGWS::Utils;

use FCGI;
use PGWS::ProcManager;
use POSIX qw(setsid);

use Fcntl qw(:DEFAULT :flock);

use File::Basename;

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

  my $prog_name = basename($0);
  $prog_name =~s /^(PGWS-)?([^.]+)(\.pl)?$/$2/;

  my $name = $self->{'name'} = $self->{'name'} || $prog_name;
  my $file = $self->{'root'}.'conf/'.$name.'.json';
  my $cfg = $self->{'cfg'} = PGWS::Utils::data_load($file);

  $cfg->{'pm'}{'pm_title'} ||= $name;
  $name = $cfg->{'pm'}{'pm_title'};
  $cfg->{'proc_title'} ||= $name.'-worker';

  $cfg->{'sock'} ||= $self->{'root'}.'var/run/'.$name.'.sock';

  $cfg->{'pm'}{'pid_fname'} ||= $self->{'root'}.'var/run/'.$name.'.pid';
  $cfg->{'log_file'} ||= $self->{'root'}.'var/log/'.$name.'.log';

  $self->{'proc_main'} ||= \&proc_main;
  $self->{'proc_loop'} ||= \&proc_loop;
  $self->{'proc_init'} ||= \&proc_init;

}

#----------------------------------------------------------------------
sub start {
  my $self = shift;
  my $silent = shift; # Don't print "started"
  my $cfg = $self->{'cfg'};
  $self->daemonize($silent);

  open my $NULL, '+>', '/dev/null' or die "Can't open /dev/null: $!"; # no nginx stderr
  reopen_std($cfg->{'log_file'});
  my $req_env={};
  my $proc_manager = PGWS::ProcManager->new($cfg->{'pm'});
  my $socket = FCGI::OpenSocket($cfg->{'sock'}, $cfg->{'sock_wait'});
  my $request = FCGI::Request(\*STDIN, \*STDOUT, $NULL, $req_env, $socket, &FCGI::FAIL_ACCEPT_ON_INTR);
print STDERR '*'x20,' '.localtime().' ','*'x20,"\n";
  $proc_manager->pm_manage();

  $proc_manager->pm_change_process_name($cfg->{'proc_title'});
  reopen_std($cfg->{'log_file'});

  &{$self->{'proc_init'}}($self);
  &{$self->{'proc_main'}}($self, $proc_manager, $request, $req_env);

  FCGI::CloseSocket($socket);
}

#----------------------------------------------------------------------
sub proc_init {
  my $self = shift;
}

#----------------------------------------------------------------------
sub proc_main {
  my ($self, $proc_manager, $request, $req_env) = @_;

  while($request->Accept() >= 0) {
    $proc_manager->pm_pre_dispatch();
    &{$self->{'proc_loop'}}($self, $req_env);
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
  open STDERR, '>>', $stderr or die "Can't redirect STDERR: $!";
}

#----------------------------------------------------------------------
sub run {
  my $self = shift;
  $_ = shift || 'help';

  my $pid;
  my $file = $self->{'cfg'}{'pm'}{'pid_fname'};
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
sub help {

print <<TEXT
Usage: $0 (start|status|check|restart|reload|stop)
  Where
    start   - run daemon if not running or raise error
    status  - print daemon status
    check   - run daemon if not running or exit
    restart - restart daemon
    reload  - restart workers
    stop    - stop daemon
TEXT
}

#----------------------------------------------------------------------
sub log {
  my ($self, $exit_code, $pid, $msg) = @_;
  if ($pid) {
    printf "%s pid %i: %s\n", $self->{'name'}, $pid, $msg;
  } else {
    printf "%s: %s\n", $self->{'name'}, $msg;
  }
  exit($exit_code) unless ($exit_code == -1);
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