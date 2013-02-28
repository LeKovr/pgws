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

    Функции поддержки типов данных
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION dt_parent_base_code(a_code d_code) RETURNS d_code STABLE LANGUAGE 'sql' AS
$_$
  SELECT base_code FROM ws.dt WHERE code = $1 AND NOT is_complex;
  -- у элементов массива может быть check
  -- SELECT base_id FROM ws.dt WHERE id = $1 AND NOT is_list AND NOT is_complex;
$_$;
SELECT pg_c('f', 'dt_parent_base_code', 'Базовый тип для заданного родительского типа');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION dt_part_parent_base_code(a_code d_code) RETURNS d_code STABLE LANGUAGE 'sql' AS
$_$
  SELECT base_code FROM ws.dt WHERE code = $1 AND NOT is_complex;
$_$;
SELECT pg_c('f', 'dt_part_parent_base_code', 'Базовый тип для заданной части комплексного типа');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION dt_is_complex(a_code d_code) RETURNS bool STABLE LANGUAGE 'sql' AS
$_$
  SELECT is_complex FROM ws.dt WHERE code = $1;
$_$;
SELECT pg_c('f', 'dt_is_complex', 'Значение is_complex для заданного типа');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION dt_code(a_code d_code) RETURNS d_code STABLE LANGUAGE 'sql' AS
$_$
  SELECT code FROM ws.dt WHERE code IN ($1, ws.pg_cs($1), 'ws.'||$1) ORDER BY 1;
$_$;
SELECT pg_c('f', 'dt_by_code', 'Атрибуты типа по маске кода');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION dt(a_code d_code DEFAULT NULL) RETURNS SETOF dt STABLE LANGUAGE 'sql' AS
$_$
  SELECT * FROM ws.dt WHERE code LIKE COALESCE($1, '%') ORDER BY 1;
$_$;
SELECT pg_c('f', 'dt', 'Атрибуты типа по маске кода');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION dt_part(a_code d_code, a_part_id d_id32 DEFAULT 0) RETURNS SETOF dt_part STABLE LANGUAGE 'sql' AS
$_$
  SELECT * FROM ws.dt_part WHERE dt_code = $1 AND $2 IN (part_id, 0) ORDER BY 2;
$_$;
SELECT pg_c('f', 'dt_part', 'Атрибуты полей комплексного типа');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION facet_id(a_code d_codei) RETURNS d_id32 STABLE STRICT LANGUAGE 'sql' AS
$_$
  SELECT id FROM ws.facet WHERE code = $1;
$_$;
SELECT pg_c('f', 'facet_id', 'ID ограничения типа по коду');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION facet(a_id d_id32) RETURNS SETOF facet STABLE STRICT LANGUAGE 'sql' AS
$_$
  SELECT * FROM ws.facet WHERE $1 IN (0, id) ORDER BY 2;
$_$;
SELECT pg_c('f', 'facet', 'Атрибуты ограничения по id');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION dt_facet(a_code d_code) RETURNS SETOF dt_facet STABLE STRICT LANGUAGE 'sql' AS
$_$
  SELECT * FROM ws.dt_facet WHERE code = $1 ORDER BY 2;
$_$;
SELECT pg_c('f', 'dt_facet', 'Атрибуты ограничения типа по коду типа');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION dt_parts(a_code d_code) RETURNS text STABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_names TEXT[];
    r ws.dt_part;
    r_dt ws.dt;
  BEGIN
    FOR r IN
      SELECT *
      FROM ws.dt_part
      WHERE dt_code = a_code
      ORDER BY 2
    LOOP
      r_dt := ws.dt(r.parent_code);
      v_names := array_append(v_names, r.code || ' ' || r_dt.code);
    END LOOP;
    RETURN array_to_string(v_names, ', ');
  END;
$_$;
SELECT pg_c('f', 'dt_parts', 'Список полей комплексного типа по коду как строка');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION dt_tree(a_code d_code) RETURNS SETOF d_code STABLE LANGUAGE 'sql' AS
$_$
  WITH RECURSIVE dtree AS (
    SELECT d.*, ARRAY[code::text] as branches
      FROM ws.dt d
      WHERE code = 'ws.d_code'
    UNION
    SELECT d.*, dtree.branches || d.code::text
      FROM ws.dt d
        JOIN dtree ON d.code = dtree.parent_code 
      WHERE NOT d.code = ANY(dtree.branches)
  )
  SELECT code 
    FROM dtree
    ORDER BY array_length(branches, 1);
$_$;

/* ------------------------------------------------------------------------- */
