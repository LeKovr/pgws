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

my $url = 'http://www.test.local/api/';

#----------------------------------------------------------------------
# End of config
#----------------------------------------------------------------------

my $client = new JSON::RPC::Client;
my $sid = shift;

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
           print Dumper($obj, $res->result);
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
print '333 + 444:', "\n";
out ($client, $object1, $res);

#----------------------------------------------------------------------
print '-' x 60, "\n";

my $object2 = {
  jsonrpc => '2.0',
  method => 'company.billing_info',
  id => $$,
  sid => $sid,
  params => { 'id' => 270 }
};
if ($sid) {
    $res = $client->call( $url, $object2);
    print "Authorised req with sid=$sid:\n";
    out ($client, $object2, $res);
} else {
    print "Call $0 <correct_sid> to see more\n";
}
#----------------------------------------------------------------------
print '-' x 60, "\n";

$object2->{'params'}{'id'}='4';
$res = $client->call( $url, $object2);
print "Authorised req with sid=$sid and unknown company_id:\n";
out ($client, $object2, $res);

#----------------------------------------------------------------------
print '-' x 60, "\n";

$object2->{'method'} = 'unknown';
$res = $client->call( $url, $object2);
print "System error with full response: \n";
print Dumper($object2, $res->content);

#----------------------------------------------------------------------
print '-' x 60, "\n";

1;
