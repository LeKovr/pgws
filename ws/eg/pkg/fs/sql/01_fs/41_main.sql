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

    Представления пакета
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW file_store AS SELECT
  f.id
, f.path
, f.size
, f.csum
, f.name
, f.created_at
, f.ctype
  FROM wsd.file f
;
SELECT pg_c('v', 'file_store', 'Атрибуты внешнего хранения файла')
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW file_info AS SELECT
  f.id
, f.size
, f.csum
, f.kind_code
, f.created_by
, f.created_at
, f.name
, f.anno
, fl.class_id
, fl.obj_id
, fl.folder_code
, fl.code
, fl.ext
, fl.ver
, fl.is_ver_last
, fl.created_by AS link_created_by
, fl.created_at AS link_created_at
, ff.sort
, ff.name AS folder_name
, (ws.page_by_code(ff.page_code, fl.obj_id::TEXT, fl.folder_code, '/' || fl.code)).req AS req
  FROM wsd.file f
    JOIN wsd.file_link fl ON f.id = fl.file_id
    JOIN fs.folder ff ON fl.class_id = ff.class_id AND fl.folder_code = ff.code
;
SELECT pg_c('v', 'file_info', 'Атрибуты внешнего файла объекта')
, pg_c('c', 'file_info.req', 'Ссылка на файл')
;

