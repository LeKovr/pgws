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

    Тесты
*/

/* ------------------------------------------------------------------------- */

-- TODO: insert into .account

\set SID '\'; \''
\set LOGIN admin

SELECT ws.test('role_const');
SELECT * FROM wsd.role WHERE id = acc.const_role_id_guest();
SELECT * FROM wsd.role WHERE id = acc.const_role_id_user();

SELECT ws.test('login');
SELECT ip, status_id, account_id, role_id, account_name, role_name FROM acc.login('127.0.0.1',:'LOGIN', (SELECT psw FROM wsd.account WHERE login=:'LOGIN'), :SID);

SELECT ws.test('session');
SELECT ip,sid FROM acc.sid_info(:SID, '127.0.0.1');

SELECT ws.test('profile');
SELECT id, status_id, login, psw, name, status_name FROM acc.profile(:SID);

SELECT ws.test('logout');
SELECT acc.logout(:SID);
