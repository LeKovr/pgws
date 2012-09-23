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

# PGWS::Plugin::Mailer - send mail

package PGWS::Plugin::System::Mailer;

use PGWS;
use PGWS::Utils;

use constant ROOT               => ($ENV{PGWS_ROOT} || '');   # PGWS root dir

use base qw(PGWS::Plugin);

use Data::Dumper;

use MIME::Base64;
use MIME::Entity;

sub new {
  my ($class, $self) = @_;
  $self ||= {};
  bless $self, $class;
  return $self;
}

#----------------------------------------------------------------------
sub mail_header_part_coder {
  my $t = encode_base64(win2koi(shift), '');
  chomp $t;
# '=?utf-8?Q?'
  return "=?koi8-r?B?" . $t . "?=";
}

#----------------------------------------------------------------------
my $exam = {
  'from' => {
    'name' => '',
    'email' => '',
  },
  'to' => {
    'name' => '',
    'email' => '',
  },
  'subject' => '',
  'copy' => '',
  'delay_file' => '',
  'src' => [{
      'ctype' => '',
      'path' => '',
      'content' => '',
    },{
      'ctype' => '',
      'path' => '',
      'content' => '',
    },
  ],
  'headers' => {
    'X-Mailer' => 'Tender.Pro mailer v2.1',
    'Return-Receipt-To' => '$args{-from}',
    'Disposition-Notification-To' => '$args{-from}',
    'X-TPro-Id' => '$args{-task_id} if ($args{-task_id})',
    'X-TPro-Class-Id' => '$args{-class_id} if ($args{-class_id})',
    'X-TPro-Class-Code' => '$args{-class_code} if ($args{-class_code})',
    'Message-Id' => '<tpro-66335.20120819233733@tender.pro>',
  },
};


# отправка письма
sub create {
  my ($self, $srv, $meta, $args) = @_;
  my $method = shift @$args; # название метода или его описание
  my $key = shift @$args || '';

  # Перекодируем FROM, TO, BCC
  foreach my $addr (qw(to from)) {
    $args->{$addr}{'name'}  =~ s/\'//g;
    my @pre_emails = split /,/, $args->{$addr}{'email'};
    my %saw;
    my @emails = grep(!$saw{$_}++, @pre_emails); # удалим повторы адресов (см Perl FAQ 5.4)
    foreach (@emails) {
      s/^\s+//; s/\s+$//;
      s/^([^<]*?)(<[^>]+>)$/&mail_header_part_coder($1)." ".$2/e;
      $_ = qq|"$_" <$_>| if $_ !~ /<[^>]+>/;
    }
    $args->{$addr}{'email'} = join ", ", @emails;
  }

  # Перекодируем SUBJECT
  my $orig_subj = $args->{'subject'};
  $args->{'subject'} = &mail_header_part_coder($args->{'subject'});

# TODO
my %args;
my $cfg;
  # Создаем письмо
  my %ent =
  (
    'To'       => $args->{'to'}{'name'},
    'Bcc'      => $args{-bcc},
    'From'     => $args{-from},
    'Subject'  => $args{-subject},
#    'X-Mailer' => 'Tender.Pro mailer v'.$VERSION,
  );
 #  'Return-Receipt-To:' => $args{-from},
 #   'Disposition-Notification-To:' => $args{-from},

  $ent{'X-TPro-Id'} = $args{-task_id} if ($args{-task_id});
  $ent{'X-TPro-Class-Id'} = $args{-class_id} if ($args{-class_id});
  $ent{'X-TPro-Class-Code'} = $args{-class_code} if ($args{-class_code});

  my $has_attach = (scalar($args->{'src'})>1);

  if ($has_attach)
  {
    $ent{'Type'} = 'multipart/mixed';
    $ent{'Encoding'} = '7bit';
  }
  else
  {
    $ent{'Type'} = $args{-ctype};
    $ent{'Encoding'} = 'quoted-printable';
    $ent{'Data'} = $args{-message};
    $ent{'Charset'} = 'windows-1251';
  }

  my $msg = MIME::Entity->build(%ent);

  if($has_attach)
  {
      $msg->attach(
        Type => $args{-ctype},
        Disposition => 'inline',
        Encoding => 'quoted-printable',
        Data => shift @{$args->{'src'}},
        Charset => 'windows-1251'
      );

    foreach my $att (@{$args->{'src'}})
    {
      my %attach = (
        Type => $att->{'ctype'},
        Disposition => 'attachment',
      );

      if(defined($att->{"path"})) {
        $attach{Encoding} = 'Base64';
        $attach{Path} = $att->{'path'};
        # $attach{Filename} = ''.fileparse($att->{'path'});
      } elsif(defined($att->{"content"})) {
        $attach{Encoding} = 'quoted-printable';
        $attach{Charset} = 'windows-1251';
        $attach{Data} = $att->{"content"};
      }
      if(defined($att->{"filename"})) {
        $attach{Filename} = $att->{"filename"};
      }

      $msg->attach(%attach);
    }
  }


#  if ($current_state eq 'WORK' || $current_state =~ /^TEST/)
#  {
    if ($args{-delay}) {
      my $dir = $cfg->value('mail_outgoing_path');
      TPro::Utils::check_path($dir);
      my $file = "$dir/$args{-delay}.eml";
      open my $F, '>', $file or PGWS::bye "Error creating file $file: ".$!;
      $msg->print($F) or PGWS::bye "Error writing file $file: ".$!;
      close $F;
    } else {
      my $mail = $cfg->value('mail_prog');
      open my $M, '|-', "$mail -t -oi -oem -f \"mail_m\@tender.pro\""
        or PGWS::bye "Error mailing to $mail: ".$!;
      $msg->print($M) or PGWS::bye "Error mailing to $mail: ".$!;
      close $M;
    }
#  }

  if ($args{-logging})
  {
    my $dir = $cfg->value('sys_log_path') . '/MAIL/';
    TPro::Utils::check_path($dir);
    my $tmp = new File::Temp( UNLINK => 0, SUFFIX => '.eml', DIR => $dir, template =>'out_XXXXXXXXXX' );
    $msg->print($tmp) or warn "Can't log mail to $tmp ($!)";
    #$msg->dump_skeleton($tmp) or warn "Can't log mail to $tmp ($!)";
  }
  return 1; # OK
}

1;
