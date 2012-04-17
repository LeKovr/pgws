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
# pwl.pl - CGI mode script

# export PERL5LIB="$PWD/lib:$PWD/pkg/pgws/lib:$PERL5LIB"
use strict;
use warnings;

use FindBin qw($Bin);

use PGWS::Frontend::CGI;

$| = 1;

my $frontend = PGWS::Frontend::CGI->new({'root' => "$Bin/../../../"});
$frontend->run(@ARGV);

1;
