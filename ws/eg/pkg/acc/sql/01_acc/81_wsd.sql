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
INSERT INTO wsd.account_group (id, name, anno) VALUES
  (1, 'Readers', '')
  , (2, 'Writers', '')
;

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.account (group_id, status_id, login, email, psw, name) VALUES
  (2, acc.const_status_id_active(), 'admin', 'admin@pgws.local', acc.const_admin_psw_default(), 'Admin')
;
