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

\qecho 'login'
select login, status_id, email, psw FROM acc.login('xx','127.0.0.1','user','nimda');

\qecho 'can_create'
SELECT wiki.can_create('xx', 1, 'definitely/new/page');

\qecho 'doc tests'

SELECT wiki.group_id_by_code('wk');


/* ------------------------------------------------------------------------- */

/*
INSERT INTO doc (group_id, code, created_by, name, src) VALUES
  (1, 'p1', 1, 'Brief test', '# sdfsdsdfdsf\n\n## dfd\n## sss\n\nttt\n---\n[wewew](http://ddd)\n\n* dsds\n* sdssd\n\n[dfdf]\n')
;
SELECT * FROM wiki.ids_by_code('wk','p1');
*/

-- SELECT wiki.doc_create ('xx', 1, 'index', 'Welcome','Welcome to our wiki','Title: Welcome\n\nWelcome to our wiki!\n## Test page working\n');

-- SELECT id, status_id, group_id, code, created_by, name, src FROM wiki.doc where group_id=1 AND code='index';

-- TODO: wiki.logout
-- TODO: delete from wiki.account

/* ------------------------------------------------------------------------- */
-- No end qecho
