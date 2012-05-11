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
-- 90_test.sql - Тесты
/* ------------------------------------------------------------------------- */

-- TODO: insert into wiki.account

\set SID '\'; \''

\qecho '1. login'
select login, status_id, email, psw FROM acc.login(:SID,'127.0.0.1','admin', (SELECT psw FROM acc_data.account WHERE login='admin'));

\qecho '2. session'
SELECT ip,sid FROM acc_data.session WHERE ip='127.0.0.1' AND sid=:SID AND deleted_at IS NULL;

\qecho '3. profile'
SELECT id, group_id, status_id, login,email,psw, name , group_name FROM acc.profile(:SID,'127.0.0.1');

\qecho '4. logout'
SELECT acc.logout(:SID,'127.0.0.1');

-- TODO: wiki.logout
-- TODO: delete from wiki.account

/* ------------------------------------------------------------------------- */
-- No end qecho
