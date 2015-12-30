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

# PGWS::Proxy - SOAP proxy

sub SOAP::Serializer::as_nonil
{
    my ($self, $value, $name, $type, $attr) = @_;
    delete $attr->{'xsi:nil'};
    return [ $name, $attr, $value ];
}

package PGWS::Proxy;

use PGWS;
use Data::Dumper;

use vars qw(@ISA);
@ISA = qw(SOAP::Server::Parameters);

# Доступный извне номер версии
our $VERSION = $PGWS::VERSION;

#----------------------------------------------------------------------
our $AUTOLOAD;

sub ws    { $_[0]->{'ws'} }
sub meta  { $_[0]->{'meta'} }
sub class { $_[0]->{'class'} }
sub req   { $_[0]->{'req'} }

#----------------------------------------------------------------------
sub new {
  my ($class, $cfg) = @_;
  my $self = $cfg ? { %{$cfg} } : {};
  bless $self, $class;

  $self->init;
  return $self;
}

#----------------------------------------------------------------------
sub init {
  my $self = shift;

  $self->{'def'} = {}; # сброс всех описаний методов
}


#----------------------------------------------------------------------
sub AUTOLOAD {
  my $self = shift;
  my $args = shift;
  my $name = $AUTOLOAD;
  return if $name =~ /^.*::[A-Z]+$/;
 
  my $envelope = pop;
 # my $str = $envelope->dataof("//echo/whatToEcho")->value;
 # return SOAP::Data->name("whatWasEchoed" => "");

  print STDERR 'ARGS:',$name, Dumper(\@_,$args);
  my $class = $self->class;
  $class =~ m|[:/](\w+)$| and $class = $1;
  my $method = $name;
  $method =~ s/PGWS::Proxy:://;
  $method =~ s/([A-Z])/'_'.$1/ge;
  my $call = {
    'sid' => delete $args->{'token'},
    'params' => exists $args->{'Data'} ? 
      $args->{'Data'} : exists $args->{'data'} ? $args->{'data'} : $args,
    'method' => lc("$class.$method"),
  };
  if ( exists($call->{'params'}{'items'}) ) {
    # items - зарезервированное имя аргумента для передачи массивов
    if (ref $call->{'params'}{'items'} eq 'ARRAY'
    and ref $call->{'params'}{'items'}[0] eq 'HASH'
    ) {
      # массив хешей - конвертируем в хэш массивов
      my $a = delete $call->{'params'}{'items'};
      foreach my $item (@$a) {
        foreach my $key (keys %$item) {
          $call->{'params'}{$key} = [] unless (defined $call->{'params'}{$key});
          push @{$call->{'params'}{$key}}, $item->{$key};
        }
      }
    } elsif (ref $call->{'params'}{'items'} eq 'HASH') {
      # хэш - конвертируем в массивы из одного элемента
      my $a = delete $call->{'params'}{'items'};
      foreach my $key (keys %$a) {
        $call->{'params'}{$key} = [] unless (defined $call->{'params'}{$key});
        push @{$call->{'params'}{$key}}, $a->{$key};
      }
    } else {
      # ничего не делаем - считаем items обычным аргументом
    }
  }
  print STDERR 'CALL:',Dumper($call);  
  my $ret = $self->ws->run_parsed($self->meta, $call);

  print STDERR 'RET:',Dumper($method,$ret);  
  if ($ret->{'error'}) {
    die SOAP::Fault
      ->faultcode($ret->{'error'}{'code'}) # will be qualified
      ->faultstring($ret->{'error'}{'message'})
    ;
  } elsif ($ret->{'success'} ne 'true') {
    # app error(s)
    my $e = $ret->{'result'}{'error'}[0]; # use first
    die SOAP::Fault
      ->faultcode($e->{'code'}) # will be qualified
      ->faultstring($e->{'message'})
    ;
  } else {
    my $x = $ret->{'result'}{'data'};
    if ($method eq 'login') {
      return SOAP::Data->name( 
        "Result" => \SOAP::Data->value(
          SOAP::Data->name( "sid" => $x->{'sid'} )->type('string'),
          SOAP::Data->name( "company_id" => $x->{'company_id'} )->type('int'),
          SOAP::Data->name( "face_id" => $x->{'face_id'} )->type('int'),
          SOAP::Data->name( "company_title" => $x->{'company_title'} )->type('string'),
          SOAP::Data->name( "face_name" => $x->{'face_name'} )->type('string'),
        )
      );
 #   return SOAP::Data->value($x); #SOAP::Data->type('tns:loginResponse')->name('loginResponse')->root(1);
    } elsif ($method eq 'logout') {
      return SOAP::Data->name("Result")->value($x)->type('boolean');
    } elsif ($method =~ /^get_/ and ref $x eq 'ARRAY') {
      my @a;
      foreach my $i (@$x) {
        my @b;
        foreach my $k (sort keys %$i) {
          my $v = $i->{$k};
          if ($v and $v =~/[^\d\.]/) {
              push @b, SOAP::Data->name( $k => $i->{$k} )->type('string')
   #         } elsif (!defined($v)) {
   #           push @b, SOAP::Data->name( $k => $i->{$k} )->type('nonil')             
            } else {
              push @b, SOAP::Data->name( $k => $i->{$k} )
            }
        }
        push @a, \SOAP::Data->value(@b)
      }
      return SOAP::Data->name( 
        "Result" => \@a
      #  \SOAP::Data->value(
      #  "Result" => \SOAP::Data->value(
      #        SOAP::Data->name("someArrayItem" => @array)
      #                  ->type("SomeObject"))
      #    \@a)
      ); #->type("tns:offerAttr") ;


#SOAP::Data->name("someArray" => \SOAP::Data->value(
#              SOAP::Data->name("someArrayItem" => @array)
#                        ->type("SomeObject"))
#                   )->type("ArrayOf_SomeObject") ))
    } else {
      return SOAP::Data->name( "Result" => $x );
    }
#    return SOAP::Data->name(%{$ret->{'result'}{'data'}});
  }

}

1;
