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

# PGWS::JobManager - Job queue sheduler

package PGWS::JobManager;

use DBI;
use IPC::Shareable;

use Data::Dumper;

use PGWS;
use PGWS::Daemon;

use constant DEBUG     => ($ENV{PGWS_JOB_DEBUG} or 0);

#----------------------------------------------------------------------
sub run {
  my ($config) = @_;
  $config->{'mgr_init'}  ||= \&mgr_init;
  $config->{'proc_init'} ||= \&proc_init;
  $config->{'proc_main'} ||= \&proc_main;
  my $daemon = PGWS::Daemon->new($config);
  $daemon->run($config->{'cmd'});
}

#----------------------------------------------------------------------
# init manager
sub mgr_init {
  my ($self, $proc_manager) = @_;

  my $mode = "0666";
  my %options = (
    create    => 1
  , exclusive => 1
  , destroy   => 1
  , mode      => oct($mode)
  , size      => $self->mgr_dbc->config('mgr.mem_size')
  );
  # хэш событий по ID, обрабатываемых индивидуально в реальном времени
  my $glue = $$; # integer number or 4 character string
  my %notify;
  my %timer;

  $proc_manager->{'_SHARE_KEY'} = $glue;

  eval {
    tie %notify, 'IPC::Shareable', $glue++, { %options };
    tie %timer, 'IPC::Shareable', $glue, { %options };
  };
  if ($@) {
    PGWS::bye "server tie failed ($glue): ".$@;
  }

  $proc_manager->{'_SHARE_NOTIFY'} = \%notify;
  $notify{'_allowed'} = 1; # сохранение событий разрешено

  $proc_manager->{'_SHARE_TIMER'} = \%timer;
  $timer{'cron'}   = 0; # атрибуты обработчика с гарантированным интервалом запуска
  $timer{'shadow'} = 0; # атрибуты регулярной проверки очереди в БД независимо от событий

}

#----------------------------------------------------------------------
# init server
sub proc_init {
  my ($self, $proc_manager) = @_;

  $proc_manager->pm_change_process_name($self->{'proc_name'});

  my $lt = localtime;
  printf STDERR ("[%s] [%i]: PROC INIT\n", $lt, $$) if DEBUG;

  $self->dbc_ping_and_listen(DEBUG);  # Конфа, загруженная в этом месте, будет перезагружена при reload

  my $glue = $proc_manager->{'_SHARE_KEY'};
  my %notify;
  my %timer;

  eval {
    tie %notify, 'IPC::Shareable', $glue++;
    tie %timer, 'IPC::Shareable', $glue;
  };
  if ($@) {
    PGWS::bye "server tie failed ($glue): ".$@;
  }

  $self->{'share'} = {
    'notify' => \%notify,
    'timer' => \%timer,
  };

  # статистика работы
  $self->{'stat'} = {
    'run_at'      => time()
  };
  map { $self->{'stat'}{$_} = 0 } qw (loop_at event_at cron_at shadow_at error_at loop_count event_count error_count);
  $self->{'errors'} = [];
}

#----------------------------------------------------------------------
sub proc_main {
  my ($self, $proc_manager) = @_;

  while (1) {
    $proc_manager->pm_pre_dispatch();
    eval {
      if (my $event = _accept($self, $proc_manager)) {
        if ($event->{'name'} eq 'system' and $event->{'id'} eq 'cron') {
          my $sleep = $event->{'stamp'} - time();
          if ($sleep > 0) {
            sleep $sleep;
          }
        } elsif ($event->{'name'} eq 'reload') {
          my $mode = ($event->{'id'} eq $self->dbc->config('mgr.reload_key'));
          my $lt = localtime;
          printf STDERR "[%s] [%i]: RELOAD %s\n", $lt,
            $$, $mode?'requested':'forbidden';
          ;
          if ($mode) {
            $event->{'id'} = '*****' ; # no log print
            kill HUP => $proc_manager->{'MANAGER_PID'};
          }
        } elsif ($event->{'name'} eq 'job' and $event->{'id'} =~ 'error') {
          # error test
          die $event->{'id'};
        }
        my $lt = localtime;
        printf STDERR ("[%s] [%i]: RUN EVENT %s(%s)\n", $lt, $$, $event->{'name'}, $event->{'id'}) if DEBUG;
        if ($event->{'name'} eq 'system' and $event->{'id'} eq 'cron') {
          $self->{'stat'}{'cron_at'} = time();
        } elsif ($event->{'name'} eq 'system' and $event->{'id'} eq 'shadow') {
          $self->{'stat'}{'shadow_at'} = time();
        } else {
          $self->{'stat'}{'event_at'} = time();
        }

        # Do the job
#      sleep 2;

        # update success counter
        $self->{'stat'}{'event_count'}++;
      }
    };
    if ($@) {
      chomp ($@);
      my $lt = localtime;
      printf STDERR "[%s] [%i]: RUN ERROR (%s)\n", $lt, $$, $@;
      my $e;
      my $tm = time();
      my $errors = $self->{'errors'};
      if (scalar(@$errors)) {
        my $e_pre = pop @$errors;
        if ($@ eq $e_pre->{'anno'}) {
          $e_pre->{'count'}++;
          $e = $e_pre;
        }
      }
      $e ||= {
        'first_at'  => $tm
      , 'count'     => 1
      , 'anno'      => $@
      };
      $e->{'last_at'} = $tm;
      push @$errors, $e;
      $self->{'stat'}{'error_at'} = $tm;
      $self->{'stat'}{'error_count'} += 1;
      sleep 2; # give some rest to server
    }
    $proc_manager->pm_post_dispatch();
  }
}

