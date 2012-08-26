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

# client.pl - PGWS client example

use strict;

# based on http://www.zabbix.com/forum/showthread.php?t=15448

# for SSL: see man Crypt::SSLeay

use JSON::RPC::Client;
use Data::Dumper;

# SSL:
# 1. Install LWP::Protocol::https
# 2. If server uses Self-Signed server cert, call:
# PERL_LWP_SSL_VERIFY_HOSTNAME=0 perl client.pl

#my $url = 'https://www.pgws.local/api/';

my $url = 'http://www.pgws.local/api/';

#----------------------------------------------------------------------
# End of config
#----------------------------------------------------------------------
our $DEBUG = $ENV{'DEBUG'} || 0; # выводить промежуточные результаты

my $client = new JSON::RPC::Client;

# http://www.perlmonks.org/?node_id=759457
$Data::Dumper::Useqq = 1;

{ no warnings 'redefine';
    sub Data::Dumper::qquote {
        my $s = shift;
        return "'$s'";
    }
}


binmode(STDOUT,':utf8');

sub out {
    my ($client, $obj, $res) = @_;
    if ($res) {
       if ($res->is_error) {
           print "Error : ", Dumper($obj, $res->error_message);
       }
       else {
           print Dumper($obj, $res->result) if ($DEBUG);
       }
    }
    else {
       print $client->status_line;
    }
}
#----------------------------------------------------------------------
print '-' x 60, "\n";

my $object1 = {
  jsonrpc => '2.0',
  method => 'info.add',
  id => $$,
  params => { 'a' => 333, 'b' => 444 }
};

my $res = $client->call( $url, $object1);
out ($client, $object1, $res);
print '333 + 444 = ', $res->result->{'data'}, "\n";

#----------------------------------------------------------------------
print '-' x 60, "\n";

my $object2 = {
  jsonrpc => '2.0',
  method => 'acc.login',
  id => $$,
  params => { 'login' => 'admin', 'psw' => 'pgws' }
};
$res = $client->call( $url, $object2);
out ($client, $object2, $res);
my $sid = $res->result->{'data'}{'sid'};
print "Logged in with SID = $sid\n";


#----------------------------------------------------------------------
print '-' x 60, "\n";

my $object3 = {
  jsonrpc => '2.0',
  method => 'acc.profile',
  id => $$,
  sid => $sid,
};
$res = $client->call( $url, $object3);
$DEBUG=1;
out ($client, $object3, $res);
$DEBUG = $ENV{'DEBUG'} || 0;
#----------------------------------------------------------------------
print '-' x 60, "\n";

my $object3 = {
  jsonrpc => '2.0',
  method => 'acc.logout',
  id => $$,
  sid => $sid,
};
$res = $client->call( $url, $object3);
out ($client, $object3, $res);
print "Logged out\n" if ($res->result->{'data'} == 1);

#----------------------------------------------------------------------
print '-' x 60, "\n";

exit(1) unless ($DEBUG);

my $object3 = {
  jsonrpc => '2.0',
  method => 'acc.profile',
  id => $$,
  sid => $sid,
};
$res = $client->call( $url, $object3);
print "Logged out error example:\n";
out ($client, $object3, $res);

delete $object3->{'sid'};
$res = $client->call( $url, $object3);
print "Anonymous error example:\n";
out ($client, $object3, $res);

#----------------------------------------------------------------------
print '-' x 60, "\n";

1;
