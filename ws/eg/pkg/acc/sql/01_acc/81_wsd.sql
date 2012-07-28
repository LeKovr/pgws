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

    Данные таблиц из схемы wsd
*/

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.pkg_script_protected (code, ver) VALUES (:'FILE', :'VER');

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.team (name, anno) VALUES
  ('Users', '')
;

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.role (level_id, has_team, name, anno) VALUES
  (1, false,  'Guest', '')
, (1, false,  'Logged in', '')
, (5, true,   'Any group member', '')
, (6, true,   'Admins', '')
, (6, true,   'Readers', '')
, (6, true,   'Writers', '')
;

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.role_team (team_id, role_id) VALUES
  (1,3)
, (1,4)
, (1,5)
, (1,6)
;

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.account (status_id, def_role_id, login, email, psw, name) VALUES
  (acc.const_status_id_active(), 4, 'admin', 'admin@pgws.local', acc.const_admin_psw_default(), 'Admin')
;
