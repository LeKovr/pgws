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

# PGWS::Plugin::System::Cache - cache control plugin

package PGWS::Plugin::System::Cache;

use PGWS;
use PGWS::Utils;

use base qw(PGWS::Plugin);

#----------------------------------------------------------------------
sub reset {
  my ($class, $self, $meta, $args) = @_;
  my $cache_id = shift @$args;

  my $ret = 0;
  my $key = PGWS::Utils::json_out($args);

  if ($self->cache and exists($self->cache->{$cache_id})) {
    $self->cache->{$cache_id}->remove($key);
    $ret = 1;
  }

  $meta->debug('p_c_l: id %i, key %s, ret %i', $cache_id, $key, $ret);
  return { 'result' => { 'data' => $ret } };
}

#----------------------------------------------------------------------
sub reset_mask {
  my ($class, $self, $meta, $args) = @_;
  $meta->dump({ 'reset_mask' => $args });
  my $cache_id = shift @$args;
  $cache_id ||= 3; # app cache
  my $ret = 0;

  if ($self->cache and exists($self->cache->{$cache_id})) {
    my $c = $self->cache->{$cache_id};
    my @keys = $c->get_keys();
    foreach my $k (@keys) {
      foreach my $m (@$args) {
        next unless $m;
        next if ($k !~ /$m/);
        $c->remove($k);
        $ret++;
        $meta->debug('p_c_rm: id %i, mask %s, key %s', $cache_id, $m, $k);
      }
    }
  }

  return { 'result' => { 'data' => $ret } };
}


#get_statistics($Clear)
#    Returns a two value list of (nreads, nreadhits). This only works if you passed enable_stats in the constructor
#    nreads is the total number of read attempts done on the cache since it was created
#    nreadhits is the total number of read attempts done on the cache since it was created that found the key/value in the cache
#    If $Clear is true, the values are reset immediately after they are retrieved

#----------------------------------------------------------------------
sub get_stats {
  my ($class, $self, $meta, $args) = @_;
  $meta->dump({ 'reset_mask' => $args });
  my $do_clear = shift @$args || 0;
  my @ids = @$args;
  @ids = keys %{$self->cache} unless (scalar(@ids));
  my $ret = {};
  foreach my $i (@ids) {
    my ($nreads, $nreadhits) = $self->cache->{$i}->get_statistics($do_clear);
    $ret->{$i} = { 'nreads' => $nreads, 'nreadhits' => $nreadhits};
  }
  return { 'result' => { 'data' => $ret } };
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