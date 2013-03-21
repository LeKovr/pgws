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

    Удаление данных из схемы ws
*/

/* ------------------------------------------------------------------------- */
DELETE FROM ws.method                WHERE pkg = :'PKG';
DELETE FROM ws.page_data             WHERE pkg = :'PKG';

/* ------------------------------------------------------------------------- */
DELETE FROM ws.dt_part          WHERE dt_code IN (SELECT code FROM ws.dt WHERE code LIKE :'PKG' ||'.%');
DELETE from ws.dt               WHERE code LIKE :'PKG' ||'.%';

DELETE FROM ws.error_data WHERE code ~ E'^Y002';

/* ------------------------------------------------------------------------- */
