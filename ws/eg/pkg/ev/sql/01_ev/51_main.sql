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

    Методы диспетчера Ev
*/

/* ------------------------------------------------------------------------- */

CREATE OR REPLACE FUNCTION kind_class_id(a_id ws.d_id32)  RETURNS INTEGER LANGUAGE 'sql' AS
$_$
  SELECT class_id FROM ev.kind WHERE id = $1;
$_$;
SELECT pg_c('f', 'kind_class_id', 'ID класса по ID вида события');

CREATE OR REPLACE FUNCTION kind(a_id ws.d_id32) RETURNS SETOF ev.kind LANGUAGE 'sql' AS
$_$
  SELECT * FROM ev.kind WHERE $1 IN (id,0);
$_$;
SELECT pg_c('f', 'kind', 'Вид события по ID');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ev.create(
  a_kind_id     ws.d_id
, a_status_id   ws.d_id32
, a_created_by  ws.d_id
, a_arg_id      ws.d_id DEFAULT NULL
, a_arg_id2     ws.d_id DEFAULT NULL
, a_arg_name    TEXT    DEFAULT NULL
, a_arg_name2   TEXT    DEFAULT NULL
) RETURNS d_id VOLATILE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    r ev.kind;
    v_id INTEGER;
  BEGIN
    r := ev.kind(a_kind_id);
    INSERT INTO wsd.event (
      kind_id
    , status_id
    , created_by
    , arg_id
    , arg_id2
    , arg_name
    , arg_name2
    , class_id
    ) VALUES (
      r.id
    , COALESCE($2, ev.const_status_id_draft())
    , $3
    , $4
    , $5
    , $6
    , $7
    , r.class_id
    )
    RETURNING id INTO v_id
    ;
    RETURN v_id;
  END;
$_$;
SELECT pg_c('f', 'create', 'Создать событие');

CREATE FUNCTION ev.role_list()
  RETURNS SETOF ev.role LANGUAGE 'sql' AS
$_$
  SELECT * FROM ev.role;
$_$;
SELECT pg_c('f', 'role_list', 'Список ролей');

CREATE FUNCTION ev.role_signup_list( a_role_id ws.d_id32 )
  RETURNS SETOF wsd.event_role_signup LANGUAGE 'sql' AS
$_$
  -- a_role_id: ID роли
  SELECT * FROM wsd.event_role_signup WHERE role_id = $1;
$_$; 
SELECT pg_c('f', 'role_signup_list', 'Список подписок роли');

CREATE FUNCTION ev.kind_list()
  RETURNS SETOF ev.kind LANGUAGE 'sql' AS
$_$
  SELECT * FROM ev.kind;
$_$; 
SELECT pg_c('f', 'kind_list', 'Список видов событий');

CREATE FUNCTION ev.role_signup_ins(
  a_role_id ws.d_id32
, a_kind_id ws.d_id32
, a_spec_id ws.d_id32
, a_is_on   BOOL DEFAULT true
, a_prio    INTEGER DEFAULT 1
) RETURNS wsd.event_role_signup LANGUAGE 'sql' AS
$_$
  -- a_role_id: ID роли
  -- a_kind_id: ID вида события
  -- a_spec_id: ID специфкации ( если требуется )
  -- a_is_on:   флаг включения ( если включён, пользователи данной роли получают уведомления, если нет — им надо подписаться вручную )
  -- a_prio:    приоритет
  INSERT INTO wsd.event_role_signup ( role_id, kind_id, spec_id, is_on, prio ) VALUES ( $1, $2, $3, $4, $5 ) RETURNING *;
$_$;
SELECT pg_c('f', 'role_signup_ins', 'Создание подписки роли');

CREATE FUNCTION ev.role_signup_del(
  a_role_id ws.d_id32
, a_kind_id ws.d_id32
, a_spec_id ws.d_id32
) RETURNS wsd.event_role_signup LANGUAGE 'sql' AS
$_$
  -- a_role_id: ID роли
  -- a_kind_id: ID вида события
  -- a_spec_id: ID спецификации
  DELETE FROM wsd.event_role_signup WHERE role_id = $1 AND kind_id = $2 AND spec_id = $3 RETURNING *;
$_$;
SELECT pg_c('f', 'role_signup_del', 'Удаление подписки роли');

CREATE OR REPLACE FUNCTION ev.create_user_login( a_user_id ws.d_id32 )
  RETURNS wsd.event LANGUAGE 'sql' AS
$_$
  -- a_user_id: ID аккаунта, выполнившего вход в систему
  -- создаём событие user login
  INSERT INTO wsd.event( status_id, kind_id, created_by, class_id )
    VALUES ( ev.const_status_id_draft(), 1, $1, 3 ) RETURNING *;
$_$;

CREATE OR REPLACE FUNCTION ev.fire_user_login( a_user_id ws.d_id32 )
  RETURNS wsd.event LANGUAGE 'plpgsql' AS
$_$
  -- a_user_id: ID аккаунта, выполнившего вход в систему
  DECLARE
    r_account wsd.account;  
    r_event   wsd.event;
  BEGIN
      -- создаём событие user login
      INSERT INTO wsd.event( status_id, kind_id, created_by, class_id )
        VALUES ( ev.const_status_id_draft(), 1, a_user_id, 3 ) RETURNING * INTO r_event;
      -- выбираем пользователя с указанным в событии id
      SELECT * INTO r_account FROM wsd.account WHERE id = a_user_id;
      -- если логин начинается с pro_ то спецификация 1
      IF position('pro_' in r_account.login) = 1 THEN
        INSERT INTO wsd.event_spec ( event_id, spec_id ) VALUES ( r_event.id, 1 );
      -- иначе 0
      ELSE
        INSERT INTO wsd.event_spec ( event_id, spec_id ) VALUES ( r_event.id, 0 );
      END IF;
      UPDATE wsd.event SET status_id = ev.const_status_id_rcpt() WHERE id = r_event.id;
    RETURN r_event;
  END;
$_$;

CREATE OR REPLACE FUNCTION ev.notifications_list( a_account_id ws.d_id32 )
  RETURNS SETOF wsd.event_notify LANGUAGE 'sql' AS
$_$
  -- a_account_id: ID аккаунта пользователя
  SELECT * FROM wsd.event_notify WHERE account_id = $1;
$_$;
SELECT pg_c('f', 'notifications_list', 'Список уведомлений пользователя');

CREATE OR REPLACE FUNCTION ev.new_notifications_count( a_account_id ws.d_id32 )
  RETURNS BIGINT LANGUAGE 'sql' AS
$_$
  -- a_account_id: ID аккаунта пользователя
  SELECT COUNT(*) FROM wsd.event_notify WHERE account_id = $1 AND is_new = TRUE;
$_$;
SELECT pg_c('f', 'new_notifications_count', 'Возвращает количество новых уведомлений пользователя');
/* ------------------------------------------------------------------------- */
