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
CREATE TABLE wsd.file (
  id            INTEGER       PRIMARY KEY
, path          TEXT          NOT NULL
, name          TEXT          NOT NULL
, size          INTEGER       NOT NULL
, csum          TEXT          NOT NULL
, kind_code     TEXT          NOT NULL
, ctype         TEXT          NOT NULL DEFAULT 'application/unknown'
, link_cnt      INTEGER       NOT NULL DEFAULT 1
, created_by    INTEGER       NOT NULL
, created_at    TIMESTAMP(0)  NOT NULL DEFAULT CURRENT_TIMESTAMP
, anno          TEXT
);
SELECT pg_c('r', 'wsd.file', 'Внешние файлы')
, pg_c('c', 'wsd.file.id',          'd_id,   ID файла')
, pg_c('c', 'wsd.file.path',        'd_path, Ключ файл-сервера')
, pg_c('c', 'wsd.file.name',        'd_string,       Оригинальное имя файла')
, pg_c('c', 'wsd.file.size',        'd_id_positive,  Размер (байт)')
, pg_c('c', 'wsd.file.csum',        'd_string,       Контрольная сумма (sha1)')
, pg_c('c', 'wsd.file.kind_code',   'd_code,    Код вида')
, pg_c('c', 'wsd.file.ctype',       'd_string,  Content type')
, pg_c('c', 'wsd.file.link_cnt',    'd_cnt,     Количество связанных объектов')
, pg_c('c', 'wsd.file.created_by',  'd_id,      Автор загрузки/генерации')
, pg_c('c', 'wsd.file.created_at',  'd_stamp,   Момент загрузки/генерации')
, pg_c('c', 'wsd.file.anno',        'd_text,    Комментарий')
;

CREATE SEQUENCE wsd.file_id_seq;
ALTER TABLE wsd.file ALTER COLUMN id SET DEFAULT NEXTVAL('wsd.file_id_seq');

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.file_link (
  class_id    INTEGER
, obj_id      INTEGER
, folder_code TEXT
, code        TEXT -- TODO: d_code, если сделаем нормализацию
, ver         INTEGER        DEFAULT 1
, ext         TEXT           NOT NULL
, file_id     INTEGER        NOT NULL REFERENCES wsd.file
, up_id       INTEGER        REFERENCES wsd.file
, is_ver_last BOOL           NOT NULL DEFAULT TRUE -- TODO: d_ton?
, created_by  INTEGER        NOT NULL
, created_at  TIMESTAMP(0)   NOT NULL DEFAULT CURRENT_TIMESTAMP
, CONSTRAINT  file_link_pkey PRIMARY KEY (class_id, obj_id, folder_code, code, ver)
);
SELECT pg_c('r', 'wsd.file_link', 'Связи внешних файлов')
, pg_c('c', 'wsd.file_link.class_id',     'd_class, ID класса')
, pg_c('c', 'wsd.file_link.obj_id',       'd_id,   ID объекта')
, pg_c('c', 'wsd.file_link.folder_code',  'd_code, Номер папки в классе')
, pg_c('c', 'wsd.file_link.code',         'd_string, Имя файла в URI')
, pg_c('c', 'wsd.file_link.ext',          'd_cnt,   Расширение файла')
, pg_c('c', 'wsd.file_link.ver',          'd_code,  Версия файла')
, pg_c('c', 'wsd.file_link.file_id',      'd_id,    ID файла')
, pg_c('c', 'wsd.file_link.up_id',        'd_id,    ID файла, по которому сформирован текущий (TODO)')
, pg_c('c', 'wsd.file_link.is_ver_last',  'Версия файла является последней')
, pg_c('c', 'wsd.file_link.created_by',   'd_id,    Автор привязки')
, pg_c('c', 'wsd.file_link.created_at',   'd_stamp, Момент привязки')
;

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.pkg_fkey_protected (rel, wsd_rel, wsd_col) VALUES
  ('fs.kind',   'file',       'kind_code')
, ('fs.folder', 'file_link',  'class_id, folder_code')
;
