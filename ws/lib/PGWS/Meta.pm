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

# PGWS::Meta - metadata handling

package PGWS::Meta;

use PGWS;
use PGWS::Utils;
use Data::Dumper;
#use utf8;
use Time::HiRes qw(gettimeofday tv_interval);

use constant DMP_LEVEL => 6;
#----------------------------------------------------------------------
# http://www.perlmonks.org/?node_id=759457
$Data::Dumper::Useqq = 1;

{ no warnings 'redefine';
    sub Data::Dumper::qquote {
        my $s = shift;
        return "'$s'";
    }
}

#----------------------------------------------------------------------

sub setip     { $_[0]->{'ip'}   = $_[1] }
sub keyoff    { $_[0]->{'key'}  = undef }
sub setsid    { $_[0]->{'sid'}  = $_[1] }
sub setcook   { $_[0]->{'cook'}  = $_[1] }
sub setenc    { $_[0]->{'enc'}  = $_[1] }
sub setlang   { $_[0]->{'lang'} = $_[1] }

sub setsource { $_[0]->{'source'} = $_[1] }
sub stage_in  { unshift @{$_[0]->{'stage'}}, $_[1] }
sub stage_out { shift @{$_[0]->{'stage'}} }

sub sys_error { shift->_store(1, undef, 1, @_); }
sub rpc_error { shift->_store(2, undef, 1, @_); }
sub app_error { shift->_store(3, undef, 1, @_); }
sub app_nodata{ shift->_store(4, undef, 1, @_); }
sub debug     { shift->_store(5, undef, 0, @_); }
sub dump      { shift->_store(DMP_LEVEL, undef, 0, @_); }

sub debugN    { shift->_store(5, shift, 0, @_); }
sub dumpN     { shift->_store(DMP_LEVEL, shift, 0, @_); }

sub has_data  { return scalar(@{$_[0]->{'buffer'}}) }
sub data      { return $_[0]->{'buffer'} }

sub changed   { shift->_store(5, undef, 0, @_); }  # изменение БД

sub elapsed   { return tv_interval(shift->{'started'}) }

sub stat_hit_inc { $_[0]->{'stat_hit'} = $_[0]->{'stat_hit'} + 1 }
sub stat_db_inc { $_[0]->{'stat_db'} = $_[0]->{'stat_db'} + 1 }
sub stat_hit { return $_[0]->{'stat_hit'} }
sub stat_db { return $_[0]->{'stat_db'} }

#----------------------------------------------------------------------
sub new {
  my ($class, $self) = @_;
  $self ||= {};
  $self->{'buffer'} ||= [];
  $self->{'stage'} ||= ['default'];
  $self->{'source'} ||= 'default';
  $self->{'default_level'} ||= 1;
  $self->{'stat_hit'} ||= 0;
  $self->{'stat_db'} ||= 0;
  my $t = [gettimeofday];
  $self->{'started'} = $t;
  bless $self, $class;
  return $self;
}

#----------------------------------------------------------------------
sub _store {
  my $self = shift;
  my $level = shift;
  my $src = shift || $self->{'source'};
  my $up_stack = shift;
  my $stage = $self->{'stage'}[0];
  my $meta = $self->_log_mode('debug', $src, $stage);
  my $stderr = $self->_log_mode('syslog', $src, $stage);
  return if ($level > $meta and $level > $stderr);
  my ($package, $filename, $line, $caller_name) = caller(2 + $up_stack);
  ($package, $filename, $line) = caller(1 + $up_stack);
  my $ret = {
    'caller'  => $caller_name,
    'package' => $package,
    'line'    => $line,
    'level'   => $level,
    'source'  => $src,
    'stage'   => $stage,
  };
  if ($level == DMP_LEVEL) {
    my ($d) = (@_);
    $ret->{'data'} = (ref(\$d) eq 'SCALAR')?$d: Dumper($d);
  } else {
    $ret->{'message'} = PGWS::Utils::format_message(@_);
  }

  unless ($level > $meta) {
    push @{$self->{'buffer'}}, $ret;
  }
  return if ($level > $stderr);
  my $msg = sprintf '[%i] [%s / %s / %i] [%s / %i]: ', $$, $src, $stage, $level, $caller_name, $line;
  my $lt = localtime;
  my $s;
  if ($level == DMP_LEVEL) {
    $s = $ret->{'data'};
  } else {
    $s = $ret->{'message'};
  }
  utf8::encode($s);
  print STDERR "[$lt] $msg", $s, "\n";
}

#----------------------------------------------------------------------
sub _log_mode {
  my ($self, $dest, $src, $stage) = @_;
  return $self->{'default_level'} unless defined($self->{$dest});
  my $ds = $self->{$dest}{$src} || $self->{$dest}{'default'};
  return $self->{'default_level'} unless defined($ds);
  my $dss = $ds->{$stage} || $ds->{'default'};
  return defined($dss)?$dss:return $self->{'default_level'};
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