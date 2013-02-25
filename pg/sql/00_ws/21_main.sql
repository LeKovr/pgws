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

    Таблицы API
*/

/* ------------------------------------------------------------------------- */
CREATE TABLE method (
  code          d_code   PRIMARY KEY
, class_id      d_class  NOT NULL
, action_id     d_id32   NOT NULL
, cache_id      d_id32   NOT NULL
, rvf_id        d_id32   NOT NULL REFERENCES method_rv_format
, is_write      bool     NOT NULL DEFAULT FALSE
, is_i18n       bool     NOT NULL DEFAULT FALSE
, is_sql        bool     NOT NULL DEFAULT TRUE
, is_strict     bool     /*NOT NULL - TODO */ DEFAULT FALSE
, code_real     d_sub    NOT NULL
, arg_dt_code   d_code   NULL REFERENCES dt
, rv_dt_code    d_code   NULL REFERENCES dt
, name          text     NOT NULL
, args_exam     text     NULL
, args          text     NOT NULL
, pkg           text     NOT NULL DEFAULT ws.pg_cs()
, realm_code d_code
, CONSTRAINT method_class_id_action_id_fkey FOREIGN KEY (class_id, action_id) REFERENCES class_action
);
SELECT pg_c('r', 'method', 'Метод API')
, pg_c('c', 'method.code'       , 'внешнее имя метода')
, pg_c('c', 'method.class_id'   , 'ID класса, к которому относится метод')
, pg_c('c', 'method.action_id'  , 'ID акции, которой соответствует метод')
, pg_c('c', 'method.cache_id'   , 'ID кэша, в котором размещается результат вызова метода')
, pg_c('c', 'method.rvf_id'     , 'ID формата результата (для SQL-методов)')
, pg_c('c', 'method.is_write'   , 'метод меняет БД')
, pg_c('c', 'method.is_i18n'    , 'метод поддерживает интернационализацию')
, pg_c('c', 'method.is_sql'     , 'метод реализован как sql function')
, pg_c('c', 'method.is_strict'  , 'отсутствие результата порождает ошибку')
, pg_c('c', 'method.code_real'  , 'имя вызываемого метода (для не-sql - включая package)')
, pg_c('c', 'method.arg_dt_code', 'Код типа, описывающего аргументы')
, pg_c('c', 'method.rv_dt_code' , 'Код типа результата')
, pg_c('c', 'method.name'       , 'внешнее описание метода')
, pg_c('c', 'method.args_exam'  , 'пример вызова функции')
, pg_c('c', 'method.args'       , 'строка списка аргументов')
, pg_c('c', 'method.pkg'        , 'пакет, в котором метод зарегистрирован')
, pg_c('c', 'method.realm_code' , 'код области вызова метода')
;

/* ------------------------------------------------------------------------- */
-- для текущего размера таблицы несущественно, используется как пример
CREATE INDEX method_code ON method USING btree(lower(code)  text_pattern_ops);

/* ------------------------------------------------------------------------- */
CREATE TABLE page_data (
  code       d_code   PRIMARY KEY
, up_code    d_code   REFERENCES page_data
, class_id   d_class  NOT NULL
, action_id  d_id32   NOT NULL
, group_id   d_id32   REFERENCES i18n_def.page_group
, sort       d_sort   NULL
, uri        d_regexp UNIQUE
, tmpl       d_path   NULL
, id_fixed   d_id     NULL
, id_session d_code   NULL
, is_hidden  BOOL     NOT NULL DEFAULT TRUE
, target     text     NOT NULL DEFAULT ''
, uri_re     text     NULL
, uri_fmt    text     NOT NULL
, pkg        TEXT     NOT NULL
, CONSTRAINT page_fkey_class_action FOREIGN KEY (class_id, action_id) REFERENCES class_action
);
SELECT pg_c('r', 'page_data', 'Атрибуты страниц для page_data')
, pg_c('c', 'page_data.code'      , 'Идентификатор страницы')
, pg_c('c', 'page_data.up_code'   , 'идентификатор страницы верхнего уровня')
, pg_c('c', 'page_data.class_id'  , 'ID класса, к которому относится страница')
, pg_c('c', 'page_data.action_id' , 'ID акции, к которой относится страница')
, pg_c('c', 'page_data.group_id'  , 'ID группы страниц для меню')
, pg_c('c', 'page_data.sort'      , 'порядок сортировки в меню страниц одного уровня (NULL - нет в меню)')
, pg_c('c', 'page_data.uri'       , 'мета-маска с именами переменных, которой должен соответствовать URI запроса')
, pg_c('c', 'page_data.tmpl'      , 'файл шаблона (NULL для внешних адресов)')
, pg_c('c', 'page_data.id_fixed'  , 'ID объекта взять из этого поля')
, pg_c('c', 'page_data.id_session', 'ID объекта взять из этого поля сессии')
, pg_c('c', 'page_data.is_hidden' , 'Запрет включения внешних блоков в разметку страницы')
, pg_c('c', 'page_data.target'    , 'значение атрибута target в формируемых ссылках')
, pg_c('c', 'page_data.uri_re'    , 'regexp URI, вычисляется триггером при insert/update')
, pg_c('c', 'page_data.uri_fmt'   , 'строка формата для генерации URI, вычисляется триггером при insert/update')
, pg_c('c', 'page_data.pkg'       , 'пакет, в котором зарегистрирована страница')
;
