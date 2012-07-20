#!/usr/bin/env perl
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
#
# tmd.pl - Task manager daemon

use lib 'lib';

use PGWS;
use PGWS::Daemon;

use constant ROOT               => ($ENV{PGWS_ROOT} || '');   # PGWS root dir

use constant POGC     => 'tm';                      # Property Owner Group Code
use constant POID     => ($ENV{PGWS_FCGI_POID} or 1); # Property Owner ID

use constant CMD        => ($ENV{PGWS_TM_CMD});

use constant DEBUG     => ($ENV{PGWS_TM_DEBUG} or 0);

use constant EVENT_REQUIRED => ($ENV{PGWS_TM_EVENT_REQUIRED}); # Запускать cmd только по notify

#----------------------------------------------------------------------
$| = 1;

my $daemon = PGWS::Daemon->new({
  'pogc' => POGC
, 'poid' => POID
, 'proc_init' => \&proc_init
, 'proc_main' => \&proc_main
});

$daemon->run(shift);

#----------------------------------------------------------------------
1;

#----------------------------------------------------------------------
# init server
sub proc_init {
  my ($self, $proc_manager) = @_;

  $proc_manager->pm_change_process_name($self->{'proc_name'});
  $self->dbc_ping_and_listen(DEBUG);
}

#----------------------------------------------------------------------
sub proc_main {
  my ($self, $proc_manager, $request, $req_env) = @_;

  while (1) {

    $self->dbc_ping_and_listen(DEBUG);
    my $dbh = $self->dbc->dbh;

    my $listen_wait     = $self->dbc->config('mgr.listen_wait');

    my $start = EVENT_REQUIRED?0:1;
    $proc_manager->pm_pre_dispatch();

    # code from http://rhodiumtoad.org.uk/junk/listen-min.pl.txt
    my $notifies = $dbh->func('pg_notifies');
    if (!$notifies) {
      my $fd = $dbh->{'pg_socket'} or die $dbh->errstr;
      my $rfds = '';
      vec($rfds,$fd,1) = 1;
      my $n = select($rfds, undef, undef, $listen_wait);
      $notifies = $dbh->func('pg_notifies');
    }
    while ($notifies) {
      $start++;
      # the result from pg_notifies is a ref to a two-element array,
      # with the notification name and the sender's backend PID.
      my ($n,$p) = @$notifies;
      #$self->logt(2, "$$ Monitor Notification: $n $p");
      # read more notifications, until there are none outstanding
      $notifies = $dbh->func('pg_notifies');
    }
    if ($start) {
      my $lt = localtime;
      print STDERR "[$lt] [$$]: Run JQ\n" if (DEBUG);
      system ROOT.CMD;
    }
    $proc_manager->pm_post_dispatch();
  }
}
