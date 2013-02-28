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

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.team (
  id              INTEGER      PRIMARY KEY
, name            TEXT        NOT NULL
, anno            TEXT        NOT NULL
);
SELECT pg_c('r', 'wsd.team', 'Группа пользователей')
, pg_c('c', 'wsd.team.id', 'ID группы')
;
CREATE SEQUENCE wsd.team_id_seq;
ALTER TABLE wsd.team ALTER COLUMN id SET DEFAULT NEXTVAL('wsd.team_id_seq');

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.role (
  id              INTEGER       PRIMARY KEY
, level_id        INTEGER       NOT NULL            -- REFERENCES acc.role_level
, has_team        BOOL          NOT NULL DEFAULT TRUE
, name            TEXT          NOT NULL
, anno            TEXT          NOT NULL
);
SELECT pg_c('r', 'wsd.role', 'Глобальная роль')
, pg_c('c', 'wsd.role.id', 'ID роли')
;

CREATE SEQUENCE wsd.role_id_seq;
ALTER TABLE wsd.role ALTER COLUMN id SET DEFAULT NEXTVAL('wsd.role_id_seq');

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.role_team (
  role_id         INTEGER       PRIMARY KEY REFERENCES wsd.role
, team_id         INTEGER       NOT NULL REFERENCES wsd.team
);
SELECT pg_c('r', 'wsd.role_team', 'Роль группы пользователей')
, pg_c('c', 'wsd.role_team.team_id', 'ID группы')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.role_acl (
  role_id         INTEGER REFERENCES wsd.role
, class_id        INTEGER
, object_id       INTEGER
, acl_id          INTEGER
, CONSTRAINT role_acl_pkey PRIMARY KEY (role_id,class_id,object_id)
);
SELECT pg_c('r', 'wsd.role_acl', 'ACL глобальной роли')
, pg_c('c', 'wsd.role_acl.role_id', 'ID роли')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.account (
  id              INTEGER       PRIMARY KEY
, status_id       INTEGER       NOT NULL DEFAULT 1
, def_role_id     INTEGER       NOT NULL REFERENCES wsd.role
, login           TEXT          NOT NULL UNIQUE
, psw             TEXT          NOT NULL
, name            TEXT          NOT NULL
, is_psw_plain    BOOL          NOT NULL DEFAULT TRUE
, is_ip_checked   BOOL          NOT NULL DEFAULT TRUE
, created_at      TIMESTAMP(0)  NOT NULL DEFAULT CURRENT_TIMESTAMP
, updated_at      TIMESTAMP(0)  NOT NULL DEFAULT CURRENT_TIMESTAMP
, psw_updated_at  TIMESTAMP(0)  NOT NULL DEFAULT CURRENT_TIMESTAMP
);
SELECT pg_c('r', 'wsd.account', 'Учетные записи пользователей')
, pg_c('c', 'wsd.account.def_role_id', 'ID роли по умолчанию')
, pg_c('c', 'wsd.account.is_psw_plain', 'Пароль хранить незашифрованным')
, pg_c('c', 'wsd.account.is_ip_checked', 'IP проверять при валидации сессии')
, pg_c('c', 'wsd.account.psw_updated_at', 'Момент изменения пароля')
;

CREATE SEQUENCE wsd.account_id_seq;
ALTER TABLE wsd.account ALTER COLUMN id SET DEFAULT NEXTVAL('wsd.account_id_seq');

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.account_role (
  account_id      INTEGER      NOT NULL REFERENCES wsd.account
, role_id        INTEGER       NOT NULL REFERENCES wsd.role
, CONSTRAINT account_role_pkey PRIMARY KEY (account_id, role_id)
);
SELECT pg_c('r', 'wsd.account_role', 'Роли учетной записи')
, pg_c('c', 'wsd.account_role.account_id', 'ID учетной записи')
, pg_c('c', 'wsd.account_role.role_id', 'ID роли')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.account_contact (
  account_id      INTEGER      NOT NULL REFERENCES wsd.account
, contact_type_id INTEGER      NOT NULL
, value           TEXT
, varified_at     TIMESTAMP(0)
, deleted_at      TIMESTAMP(0)
, CONSTRAINT account_contact_pkey PRIMARY KEY (account_id, contact_type_id, value)
);
SELECT pg_c('r', 'wsd.account_contact',         'Контакты учетной записи')
, pg_c('c', 'wsd.account_contact.account_id',      'ID учетной записи')
, pg_c('c', 'wsd.account_contact.contact_type_id', 'ID типа контакта')
;
/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.session (
  id         INTEGER      PRIMARY KEY
, account_id INTEGER      NOT NULL REFERENCES wsd.account
, role_id    INTEGER      NOT NULL REFERENCES wsd.role -- текущая роль
, sid        TEXT
, ip         TEXT         NOT NULL
, is_ip_checked BOOL      NOT NULL
, created_at TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
, updated_at TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
, deleted_at TIMESTAMP(0)
, CONSTRAINT session_sid_key UNIQUE (sid)
);
SELECT pg_c('r', 'wsd.session', 'Сессия авторизованного пользователя')
, pg_c('c', 'wsd.session.deleted_at', 'Признак и время завершения сессии')
;

CREATE SEQUENCE wsd.session_id_seq;
ALTER TABLE wsd.session ALTER COLUMN id SET DEFAULT NEXTVAL('wsd.session_id_seq');

/* TODO
CREATE TABLE wsd.session_log (LIKE wsd.session INCLUDING CONSTRAINTS INCLUDING COMMENTS);
*/
/* ------------------------------------------------------------------------- */
CREATE INDEX sid_deleted_at ON wsd.session (sid, deleted_at);
