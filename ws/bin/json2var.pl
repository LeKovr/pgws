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
# json2var.pl - Convert DB connect data from JSON to string
# Usage: $0 < db.json

use strict;
use JSON;
use Data::Dumper;

my @cdata = <STDIN>;
my $json = new JSON;
my $cfg = $json->relaxed(1)->decode(join '', @cdata);

foreach my $name (@ARGV) {
  my $value;
  if ($name eq 'DB') {
    $value = $cfg->{'ACTIVE'}{'DB_CONNECT'};
    $value =~ s/dbi:pg://i;
    $value =~ s/;/ /g;
  } elsif ($name eq 'DAEMON_USER' or $name eq 'PACKAGES') {
    $value = $cfg->{'SHELL'}{$name};
  } else {
    $value = $cfg->{'ACTIVE'}{$name};
  }
  print "$value\n";
}
1;

