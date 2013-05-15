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
CREATE TABLE wsd.team (
  id              INTEGER    PRIMARY KEY
, status_id       INTEGER    NOT NULL
, name            TEXT
, created_at      TIMESTAMP(0)  NOT NULL DEFAULT CURRENT_TIMESTAMP
);
SELECT pg_c('r', 'wsd.team', 'Команда пользователей')
, pg_c('c', 'wsd.team.id',        'd_id,     ID группы')
, pg_c('c', 'wsd.team.status_id', 'd_id32,   ID статуса')
, pg_c('c', 'wsd.team.name',      'd_string, Название команды')
;
CREATE SEQUENCE wsd.team_id_seq;
ALTER TABLE wsd.team ALTER COLUMN id SET DEFAULT NEXTVAL('wsd.team_id_seq');

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.role (
  id              INTEGER       PRIMARY KEY
, team_id         INTEGER           NULL REFERENCES wsd.team
, name            TEXT          NOT NULL
, anno            TEXT          NOT NULL
);
SELECT pg_c('r', 'wsd.role', 'Роль пользователя')
, pg_c('c', 'wsd.role.id',      'd_id,     ID роли')
, pg_c('c', 'wsd.role.team_id', 'd_id,     ID команды (NULL для типовых ролей)')
, pg_c('c', 'wsd.role.name',    'd_string, Название')
, pg_c('c', 'wsd.role.anno',    'd_text,   Описание')
;

CREATE SEQUENCE wsd.role_id_seq;
ALTER TABLE wsd.role ALTER COLUMN id SET DEFAULT NEXTVAL('wsd.role_id_seq');

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.account (
  id              INTEGER        PRIMARY KEY
, status_id       INTEGER        NOT NULL DEFAULT 1
, login           TEXT           NOT NULL UNIQUE
, psw             TEXT           NOT NULL
, name            TEXT
, is_psw_plain    BOOL           NOT NULL DEFAULT TRUE
, is_ip_checked   BOOL           NOT NULL DEFAULT TRUE
, created_at      TIMESTAMP(0)   NOT NULL DEFAULT CURRENT_TIMESTAMP
, updated_at      TIMESTAMP(0)   NOT NULL DEFAULT CURRENT_TIMESTAMP
, psw_updated_at  TIMESTAMP(0)   NOT NULL DEFAULT CURRENT_TIMESTAMP
);
SELECT pg_c('r', 'wsd.account', 'Учетные записи пользователей')
, pg_c('c', 'wsd.account.id',             'd_id,     ID пользователя')
, pg_c('c', 'wsd.account.status_id',      'd_id32,   ID статуса')
, pg_c('c', 'wsd.account.login',          'd_string, Имя для авторизации на сайте')
, pg_c('c', 'wsd.account.psw',            'd_string, Пароль')
, pg_c('c', 'wsd.account.is_psw_plain',   'Пароль хранить незашифрованным')
, pg_c('c', 'wsd.account.is_ip_checked',  'IP проверять при валидации сессии')
, pg_c('c', 'wsd.account.created_at',     'd_stamp,  Момент регистрации')
, pg_c('c', 'wsd.account.updated_at',     'd_stamp,  Момент обновления записи')
, pg_c('c', 'wsd.account.psw_updated_at', 'd_stamp   Момент изменения пароля')
;

