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

    Данные основных таблиц пакета
*/

/* ------------------------------------------------------------------------- */
INSERT INTO kind (code, sort, name) VALUES
  (const_kind_code_any(),     1, 'Любой')
, ('img',     2, 'Изображение')
, ('img_us',  3, 'Изображение (без масштабирования)') -- unscaled
, ('doc',     4, 'Документ')
, ('sheet',   5, 'Таблица')
, ('data',    6, 'Данные')
, ('arc',     7, 'Архив')
;

INSERT INTO mime_type (kind_code, ctype, ext) VALUES
  ('img',   'image/jpeg',                   'jpg')
, ('img',   'image/jpeg',                   'jpeg')
, ('img',   'image/jpeg',                   'jpe')
, ('img',   'image/gif',                    'gif')
, ('img',   'image/png',                    'png')

, ('img_us','image/vnd.microsoft.icon',     'ico')
, ('img_us','image/x-ms-bmp',               'bmp')

, ('doc',   'application/msword',           'doc')
, ('doc',   'application/rtf',              'rtf')
, ('doc',   'application/pdf',              'pdf')

, ('sheet', 'application/vnd.ms-excel',     'xls')

, ('data',  'application/xml',              'xml')
, ('data',  'application/json',             'json')

, ('arc',   'application/x-gzip',           'zip')
, ('arc',   'application/octet-stream',     'arj')
, ('arc',   'application/x-rar-compressed', 'rar')
, ('arc',   'application/x-gtar',           'tar')
, ('arc',   'application/x-gzip',           'gz')
, ('arc',   'application/x-gzip',           'tgz')
, ('arc',   'application/octet-stream',     'lha')
;

INSERT INTO ws.dt (code, anno, is_complex) VALUES (pg_cs('z_store_get'), 'Аргументы функций store_get', true);
INSERT INTO ws.dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('z_store_get'), 1, 'path',   dt_code('d_path'), 'ID данных');

INSERT INTO ws.dt (code, anno, is_complex) VALUES (pg_cs('z_store_set'), 'Аргументы функций store_set', true);
INSERT INTO ws.dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('z_store_set'), 1, 'path',   dt_code('d_path'), 'ID данных');
INSERT INTO ws.dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('z_store_set'), 2, 'data',   dt_code('text'), 'данные');

INSERT INTO ws.method (code, class_id , action_id, cache_id, rvf_id, code_real, is_write, realm_code) VALUES
  ('fe.file_new',   2, 1, 1,  3, pg_cs('file_new_path_mk'), TRUE,   'fe_only')
, ('fe.file_attr',  2, 1, 1,  3, pg_cs('file_store'),       FALSE,  'fe_only')
;

INSERT INTO method (code, class_id, action_id, cache_id, rvf_id, code_real, arg_dt_code, rv_dt_code, is_write, realm_code, name) VALUES
  ('fe.file_get',   2, 1, 1, 2, 'store:get',    dt_code('z_store_get'), dt_code('d_id'), FALSE, 'fe_only', 'Получение данных из файлового хранилища')
, ('fe.file_get64', 2, 1, 1, 2, 'store:get64',  dt_code('z_store_get'), dt_code('d_id'), FALSE, 'fe_only', 'Получение данных  из файлового хранилища и конвертация в base64')
, ('fe.file_set',   2, 1, 1, 3, 'store:set',    dt_code('z_store_set'), dt_code('d_id'), TRUE,  'fe_only', 'Сохранение данных в файловом хранилище')
;

