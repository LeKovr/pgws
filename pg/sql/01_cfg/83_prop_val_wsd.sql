/*

    Copyright (c) 2010, 2012 Tender.Pro http://tender.pro.

    This file is part of PGWS - Postgresql WebServices.

    PGWS is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    PGWS is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with PGWS.  If not, see <http://www.gnu.org/licenses/>.

    Реестр свойств.
*/

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.pkg_script_protected (pkg, code, ver) VALUES (:'PKG', :'FILE', :'VER');

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.prop_value (pogc, poid, code,      value) VALUES
  ('db',    1,  'ws.daemon.db.sql.0',                   $_$SET datestyle TO 'German'$_$)
, ('db',    1,  'ws.daemon.db.sql.1',                   $_$SET time zone local$_$)
, ('fcgi',  1,  'ws.daemon.startup.sock_wait',          NULL)

-- , ('fe',    1,  'ws.daemon.fe.tmpl.layout_default',     'style01')
, ('fe',    1,  'ws.daemon.lang.allowed.0',             'ru')
, ('fe',    1,  'ws.daemon.lang.allowed.1',             'en')

, ('be',    1,  'ws.daemon.lang.allowed.0',             'ru')
, ('be',    1,  'ws.daemon.lang.allowed.1',             'en')

, ('fe',    1,  'ws.daemon.fe.tt2.ENCODING',            'utf-8')
, ('fe',    1,  'ws.daemon.fe.tt2.CACHE_SIZE',          '100')
, ('fe',    1,  'ws.daemon.fe.tt2.COMPILE_EXT',         '.pm')
, ('fe',    1,  'ws.daemon.fe.tt2.EVAL_PERL',           '0')
, ('fe',    1,  'ws.daemon.fe.tt2.PRE_CHOMP',           '1')
, ('fe',    1,  'ws.daemon.fe.tt2.POST_CHOMP',          '1')
, ('fe',    1,  'ws.daemon.fe.tt2.PLUGIN_BASE',         'PGWS::TT2::Plugin')

, ('fe',    1,  'ws.daemon.fe.post./pwl',               '/pwl')
, ('fe',    1,  'ws.daemon.fe.post./api',               '/api')
, ('fe',    1,  'ws.daemon.fe.post./api_cgi',           '/cgi-bin/pwl.pl')

, ('be',    1,  'ws.daemon.log.syslog.default.default', NULL)
, ('be',    1,  'ws.daemon.log.syslog.default.init',    NULL)
, ('be',    1,  'ws.daemon.log.syslog.default.cache',   NULL)

, ('fe',    1,  'ws.daemon.log.debug.default.default',  NULL)
, ('fe',    1,  'ws.daemon.log.debug.default.call',     NULL)
, ('fe',    1,  'ws.daemon.log.debug.default.sid',      NULL)
, ('fe',    1,  'ws.daemon.log.debug.default.acl',      NULL)
, ('fe',    1,  'ws.daemon.log.debug.default.cache',    NULL)
, ('fe',    1,  'ws.daemon.log.debug.default.validate', NULL)

, ('fe',    1,  'ws.daemon.log.debug.post.default',     NULL)
, ('fe',    1,  'ws.daemon.log.debug.post.call',        NULL)
, ('fe',    1,  'ws.daemon.log.debug.post.sid',         NULL)
, ('fe',    1,  'ws.daemon.log.debug.post.acl',         NULL)
, ('fe',    1,  'ws.daemon.log.debug.post.cache',       NULL)
, ('fe',    1,  'ws.daemon.log.debug.post.validate',    NULL)

, ('fe',    1,  'ws.daemon.log.debug.get.default',      NULL)
, ('fe',    1,  'ws.daemon.log.debug.get.call',         NULL)
, ('fe',    1,  'ws.daemon.log.debug.get.sid',          NULL)
, ('fe',    1,  'ws.daemon.log.debug.get.acl',          NULL)
, ('fe',    1,  'ws.daemon.log.debug.get.cache',        NULL)
, ('fe',    1,  'ws.daemon.log.debug.get.validate',     NULL)

, ('fe',    1,  'ws.daemon.log.debug.tmpl.default',     5)
, ('fe',    1,  'ws.daemon.log.debug.tmpl.call',        NULL)
, ('fe',    1,  'ws.daemon.log.debug.tmpl.sid',         NULL)
, ('fe',    1,  'ws.daemon.log.debug.tmpl.acl',         NULL)
, ('fe',    1,  'ws.daemon.log.debug.tmpl.cache',       NULL)
, ('fe',    1,  'ws.daemon.log.debug.tmpl.validate',    NULL)

