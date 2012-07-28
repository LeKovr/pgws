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

    Основные таблицы пакета
*/

/* ------------------------------------------------------------------------- */
CREATE TABLE status (
  id              d_id32    PRIMARY KEY
, can_create      BOOL      NOT NULL
, can_run         BOOL      NOT NULL
, can_arc         BOOL      NOT NULL
, name            d_string  NOT NULL
, anno            d_text    NOT NULL
);
SELECT pg_c('r', 'status',  'Статус')
, pg_c('c', 'status.id',   'ID статуса')
, pg_c('c', 'status.can_create', 'Допустим при создании')
, pg_c('c', 'status.can_run', 'Допустим при выполнении')
, pg_c('c', 'status.can_arc', 'Допустим при архивации')
, pg_c('c', 'status.name', 'Название')
, pg_c('c', 'status.anno', 'Аннотация')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE srv_error (
  created_at      TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
, job_id          INTEGER NOT NULL
, exit_code       INTEGER NOT NULL
, exit_text       TEXT NOT NULL
);
SELECT pg_c('r', 'srv_error',       'Ошибки выполнения job.srv')
, pg_c('c', 'srv_error.created_at', 'Момент возникновения')
, pg_c('c', 'srv_error.job_id',     'ID задачи')
, pg_c('c', 'srv_error.exit_code',  'Код ошибки')
, pg_c('c', 'srv_error.exit_text',  'Текст ошибки')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE arg_type (
  id              d_id32    PRIMARY KEY
, name            d_string  NOT NULL
);
SELECT pg_c('r', 'arg_type',  'Тип аргумента')
, pg_c('c', 'arg_type.id',    'ID типа')
, pg_c('c', 'arg_type.name',  'Название типа')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE run_type (
  id              d_id32    PRIMARY KEY
, name            d_string  NOT NULL
);
SELECT pg_c('r', 'run_type',  'Тип запуска')
, pg_c('c', 'run_type.id',    'ID типа')
, pg_c('c', 'run_type.name',  'Название типа')
;
/* ------------------------------------------------------------------------- */
CREATE TABLE category ( -- jq.type
  code            d_code    PRIMARY KEY
, pkg             d_string  NOT NULL DEFAULT ws.pg_cs() REFERENCES ws.pkg
, name            d_string  NOT NULL
);
SELECT pg_c('r', 'category',  'Категория')
, pg_c('c', 'category.code',  'Код категории')
, pg_c('c', 'category.pkg',   'Код пакета')
, pg_c('c', 'category.name',  'Название категории')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE class (
  id              d_id32    PRIMARY KEY                   -- уникальный ID класса
, category_code   d_code    NOT NULL REFERENCES category  -- категория обработчика
, def_prio        d_id32    NOT NULL DEFAULT 1            -- приоритет по умолчанию
, def_status_id   d_id32    NOT NULL REFERENCES status    -- статус по умолчанию
, run_type        d_id32    NOT NULL REFERENCES run_type  -- режим запуска
, uk_bits         d_bitmask NOT NULL DEFAULT 0            -- маска аргументов, которые должны быть уникальны
, code            d_code    NOT NULL                      -- символьный код класса
, sub             d_code    NOT NULL                      -- символьный код обработчика
, notify_class_id d_id32    REFERENCES class              -- ID класса задачи уведомления о выполнении  текущей
, arg_id_type     d_id32    NOT NULL REFERENCES arg_type  -- домен значений аргумента
, arg_date_type   d_id32    NOT NULL REFERENCES arg_type  -- домен значений аргумента
, arg_num_type    d_id32    NOT NULL REFERENCES arg_type  -- домен значений аргумента
, arg_more_type   d_id32    NOT NULL REFERENCES arg_type  -- домен значений аргумента
, arg_id2_type    d_id32    NOT NULL REFERENCES arg_type  -- домен значений аргумента
, arg_date2_type  d_id32    NOT NULL REFERENCES arg_type  -- домен значений аргумента
, arg_id3_type    d_id32    NOT NULL REFERENCES arg_type  -- домен значений аргумента
, dust_days       d_id32    NOT NULL DEFAULT 0            -- через сколько дней удалять из dust (0 - перемещать в past)
, name            d_string  NOT NULL                      -- название класса
, CONSTRAINT class_uk_type_id_code UNIQUE (category_code, code)
);
SELECT pg_c('r', 'class',  'Класс задач')
, pg_c('c', 'class.id',              'ID класса')
, pg_c('c', 'class.category_code',   'категория обработчика')
, pg_c('c', 'class.def_prio',        'приоритет по умолчанию')
, pg_c('c', 'class.def_status_id',   'статус по умолчанию')
, pg_c('c', 'class.run_type',        'тип запуска обработчика')
, pg_c('c', 'class.uk_bits',         'маска аргументов, которые должны быть уникальны')
, pg_c('c', 'class.code',            'символьный код класса')
, pg_c('c', 'class.sub',             'символьный код обработчика')
, pg_c('c', 'class.notify_class_id', 'ID класса задачи уведомления о выполнении текущей задачи')
, pg_c('c', 'class.arg_id_type',     'домен значений аргумента arg_id')
, pg_c('c', 'class.arg_date_type',   'домен значений аргумента arg_date')
, pg_c('c', 'class.arg_num_type',    'домен значений аргумента arg_num')
, pg_c('c', 'class.arg_more_type',   'домен значений аргумента arg_more')
, pg_c('c', 'class.arg_id2_type',    'домен значений аргумента arg_id2')
, pg_c('c', 'class.arg_date2_type',  'домен значений аргумента arg_date2')
, pg_c('c', 'class.arg_id3_type',    'домен значений аргумента arg_id3')
, pg_c('c', 'class.dust_days',       'через сколько дней удалять из dust (0 - перемещать в past)')
, pg_c('c', 'class.name',            'название класса')
;



/* ------------------------------------------------------------------------- */
