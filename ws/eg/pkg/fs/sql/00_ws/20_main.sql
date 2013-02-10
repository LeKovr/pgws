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
CREATE TABLE file_format (
  code        TEXT    PRIMARY KEY
, sort        INTEGER NOT NULL DEFAULT 1
, ctype       TEXT    NOT NULL
, ext_mask    TEXT    NOT NULL
-- ico_uri -- ссылка на иконку формата
, name        TEXT    NOT NULL
);
SELECT pg_c('r', 'file_format', 'допустимые форматы файлов')
, pg_c('c', 'file_format.code',         'Код формата')
, pg_c('c', 'file_format.sort',         'Сортировка при выводе нескольких форматов одного файла')
, pg_c('c', 'file_format.ctype',        'Content type')
, pg_c('c', 'file_format.ext_mask',     'Маска допустимых расширений файла')
, pg_c('c', 'file_format.name',         'Название формата')
;
/* ------------------------------------------------------------------------- */
