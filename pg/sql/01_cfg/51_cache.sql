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

    Функции ядра
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION cache(a_id d_id32 DEFAULT 0) RETURNS SETOF t_hashtable STABLE STRICT LANGUAGE 'sql' AS
$_$
  SELECT poid::text, name FROM wsd.prop_owner WHERE pogc = 'cache' AND $1 IN (poid, 0) ORDER BY name;
$_$;
SELECT pg_c('f', 'cache', 'Атрибуты кэша по id');

/* ------------------------------------------------------------------------- */
