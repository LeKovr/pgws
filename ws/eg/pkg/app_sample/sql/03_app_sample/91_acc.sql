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

    Тесты пакета acc
*/

\set TEAM 3
/* ------------------------------------------------------------------------- */
SELECT ws.test('insert_test_data');
INSERT INTO wsd.session (id, account_id, role_id, team_id, sid, ip, is_ip_checked) VALUES
  (-1, 3, 5, :TEAM, '1', '127.0.0.1', FALSE)
, (-2, 4, 6, :TEAM, '2', '127.0.0.1', FALSE) 
, (-3, 5, 8, :TEAM, '3', '127.0.0.1', FALSE)
, (-4, 6, 5, :TEAM, '4', '127.0.0.1', FALSE)
;

/* ------------------------------------------------------------------------- */
SELECT ws.test('50_object');
--SELECT acc.object_acl(21, 1, '1');

/* ------------------------------------------------------------------------- */
SELECT ws.test('51_account');
SELECT (ws.class_acl(ws.class_id('account'),a)).* FROM acc.account_acl(3, '1') a ORDER BY 1,2; -- к себе
SELECT (ws.class_acl(ws.class_id('account'),a)).* FROM acc.account_acl(5, '1') a ORDER BY 1,2; -- своя команда
SELECT (ws.class_acl(ws.class_id('account'),a)).* FROM acc.account_acl(6, '1') a ORDER BY 1,2; -- чужая команда
SELECT (ws.class_acl(ws.class_id('account'),a)).* FROM acc.account_acl(3, '3') a ORDER BY 1,2; -- админ к своей команде

SELECT acc.account_server(3);
SELECT acc.account_status(3);
SELECT id, account_id, role_id, team_id, sid, ip, is_ip_checked FROM acc.sid_info('2', '127.0.0.1', FALSE);
SELECT acc.sid_account_id('3');
--SELECT acc.session_permission(21, '2');

/* ------------------------------------------------------------------------- */
SELECT ws.test('52_team');

SELECT * FROM acc.team_role(1); -- системные роли

-- список ролей команды
SELECT * FROM acc.team_role(:TEAM);

-- создаем и сразу обновляем роль
SELECT acc.team_role_save(:TEAM, 'test_role2', 'test_anno2'
, acc.team_role_save(:TEAM, 'test_role1', 'test_anno1')) IS NOT NULL AS "Role created & updated";

SELECT team_id, name, anno FROM wsd.role WHERE team_id = :TEAM;

SELECT acc.team_role_del(:TEAM, (SELECT id FROM wsd.role WHERE team_id = :TEAM and name = 'test_role2'));

SELECT team_id, name, anno FROM wsd.role WHERE team_id = :TEAM;

SELECT id, status_id, name, status_name, anno FROM acc.team_by_name('System');
SELECT id, status_id, name, status_name, anno FROM acc.team_profile(:TEAM);
SELECT id, status_id, name, status_name FROM acc.team_account_attr(:TEAM) order by id;
SELECT * FROM acc.account_team(6);
--SELECT acc.account_team_add(2, 2, 2);
--SELECT * FROM wsd.account_team WHERE account_id = 2 AND role_id = 2 AND team_id = 2
--SELECT acc.account_team_del(??);
--SELECT * FROM acc.account_team_link(6, 3);

