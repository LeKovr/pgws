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
# json2conninfo.pl - Convert DB connect data from JSON to string
# Usage: $0 < i18n_def.sql > i18n_def.tmpl

use strict;
use warnings;

#----------------------------------------------------------------------
sub _def {
  my $s = shift;
  if ($s =~ /^[a-z0-9\s\.\-\_\,]*$/i) {
    # skip latin-only strings
    $s = "'$s'";
  } else {
    $s = "{{$s}}";
  }
  return $s;
}

#----------------------------------------------------------------------

while (<>) {
  s/'([^']+)'/_def($1)/ge;
  print $_;
}

#----------------------------------------------------------------------