CREATE SEQUENCE wsd.account_id_seq;
ALTER TABLE wsd.account ALTER COLUMN id SET DEFAULT NEXTVAL('wsd.account_id_seq');

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.account_team (
  account_id      INTEGER      NOT NULL REFERENCES wsd.account
, role_id         INTEGER      NOT NULL REFERENCES wsd.role
, team_id         INTEGER      NOT NULL REFERENCES wsd.team
, is_default      BOOL         NOT NULL DEFAULT TRUE
, CONSTRAINT account_team_pkey PRIMARY KEY (account_id, team_id)
);
SELECT pg_c('r', 'wsd.account_team', 'Роли учетной записи')
, pg_c('c', 'wsd.account_team.account_id', 'd_id, ID учетной записи')
, pg_c('c', 'wsd.account_team.role_id',    'd_id, ID роли')
, pg_c('c', 'wsd.account_team.team_id',    'd_id, ID команды')
, pg_c('c', 'wsd.account_team.is_default', 'Является ролью по умолчанию')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.account_contact (
  account_id      INTEGER       NOT NULL REFERENCES wsd.account
, contact_type_id INTEGER       NOT NULL REFERENCES acc.account_contact_type
, value           TEXT
, created_at      TIMESTAMP(0)
, verified_at     TIMESTAMP(0)
, deleted_at      TIMESTAMP(0)
, CONSTRAINT account_contact_pkey PRIMARY KEY (account_id, contact_type_id, value)
);
SELECT pg_c('r', 'wsd.account_contact', 'Контакты пользователей')
, pg_c('c', 'wsd.account_contact.account_id',      'd_id,     ID пользователя')
, pg_c('c', 'wsd.account_contact.contact_type_id', 'd_id32,   ID типа контакта')
, pg_c('c', 'wsd.account_contact.value',           'd_string, Значение контакта')
, pg_c('c', 'wsd.account_contact.created_at',      'd_stamp,  Момент создания')
, pg_c('c', 'wsd.account_contact.verified_at',     'd_stamp,  Момент подтверждения')
, pg_c('c', 'wsd.account_contact.deleted_at',      'd_stamp,  Момент удаления')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.session (
  id            INTEGER        PRIMARY KEY
, account_id    INTEGER        NOT NULL REFERENCES wsd.account
, role_id       INTEGER        NOT NULL REFERENCES wsd.role
, team_id       INTEGER        REFERENCES wsd.team
, sid           TEXT
, ip            TEXT           NOT NULL
, is_ip_checked BOOL           NOT NULL
, created_at    TIMESTAMP(0)   NOT NULL DEFAULT CURRENT_TIMESTAMP
, updated_at    TIMESTAMP(0)   NOT NULL DEFAULT CURRENT_TIMESTAMP
, deleted_at    TIMESTAMP(0)
, CONSTRAINT session_sid_key UNIQUE (sid, deleted_at) -- TODO: доработать обеспечение уникальности активных sid
);
SELECT pg_c('r', 'wsd.session', 'Сессия авторизованного пользователя')
, pg_c('c', 'wsd.session.id',            'd_id,     ID сессии')
, pg_c('c', 'wsd.session.account_id',    'd_id,     ID пользователя')
, pg_c('c', 'wsd.session.role_id',       'd_id,     ID роли')
, pg_c('c', 'wsd.session.team_id',       'd_id,     ID команды')
, pg_c('c', 'wsd.session.sid',           'd_string, Код сессии')
, pg_c('c', 'wsd.session.ip',            'd_string, IP пользователя')
, pg_c('c', 'wsd.session.is_ip_checked', 'Проверять IP авторизованного пользователя')
, pg_c('c', 'wsd.session.created_at',    'd_stamp,  Момент создания сессии')
, pg_c('c', 'wsd.session.updated_at',    'd_stamp,  Момент обновления сессии')
, pg_c('c', 'wsd.session.deleted_at',    'd_stamp,  Признак и момент завершения сессии')
;

CREATE SEQUENCE wsd.session_id_seq;
ALTER TABLE wsd.session ALTER COLUMN id SET DEFAULT NEXTVAL('wsd.session_id_seq');

/* TODO
CREATE TABLE wsd.session_log (LIKE wsd.session INCLUDING CONSTRAINTS INCLUDING COMMENTS);
*/
/* ------------------------------------------------------------------------- */
CREATE INDEX sid_deleted_at ON wsd.session (sid, deleted_at);

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.permission (
  id            INTEGER   NOT NULL PRIMARY KEY
, team_id       INTEGER       NULL REFERENCES wsd.team
, name          TEXT      NOT NULL
, pkg           TEXT      NOT NULL DEFAULT ws.pg_cs() 
);
SELECT pg_c('r', 'wsd.permission', 'Разрешение')
, pg_c('c', 'wsd.permission.id',      'd_id,     ID разрешения')
, pg_c('c', 'wsd.permission.team_id', 'd_id,     ID команды')
, pg_c('c', 'wsd.permission.name',    'd_string, Название')
, pg_c('c', 'wsd.permission.pkg',     'Пакет, установивший разрешение')
;

CREATE SEQUENCE wsd.permission_id_seq;
ALTER TABLE wsd.permission ALTER COLUMN id SET DEFAULT NEXTVAL('wsd.permission_id_seq');

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.role_permission (
  role_id       INTEGER   NOT NULL REFERENCES wsd.role
, perm_id       INTEGER   NOT NULL REFERENCES wsd.permission
, CONSTRAINT role_permission_pkey PRIMARY KEY (role_id, perm_id)
);
SELECT pg_c('r', 'wsd.role_permission', 'Разрешения ролей')
, pg_c('c', 'wsd.role_permission.role_id', 'd_id, ID роли')
, pg_c('c', 'wsd.role_permission.perm_id', 'd_id, ID разрешения')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.permission_acl (
  perm_id       INTEGER    NOT NULL
, class_id      INTEGER    NOT NULL
, link_id       INTEGER    NOT NULL
, team_link_id  INTEGER    NOT NULL REFERENCES acc.team_link
, acl_id        INTEGER    NOT NULL
, CONSTRAINT permission_acl_pkey PRIMARY KEY (perm_id, class_id, link_id, team_link_id, acl_id)
);
SELECT pg_c('r', 'wsd.permission_acl', 'Соответствие разрешений уровням доступа')
, pg_c('c', 'wsd.permission_acl.perm_id',      'd_id,    ID разрешения роли')
, pg_c('c', 'wsd.permission_acl.class_id',     'd_class, ID класса')
, pg_c('c', 'wsd.permission_acl.link_id',      'd_id32,  ID связи')
, pg_c('c', 'wsd.permission_acl.team_link_id', 'd_id32,  ID связи с командой')
, pg_c('c', 'wsd.permission_acl.acl_id',       'd_acl,   ID уровня доступа')
;

/* ------------------------------------------------------------------------- */
