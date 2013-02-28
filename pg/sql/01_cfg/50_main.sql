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

    Методы доступа к свойствам
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_owner_attr(a_pogc TEXT DEFAULT NULL, a_poid INTEGER DEFAULT 0) RETURNS SETOF prop_owner_attr STABLE LANGUAGE 'sql' AS
$_$
-- a_pogc: код группы владельцев
-- a_poid: код владельца свойства
  SELECT * FROM cfg.prop_owner_attr
  WHERE COALESCE($1, pogc) = pogc
    AND $2 IN (0, poid)
$_$;
SELECT pg_c('f', 'prop_owner_attr', 'Атрибуты POID');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_attr(a_pogc TEXT DEFAULT NULL, a_poid INTEGER DEFAULT 0, a_code TEXT DEFAULT NULL) RETURNS SETOF prop_attr STABLE LANGUAGE 'sql' AS
$_$
-- a_pogc: код группы владельцев
-- a_poid: код владельца свойств
-- a_code: код свойства
  SELECT * FROM cfg.prop_attr
  WHERE COALESCE($1, pogc) = pogc
    AND $2 IN (0, poid)
    AND COALESCE($3, code) = code
$_$;
SELECT pg_c('f', 'prop_attr', 'Атрибуты Свойства');
