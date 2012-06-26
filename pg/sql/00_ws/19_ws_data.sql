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
CREATE TABLE ws_data.pkg_oper (
  code          TEXT PRIMARY KEY DEFAULT 'ws_data'
  , ver         TEXT NOT NULL DEFAULT '000'
  , stamp       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE ws_data.pkg_oper IS 'Оперативные данные пакетов PGWS';

INSERT INTO ws_data.pkg_oper (code, ver) VALUES (DEFAULT, DEFAULT);


CREATE TABLE ws_data.cfg_value (
  class_id    INTEGER  NOT NULL -- REFERENCES class
  , code      TEXT
  , id        INTEGER
  , value     TEXT
  , CONSTRAINT сfg_value_pkey PRIMARY KEY (class_id, code, id)
);

CREATE TABLE ws_data.cfg_timed_value (
  class_id   INTEGER  NOT NULL -- REFERENCES class
  , code      TEXT
  , id        INTEGER
  , valid_from DATE NOT NULL
  , value     TEXT
  , CONSTRAINT сfg_timed_value_pkey PRIMARY KEY (class_id, code, id, valid_from)
);

/* ------------------------------------------------------------------------- */
\qecho '-- FD: pgws:ws:19_ws_data.sql / 57 --'
