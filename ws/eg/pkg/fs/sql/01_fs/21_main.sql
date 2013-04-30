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
CREATE TABLE kind (
  code        d_code    PRIMARY KEY
, sort        d_sort    NOT NULL DEFAULT 1
, name        d_string  NOT NULL
);
SELECT pg_c('r', 'kind', 'Вид файла')
, pg_c('c', 'kind.code',     'Код вида')
, pg_c('c', 'kind.sort',     'Сортировка')
, pg_c('c', 'kind.name',     'Название')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE mime_type (
  ext       d_string  PRIMARY KEY -- TODO: был бы d_code, но если расширение на русском...
, ctype     d_string  NOT NULL
, kind_code d_code    NOT NULL REFERENCES fs.kind
-- ico_uri -- ссылка на иконку формата
);
SELECT pg_c('r', 'mime_type', 'Тип файла')
, pg_c('c', 'mime_type.ext', 'Расширение')
, pg_c('c', 'mime_type.ctype',    'Content type')
, pg_c('c', 'mime_type.kind_code',     'Код вида файла')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE folder (
  class_id          d_class
, code              d_code    
, sort              d_sort    NOT NULL DEFAULT 1
, has_version       BOOL      NOT NULL DEFAULT FALSE
, page_code         d_code    NULL
, pkg               d_code    NOT NULL DEFAULT ws.pg_cs()
, name              d_string  NOT NULL
, anno              d_text
, CONSTRAINT folder_pkey PRIMARY KEY (class_id, code)
);
SELECT pg_c('r', 'folder', 'Папки файлов, объединение файлов по смыслу и правам доступа')
, pg_c('c', 'folder.class_id',         'Класс объекта привязки')
, pg_c('c', 'folder.code',             'Код папки')
, pg_c('c', 'folder.sort',             'Сортировка внутри класса')
, pg_c('c', 'folder.has_version',      'Файлы в папке имеют версии')
, pg_c('c', 'folder.page_code',        'Код страницы - ссылки на файл')
, pg_c('c', 'folder.pkg',              'Папкет, в котором используется папка')
, pg_c('c', 'folder.name',             'Название папки')
, pg_c('c', 'folder.anno',             'Аннотация')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE folder_kind (
  class_id        d_class
, code            d_code
, kind_code       d_code REFERENCES kind
, job_handler_id  d_id32 -- TODO: REFERENCES job.handler
, CONSTRAINT folder_kind_pkey PRIMARY KEY (class_id, code, kind_code)
, CONSTRAINT folder_kind_fkey_folder FOREIGN KEY (class_id, code) REFERENCES folder

);
SELECT pg_c('r', 'folder_kind', 'Допустимый в папке вид файла')
, pg_c('c', 'folder_kind.class_id',       'ID класса папки')
, pg_c('c', 'folder_kind.code',           'Код папки')
, pg_c('c', 'folder_kind.kind_code',      'Код вида')
, pg_c('c', 'folder_kind.job_handler_id', 'ID обработчика задачи, создаваемой при обновлении')
;
/* ------------------------------------------------------------------------- */
