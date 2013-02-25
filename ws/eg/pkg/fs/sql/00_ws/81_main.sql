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
INSERT INTO file_format (sort, code, ctype, ext_mask, name) VALUES
  (9, fs.const_file_format_any(), 'application/unknown', '.+', 'Файл')
;
INSERT INTO file_format (code, ctype, ext_mask, name) VALUES
  ('jpg', 'image/jpeg',                   'jp(g|eg|e)', 'Файл jpg')
, ('gif', 'image/gif',                    'gif', 'Файл gif')
, ('png', 'image/png',                    'png', 'Файл png')
, ('doc', 'application/msword',           'doc', 'Файл doc')
, ('rtf', 'application/rtf',              'rtf', 'Файл rtf')
, ('pdf', 'application/pdf',              'pdf', 'Файл pdf')
, ('zip', 'application/x-gzip',           'zip', 'Файл zip')
, ('arj', 'application/octet-stream',     'arj', 'Файл arj')
, ('rar', 'application/x-rar-compressed', 'rar', 'Файл rar')
, ('tar', 'application/x-gtar',           'tar', 'Файл tar')
, ('gz',  'application/x-gzip',           'gz',  'Файл gz ')
, ('tgz', 'application/x-gzip',           'tgz', 'Файл tgz')
, ('lha', 'application/octet-stream',     'lha', 'Файл lha')
, ('xls', 'application/vnd.ms-excel',     'xls', 'Файл xls')
, ('xml', 'application/xml',              'xml', 'Файл xml')
;

INSERT INTO ws.method (code, class_id , action_id, cache_id, rvf_id, code_real, is_write, realm_code) VALUES
  ('fe.file_new',   2, 1, 1,  3, pg_cs('file_new_path_mk'), true,   'fe_only')
, ('fe.file_attr',  2, 1, 1,  3, pg_cs('file_store'),   false,  'fe_only')
;

INSERT INTO method (code, class_id, action_id, cache_id, rvf_id, code_real, arg_dt_code, rv_dt_code, is_write, realm_code, name) VALUES
  ('fe.file_get',             2, 1, 1, 2, 'store:get',     dt_code('z_store_get'), dt_code('d_id'), FALSE, 'fe_only', 'Получение данных из файлового хранилища')
, ('fe.file_get64',           2, 1, 1, 2, 'store:get64',   dt_code('z_store_get'), dt_code('d_id'), FALSE, 'fe_only', 'Получение данных  из файлового хранилища и конвертация в base64')
, ('fe.file_set',              2, 1, 1, 3, 'store:set',     dt_code('z_store_set'), dt_code('d_id'), TRUE, 'fe_only', 'Сохранение данных в файловом хранилище')
;
