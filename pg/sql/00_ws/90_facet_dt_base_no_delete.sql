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

    Тесты автоудаления только авторегистрируемых доменов
*/

/* ------------------------------------------------------------------------- */

SET search_path = 'ws';
CREATE TYPE ws.t_test_1 AS (
  _a    bigint
, _b    d_lang
, _c    d_string
);
SELECT ws.pg_c('t','ws.t_test_1', 'Тест автоудаления типов 2')
, ws.pg_c('c','ws.t_test_1._a',   'Кол. a')
, ws.pg_c('c','ws.t_test_1._b',   'Кол. b')
, ws.pg_c('c','ws.t_test_1._c',   'Кол. c')
;

CREATE FUNCTION ws.dt_debug(a_inp ws.d_id32) RETURNS SETOF ws.t_test_1 VOLATILE LANGUAGE 'sql' AS
$_$
  SELECT (0, 'en', ' ')::ws.t_test_1;
$_$;

-- статус в начале
SELECT * FROM ws.dt WHERE code in ('bigint', 'ws.d_string');

INSERT INTO ws.method (code, class_id, action_id, cache_id, rvf_id, code_real,args_exam, name) VALUES
   ('ws.dt_debug',2, 1, 2, 3,ws.pg_cs('dt_debug'), '', 'Test autodelete');

SELECT * FROM ws.method WHERE code IN ('ws.dt_debug');

-- после авторегистрации
SELECT * FROM ws.dt WHERE code in ('bigint', 'ws.d_string', 'ws.d_lang');

DELETE FROM ws.method WHERE code IN ('ws.dt_debug');

-- после автоудаления
SELECT * FROM ws.method WHERE code IN ('ws.dt_debug');
SELECT * FROM ws.dt WHERE code in ('bigint', 'ws.d_string');

