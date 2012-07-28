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
INSERT INTO dt (code, parent_id, anno, is_list) VALUES (pg_cs('d_links'), dt_id('d_path'), 'Массив ссылок wiki', true);

/* ------------------------------------------------------------------------- */
INSERT INTO dt (code, anno, is_complex) VALUES (pg_cs('z_format'), 'Аргументы метода format', true);
INSERT INTO dt_part (id, part_id, code, parent_id, anno) VALUES
  (dt_id('z_format'), 1, '_sid',      dt_id('text'), 'ID сессии')
, (dt_id('z_format'), 2, 'uri',       dt_id('text'), 'Префикс адреса')
, (dt_id('z_format'), 3, 'src',       dt_id('text'), 'Текст в разметке wiki')
, (dt_id('z_format'), 4, 'extended',  dt_id('boolean'), 'Расширенный формат')
, (dt_id('z_format'), 5, 'id',        dt_id('d_id'), 'ID оригинала для diff')
;

INSERT INTO dt (code, anno, is_complex) VALUES (pg_cs('z_add'), 'Аргументы метода add', true);
INSERT INTO dt_part (id, part_id, code, parent_id, anno) VALUES
  (dt_id('z_add'), 1, '_sid',      dt_id('text'), 'ID сессии')
, (dt_id('z_add'), 2, 'uri',       dt_id('text'), 'Префикс адреса')
, (dt_id('z_add'), 3, 'id',        dt_id('d_id'), 'ID wiki')
, (dt_id('z_add'), 4, 'code',      dt_id('text'), 'Адрес страницы')
, (dt_id('z_add'), 5, 'src',       dt_id('text'), 'Текст в разметке wiki')
;

INSERT INTO dt (code, anno, is_complex) VALUES (pg_cs('z_save'), 'Аргументы метода save', true);
INSERT INTO dt_part (id, part_id, code, parent_id, anno) VALUES
  (dt_id('z_save'), 1, '_sid',      dt_id('text'), 'ID сессии')
, (dt_id('z_save'), 2, 'uri',       dt_id('text'), 'Префикс адреса')
, (dt_id('z_save'), 3, 'id',        dt_id('d_id'), 'ID статьи')
, (dt_id('z_save'), 4, 'revision',  dt_id('d_id'), 'Номер ревизии')
, (dt_id('z_save'), 5, 'src',       dt_id('text'), 'Текст в разметке wiki')
;
