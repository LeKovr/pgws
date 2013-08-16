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
COMMENT ON SCHEMA wsd IS 'WebService (PGWS) realtime Data';

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.ref_update (
  code        TEXT
, item_code   TEXT
, lang        TEXT -- DEFAULT ws.const_lang_default() -- 'def'
, op          TEXT NOT NULL
, updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
, CONSTRAINT ref_update_pkey PRIMARY KEY (code, item_code, lang)
);
SELECT pg_c('r', 'wsd.ref_update', 'Обновления позиций справочников')
, pg_c('c', 'wsd.ref_update.code',        'Код справочника')
, pg_c('c', 'wsd.ref_update.item_code',   'Код позиции')
, pg_c('c', 'wsd.ref_update.lang',        'Языковая схема справочника')
, pg_c('c', 'wsd.ref_update.op',          'Код произведенного изменения')
, pg_c('c', 'wsd.ref_update.updated_at',  'Момент времени измененния')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.pkg_script_protected (
  pkg         name
, schema      name
, code        TEXT
, csum        TEXT NOT NULL
, created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
, CONSTRAINT  pkg_script_protected_pkey PRIMARY KEY (pkg, schema, code)
);
COMMENT ON TABLE wsd.pkg_script_protected IS 'Оперативные данные пакетов PGWS';


/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.pkg_fkey_protected (
  pkg         name
, wsd_rel     name
, wsd_col     text
, rel         name
, is_active   bool NOT NULL DEFAULT FALSE
, schema      name -- NOT NULL только для 2й схемы пакета
, CONSTRAINT pkg_fkey_protected_pkey PRIMARY KEY (pkg, wsd_rel, wsd_col)
);

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.pkg_fkey_required_by (
  pkg         name 
, rel         name
, required_by name
, CONSTRAINT pkg_fkey_required_by_pkey PRIMARY KEY (pkg, rel, required_by)
);
-- TODO: В триггере на INSERT проверять, что в wsd.pkg_fkey_protected есть такая пара pkg,rel

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.pkg_default_protected (
  pkg         name
, wsd_rel     name NOT NULL
, wsd_col     text NOT NULL
, func        name
, is_active   bool NOT NULL DEFAULT FALSE
, schema      name NOT NULL DEFAULT 'ws' -- только для 1й схемы пакета ws
, CONSTRAINT pkg_default_protected_pkey PRIMARY KEY (pkg, wsd_rel, wsd_col)
);

/* ------------------------------------------------------------------------- */
/*
-- TODO - контролировать триггерами на INSERT
 INSERT INTO wsd.pkg_fkey_protected (pkg, wsd_rel, wsd_col, rel) VALUES
  ('ws', 'pkg_script_protected', 'pkg',         'ws.pkg')     -- мешает удалению пакета при drop
, ('ws', 'pkg_fkey_protected',   'pkg',         'ws.pkg')     -- мешает удалению пакета при drop
, ('ws', 'pkg_fkey_required_by', 'required_by', 'ws.pkg')     --мешает сборке
, ('ws', 'pkg_fkey_required_by', 'pkg,required_by', 'ws.pkg_required_by') -- мешает сборке
 ;
*/

INSERT INTO wsd.pkg_default_protected (pkg, wsd_rel, wsd_col, func) VALUES
  ('ws', 'pkg_script_protected',  'pkg',          'ws.pg_cs()')
, ('ws', 'pkg_script_protected',  'schema',       'ws.pg_cs()')
, ('ws', 'pkg_default_protected', 'pkg',          'ws.pg_cs()')
, ('ws', 'pkg_default_protected', 'schema',       'ws.pg_cs()')
, ('ws', 'pkg_fkey_protected',    'pkg',          'ws.pg_cs()')
, ('ws', 'pkg_fkey_protected',    'schema',       'ws.pg_cs()')
, ('ws', 'pkg_fkey_required_by',  'required_by',  'ws.pg_cs()')
, ('ws', 'ref_update',            'lang',         'ws.const_lang_default()')
;
/* ------------------------------------------------------------------------- */
