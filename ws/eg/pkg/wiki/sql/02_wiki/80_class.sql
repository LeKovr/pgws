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

    Классы и акции
*/

/* ------------------------------------------------------------------------- */
INSERT INTO class (id, up_id, id_count, is_ext, sort, code, name) VALUES
  (5, NULL, 1,        FALSE, '5', 'wiki',        'Вики')
;

/* ------------------------------------------------------------------------- */
INSERT INTO class_status (class_id, id, sort, name) VALUES
  (5, 1, '51', 'Черновик')
, (5, 2, '52', 'Готова к публикации')
, (5, 3, '53', 'Опубликована')
, (5, 4, '54', 'Архив')
, (5, 5, '55', 'Удалена')
;

/* ------------------------------------------------------------------------- */
INSERT INTO class_action (class_id, id, sort, name) VALUES
  (5, 1,  '51', 'Публичное чтение')
, (5, 2,  '52', 'Авторизованное чтение')
, (5, 3,  '53', 'Изменение атрибутов')
, (5, 4,  '54', 'Редактирование')
;