#----------------------------------------------------------------------
sub _accept {
  my ($self, $proc_manager) = @_;

  $self->{'stat'}{'loop_at'} = time();
  $self->{'stat'}{'loop_count'}++;

  my $lt = localtime;
  printf STDERR ("[%s] [%i]: RUN LOOP\n", $lt, $$) if DEBUG;

  $self->dbc_ping_and_listen(DEBUG);

  my $dbh = $self->dbc->dbh;

  my $cron_predict    = $self->dbc->config('mgr.cron_predict');
  my $cron_every      = $self->dbc->config('mgr.cron_every');
  my $listen_wait     = $self->dbc->config('mgr.listen_wait');

  my $sql_stat_load   = $self->dbc->config('mgr.sql.stat_load');
  my $sql_error_load  = $self->dbc->config('mgr.sql.error_load');

  my $event;

  # CRON
  my $timer = $self->{'share'}{'timer'};
  (tied %$timer)->shlock;
  if ($timer->{'cron'} - $cron_predict < time()) {
    my $tm = time();
    my $ce = $cron_every;                       # запускаем каждые $ce секунд

    my $daysec  = $tm % 86400;                  # секунд после полуночи
    my $mid     = $tm - $daysec;                # полночь по GMT
    my $late    = $daysec % $ce;                # секунд после прошлого запуска
    my $nearest = $mid + $daysec - $late + $ce; # ближайший запуск
    my $next    = $nearest + $ce;               # следующий запуск

    $event = {'name' => 'system', 'id' => 'cron', 'pid' => $$, 'stamp' => $nearest};
    $timer->{'cron'} = $next;

  }
  (tied %$timer)->shunlock;
  return $event if $event;

  # SHADOW
  (tied %$timer)->shlock;
  my $tm = time();
  my $tm_next = $timer->{'shadow'};
  if ($tm_next <= $tm) {
    $event = {'name' => 'system', 'id' => 'shadow', 'pid' => $$, 'stamp' => $tm};
    $timer->{'shadow'} = $tm + $listen_wait;
  }
  (tied %$timer)->shunlock;
  if ($event) {
    # purge events
    my $notify = $self->{'share'}{'notify'};
    (tied %$notify)->shlock;
    my $deleted = 0;
    foreach my $key (keys %$notify) {
      next if ($key eq '_allowed');
      # delete $notify->{$key} unless ($notify->{$key});
      my ($pid, $tm) = split /\-/, $notify->{$key};
      if ($tm < $tm_next - $listen_wait) {
        delete $notify->{$key};
        $deleted++;
      }
    }
    $notify->{'_allowed'} = 1 if ($deleted);
    (tied %$notify)->shunlock;
    # run shadow
    return $event;
  }

  # NOTIFIES
  my $notifies = $dbh->func('pg_notifies');
  if (!$notifies) {
    # code from http://rhodiumtoad.org.uk/junk/listen-min.pl.txt
    my $fd = $dbh->{'pg_socket'} or PGWS::bye $dbh->errstr;
    my $rfds = '';
    vec($rfds, $fd, 1) = 1;
    my $n = select($rfds, undef, undef, $listen_wait);
    $notifies = $dbh->func('pg_notifies');
  }
  while ($notifies) {
    # the result from pg_notifies is a ref to a two-element array,
    # with the notification name and the sender's backend PID.
    my ($name, $pid, $payload) = @$notifies;

    if ($self->{'listen'}{$name} eq 'stat') {
      my $lt = localtime;
      printf STDERR ("[%s] [%i]: STAT SAVE (loop: %i event %i error: %i)\n", $lt,
        $$, map { $self->{'stat'}{$_} } qw(loop_count event_count error_count)
      )  if DEBUG;
      $dbh->do($sql_stat_load, {},
        $$, map { $self->{'stat'}{$_} } qw(loop_count event_count error_count run_at loop_at event_at error_at cron_at shadow_at)
      );
      my $errors = $self->{'errors'};
      foreach my $e (@$errors) {
        $dbh->do($sql_error_load, {},
          $$, map { $e->{$_} } qw(count first_at last_at anno)
        );
      }
    } else {
      # my $key = sprintf '%s-%s-%s', $pid, $name, $payload;
      my $key = sprintf '%s-%s', $self->{'listen'}{$name}, $payload;
      my $notify = $self->{'share'}{'notify'};
      (tied %$notify)->shlock;
      if ($notify->{'_allowed'} and (!exists $notify->{$key} or $notify->{$key} =~ /^$$\-/)) {
        my $tm = time();
        $event = {'name' => $self->{'listen'}{$name}, 'id' => $payload, 'pid' => $$, 'stamp' => $tm };
        $notify->{$key} = sprintf '%i-%i', $$, $tm;
      }
      eval {
        (tied %$notify)->shunlock;
      };
      if ($@) {
        # no room to store
        delete $notify->{$key};
        $notify->{'_allowed'} = 0; # до shadow прекращаем обработку событий
        my $notifies = scalar(keys %$notify);
        (tied %$notify)->shunlock;
        die "no room to store event No. $notifies";
      }
      return $event if $event;
    }
    # read more notifications, until there are none outstanding
    $notifies = $dbh->func('pg_notifies');
  }

  return;
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