, ('fe',    1,  'ws.daemon.log.syslog.default.default', NULL)
, ('fe',    1,  'ws.daemon.log.syslog.default.call',    NULL)
, ('fe',    1,  'ws.daemon.log.syslog.default.sid',     NULL)
, ('fe',    1,  'ws.daemon.log.syslog.default.acl',     NULL)
, ('fe',    1,  'ws.daemon.log.syslog.default.cache',   NULL)
, ('fe',    1,  'ws.daemon.log.syslog.default.validate',NULL)

, ('fe',    1,  'ws.daemon.log.syslog.post.default',    NULL)
, ('fe',    1,  'ws.daemon.log.syslog.post.call',       NULL)
, ('fe',    1,  'ws.daemon.log.syslog.post.sid',        NULL)
, ('fe',    1,  'ws.daemon.log.syslog.post.acl',        NULL)
, ('fe',    1,  'ws.daemon.log.syslog.post.cache',      NULL)
, ('fe',    1,  'ws.daemon.log.syslog.post.validate',   NULL)

, ('fe',    1,  'ws.daemon.log.syslog.get.default',     5)  -- запросы до вызова шаблона tt2
, ('fe',    1,  'ws.daemon.log.syslog.get.call',        NULL)
, ('fe',    1,  'ws.daemon.log.syslog.get.sid',         NULL)
, ('fe',    1,  'ws.daemon.log.syslog.get.acl',         NULL)
, ('fe',    1,  'ws.daemon.log.syslog.get.cache',       NULL)
, ('fe',    1,  'ws.daemon.log.syslog.get.validate',    NULL)

, ('fe',    1,  'ws.daemon.log.syslog.tmpl.default',    5)  -- запросы во время вызова шаблона tt2
, ('fe',    1,  'ws.daemon.log.syslog.tmpl.call',       NULL)
, ('fe',    1,  'ws.daemon.log.syslog.tmpl.sid',        NULL)
, ('fe',    1,  'ws.daemon.log.syslog.tmpl.acl',        NULL)
, ('fe',    1,  'ws.daemon.log.syslog.tmpl.cache',      NULL)
, ('fe',    1,  'ws.daemon.log.syslog.tmpl.validate',   NULL)

, ('tm',    1,  'ws.daemon.mgr.listen.job',             'jq_event')
, ('tm',    1,  'ws.daemon.mgr.listen_wait',            '300')
, ('tm',    1,  'ws.daemon.startup.pm.n_processes',     '1')

, ('be',    1,  'ws.daemon.be.error.bad_json.code',     '-32700')
, ('be',    1,  'ws.daemon.be.error.bad_json.message',  'Parse error')
, ('be',    1,  'ws.daemon.be.error.bad_json.data',     'Invalid JSON was received by the server.')

, ('be',    1,  'ws.daemon.be.error.bad_req.code',      '-32600')
, ('be',    1,  'ws.daemon.be.error.bad_req.message',   'Invalid Request')
, ('be',    1,  'ws.daemon.be.error.bad_req.data',      'The JSON sent is not a valid Request object.')

, ('be',    1,  'ws.daemon.be.error.no_mtd.code',       '-32601')
, ('be',    1,  'ws.daemon.be.error.no_mtd.message',    'Method not found')
, ('be',    1,  'ws.daemon.be.error.no_mtd.data',       'The method does not exist / is not available.')

, ('be',    1,  'ws.daemon.be.error.bad_args.code',     '-32602')
, ('be',    1,  'ws.daemon.be.error.bad_args.message',  'Invalid params')
, ('be',    1,  'ws.daemon.be.error.bad_args.data',     'Invalid method parameter(s).')

, ('be',    1,  'ws.daemon.be.error.int_err.code',      '-32603')
, ('be',    1,  'ws.daemon.be.error.int_err.message',   'Internal error')
, ('be',    1,  'ws.daemon.be.error.int_err.data',      'Internal JSON-RPC error.')

