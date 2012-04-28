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



package PGWS::MultiMarkdown;

use base qw(Text::MultiMarkdown);

use utf8;

# code from http://phpsuxx.blogspot.com/2007/09/perl.html
sub ts($) {
  my $z = shift;
  my %hs = ('аА'=>'a' , 'бБ'=>'b'  , 'вВ'=>'v'  , 'гГ'=>'g', 'дД'=>'d' ,
  'еЕ'=>'e' , 'ёЁ'=>'jo' , 'жЖ'=>'zh' , 'зЗ'=>'z', 'иИ'=>'i' ,
  'йЙ'=>'j' , 'кК'=>'k'  , 'лЛ'=>'l'  , 'мМ'=>'m', 'нН'=>'n' ,
  'оО'=>'o' , 'пП'=>'p'  , 'рР'=>'r'  , 'сС'=>'s', 'тТ'=>'t' ,
  'уУ'=>'u' , 'фФ'=>'f'  , 'хХ'=>'kh' , 'цЦ'=>'c', 'чЧ'=>'ch',
  'шШ'=>'sh', 'щЩ'=>'shh', 'ъЪ'=>''   , 'ыЫ'=>'y', 'ьЬ'=>''  ,
  'эЭ'=>'eh', 'юЮ'=>'ju' , 'яЯ'=>'ja', ' '=>'_', ',\.?/'=>'');
  map { $z =~ s|[$_]|$hs{$_}|gi; } keys %hs;
  $z;
}

