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

*/
-- 21_main.sql - Таблицы API
/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:20_auth.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE TABLE account_group (
  id                d_id32      PRIMARY KEY
  , name            text        NOT NULL
  , anno            text        NOT NULL
);

/* ------------------------------------------------------------------------- */
CREATE TABLE account (
  id                d_id        PRIMARY KEY
  , group_id        d_id32      NOT NULL REFERENCES account_group
  , status_id       d_id32      NOT NULL DEFAULT 1
  , login           d_code      NOT NULL UNIQUE
  , email           d_email     NOT NULL
  , psw             text        NOT NULL
  , name            text        NOT NULL
  , created_at      ws.d_stamp  NOT NULL DEFAULT CURRENT_TIMESTAMP
  , updated_at      ws.d_stamp  NOT NULL DEFAULT CURRENT_TIMESTAMP
  , pws_updated_at  ws.d_stamp  NOT NULL DEFAULT CURRENT_TIMESTAMP

);

CREATE SEQUENCE account_id_seq;
ALTER TABLE account ALTER COLUMN id SET DEFAULT NEXTVAL('account_id_seq');

SELECT pg_c('t', 'account', 'Пользователь wiki')
  , pg_c('c', 'account.pws_updated_at', 'Момент изменения пароля')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE session (
  id           d_id PRIMARY KEY
  , account_id    d_id  NOT NULL REFERENCES account
  , ip         text  NOT NULL
  , sid        text
  , created_at ws.d_stamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  , deleted_at ws.d_stamp
);

CREATE SEQUENCE session_id_seq;
ALTER TABLE session ALTER COLUMN id SET DEFAULT NEXTVAL('session_id_seq');

SELECT pg_c('t', 'session', 'Сессия авторизованного пользователя wiki')
  , pg_c('c', 'session.deleted_at', 'Признак и время завершения сессии')
;

CREATE INDEX sid_deleted_at ON session (sid, deleted_at);

/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:20_auth.sql / 74 --'
