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

    Добавление объектов в схему wsd
*/

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.pkg_script_protected (code, pkg, ver) VALUES (:'FILE', :'PKG', :'VER');

SET LOCAL search_path = ws, i18n_def, public;

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.account_group (
  id                INTEGER      PRIMARY KEY
  , name            TEXT        NOT NULL
  , anno            TEXT        NOT NULL
);

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.account (
  id                INTEGER       PRIMARY KEY
  , group_id        INTEGER       NOT NULL REFERENCES wsd.account_group
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
SELECT pg_c('t', 'wsd.account', 'Пользователь')
  , pg_c('c', 'wsd.account.psw_updated_at', 'Момент изменения пароля')
;

CREATE SEQUENCE wsd.account_id_seq;
ALTER TABLE wsd.account ALTER COLUMN id SET DEFAULT NEXTVAL('wsd.account_id_seq');

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.session (
  id           INTEGER      PRIMARY KEY
  , account_id INTEGER      NOT NULL REFERENCES wsd.account
  , ip         TEXT         NOT NULL
  , sid        TEXT
  , created_at TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
  , updated_at TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
  , deleted_at TIMESTAMP(0)
);
SELECT pg_c('t', 'wsd.session', 'Сессия авторизованного пользователя')
  , pg_c('c', 'wsd.session.deleted_at', 'Признак и время завершения сессии')
;

CREATE SEQUENCE wsd.session_id_seq;
ALTER TABLE wsd.session ALTER COLUMN id SET DEFAULT NEXTVAL('wsd.session_id_seq');

/* ------------------------------------------------------------------------- */
CREATE INDEX sid_deleted_at ON wsd.session (sid, deleted_at);
