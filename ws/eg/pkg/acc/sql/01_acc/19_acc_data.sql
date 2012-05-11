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
--  19_acc_data.sql - Создание схемы acc_data и ее объектов.
-- Выполняется только при отсутствии схемы acc_data
/* ------------------------------------------------------------------------- */
\qecho '-- FD: acc:acc:19_acc_data.sql / 24 --'

/* ------------------------------------------------------------------------- */
CREATE SCHEMA acc_data;

/* ------------------------------------------------------------------------- */
CREATE TABLE acc_data.account_group (
  id                INTEGER      PRIMARY KEY
  , name            TEXT        NOT NULL
  , anno            TEXT        NOT NULL
);

/* ------------------------------------------------------------------------- */
CREATE TABLE acc_data.account (
  id                INTEGER       PRIMARY KEY
  , group_id        INTEGER       NOT NULL REFERENCES acc_data.account_group
  , status_id       INTEGER       NOT NULL DEFAULT 1
  , login           TEXT          NOT NULL UNIQUE
  , email           TEXT          NOT NULL
  , psw             TEXT          NOT NULL
  , name            TEXT          NOT NULL
  , is_psw_plain    BOOL          NOT NULL DEFAULT TRUE
  , created_at      TIMESTAMP(0)  NOT NULL DEFAULT CURRENT_TIMESTAMP
  , updated_at      TIMESTAMP(0)  NOT NULL DEFAULT CURRENT_TIMESTAMP
  , psw_updated_at  TIMESTAMP(0)  NOT NULL DEFAULT CURRENT_TIMESTAMP
);
SELECT pg_c('t', 'acc_data.account', 'Пользователь wiki')
  , pg_c('c', 'acc_data.account.psw_updated_at', 'Момент изменения пароля')
;

CREATE SEQUENCE acc_data.account_id_seq;
ALTER TABLE acc_data.account ALTER COLUMN id SET DEFAULT NEXTVAL('acc_data.account_id_seq');

/* ------------------------------------------------------------------------- */
CREATE TABLE acc_data.session (
  id           INTEGER      PRIMARY KEY
  , account_id INTEGER      NOT NULL REFERENCES acc_data.account
  , ip         TEXT         NOT NULL
  , sid        TEXT
  , created_at TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
  , updated_at TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
  , deleted_at TIMESTAMP(0)
);
SELECT pg_c('t', 'acc_data.session', 'Сессия авторизованного пользователя wiki')
  , pg_c('c', 'acc_data.session.deleted_at', 'Признак и время завершения сессии')
;

CREATE SEQUENCE acc_data.session_id_seq;
ALTER TABLE acc_data.session ALTER COLUMN id SET DEFAULT NEXTVAL('acc_data.session_id_seq');

/* ------------------------------------------------------------------------- */
CREATE INDEX sid_deleted_at ON acc_data.session (sid, deleted_at);

/* ------------------------------------------------------------------------- */
SELECT ws.pkg_data_add('acc_data');

/* ------------------------------------------------------------------------- */
INSERT INTO acc_data.account_group (id, name, anno) VALUES
  (1, 'Readers', '')
  , (2, 'Writers', '')
;

/* ------------------------------------------------------------------------- */
INSERT INTO acc_data.account (id, group_id, login, email, psw, name) VALUES
  (1, 2, 'admin', 'admin@pgws.local', ((random()*10^16)::bigint)::text, 'Admin')
;

/* ------------------------------------------------------------------------- */
\qecho '-- FD: acc:acc:19_acc_data.sql / 92 --'
