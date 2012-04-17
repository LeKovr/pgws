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
-- 82_misc.sql - Вспомогательные таблицы
/* ------------------------------------------------------------------------- */
\qecho '-- FD: pg:ws:82_misc.sql / 23 --'

/* ------------------------------------------------------------------------- */
INSERT INTO cache (id, is_active, code, name) VALUES
  (1, false, 'none',  'нет')
 ,(2, true,  'meta',  'метаданные системы')
 ,(3, true,  'short', 'Анти-DoS')
 ,(4, true,  'session', 'Данные сессий')
 ,(5, true,  'big', 'Большие объекты')
;

INSERT INTO server VALUES (1, 'http://localhost:8080', 'Основной сервер');

/* ------------------------------------------------------------------------- */
INSERT INTO method_rv_format VALUES (1, 'нет');
INSERT INTO method_rv_format VALUES (2, 'скаляр');
INSERT INTO method_rv_format VALUES (3, 'хэш');
INSERT INTO method_rv_format VALUES (4, 'хэш {[i][0] -> [i][1]}');
INSERT INTO method_rv_format VALUES (5, 'хэш {([i]{id}|[i]{code}) -> %[i]}');
INSERT INTO method_rv_format VALUES (6, 'массив [i][0]');
INSERT INTO method_rv_format VALUES (7, 'массив хэшей');
INSERT INTO method_rv_format VALUES (8, 'массив массивов');

/* ------------------------------------------------------------------------- */
\qecho '-- FD: pg:ws:82_misc.sql / 47 --'
