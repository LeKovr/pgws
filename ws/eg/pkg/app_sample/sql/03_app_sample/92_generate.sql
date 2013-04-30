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
\set MAX_ACCOUNT_COUNT 5
\set ADMIN_ROLE_ID 8

CREATE TEMP TABLE tmp_count(
  code text PRIMARY KEY
, quantity integer NOT NULL
);
-- Counting start data

INSERT INTO tmp_count
  SELECT 'team', COUNT(*) FROM wsd.team
  UNION
  SELECT 'account', COUNT(*) FROM wsd.account
  UNION
  SELECT 'admin', COUNT(*) FROM wsd.account_team WHERE role_id = :ADMIN_ROLE_ID
;
-- Generate teams and accounts
SELECT app_sample.generate_team(:TEAM_COUNT, :MAX_ACCOUNT_COUNT, :'PSW_DEFAULT', 'TEST');
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
  WHERE role_id = :ADMIN_ROLE_ID
;
-- Drop new teams and accounts
SELECT app_sample.drop_generated_team('TEST');
-- Test droped
SELECT 
  COUNT(*) = (SELECT quantity FROM tmp_count WHERE code = 'team')
  FROM wsd.team
;
SELECT 
  COUNT(*) = (SELECT quantity FROM tmp_count WHERE code = 'account')
  FROM wsd.account
;
SELECT 
  COUNT(*) = (SELECT quantity FROM tmp_count WHERE code = 'admin')
  FROM wsd.account_team
  WHERE role_id = :ADMIN_ROLE_ID
;

DROP TABLE tmp_count;
