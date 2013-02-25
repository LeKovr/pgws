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

    Типы данных
*/

/* ------------------------------------------------------------------------- */
INSERT INTO dt (code, parent_code, anno, is_list) VALUES (pg_cs('d_links'), dt_code('d_path'), 'Массив ссылок wiki', true);

/* ------------------------------------------------------------------------- */
INSERT INTO dt (code, anno, is_complex) VALUES (pg_cs('z_format'), 'Аргументы метода format', true);
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES
  (dt_code('z_format'), 1, '_sid',      dt_code('text'), 'ID сессии')
, (dt_code('z_format'), 2, 'uri',       dt_code('text'), 'Префикс адреса')
, (dt_code('z_format'), 3, 'src',       dt_code('text'), 'Текст в разметке wiki')
, (dt_code('z_format'), 4, 'extended',  dt_code('boolean'), 'Расширенный формат')
, (dt_code('z_format'), 5, 'id',        dt_code('d_id'), 'ID оригинала для diff')
;

INSERT INTO dt (code, anno, is_complex) VALUES (pg_cs('z_add'), 'Аргументы метода add', true);
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES
  (dt_code('z_add'), 1, '_sid',      dt_code('text'), 'ID сессии')
, (dt_code('z_add'), 2, 'uri',       dt_code('text'), 'Префикс адреса')
, (dt_code('z_add'), 3, 'id',        dt_code('d_id'), 'ID wiki')
, (dt_code('z_add'), 4, 'code',      dt_code('text'), 'Адрес страницы')
, (dt_code('z_add'), 5, 'src',       dt_code('text'), 'Текст в разметке wiki')
;

INSERT INTO dt (code, anno, is_complex) VALUES (pg_cs('z_save'), 'Аргументы метода save', true);
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES
  (dt_code('z_save'), 1, '_sid',      dt_code('text'), 'ID сессии')
, (dt_code('z_save'), 2, 'uri',       dt_code('text'), 'Префикс адреса')
, (dt_code('z_save'), 3, 'id',        dt_code('d_id'), 'ID статьи')
, (dt_code('z_save'), 4, 'revision',  dt_code('d_id'), 'Номер ревизии')
, (dt_code('z_save'), 5, 'src',       dt_code('text'), 'Текст в разметке wiki')
;
