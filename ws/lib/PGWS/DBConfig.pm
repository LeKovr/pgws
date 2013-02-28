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

# PGWS::DBConfig - DB & config access package

package PGWS::DBConfig;

use DBI;

use PGWS;
use PGWS::Utils;

use constant ROOT               => ($ENV{'PGWS_ROOT'} || '');               # PGWS root dir
use constant DB_CONNECT         => ($ENV{'PGWS_DB_CONNECT'});               # DB connect string

use constant PROCESS_PREFIX     => ($ENV{'PGWS_PROCESS_PREFIX'} || 'pgws'); # PGWS process prefix

use constant POGC               => 'db';                                    # Property Owner Group Code
use constant POID               => ($ENV{'PGWS_DB_POID'}        or 1);      # Property Owner ID

use constant LOG_CONNECT        => ($ENV{'PGWS_DB_LOG_CONNECT'});

use constant PROP_FUNC          => ($ENV{'PGWS_DB_PROP_FUNC'}   or 'cfg.prop_group_value_list(?, ?, ?, FALSE, NULL)');
use constant PROP_PREFIX        => ($ENV{'PGWS_DB_PROP_PREFIX'} or 'ws.daemon');

use constant SET_APPNAME        => ($ENV{'PGWS_DB_SET_APPNAME'} or 0);
use constant SQL_APPNAME        => ($ENV{'PGWS_DB_SQL_APPNAME'} or 'SET application_name = \'%s\'');

use constant SQL_SELECT_FORMAT  => 'SELECT * FROM %s';


use Data::Dumper;
#----------------------------------------------------------------------

#----------------------------------------------------------------------
sub new {
  my ($class, $self) = @_;
  $self ||= {};
  bless $self, $class;
  $self->init;
  return $self;
}

#----------------------------------------------------------------------
sub init {
  my $self = shift;

  my $dbh = $self->{'_dbh'};
  my $reconnect = ($dbh and !$dbh->ping);

  if (DB_CONNECT and (!$dbh or $reconnect)) {
    # load from DB
    $dbh = $self->_connect($reconnect);
  }

  return unless (defined($self->{'poid'}) and $self->{'poid'} ne '');

  # Подгрузить свойства, если задан POID
  if (DB_CONNECT) {
    $self->{'_conf'} = $self->config_from_db($dbh, $self->{'pogc'}, $self->{'poid'});
    PGWS::Utils::data_set($self->{'_conf'}, $self->dump_name($self->{'pogc'}, $self->{'poid'})) if ($self->{'data_set'});
  } else {
    # load from file
    my $file = $self->dump_name($self->{'pogc'}, $self->{'poid'});
    warn "WARNING!! No database but keep_db is set. Read config from $file\n" if($self->{'keep_db'});
    $self->{'_conf'} = PGWS::Utils::data_get($file);
  }
}

#----------------------------------------------------------------------
sub config_from_db {
  my ($self, $dbh, $pogc, $poid) = @_;

  my $sql = sprintf SQL_SELECT_FORMAT, PROP_FUNC;
  my $data = $dbh->selectall_arrayref($sql, undef, $pogc, $poid
  , ($self->{'prop_prefix'} || PROP_PREFIX)
  #, $self->{'cfg_prefix'} || ''
  );
  my $ret = PGWS::Utils::hashtree_mk($data);
  return $ret;
}

#----------------------------------------------------------------------
sub config {
  my $self = shift;
  return PGWS::Utils::hashtree_go($self->{'_conf'}, @_);
}

#----------------------------------------------------------------------
sub has_dbh {
  my $self = shift;
  $self->{'_dbh'}?1:0;
}

#----------------------------------------------------------------------
sub dbh {
  my $self = shift;
  my $read_only = shift;
  # TODO: return read-only handle if exists
  # TODO: restore connect if lost
  my $dbh = $self->{'_dbh'} or PGWS::bye "DB requested but does not attached";
  $dbh = $self->_connect(1) unless ($dbh->ping);
  return $dbh;
}

#----------------------------------------------------------------------
sub dump_name {
  my $self = shift;
  my $pogc = shift;
  my $poid = shift;
  return sprintf '%svar/conf/%s%s.json', ROOT, $pogc, ($poid == 1)?'':"-$poid";
}

#----------------------------------------------------------------------
sub proc_name {
  my $self = shift;
  return sprintf '%s-%s%s', PROCESS_PREFIX, $self->{'pogc'}, ($self->{'poid'} == 1)?'':"-$self->{'poid'}";
}

#----------------------------------------------------------------------
sub dump {
  my $self = shift;
  return PGWS::Utils::json_out_utf8($self->{'_conf'}, 1);
}

#----------------------------------------------------------------------
sub db_detach {
  my $self = shift;
  my $dbh = $self->{'_dbh'};
  $dbh->disconnect if ($dbh and $dbh->ping);
}

#----------------------------------------------------------------------
sub _connect {
  my ($self, $reconnect) = @_;
  my $dbh = DBI->connect(DB_CONNECT) or PGWS::bye $DBI::errstr;
  $dbh->{'pg_enable_utf8'} = 1;

  # own config
  my $conf_db = $self->config_from_db($dbh, POGC, POID);
  my $init = $conf_db->{'db'}{'sql'};

  push @$init, LOG_CONNECT                              if (LOG_CONNECT);
  push @$init, (sprintf SQL_APPNAME, $self->proc_name)  if (SET_APPNAME and $self->{'keep_db'});

  if ($conf_db->{'db'} and $conf_db->{'db'}{'sql'}) {
    foreach my $sql (@{$conf_db->{'db'}{'sql'}}) {
      $dbh->do($sql) or die $DBI::errstr;
    }
  }

  $self->{'_dbh'} = $dbh if ($self->{'keep_db'} or $reconnect);
  PGWS::Utils::data_set($conf_db, $self->dump_name(POGC, POID)) if ($self->{'data_set'} and !$reconnect);
  return $dbh;
}

#----------------------------------------------------------------------
sub _plugin_load{
  my ($plugin, $prop_prefix) = @_;
  my $lib = $plugin->{'lib'}; # may delete
  my $conf = {};
  if ($plugin->{'pogc'}) {
    $plugin->{'prop_prefix'} = $prop_prefix;
    my $pdbc = PGWS::DBConfig->new($plugin);
    $conf->{'dbc'} = $pdbc;
  }
  ## no critic
  eval "require $lib" or PGWS::bye "require lib ($lib) error: ".$!; # бывает, если зависимость недоступна т.к. @INC изменился при sudo
  ## use critic
  return $lib->new($conf);
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