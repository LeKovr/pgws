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

# PGWS::Frontend::Apache - access from Apache mod_perl 1.3.

package PGWS::Frontend::Apache;

use PGWS;
use PGWS::Frontend;

use Apache::Request;
use Apache::Constants ':response';

# Доступный извне номер версии
our $VERSION = $PGWS::VERSION;

use constant COOKIE_MASK        => ($ENV{PGWS_FE_COOKIE_MASK});

# Хэш хост-объект для каждого серверного процесса
use constant APPS => {};

sub user_ip { $_[0]->{'user_ip'}  }
sub proto   { $_[0]->{'proto'}    }
sub type    { $_[0]->{'type'}     }
sub method  { $_[0]->{'method'}   }
sub uri     { $_[0]->{'uri'}      }
sub prefix  { $_[0]->{'prefix'}   }
sub accept  { $_[0]->{'accept'}   }
sub params  { $_[0]->{'params'}   }

#----------------------------------------------------------------------
## @fn hash data_load($config_file)
# Загрузить данные из файла в perl-структуру
# @return указатель на загруженную структуру данных
# TODO: загружать форматы, отличные от JSON
sub handler {
  my $r = shift;

  my $id = $ENV{'JAST_SITE'} || $r->hostname.':'.$r->get_server_port;
  my $apps = APPS;
  my $root = $ENV{'JAST_ROOT'} || $r->document_root().'/../../..';
  unless (exists($apps->{$id})) {
    $apps->{$id} = PGWS::Frontend->new({'root' => $root});
  }

  my $apr = $r; #Apache::Request->new($r);
  my $self = __PACKAGE__->new({'req' => $apr});

  $apps->{$id}->run($self);
}

#----------------------------------------------------------------------
sub new {
  my ($class, $self) = @_;
  bless $self, $class;
  my $r = $self->{'req'};

  $self->{'user_ip'} ||= $ENV{'HTTP_X_REAL_IP'} || $ENV{'HTTP_X_FORWARDED_FOR'} || $ENV{'REMOTE_ADDR'};
  $self->{'proto'} ||= $ENV{'HTTP_UT_HTTPS'}?'https':'http';
  $self->{'type'} ||=  $r->header_in('Content-type');
  $self->{'accept'} ||=  $r->header_in('Accept');
  $self->{'method'} ||= $r->method;
  $self->{'uri'} ||= $r->path_info || '/';

  $self->{'_q'} = new CGI::Simple;

  if ($self->{'method'} eq 'POST') {
    $self->{'params'} = $self->post_data;
  } elsif ($self->{'method'} eq 'GET') {
    $self->{'params'} = $self->get_data;
  }
  my $prefix = $r->location;
#  if ($ENV{'REQUEST_URI'} and $ENV{'REQUEST_URI'} =~ /^(.*)$self->{'uri'}/) {
#    $prefix = $1;
#  }
  $self->{'prefix'} ||= $prefix;
  $self->fetch_cook(COOKIE_MASK);

  return $self;
}

#----------------------------------------------------------------------
sub fetch_cook {
  my ($self, $mask) = @_;
  if ($mask and $ENV{'HTTP_COOKIE'} and $ENV{'HTTP_COOKIE'} =~ /$mask/) {
    $self->{'cookie'} = $1;
  }
}

#----------------------------------------------------------------------
sub fetch_ip {
  my $self = shift;
  my $r = shift;
  my $h = $r->headers_in;

#  $self->print_log(LL_DMP, 'Request Header:'.Dumper($h));
# $ENV{'HTTP_X_REAL_IP'} || $ENV{'HTTP_X_FORWARDED_FOR'} || $ENV{'REMOTE_ADDR'};
  my $ips = $r->header_in('X-Forwarded-For') or return;
  my @ips = split /,\s*/, $ips;
  return pop @ips;
}

#----------------------------------------------------------------------
sub post_data {
  my $self = shift;
  my $r = $self->{'req'};
  # code from http://cpansearch.perl.org/src/LYOKATO/OAuth-Lite-1.27/lib/OAuth/Lite/Server/mod_perl2.pm
  # sub request_body
  my $length = $r->headers_in->{'Content-Length'} || 0;
  my $body = "";
  while ($length) {
      $r->read( my $buffer, ($length < 8192) ? $length : 8192 );
      $length -= bytes::length($buffer);
      $body .= $buffer;
  }
  return $body;
}

#----------------------------------------------------------------------
sub get_data {
  my $self = shift;
  my $r = $self->{'req'};

  my %in = $r->args;
  return \%in;
}

#----------------------------------------------------------------------
sub attrs {
  my $self = shift;
  my %params;
  foreach my $n (qw(proto accept user_ip cookie uri type method prefix)) {
    $params{$n} = $self->{$n};
  }
  return \%params;
}
#----------------------------------------------------------------------
sub header {
  my ($self, $ctype, $status) = @_;
  my $r = $self->{'req'};
  $r->status_line( $status);
  $r->send_http_header($ctype);
}

#----------------------------------------------------------------------
sub print {
  my $self = shift;
  my $r = $self->{'req'};
  $r->print(@_);
}

#----------------------------------------------------------------------
sub redirect {
  my $self = shift;
  my $r = $self->{'req'};
  $r->header_out(Location => shift);
  $r->status(REDIRECT);
  return REDIRECT;
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