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

# PGWS.pm - Class for storing project verion number

use strict;
use warnings;

package PGWS;

our $VERSION = '1.11';

use constant TRACE_DIE     => ($ENV{PGWS_TRACE_DIE} or 0);

#----------------------------------------------------------------------

# see Mojolitious::Lite
sub import {
    my $class = shift;

    # Lite apps are strict!
    strict->import;
    warnings->import;
}

#----------------------------------------------------------------------
sub bye {
  my $message = shift;
  require Carp;
  if (TRACE_DIE) {
    Carp::confess($message);
  } else {
    Carp::croak('FATAL:'.$message);
  }
}

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
