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
-- 21_main.sql - Таблицы API
/* ------------------------------------------------------------------------- */
\qecho '-- FD: pgws:ws:21_main.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE TABLE method (
  code         d_code   PRIMARY KEY
  , class_id   d_class  NOT NULL
  , action_id  d_id32   NOT NULL
  , cache_id   d_id32   NOT NULL REFERENCES cache
  , rvf_id     d_id32   NOT NULL REFERENCES method_rv_format
  , is_write   bool     NOT NULL DEFAULT FALSE
  , is_i18n    bool     NOT NULL DEFAULT FALSE
  , is_sql     bool     NOT NULL DEFAULT TRUE
  , code_real  d_sub    NOT NULL
  , arg_dt_id  d_id32   NULL REFERENCES dt
  , rv_dt_id   d_id32   NULL REFERENCES dt
  , name       text     NOT NULL
  , args_exam  text     NULL
  , args       text     NOT NULL
  , CONSTRAINT method_class_id_action_id_fkey FOREIGN KEY (class_id, action_id) REFERENCES class_action
);

COMMENT ON TABLE method IS 'Метод API';
COMMENT ON COLUMN method.code       IS 'внешнее имя метода';
COMMENT ON COLUMN method.class_id   IS 'ID класса, к которому относится метод';
COMMENT ON COLUMN method.action_id  IS 'ID акции, которой соответствует метод';
COMMENT ON COLUMN method.cache_id   IS 'ID кэша, в котором размещается результат вызова метода';
COMMENT ON COLUMN method.rvf_id     IS 'ID формата результата (для SQL-методов)';
COMMENT ON COLUMN method.is_write   IS 'метод меняет БД';
COMMENT ON COLUMN method.is_i18n    IS 'метод поддерживает интернационализацию';
COMMENT ON COLUMN method.is_sql     IS 'метод реализован как sql function';
COMMENT ON COLUMN method.code_real  IS 'имя вызываемого метода (для не-sql - включая package)';
COMMENT ON COLUMN method.arg_dt_id  IS 'ID типа, описывающего аргументы';
COMMENT ON COLUMN method.rv_dt_id   IS 'ID типа результата';
COMMENT ON COLUMN method.name       IS 'внешнее описание метода';
COMMENT ON COLUMN method.args_exam  IS 'пример вызова функции';
COMMENT ON COLUMN method.args       IS 'строка списка аргументов';

/* ------------------------------------------------------------------------- */
-- для текущего размера таблицы несущественно, используется как пример
CREATE INDEX method_code ON method USING btree(lower(code)  text_pattern_ops);

/* ------------------------------------------------------------------------- */
CREATE TABLE page_data (
  code         d_code   PRIMARY KEY
  , up_code    d_code   REFERENCES page_data
  , class_id   d_class  NOT NULL
  , action_id  d_id32   NOT NULL
  , group_id   d_id32   REFERENCES i18n_def.page_group
  , sort       d_sort   NULL
  , uri        d_regexp UNIQUE
  , tmpl       d_path   NULL
  , id_source  d_code   NULL
  , is_hidden  BOOL     NOT NULL DEFAULT TRUE
  , target     text     NOT NULL DEFAULT ''
  , uri_re     text     NULL
  , uri_fmt    text     NOT NULL
  , CONSTRAINT page_fkey_class_action FOREIGN KEY (class_id, action_id) REFERENCES class_action
);


/* ------------------------------------------------------------------------- */
\qecho '-- FD: pgws:ws:21_main.sql / 84 --'
