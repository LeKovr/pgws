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

    Схема изменяемых в процессе эксплуатации данных и ее базовые объекты
*/

/* ------------------------------------------------------------------------- */
CREATE SCHEMA wsd;
COMMENT ON SCHEMA wsd IS 'WebService (PGWS) data';

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.pkg_script_protected (
  pkg         TEXT
, code        TEXT
, ver         TEXT DEFAULT '000'
, schema      TEXT
, created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
, CONSTRAINT  pkg_script_protected_pkey PRIMARY KEY (pkg, code, ver)
);
COMMENT ON TABLE wsd.pkg_script_protected IS 'Оперативные данные пакетов PGWS';

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.pkg_script_protected (pkg, code, ver, schema) VALUES (:'PKG', :'FILE', :'VER', :'PKG');

