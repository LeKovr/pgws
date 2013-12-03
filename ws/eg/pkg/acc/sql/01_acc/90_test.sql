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
\set LOGIN 'admin_test_norealdb'
\set a_psw '1234'

-- тестовый ID
\set TEAM -1
\set ROLE -1
\set ACC -1

-- begin: тест авторизации в системе
SELECT ws.test('login');
INSERT INTO wsd.role (id, name, anno) VALUES
  (:ROLE, 'Admins', '');

INSERT INTO wsd.account (id, status_id, login, psw, name) VALUES
  (:ACC, acc.const_status_id_active(), :'LOGIN', :'a_psw', 'Admin');

INSERT INTO wsd.team (id, name, status_id) VALUES
  (:TEAM, 'ACC-Test-Admins', acc.const_team_status_id_active())
;

SELECT acc.team_account_add(:TEAM, :ACC, :ROLE);

SELECT ip, status_id, role_id, account_name, role_name FROM acc.login('127.0.0.1', :'LOGIN', (SELECT psw FROM wsd.account WHERE login=:'LOGIN'), :SID);
-- end: тест авторизации в системе

SELECT ws.test('session');
SELECT ip,sid FROM acc.sid_info(:SID, '127.0.0.1');

SELECT ws.test('profile');
SELECT acc.sid_account_id(:SID);

SELECT ws.test('logout');
SELECT acc.logout(:SID);

SELECT acc.team_account_del(:TEAM, :ACC);

/* ------------------------------------------------------------------------- */
-- Пример регистрации клиента!
-- Регистрация проводится в два этапа: 
-- 1 этап это вставка в таблицу acc.account, без заполнения полей name, city, gender...
-- 2 этап это добавление значений свойств в wsd.prop_value
-- Примечание: регистрация команды проводится по аналогичному алгоритму.

SELECT ws.test('registration');
SELECT status_id,login,psw,name,is_psw_plain,is_ip_checked FROM wsd.account where name = 'registration';
-- begin: first step
INSERT INTO wsd.account (login, psw) VALUES ('reg_test', '111111');
-- end: first step

-- begin: second step
SELECT cfg.prop_value_edit(acc.const_account_group_prop(), (SELECT id FROM wsd.account WHERE login = 'reg_test'), 'abp.name.short', 'registration');
SELECT cfg.prop_value_edit(acc.const_account_group_prop(), (SELECT id FROM wsd.account WHERE login = 'reg_test'), 'abp.person.gender', 'male');
-- end: second step

SELECT  status_id,login,name,is_psw_plain,is_ip_checked FROM wsd.account where name = 'registration';

/* ------------------------------------------------------------------------- */
SELECT acc.account_password_change(-1, 'Test111', 'Test111', TRUE);
SELECT psw FROM wsd.account WHERE id=-1;

SELECT acc.account_password_change_own(-1, 'Test111', 'Test222', 'Test222', TRUE);
SELECT psw FROM wsd.account WHERE id=-1;
