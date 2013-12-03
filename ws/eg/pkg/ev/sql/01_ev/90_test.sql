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

    Тесты пакета EV
*/
\set ACC1 -1
\set ACC2 -2
\set TEAM1 -1
\set TEAM2 -2
\set ROLE1 -1
\set ROLE2 -2

SELECT ws.test('ev.package_tests');

-- Begin: подготовка данных
  INSERT INTO wsd.account (id, status_id, login, psw, name) VALUES 
    (:ACC1, 1, 'test_acc', '111111', 'account_name')
  , (:ACC2, 1, 'test_acc2', '111111', 'account_name2')
  ;

  INSERT INTO wsd.team (id, status_id, name) VALUES 
    (:TEAM1, 1, 'test_team')
  , (:TEAM2, 1, 'test_team2')
  ;

  INSERT INTO wsd.role (id, team_id, name, anno) VALUES 
    (:ROLE1, :TEAM1, 'test_team', 'anno')
  , (:ROLE2, :TEAM2, 'test_team2', 'anno2')
  ;

  INSERT INTO wsd.account_team (account_id, role_id, team_id) VALUES 
    (:ACC1, :ROLE2, :TEAM2)
  , (:ACC2, :ROLE1, :TEAM1)
  ;

  INSERT INTO wsd.event_signup (role_id, kind_id, spec_id, is_on, prio) VALUES 
    (:ROLE1, 1, 0, TRUE, NULL)
  , (:ROLE2, 1, 0, FALSE, NULL)
  ;

  INSERT INTO wsd.event_account_signup (account_id, kind_id, spec_id, role_id, is_on, prio) VALUES 
    (:ACC1, 1, 0, :ROLE1, TRUE, 1)
  , (:ACC2, 1, 0, :ROLE2, TRUE, 1)
  ;
-- End: подготовка данных

-- Begin: тест
  SELECT CASE WHEN ev.create(1, 2, 3, 4, 5, 6, 'test', 'test2') IS NOT NULL THEN 'TRUE' END;
  SELECT status_id, reason_id, kind_id, created_by, class_id, arg_id, arg_id2, arg_name, arg_name2 FROM wsd.event WHERE arg_name = 'test';

  SELECT group_id, class_id, def_prio, keep_days, has_spec, signature_id, tmpl, form_codes, name, name_fmt, name_count, spec_name, anno, pkg, group_sort, group_name FROM ev.kind(1);
  SELECT group_id, class_id, def_prio, keep_days, has_spec, signature_id, tmpl, form_codes, name, name_fmt, name_count, spec_name, anno, pkg, group_sort, group_name FROM ev.kind() WHERE id IN (1,2,3);

  SELECT sort, name, anno FROM ev.kind_group(1);
  SELECT sort, name, anno FROM ev.kind_group() WHERE id IN (1);

  SELECT team_id, name, anno, kind_id, spec_id, is_on, prio FROM ev.role_signup_by_kind_id(1, :ROLE2);
  SELECT team_id, name, anno, kind_id, spec_id, is_on, prio FROM ev.role_signup_by_kind_id(1);

  SELECT * FROM ev.signup_by_account_id(:ACC1);

  SELECT * FROM ev.signup_by_role_id(:ROLE2);

  SELECT is_team_only, name, anno, team_id, kind_id, spec_id, is_on, prio, kind_name, group_id, group_sort, group_name FROM ev.signup_by_team_kind_id(:TEAM2);
  SELECT is_team_only, name, anno, team_id, kind_id, spec_id, is_on, prio, kind_name, group_id, group_sort, group_name FROM ev.signup_by_team_kind_id(:TEAM2, 1);

  SELECT is_team_only, name, anno, team_id, kind_id, spec_id, is_on, prio, kind_name, group_id, group_sort, group_name FROM ev.signup_by_team_role_id(:TEAM2);
  SELECT is_team_only, name, anno, team_id, kind_id, spec_id, is_on, prio, kind_name, group_id, group_sort, group_name FROM ev.signup_by_team_role_id(:TEAM2, :ROLE2);
-- End: тест
