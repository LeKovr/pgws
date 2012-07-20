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

    Данные вспомогательных таблиц
*/

/* ------------------------------------------------------------------------- */
INSERT INTO server VALUES (1, 'http://localhost:8080', 'Основной сервер');

/* ------------------------------------------------------------------------- */
INSERT INTO method_rv_format (id, name) VALUES
  (  1, 'нет')
  , (2, 'скаляр')
  , (3, 'хэш')
  , (4, 'хэш {[i][0] -> [i][1]}')
  , (5, 'хэш {([i]{id}|[i]{code}) -> %[i]}')
  , (6, 'массив [i][0]')
  , (7, 'массив хэшей')
  , (8, 'массив массивов')
  , (10, 'дерево хэшей из массива [tag1.tag2][value]')
;
