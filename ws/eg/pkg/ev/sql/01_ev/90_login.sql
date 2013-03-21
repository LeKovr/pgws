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

INSERT INTO ev.role ( id, title ) VALUES
( 1, 'admin' ),
( 2, 'user'  );

INSERT INTO ev.signature (  id, name, email, tmpl )
  VALUES ( 1, 'First Signature', 'first_email@example.com', 'first_signature' );

INSERT INTO ev.kind ( id, group_id, class_id,  def_prio, keep_days, has_spec, pkg, signature_id, tmpl, form_codes, name, name_fmt, name_count, spec_name, anno )
  VALUES( 1, 2, 3, 4, 5,  true, 'acc', 1, 'tmpl', ARRAY[1], 'user login', '',  0, 'spec_name', 'anno' ),
        ( 2, 2, 3, 4, 5, false, 'acc', 1, 'tmpl', ARRAY[1],       'test', '',  0, 'spec_name', 'anno' );

INSERT INTO ev.account_role ( account_id, role_id ) VALUES ( 1, 1 );


SELECT ws.test('user_login_spec_0');
-- Подписать роль 1 на событие 1 со специфкацией 0
SELECT ev.role_signup_ins( 1, 1, 0 );
-- Сэмулировать логин
SELECT account_name FROM acc.login( '127.0.0.1', 'admin', 'pgws');

-- Найти новое уведомление у аккаунта 1
SELECT ev.new_notifications_count( 1 );
SELECT COUNT(*) FROM ev.notifications_list( 1 );

SELECT ws.test('user_login_spec_1');
-- Подписать роль 1 на событие 1 со специфкацией 1
SELECT ev.role_signup_ins( 1, 1, 1 );
-- Создать юзера с аккаунтом pro_
INSERT INTO wsd.account ( status_id, def_role_id, login, psw, name ) VALUES 
  ( 4, 1, 'pro_admin', 'pro_admin', 'pro_admin' )
;
-- Сэмулировать логин юзера pro_
SELECT account_name FROM acc.login( '127.0.0.1', 'pro_admin', 'pro_admin');

-- Найти новое уведомление
SELECT ev.new_notifications_count( 1 );
SELECT COUNT(*) FROM ev.notifications_list( 1 );

SELECT ws.test('ev.role_signup_del');
-- Удалить подписку
SELECT ev.role_signup_del( 1, 1, 1 );
SELECT ev.role_signup_del( 1, 1, 0 );
-- Убраться за собой
TRUNCATE wsd.event_notify;
TRUNCATE wsd.session;
DELETE FROM wsd.account WHERE login = 'pro_admin' AND psw = 'pro_admin';
