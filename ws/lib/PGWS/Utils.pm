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

use File::Basename;
use File::Path;

use Data::Dumper;

#----------------------------------------------------------------------
## @fn hash data_get($config_file)
# Загрузить данные из файла в perl-структуру
# @return указатель на загруженную структуру данных
# TODO: загружать форматы, отличные от JSON
sub data_get {
  my $path = shift;
  my $out = ($path =~ /\.gz$/)?'| gzip >':'>';
  my $mode = '<';
  if ($path =~ /\.gz$/) {
    $mode = '-|';
    $path = 'gunzip - < '.$path;
  }
  open my $F, $mode, $path or PGWS::bye "File: $path error:".$!;
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
  my $ret = to_json($data, {pretty => $is_pretty});
#$is_pretty ? $json->pretty->encode($data) : $json->encode($data);
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
sub check_path {
  my $path = shift;
  my($filename, $dir, $suffix) = fileparse($path);
  unless (-d $dir) {
    my $u = umask 0;
    eval { mkpath($dir) };
    umask $u;
    if ($@) {
      PGWS::bye "Path $dir create error: ".$@;
    }
  }
  -w $dir or PGWS::bye "$dir does not allow write";
}

#----------------------------------------------------------------------
sub load_env {
  my $cfile = shift;
  my $data = PGWS::Utils::data_get($cfile);
  my $cfg = $data->{'ACTIVE'};
  $cfg->{'root'} = $ENV{'PWD'}.'/';
  foreach my $key (keys %$cfg) {
    $ENV{'PGWS_'.uc($key)} = $cfg->{$key};
  }
}

#----------------------------------------------------------------------
sub data_set {
  my ($data, $path, $do_gzip) = @_;
  check_path($path);
  my $mode = '>';
  if ($path =~ /\.gz$/) {
    $mode = '|-';
    $path = 'gzip - > '.$path;
  }
  open my $F, $mode, $path or PGWS::bye "File: $path error:".$!;
  print $F json_out_utf8($data, 1);
  close $F;
  my $mod = "0666";
  chmod oct($mod), $path;
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

#----------------------------------------------------------------------
## @method retval hashtree_mk($list)
# Конвертация массива пар <имя>,<значение> в дерево.
# Поле <имя> имеет вид "тег(.тег){}"
# Если тег числовой, в дерево добавляется массив. Иначе - хэш
# Примеры:
#   "тег1.тег2.цифра1" сохраняется в $res->{тег1}{тег2}[цифра1]
#   "тег1.цифра1.тег2.цифра2.тег3" сохраняется в $res->{тег1}[цифра1]{тег2}[цифра2]{тег3}
sub hashtree_mk {
  my $list = shift;
  my $tree = {};
  foreach my $row (sort @$list) {
    my ($key, $value) = @$row;
    my @tags = split /\./, $key;
    my ($node, $tree_used);
    foreach my $tag (@tags) {
      if ($tree_used and $tag =~ /^\d+$/) {
        $node ||= \[];
        $node = \$$node->[$tag]
      } else {
        if (!$tree_used) { $node = \$tree; $tree_used=1; } else { $node ||= \{}; }
        $node = \$$node->{$tag}
      }
    }
    $$node = $value;
  }
  return $tree;
}

#----------------------------------------------------------------------
sub hashtree_go {
  my $tree = shift;
  my $key = shift;
  return $tree unless $key;
  my @tags = split /\./, $key;
  my $node = $tree;
  my $walked = '';
  foreach my $tag (@tags, @_) {
    if ($walked and $tag =~ /^\d+$/) {
        $node = $node->[$tag];
    } else {
        $node = $node->{$tag};
    }
    defined($node) or PGWS::bye "Tree node $walked.$tag does not exists";
    $walked .= ".$tag";
  }
  return $node;
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