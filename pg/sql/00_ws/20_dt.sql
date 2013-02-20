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
-- 20_dt.sql - Таблицы типов данных
/* ------------------------------------------------------------------------- */

/* ------------------------------------------------------------------------- */
CREATE TABLE dt (
  id         d_id32 PRIMARY KEY
, code       d_code NOT NULL UNIQUE
, parent_id  d_id32 REFERENCES dt
, base_id    d_id32 REFERENCES dt
, allow_null bool   NOT NULL DEFAULT TRUE
, def_val    text   --
, anno       text   NOT NULL
, is_list    bool   NOT NULL DEFAULT FALSE -- для производных типов
, is_complex bool   NOT NULL DEFAULT FALSE -- для производных типов
, is_sql     bool   NOT NULL DEFAULT FALSE -- для производных типов
, CONSTRAINT dt_id_base_id_key UNIQUE (id, base_id) -- fk таблицы dt_facet
);
SELECT pg_c('r', 'dt', 'Описание типа')
, pg_c('c', 'dt.id',         'ID типа')
, pg_c('c', 'dt.code',       'Код типа')
, pg_c('c', 'dt.parent_id',  'ID родительского типа')
, pg_c('c', 'dt.base_id',    'ID базового типа')
, pg_c('c', 'dt.allow_null', 'Разрешен NULL')
, pg_c('c', 'dt.def_val',    'Значение по умолчанию')
, pg_c('c', 'dt.anno',       'Аннотация')
, pg_c('c', 'dt.is_list',    'Конструктор типа - массив')
, pg_c('c', 'dt.is_complex', 'Конструктор типа - структура')
, pg_c('c', 'dt.is_sql',     'Тип создан в БД')
;

CREATE SEQUENCE dt_id_seq START 100;
ALTER TABLE dt ALTER COLUMN id SET DEFAULT NEXTVAL('dt_id_seq');

/* ------------------------------------------------------------------------- */
CREATE TABLE dt_part (
  id         d_id32 NOT NULL REFERENCES dt
, part_id    d_cnt  DEFAULT 0 -- >0 для комплексных типов
, code       d_code_arg NOT NULL
, parent_id  d_id32 NOT NULL REFERENCES dt
, base_id    d_id32 NOT NULL REFERENCES dt
, allow_null bool   NOT NULL DEFAULT TRUE
, def_val    text   --
, anno       text   NOT NULL
, is_list    bool   NOT NULL DEFAULT FALSE -- для производных типов
, CONSTRAINT dt_part_pkey PRIMARY KEY (id, part_id)
, CONSTRAINT dt_part_id_code_key UNIQUE (id, code)
);
SELECT pg_c('r', 'dt_part', 'Поля композитного типа')
, pg_c('c', 'dt_part.id',         'ID комплексного типа')
, pg_c('c', 'dt_part.part_id',    'ID поля')
, pg_c('c', 'dt_part.code',       'Код поля')
, pg_c('c', 'dt_part.parent_id',  'ID родительского типа')
, pg_c('c', 'dt_part.base_id',    'ID базового типа')
, pg_c('c', 'dt_part.allow_null', 'Разрешен NULL')
, pg_c('c', 'dt_part.def_val',    'Значение по умолчанию')
, pg_c('c', 'dt_part.anno',       'Аннотация')
, pg_c('c', 'dt_part.is_list',    'Конструктор поля - массив')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE facet (
  id         d_id32  PRIMARY KEY
, code       d_codei NOT NULL
, anno       text    NOT NULL
);
SELECT pg_c('r', 'facet', 'Вид ограничений типов')
, pg_c('c', 'facet.id',   'ID ограничения')
, pg_c('c', 'facet.code', 'Код ограничения')
, pg_c('c', 'facet.anno', 'Аннотация')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE facet_dt_base (
  id         d_id32 REFERENCES facet
, base_id    d_id32 REFERENCES dt
, CONSTRAINT facet_dt_base_pkey PRIMARY KEY (id, base_id)
);
SELECT pg_c('r', 'facet_dt_base', 'Для какого базового типа применимо ограничение')
, pg_c('c', 'facet_dt_base.id',      'ID ограничения')
, pg_c('c', 'facet_dt_base.base_id', 'ID базового типа')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE dt_facet (
  id         d_id32
, facet_id   d_id32
, value      text   NOT NULL -- несколько pattern сводятся в один через OR
, base_id    d_id32 NOT NULL
, anno       text
, CONSTRAINT dt_facet_pkey PRIMARY KEY (id, facet_id)
, CONSTRAINT dt_facet_fkey_dt FOREIGN KEY (id, base_id) REFERENCES dt(id, base_id)
, CONSTRAINT dt_facet_fkey_facet_dt_base FOREIGN KEY (facet_id, base_id) REFERENCES facet_dt_base
);
SELECT pg_c('r', 'dt_facet', 'Значение ограничения типа')
, pg_c('c', 'dt_facet.id',       'ID типа')
, pg_c('c', 'dt_facet.facet_id', 'ID ограничения')
, pg_c('c', 'dt_facet.value',    'Значение ограничения')
, pg_c('c', 'dt_facet.base_id',  'ID базового типа')
, pg_c('c', 'dt_facet.anno',     'Аннотация ограничения')
;
/* ------------------------------------------------------------------------- */
