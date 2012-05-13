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
-- 20_pkg.sql - Таблицы для компиляции и установки пакетов
/* ------------------------------------------------------------------------- */
\qecho '-- FD: pgws:ws:19_ws_data.sql / 23 --'

CREATE SCHEMA ws_data;

/* ------------------------------------------------------------------------- */
CREATE TABLE ws_data.pkg (
  id            INTEGER PRIMARY KEY
  , code        TEXT NOT NULL DEFAULT 'ws'
  , ver         TEXT NOT NULL DEFAULT '000'
  , is_add      BOOL DEFAULT TRUE
  , log_name    TEXT
  , user_name   TEXT
  , ssh_client  TEXT
  , db_user     TEXT DEFAULT current_user
  , db_ip       INET DEFAULT inet_client_addr()
  , stamp       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  , rm_id       INTEGER REFERENCES ws_data.pkg
);

COMMENT ON TABLE ws_data.pkg IS 'Пакеты PGWS';

CREATE SEQUENCE ws_data.pkg_id_seq;
ALTER TABLE ws_data.pkg ALTER COLUMN id SET DEFAULT NEXTVAL('ws_data.pkg_id_seq');

/* ------------------------------------------------------------------------- */
CREATE TABLE ws_data.pkg_data (
  code          TEXT PRIMARY KEY DEFAULT 'ws_data'
  , ver         TEXT NOT NULL DEFAULT '000'
  , stamp       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO ws_data.pkg_data (code, ver) VALUES (DEFAULT, DEFAULT);
/* ------------------------------------------------------------------------- */
\qecho '-- FD: pgws:ws:19_ws_data.sql / 56 --'