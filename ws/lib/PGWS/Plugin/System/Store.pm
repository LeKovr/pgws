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

# PGWS::Plugin::System::Store - File storage methods

package PGWS::Plugin::System::Store;

use PGWS;
use PGWS::Utils;

use base qw(PGWS::Plugin);

use constant FILE_STORE_PATH        => ($ENV{PGWS_FILE_STORE_PATH} || '/tmp');
use constant FILE_GENERATED_PREFIX  => ($ENV{PGWS_FILE_GENERATED_PREFIX} || 'apidata' );

use Data::Dumper;
use XML::Simple;
#----------------------------------------------------------------------
# сохранение данных
# Пример вызова:
#   api('ws.store.set', class => 'tender', type => 'process', id => tender_id, data => res);
sub set {
  my ($pkg, $self, $meta, $args, $mtd_def) = @_;
  my ($path, $data) = (@$args);

  $meta->dump({ 'path'=> $path, 'data' => $data});
  my ($size, $csum) = PGWS::Utils::data_set($data, FILE_STORE_PATH.'/'.$path);

  return { 'result' => { 'data' => { 'path' => $path, 'size' => $size, 'csum' => $csum } } };
}

#----------------------------------------------------------------------
sub get {
  my ($pkg, $self, $meta, $args, $mtd_def) = @_;
  my ($path) = (@$args);
  my $data = PGWS::Utils::data_get(FILE_STORE_PATH.'/'.$path);
  $meta->dump({ 'path'=> $path, 'data' => $data});
  return { 'result' => { 'data' => $data } };
}

#----------------------------------------------------------------------
sub get64 {
  my ($pkg, $self, $meta, $args, $mtd_def) = @_;
  my ($path) = (@$args);
  my $data = PGWS::Utils::data_get(FILE_STORE_PATH.'/'.$path, {'encode' => 'base64'});
  $meta->dump({ 'path'=> $path, 'data' => $data});
  return { 'result' => { 'data' => $data } };
}

#----------------------------------------------------------------------
sub _space_array_node {
  my ($arr) = @_;
  foreach my $i (@$arr) {
    print "type ".ref($i)."\n";
    if (ref($i) eq 'HASH') {
      if (keys(%$i) == 0) {
        $i = "";
      }
      else {
        _space_hash_node($i);
      }
    }
    elsif (ref($i) eq 'ARRAY') {
      _space_array_node($i);
    }
  }
}

#----------------------------------------------------------------------
sub _space_hash_node {
  my ($node) = @_;
  while (my ($key, $value) = each(%$node)) {
    if (ref($value) eq 'HASH') {
      if (keys(%$value) == 0) {
        $node->{$key} = "";
      }
      else {
        _space_hash_node($value);
      }
    }
    elsif (ref($value) eq 'ARRAY') {
      _space_array_node($value);
    }
  }
}

#----------------------------------------------------------------------
sub get_formatted {
  my ($pkg, $self, $meta, $args, $mtd_def) = @_;
  my ($path, $format) = (@$args);
  my $data = PGWS::Utils::data_get(FILE_STORE_PATH.'/'.$path);
  $meta->dump({ 'path'=> $path, 'data' => $data});
  if ($format =~ /JSON/i) {
    my $json = new JSON;
    $json->relaxed(1);
    utf8::decode($data);
    $data = eval { $json->decode($data) };
    $data = {'errors' => [{'error_code' => 'Y0301', 'error_arg' => $@}]} if($@);
  }
  elsif ($format =~ /XML/i) {
    my $xml = XML::Simple->new();
    $data = eval { $xml->XMLin($data) };
    if ($@) {
      $data = {'errors' => [{'error_code' => 'Y0302', 'error_arg' => $@}]};
    }
    else {
      _space_hash_node($data);
    }
  }
  return { 'result' => { 'data' => $data } };
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
