#!/usr/bin/env perl
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
#
# PGWS cache control (dump/restore) script

use strict;
use warnings;

use lib qw(lib);

use PGWS;
use PGWS::Utils;

use Cache::FastMmap;
use Data::Dumper;

use JSON;

#----------------------------------------------------------------------
# config

my $cmd = shift || 'stat';       # command (save|load|stat)
my $tag = shift || '*';       # cache tag
my $dirtag = shift || '';    # directory prefix
my $enc = 'UtF-8';     # encoding (will be language)

#print "Got: $cmd, $tag. $dirtag\n";
#----------------------------------------------------------------------
# End of config

$enc = lc($enc);
my $dir = join '.', $dirtag, $tag, $enc;

my $json = new JSON;

my $DEBUG = 0;

#----------------------------------------------------------------------
# http://www.perlmonks.org/?node_id=759457
$Data::Dumper::Useqq = 1;

{ no warnings 'redefine';
    sub Data::Dumper::qquote {
        my $s = shift;
        return "'$s'";
    }
}

my $cfg;

#----------------------------------------------------------------------
sub load_cfg {
  my $file = shift;
  $file ||= 'conf/cache.json';
  $cfg ||= PGWS::Utils::data_load($file);
}

#----------------------------------------------------------------------
sub init {
  my $tag = shift;
  load_cfg() unless $cfg;
  my $c = $cfg->{$tag} or die sprintf 'Unrecognized cache tag (%s)', $tag;

  my $f = $c->{'share_file'};
  if ($f !~ /^\//) {
    $c->{'share_file'} = 'var/cache/'.$f;
  }
  my $new;

  -f $c->{'share_file'} or $new = 1;
  my $cache = Cache::FastMmap->new($c);
  chmod 0666, $c->{'share_file'} if $new;

  return $cache;
}

#----------------------------------------------------------------------
sub stats_line {
  my $tag = shift;
  my $c = init($tag);
  my $clear = 0;
  my ($nreads, $nreadhits) = $c->get_statistics($clear);
  my @keys = $c->get_keys();
  my $rows = scalar(@keys);
  printf "%-10s %10i %10i %10i %8.2f\n", $tag,$rows,$nreads, $nreadhits,$nreads?($nreadhits*100/$nreads):0;
}

#----------------------------------------------------------------------
sub stats {
  if ($tag eq '*') {
    load_cfg;
    printf "%-10s %10s %10s %10s %8s\n", qw(Tag Keys Reads Hits Ratio);
    stats_line($_) foreach sort keys %$cfg;
  } else {
    stats_line($tag);
  }
}

#----------------------------------------------------------------------
sub clear_line {
  my $tag = shift;
  my $c = init($tag);
  $c->clear;
}

#----------------------------------------------------------------------
sub clear {
  if ($tag eq '*') {
    load_cfg;
    clear_line($_) foreach sort keys %$cfg;
  } else {
    clear_line($tag);
  }
}

#----------------------------------------------------------------------
sub save {
  -d $dir || mkdir $dir || die "No access to dir $dir";
  printf 'Saving cache %s to dir %s...', $tag, $dir; 
  my $c = init($tag);
  my $defs = {};

  my @keys = $c->get_keys();
  foreach my $k (sort @keys) {
    my $value = $c->get($k);
    print Dumper($k, $value) if ($DEBUG);
    my $key = $json->utf8(0)->decode($k);
    next unless (lc(shift @$key) eq $enc);
    my $method = shift @$key; #$key->[1];
    my $def = [
      $key,
      $value,
      '-' x 40
    ];
    $defs->{$method} ||= [];
    push @{$defs->{$method}}, $def;
  }

  print '...';

  foreach my $method (keys %$defs) {
    print "\n\t$method",('.'x scalar(@{$defs->{$method}}));

    my $file = $dir.'/'.$method.'.json';
    open FILE, ">:utf8", $file or die "Cant open $file: ".$!;
    print FILE $json->pretty->encode($defs->{$method});
    close FILE;
  }
  print "\nDone\n"; 
}

#----------------------------------------------------------------------
sub load {
  -d $dir or die "No access to dir $dir";
  my $c = init($tag);
  printf 'Loading cache %s from dir %s...', $tag, $dir; 
  my $defs = {};

  my @elems = split /\./, $dir;
  my $enc = pop @elems;
  my @files = glob($dir.'/*.json');
  foreach my $file (@files) {
    my $method = $file;
    $method =~ s |^$dir/||;
    $method =~ s |\.json$||;

    print "\n\t$method";
    open FILE, "<:utf8", $file or die "Cant open $file: ".$!;
    my $json_text = '';
    while (<FILE>) { $json_text .= $_; }
    close FILE;
    my $defs = $json->utf8(0)->decode($json_text);
    foreach my $def (@$defs) {
      my ($prekey, $res, $delim) = @$def;
      unshift @$prekey, $method;
      unshift @$prekey, $enc;
      my $key = PGWS::Utils::json_out($prekey);

      print Dumper($key, $def) if ($DEBUG);
      
      $c->set($key, $res) or die 'ERROR: cache set fail for key '.$key;
      print '.';
    }
  }
  print "\nDone\n"; 
}

#----------------------------------------------------------------------
sub help {

print <<TEXT
Usage: $0 cmd tag DIR
  Where
    cmd - command (stat|load|save|clear)
    tag - cache tag from conf/cache.json
    DIR - directory for save/load

Example:
    pgws.sh cache save meta e11
    pgws.sh cache load meta e11
    pgws.sh cache stat meta 
TEXT
}

#----------------------------------------------------------------------
if ($cmd eq 'save') { save();
} elsif ($cmd eq 'load') { load();
} elsif ($cmd eq 'stat') { stats();
} elsif ($cmd eq 'clear') { clear();
} else { help(); exit(0);
}

1;
