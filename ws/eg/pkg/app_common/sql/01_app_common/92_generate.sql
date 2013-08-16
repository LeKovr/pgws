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
SELECT ws.test('generate_team');

\set TEAM_COUNT 8
\set MAX_ACCOUNT_COUNT 6
\set COST_ROLE_COUNT 2
\set ROLE_COUNT 6

CREATE TEMP TABLE tmp_count(
  code text PRIMARY KEY
, quantity integer NOT NULL
);
INSERT INTO wsd.role(id, name, anno) 
  SELECT 12000 + a, 'test role ' || a::text, '' FROM generate_series(1, :ROLE_COUNT) a
;
-- Counting start data

INSERT INTO tmp_count
  SELECT 'team', COUNT(*) FROM wsd.team
  UNION
  SELECT 'account', COUNT(*) FROM wsd.account
  UNION
  SELECT 'admin', COUNT(*) FROM wsd.account_team WHERE role_id = ANY(ARRAY[12001, 12002])
;
-- Generate teams and accounts
SELECT app_common.generate_team(:TEAM_COUNT, :MAX_ACCOUNT_COUNT, :'PSW_DEFAULT', ARRAY[12001, 12002], ARRAY[12003, 12004, 12005, 12006], 'TEST');
-- Test new teams and accounts
SELECT 
  (COUNT(*) - (SELECT quantity FROM tmp_count WHERE code = 'team'))
  FROM wsd.team
;
SELECT 
  (COUNT(*) - (SELECT quantity FROM tmp_count WHERE code = 'account')) BETWEEN :TEAM_COUNT AND :TEAM_COUNT * :MAX_ACCOUNT_COUNT
  FROM wsd.account
;
SELECT 
  (COUNT(*) - (SELECT quantity FROM tmp_count WHERE code = 'admin')) = :TEAM_COUNT
  FROM wsd.account_team
  WHERE role_id = :ROLE_COUNT
;
-- Drop new teams and accounts
SELECT app_common.drop_generated_team('TEST');
-- Test droped
SELECT 
  COUNT(*) = (SELECT quantity FROM tmp_count WHERE code = 'team')
  FROM wsd.team
;
SELECT 
  COUNT(*) = (SELECT quantity FROM tmp_count WHERE code = 'account')
  FROM wsd.account
;
/* TODO: Fails on pgws
SELECT 
  COUNT(*) = (SELECT quantity FROM tmp_count WHERE code = 'admin')
  FROM wsd.account_team
  WHERE role_id = :ROLE_COUNT
;
*/
DELETE FROM wsd.role WHERE id BETWEEN 12001 AND (12000 + :ROLE_COUNT);
DROP TABLE tmp_count;
