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
/*
DELETE FROM wsd.prop_value WHERE pkg = :'PKG';
DELETE FROM wsd.prop_owner WHERE pkg = :'PKG';
DELETE FROM wsd.prop_group WHERE pkg = :'PKG';

DELETE FROM cfg.prop                 WHERE pkg = :'PKG';
*/
/* ------------------------------------------------------------------------- */
DROP TABLE wsd.event_notify_spec;
DROP TABLE wsd.event_notify;
DROP TABLE wsd.event_signup;
DROP TABLE wsd.event_signup_profile;
DROP TABLE wsd.event_role_signup;
DROP TABLE wsd.event_spec;
DROP TABLE wsd.event;
DROP SEQUENCE wsd.event_seq;

/* ------------------------------------------------------------------------- */
DELETE FROM wsd.pkg_script_protected WHERE pkg = :'PKG';

