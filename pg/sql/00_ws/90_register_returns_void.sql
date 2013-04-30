/*

    Copyright (c) 2013 Tender.Pro http://tender.pro.

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

    Тест регистрации метода, который возвращает VOID
*/

/* ------------------------------------------------------------------------- */

SET SEARCH_PATH='ws';

CREATE DOMAIN d_test_6 AS INT; 
CREATE DOMAIN d_test_7 AS TEXT;
CREATE DOMAIN d_test_8 AS INT; 
SELECT
  pg_c('d','d_test_6', 'Домен 6')
, pg_c('d','d_test_7', 'Домен 7')
, pg_c('d','d_test_8', 'Домен 8');
CREATE TYPE ws.t_test_3 AS (
  _a    d_test_6
 ,_b    d_test_7)
;
SELECT pg_c('t','t_test_3', 'Тест RETURN VOID')
, pg_c('c','t_test_3._a',   'Кол. a')
, pg_c('c','t_test_3._b',   'Кол. b')
;
SELECT pg_register_type(pg_cs('t_test_3'));
CREATE FUNCTION ws.dt_returnvoid(a_inp ws.d_test_8) RETURNS VOID VOLATILE LANGUAGE 'plpgsql' AS
$_$
  BEGIN
    RETURN;
  END;
$_$;
INSERT INTO method (code, class_id, action_id, cache_id, rvf_id, code_real,name) VALUES
   ('ws.dt_returnvoid',2, 1, 2, 3,pg_cs('dt_returnvoid'), 'Test RETURN VOID');
SELECT * FROM ws.method WHERE code = 'ws.dt_returnvoid';

/* ------------------------------------------------------------------------- */

