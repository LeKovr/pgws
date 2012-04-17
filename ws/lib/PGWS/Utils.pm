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

# PGWS::Utils - utility functions

package PGWS::Utils;

use PGWS;
use JSON;

use Data::Dumper;

# Доступный извне номер версии
our $VERSION = $PGWS::VERSION;

#----------------------------------------------------------------------
## @fn hash data_load($config_file)
# Загрузить данные из файла в perl-структуру
# @return указатель на загруженную структуру данных
# TODO: загружать форматы, отличные от JSON
sub data_load {
  my $cfile = shift;
  open my $F, '<', $cfile or die "File: $cfile error:".$!;
  my @cdata=<$F>;
  close $F;
  my $json = new JSON;
  $json->relaxed(1);
  my $cfg = $json->decode(join '',@cdata);
  return $cfg;
}

#----------------------------------------------------------------------
sub json_out_utf8 {
  my $data = shift;
  my $is_pretty = shift;
  my $json = new JSON;
  my $ret = $is_pretty?$json->pretty->encode($data):$json->encode($data);
  utf8::decode($ret);
  return $ret;
}

#----------------------------------------------------------------------
sub json_out {
  my $perl_data = shift;
  my $json = new JSON;
  return $json->encode($perl_data);
}

#----------------------------------------------------------------------
sub json_in {
  my $json_text = shift;
  my $json = new JSON;
  my $flag = utf8::is_utf8($json_text);
  return $json->utf8(!$flag)->decode($json_text);
}

#----------------------------------------------------------------------
sub format_message {
  my ($str, @err) = @_;
  my $msg;
  if (scalar(@err)) {
    $msg = sprintf($str, map { defined($_)?$_:'undef' } @err);
  } elsif (! defined($str)) {
    $msg = 'undef';
  } elsif (ref \$str eq 'SCALAR') {
    $msg = $str;
  } else {
    $msg = Dumper($str);
  }
  return $msg;
}

#----------------------------------------------------------------------
#PGWS::Utils::uri_mk($req->prefix, $sid, @_)
sub uri_mk {
  my ($proto, $prefix, $sid, $name, $args, $anchor) = @_;

  my $s = $sid;
  if ($args) {
    $s = ($sid?$sid.'&':'').$args;
  }
  if ($s) {
    $s = ($name =~ /\?/)?$name.'&'.$s:$name.'?'.$s
  } else {
    $s = $name;
  }
  $s .= '#'.$anchor if ($anchor);
  if ($s =~ /^:/) {
    # задан хост
    return $proto.$s;
  } elsif ($s =~ /^\//) {
    # адрес от корня
    return $s;
  } else {
    # адрес внутри API
    $s = '/'.$s if ($s or !$prefix);
    return $prefix.$s;
  }

}

#----------------------------------------------------------------------
#PGWS::Utils::uri_mk($req->prefix, $sid, @_)
sub uri_mk_form {
  my ($u, $args) = split /\?/, uri_mk(@_);
  my $ret = {'action' => 'action="'.$u.'"' };
  if ($args) {
    my @a = map { sprintf '<input type="hidden" name="%s" value="%s">', split /=/  } split /&/,$args;
    $ret->{'args'} = join '',@a;
  }
  return $ret;
}

#----------------------------------------------------------------------
# $lang = PGWS::Utils::lang_mk($self->{'cfg'}{'tmpl'}{'lang'}, $lang, $session->{'lang'});
sub lang_mk {
  my ($def, $lang) = @_;
  if ($lang) {
    my $lang_allowed = join '|', @{$def->{'allowed'}};
    $lang = undef unless ($lang =~/^$lang_allowed$/);
  }
  return $lang;
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