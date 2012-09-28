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
CREATE OR REPLACE VIEW file_info AS SELECT
  f.*
, fl.class_id
, fl.obj_id
, fl.code AS link_code
, fl.created_by AS link_created_by
, fl.created_at AS link_created_at
  FROM wsd.file f
    JOIN wsd.file_link fl USING (file_id)
;
SELECT pg_c('v', 'file_info', 'Атрибуты внешнего файла объекта')
, pg_c('c', 'file_info.file_id',    'ID файла')
, pg_c('c', 'file_info.path',       'Ключ файл-сервера')
, pg_c('c', 'file_info.size',       'Размер (байт)')
, pg_c('c', 'file_info.csum',       'Контрольная сумма (sha1)')
, pg_c('c', 'file_info.name',       'Внешнее имя файла')
, pg_c('c', 'file_info.ctype',      'Content type')
, pg_c('c', 'file_info.link_cnt',   'Количество связанных объектов')
, pg_c('c', 'file_info.created_by', 'Автор загрузки/генерации')
, pg_c('c', 'file_info.created_at', 'Момент загрузки/генерации')
, pg_c('c', 'file_info.anno',       'Комментарий')
, pg_c('c', 'file_info.class_id',   'ID класса')
, pg_c('c', 'file_info.obj_id',     'ID объекта')
, pg_c('c', 'file_info.link_code',       'Код связи')
, pg_c('c', 'file_info.link_created_by', 'Автор привязки')
, pg_c('c', 'file_info.link_created_at', 'Момент привязки')
;