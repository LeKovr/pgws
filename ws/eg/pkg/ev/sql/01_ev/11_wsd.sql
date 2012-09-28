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

    Создание объектов в схеме wsd
*/

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.pkg_script_protected (code, pkg, ver) VALUES (:'FILE', :'PKG', :'VER');

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.event (
  id          INTEGER PRIMARY KEY
,  status_id   INTEGER NOT NULL
, created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
, kind_id     INTEGER NOT NULL
, created_by  INTEGER
, class_id    INTEGER NOT NULL
, arg_id      INTEGER
, arg_id2     INTEGER
, arg_name    TEXT
, arg_name2   TEXT
);
SELECT pg_c('r', 'wsd.event',  'Событие')
, pg_c('c', 'wsd.event.id'    , 'ID события')
, pg_c('c', 'wsd.event.status_id'   , 'ID статуса')
, pg_c('c', 'wsd.event.created_at'  , 'отметка времени возникновения')
, pg_c('c', 'wsd.event.kind_id'     , 'ID категории')
, pg_c('c', 'wsd.event.class_id'    , 'ID класса объектов') -- (дубль из Категории для уменьшения числа join)
, pg_c('c', 'wsd.event.created_by'  , 'Идентификатор автора') -- (если ID сессии, он указывается со знаком "-")
, pg_c('c', 'wsd.event.arg_id'      , 'ID объекта')
, pg_c('c', 'wsd.event.arg_id2'     , 'ID объекта2')
, pg_c('c', 'wsd.event.arg_name'    , 'Параметр названия события')
, pg_c('c', 'wsd.event.arg_name2'   , 'Параметр2 названия события')
;

CREATE SEQUENCE wsd.event_seq;
ALTER TABLE wsd.event ALTER COLUMN id SET DEFAULT NEXTVAL('wsd.event_seq');

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.event_spec (
  event_id    INTEGER
, spec_id     INTEGER
, CONSTRAINT  event_spec_pkey PRIMARY KEY (event_id, spec_id)
);
SELECT pg_c('r', 'wsd.event_spec',  'Спецификация события')
, pg_c('c', 'wsd.event_spec.event_id'    , 'ID события')
, pg_c('c', 'wsd.event_spec.spec_id'     , 'ID спецификации')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.event_role_signup (
  role_id    INTEGER
, kind_id    INTEGER
, spec_id    INTEGER
, is_on      BOOL NOT NULL DEFAULT TRUE
, prio       INTEGER NOT NULL
, CONSTRAINT  event_role_signup_pkey PRIMARY KEY (role_id, kind_id, spec_id)
);
SELECT pg_c('r', 'wsd.event_role_signup'      , 'Подписка роли')
, pg_c('c', 'wsd.event_role_signup.role_id'   , 'ID роли')
, pg_c('c', 'wsd.event_role_signup.kind_id'   , 'ID вида события')
, pg_c('c', 'wsd.event_role_signup.spec_id'   , 'ID спецификации')
, pg_c('c', 'wsd.event_role_signup.is_on'     , 'Подписка активна')
, pg_c('c', 'wsd.event_role_signup.prio'      , 'Приоритет')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.event_signup_profile (
  account_id INTEGER NOT NULL
, profile_id INTEGER NOT NULL
, format_code TEXT
, delay_hours INTEGER NOT NULL DEFAULT 0
, CONSTRAINT  event_signup_profile_pkey PRIMARY KEY (account_id, profile_id)
);
SELECT pg_c('r', 'wsd.event_signup_profile'       , 'Профайл подписок пользователя')
, pg_c('c', 'wsd.event_signup_profile.account_id' , 'ID пользователя')
, pg_c('c', 'wsd.event_signup_profile.profile_id' , 'ID профайла')
, pg_c('c', 'wsd.event_signup_profile.format_code'        , 'Код формата')
, pg_c('c', 'wsd.event_signup_profile.delay_hours'        , 'Частота уведомления')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.event_signup (
  account_id  INTEGER
, role_id     INTEGER
, kind_id     INTEGER
, spec_id     INTEGER
, is_on       BOOL NOT NULL DEFAULT TRUE
, prio        INTEGER NOT NULL
, profile_id  INTEGER
, CONSTRAINT  event_signup_pkey PRIMARY KEY (account_id, role_id, kind_id, spec_id)
, CONSTRAINT  event_signup_role_id_kind_id_spec_id_fkey FOREIGN KEY (role_id, kind_id, spec_id) REFERENCES wsd.event_role_signup
, CONSTRAINT  event_signup_account_id_profile_id_fkey FOREIGN KEY (account_id, profile_id) REFERENCES wsd.event_signup_profile
);
SELECT pg_c('r', 'wsd.event_signup'       , 'Подписка роли')
, pg_c('c', 'wsd.event_signup.account_id' , 'ID пользователя')
, pg_c('c', 'wsd.event_signup.kind_id'    , 'ID вида события')
, pg_c('c', 'wsd.event_signup.spec_id'    , 'ID спецификации')
, pg_c('c', 'wsd.event_signup.is_on'      , 'Подписка активна')
, pg_c('c', 'wsd.event_signup.prio'       , 'Приоритет')
, pg_c('c', 'wsd.event_signup.profile_id' , 'ID профайла подписки')
;


