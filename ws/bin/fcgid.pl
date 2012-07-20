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
# fcgid.pl - FastCGI daemon

use lib $ENV{'PWD'}.'/lib'; # fix for require.  TODO: use Module::Pluggable

use PGWS;
use PGWS::Daemon;
use PGWS::Frontend;
use PGWS::Frontend::CGI;

use constant POGC     => 'fcgi';                      # Property Owner Group Code
use constant POID     => ($ENV{PGWS_FCGI_POID} or 1); # Property Owner ID
use constant SOCKET   => ($ENV{PGWS_FCGI_SOCKET} or 'back.test.local:9001');    # socket nginx forward to
#----------------------------------------------------------------------
$| = 1;

my $daemon = PGWS::Daemon->new({
  'pogc' => POGC
, 'poid' => POID
, 'socket' => SOCKET
, 'mgr_init' => \&init
, 'proc_loop' => \&proc_loop
});
$daemon->run(shift);

#----------------------------------------------------------------------
# init manager
sub init {
  my ($self, $proc_manager) = @_;

  my $cfg = $self->mgr_dbc->config('fcgi');
#  $proc_manager->{'frontend'} = PGWS::Frontend->new($cfg);
  $self->{'frontend'} = PGWS::Frontend->new($cfg);
}

#----------------------------------------------------------------------
sub proc_loop {
  my ($self, $proc_manager, $req_env) = @_;
  local @ENV{keys %$req_env}=values %$req_env;
  my $req = PGWS::Frontend::CGI->new();
#  $proc_manager->{'frontend'}->run($req);
  $self->{'frontend'}->run($req);
}

1;