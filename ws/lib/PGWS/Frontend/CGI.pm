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

# PGWS::Frontend::CGI - access from CGI and FastCGI

package PGWS::Frontend::CGI;

use PGWS;
use PGWS::Frontend;

use CGI::Simple;

# Доступный извне номер версии
our $VERSION = $PGWS::VERSION;

#----------------------------------------------------------------------
# Apache::Registry support
our $frontend;

# DIE handling
my $S;
#----------------------------------------------------------------------

#use CGI::Carp qw(set_die_handler);
#BEGIN {
#  sub handle_errors {
#     return redirect($S, $S->{'error_500'}) if ($S and $S->{'error_500'});
#    my $msg = shift;
#    print "content-type: text/html\n\n";
#    print "<h1>SERVER ERROR</h1>";
#    print "<p>Got an error: $msg</p>";
#  }
 # set_die_handler(\&handle_errors);
#}

use constant COOKIE_MASK        => ($ENV{PGWS_FE_COOKIE_MASK});

#----------------------------------------------------------------------
sub user_ip { $_[0]->{'user_ip'}  }
sub proto   { $_[0]->{'proto'}    }
sub type    { $_[0]->{'type'}     }
sub method  { $_[0]->{'method'}   }
sub uri     { $_[0]->{'uri'}      }
sub prefix  { $_[0]->{'prefix'}   }
sub accept  { $_[0]->{'accept'}   }
sub cookie  { $_[0]->{'cookie'}   }
sub params  { $_[0]->{'params'}   }

#----------------------------------------------------------------------

#    $CGI::Simple::POST_MAX = 1024;       # max upload via post default 100kB
#    $CGI::Simple::DISABLE_UPLOADS = 0;   # enable uploads
$CGI::Simple::PARAM_UTF8 = 1;

use Data::Dumper;
#----------------------------------------------------------------------
sub new {
  my ($class, $self) = @_;
  $self ||= {};
  bless $self, $class;
  # TODO: валидировать внешние ip, привязывать к сессии весь список
  # TODO: (передача клиентским прокси внутреннего ип увеличит безопасность)
  # TODO: для login использовать только один ip [proxy] клиента
  my $ip = $ENV{'HTTP_X_FORWARDED_FOR'};
  if ($ip and $ip =~ /(\S+)$/) { $ip = $1 }
  $self->{'user_ip'} ||= $ENV{'HTTP_X_REAL_IP'} || $ip || $ENV{'REMOTE_ADDR'};
  $self->{'proto'} ||= $ENV{'HTTP_UT_HTTPS'}?'https':'http';
  $self->{'type'} ||= $ENV{'CONTENT_TYPE'};
  $self->{'method'} ||= $ENV{'REQUEST_METHOD'};
  $self->{'accept'} ||= $ENV{'HTTP_ACCEPT'} || '';
  $S = $self;

  $self->{'encode_utf'} = $ENV{'FCGI_ROLE'}?1:0;

  if ($self->{'method'} eq 'JOB') {
    delete $ENV{'REQUEST_METHOD'};
    delete $ENV{'FCGI_ROLE'};
    $self->{'prefix'} = delete $ENV{'REQUEST_PKG'};
    $self->{'uri'}    = delete $ENV{'REQUEST_CODE'};
    $self->{'params'} = \%ENV;
    binmode(STDOUT, ':encoding(utf8)');
    return $self;
  }

  $self->{'_q'} = new CGI::Simple;

  if ($self->{'method'} eq 'POST' and $self->type =~ /application\/json/) {
    $self->{'params'} = $self->{'_q'}->param('POSTDATA'); # TODO: POST_MAX
  } else { #if ($self->{'method'} eq 'GET') {
    my %params;
    my @names = $self->{'_q'}->param();
    foreach my $n (@names) {
      my @values = $self->{'_q'}->param($n);
      if (scalar(@values) > 1) {
        $params{$n} = \@values;
      } else {
        $params{$n} = $values[0];
      }
    }
    $self->{'params'} = \%params;
  }

  my $uri = $self->{'uri'} || $ENV{'PATH_INFO'} || $ENV{'REDIRECT_PINFO'} || '';
  my $uri_full = $ENV{'REDIRECT_URL'};
  my $prefix = '';
  my $i = rindex($uri_full, $uri);
  if ($uri_full and $i > 0 ) {
    $prefix = substr($uri_full, 0, $i);
  }
  $uri =~ s |^/||;
  $self->{'uri'} = $uri;
  $self->{'prefix'} ||= $prefix;


  $self->{'cookie'} = $self->fetch_cook(COOKIE_MASK);

  return $self;
}

#----------------------------------------------------------------------
sub fetch_cook {
  my ($self, $mask) = @_;
  if ($mask and $ENV{'HTTP_COOKIE'} and $ENV{'HTTP_COOKIE'} =~ /(^| )$mask(;|$)/) {
    return $2;
  }
  return undef;
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
  my $self = shift;

  if ($ENV{'HTTP_ORIGIN'}) {
    print $self->{'_q'}->header(
      -type => $_[0],
      -Access_Control_Allow_Credentials => 'true',
      -Access_Control_Allow_Origin => $ENV{'HTTP_ORIGIN'}
    );
  } else {
    print $self->{'_q'}->header(@_);
  }
  if ($_[0] =~ /utf-8/ and !$self->{'encode_utf'}) { # and $_[0] =~ /plain/) {
    binmode(STDOUT, ':encoding(utf8)');
  }
#print STDERR "$_ = $ENV{$_}<br>\n" foreach sort keys %ENV;
}

#----------------------------------------------------------------------
sub options_header {
  my $self = shift;

  # http://metajack.im/2010/01/19/crossdomain-ajax-for-xmpp-http-binding-made-easy/
  print $self->{'_q'}->header(
    -Access_Control_Allow_Origin => '*',
    -Access_Control_Allow_Methods => 'GET, POST, OPTIONS',
    -Access_Control_Allow_Headers => 'x-requested-with'
  );

#HTTP_ACCESS_CONTROL_REQUEST_HEADERS' => 'x-requested-with',
#'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'POST',

# Access-Control-Max-Age: 86400
}

#----------------------------------------------------------------------
sub print {
  my $self = shift;
  if ($self->{'encode_utf'}) {
    map { utf8::encode($_); print $_;} @_;
  } else {
    print @_;
  }
}

#----------------------------------------------------------------------
sub redirect {
  my $self = shift;
  my $r = $self->{'req'};
  my $u=shift;
  my $p=($u =~ m|^/|)?'':$self->{'prefix'}.'/';
  print $self->{'_q'}->redirect("$p$u");
}

#----------------------------------------------------------------------
sub send_file {
  my ($self, $file_def) = @_;
  my $name = $file_def->{'name'};
  utf8::encode($name);
  print $self->{'_q'}->header(
    -type => $file_def->{'ctype'},
    -attachment => $name,
#    -Content_Disposition => $name,
    -X_Accel_Redirect => $file_def->{'path'}
  );
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