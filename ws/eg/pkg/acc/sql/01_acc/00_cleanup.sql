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

    Удаление данных из схемы ws
*/

/* ------------------------------------------------------------------------- */

DELETE FROM job.handler             WHERE pkg = :'PKG';
/*
DELETE FROM ws.method                WHERE pkg = :'PKG';

DELETE FROM ws.dt_part          WHERE dt_code IN (SELECT code FROM ws.dt WHERE code LIKE 'acc.%');
DELETE from ws.dt               WHERE code LIKE 'acc.%';

\set SYSID 1 -- system class id
\set AID acc.const_class_id()       -- account class id
\set TID acc.const_team_class_id()  -- team class id
\set RID acc.const_role_class_id()  -- role class id

DELETE FROM ws.class_action_acl WHERE class_id IN (:SYSID, :AID, :TID, :RID);
DELETE FROM ws.class_status_action_acl_addon WHERE class_id IN (:SYSID, :AID, :TID, :RID);
DELETE FROM ws.class_acl WHERE class_id IN (:SYSID, :AID, :TID, :RID);

DELETE FROM ws.class_status_action WHERE class_id IN (:SYSID, :AID, :TID, :RID);
DELETE FROM ws.class_action WHERE class_id IN (:SYSID, :AID, :TID, :RID);

DELETE FROM ws.class_status WHERE class_id IN (:SYSID, :AID, :TID, :RID);
DELETE FROM acc.class_link WHERE class_id IN (:SYSID, :AID, :TID, :RID);
DELETE FROM ws.class WHERE id IN (:SYSID, :AID, :TID, :RID);

DELETE FROM ws.error_data WHERE code ~ E'^Y0[34]';
*/
/* ------------------------------------------------------------------------- */
SELECT cfg.prop_cleanup_without_value(ARRAY[acc.const_team_group_prop(),acc.const_account_group_prop()]);

