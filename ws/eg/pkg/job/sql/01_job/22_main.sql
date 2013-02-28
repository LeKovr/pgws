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
, pg_c('c', 'status.id',          'ID статуса')
, pg_c('c', 'status.can_create',  'Допустим при создании')
, pg_c('c', 'status.can_run',     'Допустимо выполнение')
, pg_c('c', 'status.can_arc',     'Допустима архивация')
, pg_c('c', 'status.name',        'Название')
, pg_c('c', 'status.anno',        'Аннотация')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE srv_error (
  created_at      TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
, job_id          INTEGER NOT NULL
, status_id       INTEGER NOT NULL
, exit_text       TEXT NOT NULL
);
SELECT pg_c('r', 'srv_error',       'Ошибки выполнения job.srv')
, pg_c('c', 'srv_error.created_at', 'Момент возникновения')
, pg_c('c', 'srv_error.job_id',     'ID задачи')
, pg_c('c', 'srv_error.status_id',  'ID статуса завершения')
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
CREATE TABLE handler (
  id              d_id32    PRIMARY KEY
, pkg             d_string  NOT NULL DEFAULT ws.pg_cs() REFERENCES ws.pkg
, code            d_code    NOT NULL
, def_prio        d_id      NOT NULL
, def_status_id   d_id32    NOT NULL DEFAULT job.const_status_id_ready() REFERENCES status
, uk_bits         d_bitmask NOT NULL DEFAULT 0
, is_sql          bool      NOT NULL DEFAULT TRUE
, next_handler_id d_id32    REFERENCES handler
, arg_date_type   d_id32    NOT NULL DEFAULT job.const_arg_type_none() REFERENCES arg_type
, arg_id_type     d_id32    NOT NULL DEFAULT job.const_arg_type_none() REFERENCES arg_type
, arg_num_type    d_id32    NOT NULL DEFAULT job.const_arg_type_none() REFERENCES arg_type
, arg_more_type   d_id32    NOT NULL DEFAULT job.const_arg_type_none() REFERENCES arg_type
, arg_date2_type  d_id32    NOT NULL DEFAULT job.const_arg_type_none() REFERENCES arg_type
, arg_id2_type    d_id32    NOT NULL DEFAULT job.const_arg_type_none() REFERENCES arg_type
, arg_id3_type    d_id32    NOT NULL DEFAULT job.const_arg_type_none() REFERENCES arg_type
, dust_days       d_id32    NOT NULL DEFAULT 0
, is_run_allowed  bool      NOT NULL DEFAULT TRUE
, is_todo_allowed bool      NOT NULL DEFAULT TRUE
, name            d_string  NOT NULL
, CONSTRAINT handler_uk_type_id_code UNIQUE (pkg, code)
);
SELECT pg_c('r', 'handler',  'Обработчик задач Job')
, pg_c('c', 'handler.id',               'ID обработчика')
, pg_c('c', 'handler.pkg',              'Код пакета')
, pg_c('c', 'handler.code',             'символьный код обработчика')
, pg_c('c', 'handler.def_prio',         'приоритет по умолчанию')
, pg_c('c', 'handler.def_status_id',    'статус по умолчанию')
, pg_c('c', 'handler.uk_bits',          'маска аргументов, которые должны быть уникальны')
, pg_c('c', 'handler.is_sql',           'обработчик - метод БД (иначе - метод API)')
, pg_c('c', 'handler.next_handler_id',  'ID обработчика задачи, создаваемой при успехе выполнения текущей')
, pg_c('c', 'handler.arg_date_type',    'домен значений аргумента arg_date')
, pg_c('c', 'handler.arg_id_type',      'домен значений аргумента arg_id')
, pg_c('c', 'handler.arg_num_type',     'домен значений аргумента arg_num')
, pg_c('c', 'handler.arg_more_type',    'домен значений аргумента arg_more')
, pg_c('c', 'handler.arg_date2_type',   'домен значений аргумента arg_date2')
, pg_c('c', 'handler.arg_id2_type',     'домен значений аргумента arg_id2')
, pg_c('c', 'handler.arg_id3_type',     'домен значений аргумента arg_id3')
, pg_c('c', 'handler.dust_days',        'через сколько дней удалять из dust (0 - перемещать в past)')
, pg_c('c', 'handler.is_run_allowed',   'выполнение обработчика разрешено')
, pg_c('c', 'handler.is_todo_allowed',  'создание задач в wsd.job_todo разрешено')
, pg_c('c', 'handler.name',             'название обработчика')
;

/* ------------------------------------------------------------------------- */
