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

use PGWS;

#----------------------------------------------------------------------
sub pm_write_pid_file {
  my ($this,$fname) = FCGI::ProcManager::self_or_default(@_);
  $fname ||= $this->pid_fname() or PGWS::bye "pidfile is required";

  my $fh = $this->{'_PIDFILE'} = new IO::File;
  open $fh, '>',$fname or PGWS::bye "Pidfile $fname open error:".$!;
  flock ($fh, LOCK_EX) or PGWS::bye "Pidfile $fname lock error:".$!;
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
use Data::Dumper;

#----------------------------------------------------------------------
sub pm_exit {
  my ($this, $msg, $n) = FCGI::ProcManager::self_or_default(@_);

  if ($this->{'role'} eq 'manager') {
    &{$this->{'_SHUTDOWN_SUB'}}($this) if ($this->{'_SHUTDOWN_SUB'});
    print STDERR 'RESULTS: ', Dumper($this);
    # remove in shell:
    # ipcs -m | grep 666 | while read a b c d ; do ipcrm -m $b ; done
    # ipcs -s | grep 666 | while read a b c d ; do ipcrm -s $b ; done
  }
  $this->SUPER::pm_exit($msg, $n);
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