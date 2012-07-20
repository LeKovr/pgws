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

use constant ROOT               => ($ENV{PGWS_ROOT} || '');   # PGWS root dir

use Cache::FastMmap;

use base qw(PGWS::Plugin);

use Data::Dumper;

sub new {
  my ($class, $self) = @_;
  $self ||= {};
  bless $self, $class;

  my $cache = $self->{'_caches'} = {};
  my $cache_list = $self->{'dbc'}->config;
  foreach my $id (keys %$cache_list) {
    my $def = $cache_list->{$id};
    next unless ($def and $def->{'is_active'});
    my $c = $def->{'code'};
    my $f = sprintf '%svar/cache/%s.pgws', ROOT, $c;
    $def->{'share_file'} = $f;
    $def->{'unlink_on_exit'} = 0;
    $cache->{$c} = Cache::FastMmap->new($def);
    chmod 0666, $f;
  }
  return $self;
}

#----------------------------------------------------------------------
sub cache_by_id {
  my ($self, $id) = @_;
  $id or PGWS::bye "Cache id required";
  my $def = $self->{'dbc'}->config($id) or PGWS::bye "Unknown cache id ".$id;
 # print STDERR 'PLUGIN2: ', $id,Dumper($def);

  return $self->{'_caches'}{$def->{'code'}};
}

#----------------------------------------------------------------------
# удалить из кэша метода $method все записи, содержащие в ключе $key
sub uncache {
  my ($self, $srv, $meta, $args) = @_;
  my $method = shift @$args; # название метода или его описание
  my $key = shift @$args || '';

  # получить описание метода
  my $mtd_def = $srv->_explain_def($method, $meta); # при ошибке будет die

  my $cache_id = $mtd_def->{'cache_id'};

  my $cache_def = $self->{'dbc'}->config($cache_id);
  my $cache_code = $cache_def->{'code'};

  my $removed = 0;
  if ($self->{'_caches'} and exists($self->{'_caches'}{$cache_code})) {
    my $c = $self->{'_caches'}{$cache_code};
    my @keys = $c->get_keys();
    my $mkey=',"'.$mtd_def->{'code'}.'",';
    foreach my $k (@keys) {
      my $i;
      if ($i = index($k, $mkey) > 0 and index($k, $key, $i) > 0) {
        # index не вернет 0 при успехе, т.к. $k - JSON и начинается с [
        $c->remove($k);
        $removed++;
      }
    }
    $meta->debug(
      'uncache method %s from cache %s with key %s removes %i rows'
      , $mtd_def->{'code'}, $cache_code, $key, $removed
    );
  }
  return { 'result' => { 'data' => $removed } };

}

#----------------------------------------------------------------------
sub reset {
  my ($self, $srv, $meta, $args) = @_;
  my $cache_id = shift @$args;

  my $ret = 0;
  my $key = PGWS::Utils::json_out($args);

  my $cache_def = $self->{'dbc'}->config($cache_id);
  my $cache_code = $cache_def->{'code'};

  if ($self->{'_caches'} and exists($self->{'_caches'}{$cache_code})) {
    $self->{'_caches'}{$cache_code}->remove($key);
    $ret = 1;
  }

  $meta->debug('p_c_l: id %i, key %s, ret %i', $cache_id, $key, $ret);
  return { 'result' => { 'data' => $ret } };
}

#----------------------------------------------------------------------
sub reset_mask {
  my ($self, $srv, $meta, $args) = @_;
  $meta->dump({ 'reset_mask' => $args });
  my $cache_id = shift @$args;
  $cache_id ||= 3; # app cache
  my $ret = 0;

  my $cache_def = $self->{'dbc'}->config($cache_id);
  my $cache_code = $cache_def->{'code'};

  if ($self->{'_caches'} and exists($self->{'_caches'}{$cache_code})) {
    my $c = $self->{'_caches'}{$cache_code};
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
  my ($self, $srv, $meta, $args) = @_;
  $meta->dump({ 'reset_mask' => $args });
  my $do_clear = shift @$args || 0;
  my @ids = @$args;
  @ids = keys %{$self->{'_caches'}} unless (scalar(@ids));
  my $ret = {};
  foreach my $i (@ids) {
    my ($nreads, $nreadhits) = $self->{'_caches'}{$i}->get_statistics($do_clear);
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