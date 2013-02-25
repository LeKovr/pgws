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
  code          d_code PRIMARY KEY
, parent_code   d_code REFERENCES dt
, base_code     d_code REFERENCES dt
, allow_null    bool   NOT NULL DEFAULT TRUE
, def_val       text   --
, anno          text   NOT NULL
, is_list       bool   NOT NULL DEFAULT FALSE -- для производных типов
, is_complex    bool   NOT NULL DEFAULT FALSE -- для производных типов
, is_sql        bool   NOT NULL DEFAULT FALSE -- для производных типов
, CONSTRAINT dt_code_base_code_key UNIQUE (code, base_code) -- fk таблицы dt_facet
);
SELECT pg_c('r', 'dt', 'Описание типа')
, pg_c('c', 'dt.code',       'Код типа')
, pg_c('c', 'dt.parent_code','Код родительского типа')
, pg_c('c', 'dt.base_code',  'Код базового типа')
, pg_c('c', 'dt.allow_null', 'Разрешен NULL')
, pg_c('c', 'dt.def_val',    'Значение по умолчанию')
, pg_c('c', 'dt.anno',       'Аннотация')
, pg_c('c', 'dt.is_list',    'Конструктор типа - массив')
, pg_c('c', 'dt.is_complex', 'Конструктор типа - структура')
, pg_c('c', 'dt.is_sql',     'Тип создан в БД')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE dt_part (
  dt_code       d_code NOT NULL REFERENCES dt
, part_id       d_cnt  DEFAULT 0 -- >0 для комплексных типов
, code          d_code_arg NOT NULL
, parent_code   d_code NOT NULL REFERENCES dt
, base_code     d_code NOT NULL REFERENCES dt
, allow_null    bool   NOT NULL DEFAULT TRUE
, def_val       text   --
, anno          text   NOT NULL
, is_list       bool   NOT NULL DEFAULT FALSE -- для производных типов
, CONSTRAINT dt_part_pkey PRIMARY KEY (dt_code, part_id)
, CONSTRAINT dt_part_id_code_key UNIQUE (dt_code, code)
);
SELECT pg_c('r', 'dt_part', 'Поля композитного типа')
, pg_c('c', 'dt_part.dt_code',    'Код комплексного типа')
, pg_c('c', 'dt_part.part_id',    'ID поля')
, pg_c('c', 'dt_part.code',       'Код поля')
, pg_c('c', 'dt_part.parent_code','Код родительского типа')
, pg_c('c', 'dt_part.base_code',  'Код базового типа')
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
, base_code  d_code REFERENCES dt
, CONSTRAINT facet_dt_base_pkey PRIMARY KEY (id, base_code)
);
SELECT pg_c('r', 'facet_dt_base', 'Для какого базового типа применимо ограничение')
, pg_c('c', 'facet_dt_base.id',         'ID ограничения')
, pg_c('c', 'facet_dt_base.base_code',  'Код базового типа')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE dt_facet (
  code       d_code
, facet_id   d_id32
, value      text   NOT NULL -- несколько pattern сводятся в один через OR
, base_code  d_code NOT NULL
, anno       text
, CONSTRAINT dt_facet_pkey PRIMARY KEY (code, facet_id)
, CONSTRAINT dt_facet_fkey_dt FOREIGN KEY (code, base_code) REFERENCES dt(code, base_code)
, CONSTRAINT dt_facet_fkey_facet_dt_base FOREIGN KEY (facet_id, base_code) REFERENCES facet_dt_base
);
SELECT pg_c('r', 'dt_facet', 'Значение ограничения типа')
, pg_c('c', 'dt_facet.code',     'Код типа')
, pg_c('c', 'dt_facet.facet_id', 'ID ограничения')
, pg_c('c', 'dt_facet.value',    'Значение ограничения')
, pg_c('c', 'dt_facet.base_code','Код базового типа')
, pg_c('c', 'dt_facet.anno',     'Аннотация ограничения')
;
/* ------------------------------------------------------------------------- */
