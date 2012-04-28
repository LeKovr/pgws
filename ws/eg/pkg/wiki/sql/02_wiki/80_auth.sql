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

*/
-- 80_class.sql - Данные классов и акций
/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:80_auth.sql / 23 --'

/* ------------------------------------------------------------------------- */
INSERT INTO account_group (id, name, anno) VALUES
  (1, 'Readers', '')
  , (2, 'Writers', '')
;

/* ------------------------------------------------------------------------- */
INSERT INTO account (id, group_id, login, email, psw, name) VALUES
  (1, 2, 'user', 'user@email.to', 'ee10c315eba2c75b403ea99136f5b48d', 'Admin') -- user / nimda
;

/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:80_auth.sql / 37 --'
