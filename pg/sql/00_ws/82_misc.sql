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

/* ------------------------------------------------------------------------- */
\set TZ ws.const_ref_code_timezone()
\set ACL ws.const_ref_acls_internal()

/* ------------------------------------------------------------------------- */
INSERT INTO i18n_def.ref (code, name) VALUES
  (:TZ, 'Часовой пояс')
;

/* ------------------------------------------------------------------------- */
SELECT
  ws.ref_op(:TZ, 'Europe/Kaliningrad', 2, 'Калининградское время',  :ACL) -- | 03:00:00   | -01:00:00
, ws.ref_op(:TZ, 'Europe/Moscow',      1, 'Московское время',       :ACL) -- | 04:00:00   | 00:00:00
, ws.ref_op(:TZ, 'Asia/Yekaterinburg', 3, 'Екатеринбургское время', :ACL) -- | 06:00:00   | 02:00:00
, ws.ref_op(:TZ, 'Asia/Omsk',          4, 'Омское время',           :ACL) -- | 07:00:00   | 03:00:00
, ws.ref_op(:TZ, 'Asia/Krasnoyarsk',   5, 'Красноярское время',     :ACL) -- | 08:00:00   | 04:00:00
, ws.ref_op(:TZ, 'Asia/Irkutsk',       6, 'Иркутское время',        :ACL) -- | 09:00:00   | 05:00:00
, ws.ref_op(:TZ, 'Asia/Yakutsk',       7, 'Якутское время',         :ACL) -- | 10:00:00   | 06:00:00
, ws.ref_op(:TZ, 'Asia/Vladivostok',   8, 'Владивостокское время',  :ACL) -- | 11:00:00   | 07:00:00
, ws.ref_op(:TZ, 'Asia/Magadan',       9, 'Магаданское время',      :ACL) -- | 12:00:00   | 08:00:00
;
