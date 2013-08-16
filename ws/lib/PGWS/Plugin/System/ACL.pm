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

# PGWS::Plugin::System::ACL - ACL check plugin

package PGWS::Plugin::System::ACL;

use PGWS;
use PGWS::Utils;

use base qw(PGWS::Plugin);

#----------------------------------------------------------------------
# проверка наличия доступа.
# Результат;
# 0 - объект не найден
# undef - права отсутствуют
# иначе - список эффективных прав
sub check {
  my ($pkg, $self, $meta, $args) = @_;
  my ($sid, $class_id, $action_id, @ids_all) = (@$args);
  $meta->stage_in('acl');
  $meta->debug('class:%i, action:%i', $class_id, $action_id);

  # определить class.code и class.id_count
  my $class = $self->class_list->{$class_id};

  my @ids;
  my $res = {};
  # выбрать только те id, которые нужны для идентификации экземпляра
  if ($class->{'id_count'}) {
    for my $i (0..$class->{'id_count'} - 1) {
      my $id = shift @ids_all;
      unless (defined($id)) {
        # нет id => нет объекта
        $res->{'result'} = { 'data' => 0 };
        $meta->stage_out;
        return $res;
      }
      push @ids, $id;
    }
  }

  # получить статус экземпляра (class_status)
  my $tag = $class->{'code'}.$self->dbc->config('be.def_suffix.status');
  my $status_id = $self->_call_meta($tag, $meta, @ids);
  unless ($status_id) {
    # нет статуса => нет объекта
    $res->{'result'} = { 'data' => 0 };
    $meta->stage_out;
    return $res;
  }
  # получить список acl пользователя
  $tag = $class->{'code'}.$self->dbc->config('be.def_suffix.acl');
  my $acl = $self->_call_meta($tag, $meta, @ids, $sid);
  unless ($acl) {
    # нет acl вообще => не будет и acl_eff
    $meta->debug('No any object acl for %s(%s)', $tag, join(',', @ids, $sid));
    $res->{'result'} = { 'data' => undef };
    $meta->stage_out;
    return $res;
  }

  # по классу, статусу, акции и acl сессии получить эффективные acl (те, которые подходят текущей операции)
  my $acl_eff = $self->_call_meta($self->def_acl_eff, $meta, $class_id, $status_id, $action_id, $acl);

  $meta->debug('class:%i, status:%i, action:%i', $class_id, $status_id, $action_id);
  $meta->dump({ 'acl' => $acl, 'acl_eff' => $acl_eff });

  # вернуть список acl или undef
  if ($acl_eff) {
    $res->{'result'} = { 'data' => $acl_eff };
  } else {
    $res->{'result'} = { 'data' => undef };
  }
  $meta->stage_out;
  return $res;
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