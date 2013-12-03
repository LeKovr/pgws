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

    Типы данных и домены
*/

/* ------------------------------------------------------------------------- */
CREATE DOMAIN d_prop_code AS TEXT CHECK (VALUE ~* E'^([a-z\\d_]+)(\\.((:?[a-z\\d_]+)|(\\([a-z\\d_]+(,[a-z\\d_]+)+\\))))*$') ;
COMMENT ON DOMAIN d_prop_code IS 'Код свойства';

/* ------------------------------------------------------------------------- */
CREATE TYPE t_prop_value AS (
  code       TEXT
, value      TEXT
, valid_from DATE
);
SELECT pg_c('t','t_prop_value',        'Значения свойств')
, pg_c('c','t_prop_value.code',        'Код')
, pg_c('c','t_prop_value.value',       'Значение')
, pg_c('c','t_prop_value.valid_from',  'Начало действия')
;
