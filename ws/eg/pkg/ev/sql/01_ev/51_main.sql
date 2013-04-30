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
CREATE OR REPLACE FUNCTION ev.create(
  a_kind_id     ws.d_id
, a_created_by  ws.d_id
, a_reason_id   ws.d_id     DEFAULT NULL
, a_status_id   ws.d_id32   DEFAULT NULL
, a_arg_id      ws.d_id     DEFAULT NULL
, a_arg_id2     ws.d_id     DEFAULT NULL
, a_arg_name    ws.d_string DEFAULT NULL
, a_arg_name2   ws.d_string DEFAULT NULL
) RETURNS d_id VOLATILE LANGUAGE 'plpgsql' AS
$_$
-- a_id:          ID вида события
-- a_status_id:   ID статуса
-- a_created_by:  ID автора события
-- a_arg_id:      ID1 (аргумент события)
-- a_arg_id2:     ID2 (аргумент события)
-- a_arg_name:    Описание события
-- a_arg_name2:   Описание2 события
  DECLARE
    r ev.kind;
    v_id INTEGER;
  BEGIN
    r := ev.kind(a_kind_id);
    INSERT INTO wsd.event (
      kind_id
    , reason_id
    , status_id
    , created_by
    , arg_id
    , arg_id2
    , arg_name
    , arg_name2
    , class_id
    ) VALUES (
      r.id
    , COALESCE(a_reason_id, NEXTVAL('wsd.event_reason_seq'))
    , COALESCE(a_status_id, ev.const_status_id_draft())
    , a_created_by
    , a_arg_id
    , a_arg_id2
    , a_arg_name
    , a_arg_name2
    , r.class_id
    )
    RETURNING id INTO v_id
    ;
    RETURN v_id;
  END;
$_$;
SELECT pg_c('f', 'create', 'Создать событие');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ev.role_signup_ins(
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

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ev.role_signup_del(
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