, ('be',    1,  'ws.daemon.be.error.no_data.code',      '-32001')
, ('be',    1,  'ws.daemon.be.error.no_data.message',   'Empty request')
, ('be',    1,  'ws.daemon.be.error.no_data.data',      'The request contains no data')
, ('be',    1,  'ws.daemon.be.error.srv_error.code',    '-32002')
, ('be',    1,  'ws.daemon.be.error.srv_error.message', 'Server error')
, ('be',    1,  'ws.daemon.be.error.srv_error.data',    'Unhandled server error')
, ('be',    1,  'ws.daemon.be.error.db_error.code',     '-32003')
, ('be',    1,  'ws.daemon.be.error.db_error.message',  'DB error')
, ('be',    1,  'ws.daemon.be.error.db_error.data',     'Unhandled database error')
, ('be',    1,  'ws.daemon.be.error.pl_error.code',     '-32004')
, ('be',    1,  'ws.daemon.be.error.pl_error.message',  'Plugin error')
, ('be',    1,  'ws.daemon.be.error.pl_error.data',     'Unhandled plugin error')
, ('be',    1,  'ws.daemon.be.error.bad_sid.code',      '-32005')
, ('be',    1,  'ws.daemon.be.error.bad_sid.message',   'SID error')
, ('be',    1,  'ws.daemon.be.error.bad_sid.data',      'Incorrect SID value')
, ('be',    1,  'ws.daemon.be.error.bad_realm.code',    '-32006')
, ('be',    1,  'ws.daemon.be.error.bad_realm.message', 'Realm error')
, ('be',    1,  'ws.daemon.be.error.bad_realm.data',    'Incorrect Realm code')
, ('be',    1,  'ws.daemon.be.error.ws_bad_bt.code',    '-32011')
, ('be',    1,  'ws.daemon.be.error.ws_bad_bt.message', 'Base type error')
, ('be',    1,  'ws.daemon.be.error.ws_bad_bt.data',    'Error found in base type definition')
, ('be',    1,  'ws.daemon.be.error.ws_bad_mt.code',    '-32012')
, ('be',    1,  'ws.daemon.be.error.ws_bad_mt.message', 'Argument type')
, ('be',    1,  'ws.daemon.be.error.ws_bad_mt.data',    'Error found in argument type definition')
, ('be',    1,  'ws.daemon.be.error.ws_no_acc.code',    '-32031')
, ('be',    1,  'ws.daemon.be.error.ws_no_acc.message', 'Access forbidden')
, ('be',    1,  'ws.daemon.be.error.ws_no_acc.data',    'Access to this method is forbidden')
, ('be',    1,  'ws.daemon.be.error.db_no_acc.code',    '-32032')
, ('be',    1,  'ws.daemon.be.error.db_no_acc.message', 'Access forbidden')
, ('be',    1,  'ws.daemon.be.error.db_no_acc.data',    'Access to this method is forbidden')
, ('be',    1,  'ws.daemon.be.error.no_error.code',     '-32099')
, ('be',    1,  'ws.daemon.be.error.no_error.message',  'Last error')
, ('be',    1,  'ws.daemon.be.error.no_error.data',     'Reserved as last error code')

, ('be',    1,  'ws.daemon.be.plugin.cache.lib',        'PGWS::Plugin::System::Cache')
, ('be',    1,  'ws.daemon.be.plugin.cache.pogc',       'cache')
, ('be',    1,  'ws.daemon.be.plugin.cache.poid',       '0')
, ('be',    1,  'ws.daemon.be.plugin.cache.data_set',   '1')
, ('be',    1,  'ws.daemon.be.plugin.acl.lib',          'PGWS::Plugin::System::ACL')
, ('be',    1,  'ws.daemon.be.plugin.store.lib',        'PGWS::Plugin::System::Store')

, ('cache', 1,  'ws.plugin.cache.code',                 'none')
, ('cache', 1,  'ws.plugin.cache.is_active',            '0')
, ('cache', 2,  'ws.plugin.cache.code',                 'meta')
, ('cache', 2,  'ws.plugin.cache.expire_time',          '0')
, ('cache', 3,  'ws.plugin.cache.code',                 'short')
, ('cache', 3,  'ws.plugin.cache.expire_time',          '3')
, ('cache', 4,  'ws.plugin.cache.code',                 'session')
, ('cache', 5,  'ws.plugin.cache.code',                 'big')
, ('cache', 5,  'ws.plugin.cache.cache_size',           '4096k')
, ('cache', 5,  'ws.plugin.cache.expire_time',          '10m')
;
