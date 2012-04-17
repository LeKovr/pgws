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

# PGWS::ProcManager - FCGI::ProcManager customisation

package PGWS::ProcManager;
use base qw(FCGI::ProcManager);

use Fcntl qw(:DEFAULT :flock);
use IO::File;

#----------------------------------------------------------------------
sub pm_write_pid_file {
  my ($this,$fname) = FCGI::ProcManager::self_or_default(@_);
  $fname ||= $this->pid_fname() or die "pidfile is required";

  my $fh = $this->{'_PIDFILE'} = new IO::File;
  open $fh, '>',$fname or die "Pidfile $fname open error:".$!;
  flock ($fh, LOCK_EX) or die "Pidfile $fname lock error:".$!;
  print $fh "$$\n";
}

#----------------------------------------------------------------------
sub pm_remove_pid_file {
  my ($this,$fname) = FCGI::ProcManager::self_or_default(@_);
  $fname ||= $this->pid_fname();
  my $fh = $this->{'_PIDFILE'};
  close $fh or $this->pm_warn("close pidfile error: $!");
  my $ret = unlink($fname) or $this->pm_warn("unlink pidfile error: $!");
  return $ret;
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