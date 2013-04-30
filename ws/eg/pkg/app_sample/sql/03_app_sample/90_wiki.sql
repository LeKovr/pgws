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

\set SID '\'; \''
\set LOGIN admin
\set WIKI test_wiki
\set URI definitely/new/page
/* ------------------------------------------------------------------------- */
SELECT ws.test('login');

SELECT ip, status_id, account_id, role_id, account_name, role_name FROM acc.login('127.0.0.1', :'LOGIN', (SELECT psw FROM wsd.account WHERE login=:'LOGIN'), :SID);

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.doc_group (id, code, team_id, name, anno) VALUES
  (-1, :'WIKI', 2, 'TestWiki', 'TestWiki')
;

SELECT ws.test('wiki_group');
SELECT wiki.id_by_code(:'WIKI') IS NOT NULL AS group_exists;

/* ------------------------------------------------------------------------- */

SELECT ws.test('wiki_create');

--acl:wiki.add SELECT wiki.can_create(:SID, wiki.id_by_code(:'WIKI'), 'definitely/new/page');

SELECT wiki.doc_create(:SID, wiki.id_by_code(:'WIKI'), :'URI', FALSE, 'New test page',E'==test title\n\ntest body') IS NOT NULL AS doc_created;

SELECT (wiki.doc_id_by_code(wiki.id_by_code(:'WIKI'), :'URI') IS NOT NULL) AS doc_exists;

/* ------------------------------------------------------------------------- */

SELECT ws.test('wiki_update');

SELECT wiki.doc_update_src(:SID, wiki.doc_id_by_code(wiki.id_by_code(:'WIKI'), :'URI'), 1, 'New test page updated', E'==test title\n\ntest body2', NULL, NULL, NULL, E'>\n<2') = wiki.doc_id_by_code(wiki.id_by_code(:'WIKI'), :'URI') AS src_updated;

SELECT wiki.doc_update_attr(:SID, wiki.doc_id_by_code(wiki.id_by_code(:'WIKI'), :'URI'), 2, NULL, NULL, NULL, '{{test,page}}') = wiki.doc_id_by_code(wiki.id_by_code(:'WIKI'), :'URI') AS attr_updated;

SELECT status_id, group_id, up_id, code, revision, name, group_name, updated_by_name
  FROM wiki.doc_info(wiki.doc_id_by_code(wiki.id_by_code(:'WIKI'), :'URI'))
;

/* ------------------------------------------------------------------------- */

SELECT ws.test('wiki_keywords');

SELECT * FROM wiki.doc_keyword(wiki.doc_id_by_code(wiki.id_by_code(:'WIKI'), :'URI'));

SELECT acc.logout(:SID);
