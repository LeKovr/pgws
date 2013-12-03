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

    Тест создания уведомления на авторизацию пользователя
*/

-- тестовый ID
\set TEAM -1
\set ROLE -1
\set USER -1
\set USER2 -2
\set LOGIN EV-Test-Admin-Login

DO $_$ -- очистим job, убрав вывод в файл DELETE XXXX
  BEGIN
    DELETE FROM wsd.job;
  END
$_$;

SELECT ws.test('ev.notification_user_login');

-- Begin: подготовка данных
  INSERT INTO wsd.team(id, status_id, name) VALUES
    (:TEAM, acc.const_team_status_id_active(), 'EV-Test Admin team');

  INSERT INTO wsd.role (id, name, anno) VALUES
    (:ROLE, 'EV-Test-Admins', '');

  INSERT INTO wsd.account (id, status_id, login, psw, name) VALUES
    (:USER, acc.const_status_id_active(), :'LOGIN', :'PSW_DEFAULT', 'Admin');

  INSERT INTO wsd.account_team(account_id, role_id, team_id, is_default) VALUES
    (:USER, :ROLE, :TEAM, TRUE);
-- End: подготовка данных

-- Begin: тест
  -- Подписать роль 1 на событие 1 со специфкацией 0
  SELECT * FROM ev.role_signup_ins( :ROLE, 1, 0 );

  -- Сэмулировать логин
  SELECT account_name FROM acc.login( '127.0.0.1', :'LOGIN', :'PSW_DEFAULT');

  -- Разослать уведомления
  SELECT job.server(-1) AS job_count;

  -- Найти новое уведомление у аккаунта 1
  SELECT ev.notification_count_new( :USER );
  SELECT COUNT(*) FROM ev.notification( :USER );

  -- Подписать роль 1 на событие 1 со специфкацией 1
  SELECT * FROM ev.role_signup_ins( :ROLE, 1, 1 );

  -- Создать юзера с аккаунтом pro_
  INSERT INTO wsd.account (id, status_id, login, psw, name ) VALUES 
    (:USER2, acc.const_status_id_active(), 'pro_admin', 'pro_admin', 'pro_admin' )
  ;
  INSERT INTO wsd.account_team(account_id, role_id, team_id, is_default) VALUES
    (:USER2, :ROLE, :TEAM, TRUE);

  -- Сэмулировать логин юзера pro_
  SELECT account_name FROM acc.login( '127.0.0.1', 'pro_admin', 'pro_admin');

  -- Разослать уведомления
  SELECT job.server(-1) AS job_count;

  -- Найти новое уведомление
  SELECT ev.notification_count_new( :USER );
  SELECT COUNT(*) FROM ev.notification( :USER );

  -- Удалить подписку
  SELECT * FROM ev.role_signup_del( :ROLE, 1, 1 );
  SELECT * FROM ev.role_signup_del( :ROLE, 1, 0 );
-- End: тест