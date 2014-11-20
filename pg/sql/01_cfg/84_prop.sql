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
-- откат временного добавления свойств, см 82_prop.sql
UPDATE cfg.prop SET pogc_list = array_remove(pogc_list, 'tm') WHERE code IN (
  'ws.daemon.startup.pm.n_processes'
, 'ws.daemon.startup.pm.die_timeout'
);

DELETE FROM cfg.prop WHERE code IN 
 ('ws.daemon.mgr.listen_wait','ws.daemon.mgr.listen.job')
;
