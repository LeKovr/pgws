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

use strict;
use warnings;

use Cwd;
our $dir;
BEGIN {
    $dir = getcwd;
}

use lib "$dir/lib";

use PGWS::Daemon;

#----------------------------------------------------------------------
$| = 1;

my $daemon = PGWS::Daemon->new({'root' => "$dir/", 'proc_main' => \&proc_main });
$daemon->run(shift);

#----------------------------------------------------------------------
1;

use DBI;

#----------------------------------------------------------------------
sub proc_main {
  my ($self, $proc_manager, $request, $req_env) = @_;
  my $cmd = $self->{'root'}.$self->{'cfg'}{'app'}{'cmd'};
  my $listen = $self->{'cfg'}{'app'}{'listen'};
  my $timeout = $self->{'cfg'}{'app'}{'timeout'};
  my $file = $self->{'root'}.'conf/db.json';
  my $cfg_db = PGWS::Utils::data_load($file);

  my $dbh = DBI->connect(@{$cfg_db->{'connect'}}) or die $DBI::errstr;
  if ($cfg_db->{'init'}) {
    foreach my $sql (@{$cfg_db->{'init'}}) {
      $dbh->do($sql) or die $DBI::errstr;
    }
  }
  # code from http://rhodiumtoad.org.uk/junk/listen-min.pl.txt

  $dbh->do(qq{listen "$listen";}) or die $dbh->errstr;

  while (1) {
    my $start = $self->{'cfg'}{'app'}{'run_anyway'}?1:0;
    $proc_manager->pm_pre_dispatch();
    my $notifies = $dbh->func('pg_notifies');
    if (!$notifies) {
      my $fd = $dbh->{'pg_socket'} or die $dbh->errstr;
      my $rfds = '';
      vec($rfds,$fd,1) = 1;
      my $n = select($rfds, undef, undef, $timeout);
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
      print STDERR "[$lt] [$$]: Run JQ\n";
      system $cmd;
    }
    $proc_manager->pm_post_dispatch();
  }
}
