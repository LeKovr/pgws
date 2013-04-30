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

    Значения свойств.

*/

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.prop_value (pogc, poid, code,      value) VALUES
  (job.const_job_group_prop(),   1,  'ws.daemon.mgr.listen.job',             'job_event')
, (job.const_job_group_prop(),   1,  'ws.daemon.mgr.listen.stat',            'job_stat')
, (job.const_job_group_prop(),   1,  'ws.daemon.mgr.listen.reload',          'job_reload')
, (job.const_job_group_prop(),   1,  'ws.daemon.mgr.reload_key',             'job_secret_reload')
, (job.const_job_group_prop(),   1,  'ws.daemon.startup.pm.n_processes',     '5')

, ('fe',    1,  'ws.daemon.log.syslog.job.default',     '6')
, ('fe',    1,  'ws.daemon.log.syslog.job.call',        NULL)
, ('fe',    1,  'ws.daemon.log.syslog.job.sid',         NULL)
, ('fe',    1,  'ws.daemon.log.syslog.job.acl',         NULL)
, ('fe',    1,  'ws.daemon.log.syslog.job.cache',       NULL)
, ('fe',    1,  'ws.daemon.log.syslog.job.validate',    NULL)
;

