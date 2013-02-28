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

    Добавление объектов в схему wsd
*/

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.pkg_script_protected (pkg, code, ver) VALUES (:'PKG', :'FILE', :'VER');

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.file_folder (
  code              TEXT    PRIMARY KEY
, class_id          INTEGER NOT NULL
, sort              INTEGER NOT NULL DEFAULT 1
, has_version       BOOL NOT NULL DEFAULT FALSE
, has_file_code     BOOL NOT NULL DEFAULT FALSE
, file_code_unpack  TEXT
, file_code_mask    TEXT
, page_code         TEXT
, name              TEXT    NOT NULL
, anno              TEXT
, pkg               TEXT    NOT NULL DEFAULT ws.pg_cs()
);
SELECT pg_c('r', 'wsd.file_folder', 'Папки файлов, объединение файлов по смыслу и правам доступа')
, pg_c('c', 'wsd.file_folder.code',             'Код папки')
, pg_c('c', 'wsd.file_folder.class_id',         'Класс объектов, которым принадлежат файлы')
, pg_c('c', 'wsd.file_folder.sort',             'Сортировка внутри класса')
, pg_c('c', 'wsd.file_folder.has_version',      'Файлы в папке имеют версии')
, pg_c('c', 'wsd.file_folder.has_file_code',    'Файлы в папке различаются кодом файла')
, pg_c('c', 'wsd.file_folder.file_code_mask',   'Маска кода файла')
, pg_c('c', 'wsd.file_folder.file_code_unpack', 'Функция декодирования кода файла')
, pg_c('c', 'wsd.file_folder.page_code',        'Код страницы - ссылки на файл')
, pg_c('c', 'wsd.file_folder.name',             'Название папки')
, pg_c('c', 'wsd.file_folder.anno',             'Аннотация')
, pg_c('c', 'wsd.file_folder.pkg',              'Папкет, в котором используется папка')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.file_folder_format (
  folder_code TEXT REFERENCES wsd.file_folder
, format_code TEXT
, is_internal BOOL NOT NULL DEFAULT FALSE -- не показывать в списке доступных
, CONSTRAINT  file_folder_format_pkey PRIMARY KEY (folder_code, format_code)
);
SELECT pg_c('r', 'wsd.file_folder', 'Допустимые в папке форматов файлов')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.file (
  id            INTEGER       PRIMARY KEY
, path          TEXT          NOT NULL
, name          TEXT          NOT NULL
, size          INTEGER       NOT NULL
, csum          TEXT          NOT NULL
, format_code   TEXT          NOT NULL
, ctype         TEXT          NOT NULL DEFAULT 'application/unknown'
, link_cnt      INTEGER       NOT NULL DEFAULT 1
, created_by    INTEGER       NOT NULL -- REFERENCES wsd.account
, created_at    TIMESTAMP(0)  NOT NULL DEFAULT CURRENT_TIMESTAMP
, anno          TEXT
);

SELECT pg_c('r', 'wsd.file', 'Внешний файл')
, pg_c('c', 'wsd.file.id',          'ID файла')
, pg_c('c', 'wsd.file.path',        'Ключ файл-сервера')
, pg_c('c', 'wsd.file.name',        'Внешнее имя файла')
, pg_c('c', 'wsd.file.size',        'Размер (байт)')
, pg_c('c', 'wsd.file.csum',        'Контрольная сумма (sha1)')
, pg_c('c', 'wsd.file.format_code', 'Код формата файла')
, pg_c('c', 'wsd.file.ctype',       'Content type (для формата *)')
, pg_c('c', 'wsd.file.link_cnt',    'Количество связанных объектов')
, pg_c('c', 'wsd.file.created_by',  'Автор загрузки/генерации')
, pg_c('c', 'wsd.file.created_at',  'Момент загрузки/генерации')
, pg_c('c', 'wsd.file.anno',        'Комментарий')
;

CREATE SEQUENCE wsd.file_id_seq;
ALTER TABLE wsd.file ALTER COLUMN id SET DEFAULT NEXTVAL('wsd.file_id_seq');

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.file_link (
  class_id    INTEGER       NOT NULL
, obj_id      INTEGER       NOT NULL
, folder_code TEXT          REFERENCES wsd.file_folder
, format_code TEXT
, file_code   TEXT          NOT NULL DEFAULT ''
, ver         INTEGER       NOT NULL DEFAULT 1
, id          INTEGER       REFERENCES wsd.file
, up_id          INTEGER       REFERENCES wsd.file
, is_ver_last BOOL          NOT NULL DEFAULT TRUE
, created_by  INTEGER       NOT NULL -- REFERENCES wsd.account
, created_at  TIMESTAMP(0)  NOT NULL DEFAULT CURRENT_TIMESTAMP
, CONSTRAINT  file_link_pkey PRIMARY KEY (class_id, obj_id, folder_code, format_code, file_code, ver)
);
SELECT pg_c('r', 'wsd.file_link', 'Связи внешнего файла')
, pg_c('c', 'wsd.file_link.class_id',     'ID класса')
, pg_c('c', 'wsd.file_link.obj_id',       'ID объекта')
, pg_c('c', 'wsd.file_link.folder_code',  'Код папки')
, pg_c('c', 'wsd.file_link.format_code',  'Код формата')
, pg_c('c', 'wsd.file_link.file_code',    'Код файла')
, pg_c('c', 'wsd.file_link.ver',          'Версия файла')
, pg_c('c', 'wsd.file_link.id',           'ID файла')
, pg_c('c', 'wsd.file_link.up_id',        'ID файла, по которому сформирован текущий (TODO)')
, pg_c('c', 'wsd.file_link.is_ver_last',  'Версия файла является последней')
, pg_c('c', 'wsd.file_link.created_by',   'Автор привязки')
, pg_c('c', 'wsd.file_link.created_at',   'Момент привязки')
;
