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

  PGWS. Типы и домены

*/
/* ------------------------------------------------------------------------- */
CREATE TYPE t_attr AS (
  handler_id  INTEGER
, status_id   INTEGER
, arg_id      INTEGER
, arg_date    DATE
, arg_num     DECIMAL
, arg_more    TEXT
, arg_id2     INTEGER
, arg_date2   DATE
, arg_id3     INTEGER
);
SELECT pg_c('t', 't_attr', 'Атрибуты задачи')
, pg_c('c', 't_attr.handler_id' , 'класс задачи (обработчика)')
, pg_c('c', 't_attr.status_id', 'текущий статус')
, pg_c('c', 't_attr.arg_id'   , 'аргумент id')
, pg_c('c', 't_attr.arg_date' , 'аргумент date')
, pg_c('c', 't_attr.arg_num'  , 'аргумент num')
, pg_c('c', 't_attr.arg_more' , 'аргумент more')
, pg_c('c', 't_attr.arg_id2'  , 'аргумент id2')
, pg_c('c', 't_attr.arg_date2', 'аргумент, 2я дата для периодов')
, pg_c('c', 't_attr.arg_id3'  , 'аргумент id3')
;

/* Описание хэша данных для темплейта */
-- TYPE jq.tmpl_def AS t_hashtable

/* ------------------------------------------------------------------------- */
