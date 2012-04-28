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

*/
-- 81_dt.sql - Типы данных
/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:88_dt.sql / 23 --'

INSERT INTO dt (code, anno, is_complex) VALUES (pg_cs('t_wiki_ids'), 'Идентификаторы статьи', true);
INSERT INTO dt_part (id, part_id, code, parent_id, anno) VALUES (dt_id('t_wiki_ids'), 1, 'id',  dt_id('d_id'), 'ID статьи');
INSERT INTO dt_part (id, part_id, code, parent_id, anno) VALUES (dt_id('t_wiki_ids'), 2, 'group_id', dt_id('d_id32'), 'ID группы');

/* ------------------------------------------------------------------------- */

INSERT INTO dt (code, anno, is_complex) VALUES (pg_cs('z_format'), 'Аргументы метода format', true);
INSERT INTO dt_part (id, part_id, code, parent_id, anno) VALUES (dt_id('z_format'), 1, 'uri',       dt_id('text'), 'Префикс адреса');
INSERT INTO dt_part (id, part_id, code, parent_id, anno) VALUES (dt_id('z_format'), 2, 'code',      dt_id('text'), 'Адрес страницы');
INSERT INTO dt_part (id, part_id, code, parent_id, anno) VALUES (dt_id('z_format'), 3, 'src',       dt_id('text'), 'Текст в разметке wiki');
INSERT INTO dt_part (id, part_id, code, parent_id, anno) VALUES (dt_id('z_format'), 4, 'extended',  dt_id('boolean'), 'Расширенный формат');

INSERT INTO dt (code, anno, is_complex) VALUES (pg_cs('z_save'), 'Аргументы метода save', true);
INSERT INTO dt_part (id, part_id, code, parent_id, anno) VALUES (dt_id('z_save'), 1, '_sid',      dt_id('text'), 'ID сессии');
INSERT INTO dt_part (id, part_id, code, parent_id, anno) VALUES (dt_id('z_save'), 2, 'group_id',  dt_id('d_id'), 'ID группы статей');
INSERT INTO dt_part (id, part_id, code, parent_id, anno) VALUES (dt_id('z_save'), 3, 'uri',       dt_id('text'), 'Префикс адреса');

INSERT INTO dt_part (id, part_id, code, parent_id, anno) VALUES (dt_id('z_save'), 4, 'code',      dt_id('text'), 'Адрес страницы');
INSERT INTO dt_part (id, part_id, code, parent_id, anno) VALUES (dt_id('z_save'), 5, 'src',       dt_id('text'), 'Текст в разметке wiki');
INSERT INTO dt_part (id, part_id, code, parent_id, anno) VALUES (dt_id('z_save'), 6, 'id',        dt_id('d_id'), 'ID статьи');

/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:88_dt.sql / 47 --'
