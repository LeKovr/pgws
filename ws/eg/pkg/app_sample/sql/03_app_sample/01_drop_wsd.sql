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

    Удаление данных из схемы wsd
*/

\set TID acc.const_team_class_id()      -- team class id

/* ------------------------------------------------------------------------- */
SELECT cfg.prop_drop_pkg(ARRAY['acc.const_team_group_prop','acc.const_account_group_prop']);


/* ------------------------------------------------------------------------- */
-- удаление временных тестовых данных

DELETE FROM wsd.file_link;
DELETE FROM wsd.file;

/* ------------------------------------------------------------------------- */
DELETE FROM fs.folder_kind k USING fs.folder f 
  WHERE f.class_id = k.class_id AND f.code = k.code
    AND f.pkg = :'PKG'
;
DELETE FROM fs.folder WHERE pkg = :'PKG';

/* ------------------------------------------------------------------------- */
-- begin: удаление данных пакета wiki
DELETE FROM wsd.doc;
DELETE FROM wsd.doc_group;
-- end

/* ------------------------------------------------------------------------- */
-- begin: удаление данных пакета acc
DELETE FROM wsd.role_permission WHERE perm_id IN (SELECT id FROM wsd.permission WHERE pkg = :'PKG');

DELETE FROM wsd.permission_acl;

DELETE FROM wsd.permission WHERE pkg = :'PKG';

DELETE FROM wsd.account_team;

DELETE FROM wsd.session;
DELETE FROM wsd.account;

DELETE FROM wsd.role;

DELETE FROM wsd.team;

/* ------------------------------------------------------------------------- */