sub _Header2Label {
    my ($self, $header) = @_;
    my $label = lc ts $header;
    $label =~ s/[^A-Za-z0-9:_.-]//g;        # Strip illegal characters
    while ($label =~ s/^[^A-Za-z]//g)
        {};     # Strip illegal leading characters
    return $label;
}

sub _GenerateHeader {
    my ($self, $level, $id) = @_;

    my $label = $self->{heading_ids} ? $self->_Header2Label($id) : '';
    my $header = $self->_RunSpanGamut($id);

    # TODO: добавлять в метку все уровни выше для уникальности
    $self->{'toc'} = [] unless exists($self->{toc});
    push @{$self->{'toc'}}, [$level, $label, $header];

    if ($label ne '') {
        $self->{_crossrefs}{$label} = "#$label";
        $self->{_titles}{$label} = $header;
        $label = qq{ id="$label"};
    }
    return "<h$level$label>$header</h$level>\n\n";
}

# Add the extra cross-references to headers that MultiMarkdown supports, and also
# the additional link attributes.
sub _GenerateAnchor {
    # FIXME - Fugly, change to named params?
    my ($self, $whole_match, $link_text, $link_id, $url, $title, $attributes) = @_;
    if (defined($url) and $url !~ /^#/) {
      if ($url =~ /^[^:]+:/) {
        $attributes = ' class="external"';
      } else {
        $title ||= 'Титул';
        $link_text ||= 'Некая локальная ссылка';
        printf STDERR "VVQ> %s = %s\n",$url,$self->{'base_url'};
        if ($url !~ m|^/|) {
          # относительная ссылка, добавить $self->{'base_url'}
          $url = '/'.$url if ($url);
          $url = $self->{'base_url'}.$url;
          # TODO: отработать вариант, когда url содержит "?arg=val"
        }
      }
    }
    # Allow automatic cross-references to headers
#    if (defined $link_id) {
    return $self->SUPER::_GenerateAnchor($whole_match, $link_text, $link_id, $url, $title, $attributes);
}

#----------------------------------------------------------------------
# метод перенесен без изменений
# будет удален после отладки подсветки синтаксиса на стороне клиента
sub _DoCodeBlocks {
#
# Process Markdown code blocks (indented with 4 spaces or 1 tab):
# * outdent the spaces/tab
# * encode <, >, & into HTML entities
# * escape Markdown special characters into MD5 hashes
# * trim leading and trailing newlines
#

    my ($self, $text) = @_;

     $text =~ s{
        (?:\n\n|\A)
        (                # $1 = the code block -- one or more lines, starting with a space/tab
          (?:
            (?:[ ]{$self->{tab_width}} | \t)   # Lines must start with a tab or a tab-width of spaces
            .*\n+
          )+
        )
        ((?=^[ ]{0,$self->{tab_width}}\S)|\Z)    # Lookahead for non-space at line-start, or end of doc
    }{
        my $codeblock = $1;
        my $result;  # return value
# TODO: подсветка, вывод имени файла с меткой и ссылка для скачивания
        $codeblock = $self->_EncodeCode($self->_Outdent($codeblock));
        $codeblock = $self->_Detab($codeblock);
        $codeblock =~ s/\A\n+//;  # trim leading newlines
        $codeblock =~ s/\n+\z//;  # trim trailing newlines
#print STDERR $codeblock;
#        $result = "\n\n<pre class='code'>" . $codeblock . "\n</pre>\n\n";
        $result = "\n\n<pre><code>" . $codeblock . "\n</code></pre>\n\n";

        $result;
    }egmx;

    return $text;
}

#
#       $self->{_crossrefs}{$label} = "#$label";
#        $self->{_titles}{$label} = $header;

1;

package PGWS::Plugin::Wiki;

use PGWS;
use PGWS::Utils;

use base qw(PGWS::Plugin);

use Data::Dumper;

#----------------------------------------------------------------------
sub _toc_link {
  my ($is_ol, $level, $label, $header) = @_;
  my $d="'";
  if ($header =~ /"/ and $header =~ /'/) {
    $header =~ s/'/"/g;
  } elsif ($header =~ /'/) {
    $d='"';
  }
  my $s = sprintf "%s%s [%s](#%s)", '  'x($level-1), ($is_ol?'1.':'*'), $header, $label;
  return $s;
}

#----------------------------------------------------------------------
sub internal_link {
  my ($uri, $link, $name) = @_;
  $name ||= $link;
  $link = "$uri/$link" if ($link !~ m|^[/#]|);
  return sprintf '<a class="local" href="%s">%s</a>', $link, $name;
}

#----------------------------------------------------------------------
sub format {
  my ($pkg, $self, $meta, $args) = @_;
  my ($uri, $code, $src, $extended, @extra) = (@$args);

  my $m = PGWS::MultiMarkdown->new(
    tab_width => 2,
    use_metadata => 1,
    strip_metadata => 1,
    base_url => $uri,
  );
  my $html = $m->markdown( $src );

  unless($extended) { # TODO: del "!"
    return { 'result' => { 'data' => {'html' => $html} }};
  }
  my $res = {
    'toc'   => $m->{'toc'},
    'title' => $m->{_metadata}{'Title'},
  };
  my $title = $m->{_metadata}{'Title'}?"<h1>$m->{_metadata}{'Title'}</h1>":'';
  if ($src =~ /\A([\s\S]+)\n<!--\s+CUT\s+-->/m) {
    $res->{'anno'} = $1;
  }

  my $toc = '';
  if ($m->{_metadata}{'TOC'} and $m->{'toc'}) {
    my $is_ol = (lc($m->{_metadata}{'TOC'}) eq 'ordered');
    my $toc_text = join "\n", map { _toc_link($is_ol, @{$_}) } @{$m->{'toc'}};
    $toc = $m->markdown($toc_text);
    $toc =~ s/^<(o|u)l/<$1l class="toc"/;
  }
  $res->{'html'} = $title.$toc.$html;

  my $ret = {};
  $ret->{'result'} = { 'data' => $res };
  return $ret;
}

#----------------------------------------------------------------------
sub save {
  my ($self, $srv, $meta, $args) = @_;
  my ($sid, $group_id, $uri, $code, $src, $id) = (@$args);

  my $fmt_args = [$uri, $code, $src, 1];
  my $ret = $self->format($srv, $meta, $fmt_args);

  my $tag;
  my @ids = ($sid);

  unless (defined($id)) {
    # create
    $tag = 'wiki.doc_create';
    push @ids, $group_id, $code ||'',
  } else {
    $tag = 'wiki.doc_update_src';
    push @ids, $id,
  }
  push @ids, map { $_ || '' } $ret->{'name'}, $ret->{'anno'}, $src;

  my $status = $srv->_call_meta($tag, $meta, @ids);
  return { 'result' => { 'data' => $status }};

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