/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.event_notify (
  event_id      INTEGER REFERENCES wsd.event
, account_id    INTEGER
, role_id       INTEGER
, is_new        BOOL NOT NULL DEFAULT TRUE
-- , folder_id     INTEGER -- REFERENCES event_notify_folder
, cause_id      INTEGER NOT NULL
, read_at       TIMESTAMP(0)
, read_by       INTEGER
, deleted_at    TIMESTAMP(0)
, deleted_by    INTEGER
, notify_at     TIMESTAMP(0)
, notify_data   TEXT
, confirm_at    TIMESTAMP(0)
, confirm_data  TEXT
, CONSTRAINT  event_notify_pkey PRIMARY KEY (event_id, account_id, role_id, cause_id)
);
SELECT pg_c('r', 'wsd.event_notify'           , 'Уведомление')
, pg_c('c', 'wsd.event_notify.event_id', 'ID события')
, pg_c('c', 'wsd.event_notify.account_id'             , 'ID пользователя')
, pg_c('c', 'wsd.event_notify.role_id'        , 'ID роли пользователя')
, pg_c('c', 'wsd.event_notify.cause_id'       , 'ID причины связывания')
, pg_c('c', 'wsd.event_notify.read_at'        , 'время прочтения')
, pg_c('c', 'wsd.event_notify.read_by'        , 'SID пользователя')
, pg_c('c', 'wsd.event_notify.deleted_at'     , 'время удаления')
, pg_c('c', 'wsd.event_notify.deleted_by'     , 'SID пользователя')
, pg_c('c', 'wsd.event_notify.notify_at'      , 'время отправки дополнительного уведомления (согласно профайлу)')
, pg_c('c', 'wsd.event_notify.notify_data'    , 'ID доп. уведомления (message ID письма и т.п.)')
, pg_c('c', 'wsd.event_notify.confirm_at'     , 'время получения уведомления о доставке')
, pg_c('c', 'wsd.event_notify.confirm_data'   , 'результат отправки доп. уведомления')
;
/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.event_notify_spec (
  event_id    INTEGER
, account_id  INTEGER
, role_id     INTEGER
, spec_id     INTEGER
, CONSTRAINT  event_notify_spec_pkey PRIMARY KEY (event_id, account_id, role_id, spec_id)
);
SELECT pg_c('r', 'wsd.event_notify_spec'      , 'Спецификация уведомления')
, pg_c('c', 'wsd.event_notify_spec.event_id'  , 'ID события')
, pg_c('c', 'wsd.event_notify_spec.account_id', 'ID пользователя')
, pg_c('c', 'wsd.event_notify_spec.role_id'   , 'ID пользователя')
, pg_c('c', 'wsd.event_notify_spec.spec_id'   , 'ID спецификации')
;
