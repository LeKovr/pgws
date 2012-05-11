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
\qecho '-- FD: pgws:ws:20_dt.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE TABLE dt (
  id           d_id32 PRIMARY KEY
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
COMMENT ON TABLE dt IS 'Описание типа';
COMMENT ON COLUMN dt.id          IS 'ID типа';
COMMENT ON COLUMN dt.code        IS 'Код типа';
COMMENT ON COLUMN dt.parent_id   IS 'ID родительского типа';
COMMENT ON COLUMN dt.base_id     IS 'ID базового типа';
COMMENT ON COLUMN dt.allow_null  IS 'Разрешен NULL';
COMMENT ON COLUMN dt.def_val     IS 'Значение по умолчанию';
COMMENT ON COLUMN dt.anno        IS 'Аннотация';
COMMENT ON COLUMN dt.is_list     IS 'Конструктор типа - массив';
COMMENT ON COLUMN dt.is_complex  IS 'Конструктор типа - структура';
COMMENT ON COLUMN dt.is_sql      IS 'Тип создан в БД';

CREATE SEQUENCE dt_id_seq START 100;
ALTER TABLE dt ALTER COLUMN id SET DEFAULT NEXTVAL('dt_id_seq');

/* ------------------------------------------------------------------------- */
CREATE TABLE dt_part (
  id           d_id32 NOT NULL REFERENCES dt
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
COMMENT ON TABLE dt_part IS 'Поля комплексного типа';
COMMENT ON COLUMN dt_part.id          IS 'ID комплексного типа';
COMMENT ON COLUMN dt_part.part_id     IS 'ID поля';
COMMENT ON COLUMN dt_part.code        IS 'Код поля';
COMMENT ON COLUMN dt_part.parent_id   IS 'ID родительского типа';
COMMENT ON COLUMN dt_part.base_id     IS 'ID базового типа';
COMMENT ON COLUMN dt_part.allow_null  IS 'Разрешен NULL';
COMMENT ON COLUMN dt_part.def_val     IS 'Значение по умолчанию';
COMMENT ON COLUMN dt_part.anno        IS 'Аннотация';
COMMENT ON COLUMN dt_part.is_list     IS 'Конструктор поля - массив';

/* ------------------------------------------------------------------------- */
CREATE TABLE facet (
  id           d_id32  PRIMARY KEY
  , code       d_codei NOT NULL
  , anno       text    NOT NULL
);
COMMENT ON TABLE facet IS 'Ограничение';
COMMENT ON COLUMN facet.id            IS 'ID ограничения';
COMMENT ON COLUMN facet.code          IS 'Код ограничения';
COMMENT ON COLUMN facet.anno          IS 'Аннотация';

/* ------------------------------------------------------------------------- */
CREATE TABLE facet_dt_base (
  id           d_id32 REFERENCES facet
  , base_id    d_id32 REFERENCES dt
  , CONSTRAINT facet_dt_base_pkey PRIMARY KEY (id, base_id)
);
COMMENT ON TABLE facet_dt_base IS 'Допустимое ограничение для типа';

/* ------------------------------------------------------------------------- */
CREATE TABLE dt_facet (
  id           d_id32
  , facet_id   d_id32
  , value      text   NOT NULL -- несколько pattern сводятся в один через OR
  , base_id    d_id32 NOT NULL
  , anno       text
  , CONSTRAINT dt_facet_pkey PRIMARY KEY (id, facet_id)
  , CONSTRAINT dt_facet_fkey_dt FOREIGN KEY (id, base_id) REFERENCES dt(id, base_id)
  , CONSTRAINT dt_facet_fkey_facet_dt_base FOREIGN KEY (facet_id, base_id) REFERENCES facet_dt_base
);
COMMENT ON TABLE dt_facet IS 'Ограничение для типа';
COMMENT ON COLUMN dt_facet.id         IS 'ID типа';
COMMENT ON COLUMN dt_facet.facet_id   IS 'ID ограничения';
COMMENT ON COLUMN dt_facet.value      IS 'Значение ограничения';
COMMENT ON COLUMN dt_facet.base_id    IS 'ID базового типа';
COMMENT ON COLUMN dt_facet.anno       IS 'Аннотация ограничения';

/* ------------------------------------------------------------------------- */
\qecho '-- FD: pgws:ws:20_dt.sql / 117 --'
