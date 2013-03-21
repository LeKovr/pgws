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

    Удаление объектов пакета из схемы wsd
*/

/* ------------------------------------------------------------------------- */

DROP TABLE wsd.session;
DROP TABLE wsd.account_contact;
DROP TABLE wsd.account_role;
DROP TABLE wsd.account;
DROP TABLE wsd.role_acl;
DROP TABLE wsd.role_team;
DROP TABLE wsd.role;
DROP TABLE wsd.team;
DROP TABLE wsd.object_class_role;
DROP TABLE wsd.class_role_acl;
DROP TABLE wsd.class_role;

DROP SEQUENCE wsd.account_id_seq;
DROP SEQUENCE wsd.session_id_seq;
DROP SEQUENCE wsd.team_id_seq;
DROP SEQUENCE wsd.role_id_seq;
DROP SEQUENCE wsd.class_role_id_seq;

/* ------------------------------------------------------------------------- */
DELETE FROM wsd.pkg_script_protected WHERE pkg = :'PKG';
