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
-- 82_doc.sql - Вторичные данные wiki
/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:82_doc.sql / 23 --'

-- Пометим все вторичные данные как требующие переформирования
UPDATE wiki_data.doc SET cached_at = NULL;

-- TODO: создать в tm задачу переформирования вторичных данных
/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:82_doc.sql / 30 --'
