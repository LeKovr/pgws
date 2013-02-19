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

    Примитивы, использующие особенности Postgresql
*/

/* ------------------------------------------------------------------------- */
CREATE DOMAIN d_pg_argtypes AS oidvector; -- pg_catalog.pg_proc.proargtypes
CREATE DOMAIN d_pg_argnames AS text[];    -- pg_catalog.pg_proc.proargnames

/* ------------------------------------------------------------------------- */
CREATE TYPE t_pg_object AS ENUM ('h', 'r', 'v', 'c', 't', 'd', 'f', 'a', 's'); -- see pg_comment

/* ------------------------------------------------------------------------- */
CREATE TYPE t_pg_proc_info AS (
  schema      text
, name        text
, anno        text
, rt_oid      oid
, rt_name     text
, is_set      bool
, args        text
, args_pub    text
);

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_cs(TEXT DEFAULT '') RETURNS name STABLE LANGUAGE 'sql' AS
$_$
 SELECT (current_schema() || CASE WHEN COALESCE($1, '') = '' THEN '' ELSE '.' || $1 END)::name
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION sprintf (TEXT, TEXT DEFAULT '', TEXT DEFAULT '', TEXT DEFAULT '', TEXT DEFAULT '') RETURNS TEXT IMMUTABLE LANGUAGE 'plperl' AS
$_$ #
    my ($fmt, @args) = @_; my $str = sprintf($fmt, @args); return $str;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_schema_oid(a_name text) RETURNS oid STABLE LANGUAGE 'sql' AS
$_$
  SELECT oid FROM pg_namespace WHERE nspname = $1
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_exec_func(a_name text) RETURNS text STABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v TEXT;
  BEGIN
    EXECUTE 'SELECT * FROM ' || a_name || '()' INTO v;
    RETURN v;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_exec_func(a_schema TEXT, a_name TEXT) RETURNS TEXT STABLE LANGUAGE 'sql' AS
$_$
  SELECT ws.pg_exec_func($1 || '.' || $2)
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_schema_by_oid(a_oid oid) RETURNS TEXT STABLE LANGUAGE 'sql' AS
$_$
  SELECT nspname::TEXT FROM pg_namespace WHERE oid = $1
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.pg_type_name(a_oid oid) RETURNS text STABLE LANGUAGE 'sql' AS
$_$
  SELECT CASE WHEN nspname = 'pg_catalog' THEN pg_catalog.format_type($1, NULL) ELSE  nspname || '.' || typname END
    FROM (
      SELECT (SELECT nspname FROM pg_namespace WHERE oid = typnamespace) as nspname, typname FROM pg_type WHERE oid = $1
    ) AS pg_type_name_temp
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION reserved_args() RETURNS text[] IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT ARRAY['a__acl', 'a__sid', 'a__ip', 'a__cook', 'a__lang'];
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_proargs2str(a_names d_pg_argnames, a_types d_pg_argtypes, a_pub BOOL) RETURNS text STABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_reserved TEXT[];
    v_names TEXT[];
    v_i INTEGER;
  BEGIN
    v_reserved := ws.reserved_args();
    FOR v_i IN 0 .. pg_catalog.array_upper(a_types, 1) LOOP
      CONTINUE WHEN a_pub AND a_names[v_i + 1] = ANY (v_reserved);
      v_names[v_i] := pg_catalog.format_type(a_types[v_i], NULL);
      IF a_names IS NOT NULL THEN
        IF a_pub AND COALESCE(a_names[v_i + 1], '') = '' THEN
          RETURN ''; -- аргумент без имени => не формируем строку публичных аргументов
        END IF;
        v_names[v_i] := CASE
          WHEN COALESCE(a_names[v_i + 1], '') = '' THEN ''
          WHEN a_pub THEN regexp_replace(a_names[v_i + 1], '^a_', '') || ' '
          ELSE a_names[v_i + 1] || ' '
          END || v_names[v_i];
      ELSIF a_pub THEN
        RETURN ''; -- аргументы без имен => не формируем строку публичных аргументов
      END IF;
    END LOOP;
    RETURN array_to_string(v_names, ', ');
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_proc_info(a_ns text, a_name text) RETURNS SETOF t_pg_proc_info STABLE LANGUAGE 'sql' AS
$_$
  SELECT $1
  , $2
  , obj_description(p.oid, 'pg_proc')
  , p.prorettype
  , ws.pg_type_name(p.prorettype)
  , proretset
  , ws.pg_proargs2str(p.proargnames, p.proargtypes, false) -- proargtypes - only IN arguments
  , ws.pg_proargs2str(p.proargnames, p.proargtypes, true)
    FROM pg_catalog.pg_proc p
    WHERE p.pronamespace = ws.pg_schema_oid($1)
      AND p.proname = $2
  ;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.pg_c(
  a_type ws.t_pg_object    -- тип объекта (из перечисления ws.t_pg_object)
, a_code name              -- имя объекта
, a_text text              -- комментарий
, a_anno text DEFAULT NULL -- аннотация (не сохраняется, предназначено для размещения описания рядом с кодом)
) RETURNS void VOLATILE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_code TEXT;
    v_name TEXT;
    rec ws.t_pg_proc_info;
  BEGIN
    IF split_part(a_code, '.', 2) = '' AND a_type NOT IN ('h')
      OR a_type IN ('c','a') AND split_part(a_code, '.', 3) = '' THEN
      v_code := ws.pg_cs(a_code); -- добавить имя текущей схемы
    ELSE
      v_code := a_code;
    END IF;
    v_name := CASE
      WHEN a_type = 'h' THEN 'SCHEMA'
      WHEN a_type = 'r' THEN 'TABLE'
      WHEN a_type = 'v' THEN 'VIEW'
      WHEN a_type = 'c' THEN 'COLUMN'
      WHEN a_type = 't' THEN 'TYPE'
      WHEN a_type = 'd' THEN 'DOMAIN'
      WHEN a_type = 'f' THEN 'FUNCTION'
      WHEN a_type = 's' THEN 'SEQUENCE'
      ELSE NULL -- a_type = 'a'
    END;
RAISE NOTICE 'COMMENT FOR % %: % (%)', v_name, v_code, a_text, a_anno;
    IF v_name IS NULL THEN
      -- a(rgument)
      UPDATE ws.dt_part SET anno = a_text
        WHERE id = dt_id(split_part(v_code, '.', 1)||'.'||split_part(v_code, '.', 2))
          AND code = split_part(v_code, '.', 3)
      ;
    ELSIF a_type = 'f' THEN
      -- получить списки аргументов и прописать коммент каждой ф-и с этим именем
      FOR rec IN SELECT * FROM ws.pg_proc_info(split_part(v_code, '.', 1), split_part(v_code, '.', 2)) LOOP
        v_name := ws.sprintf(E'COMMENT ON FUNCTION %s(%s) IS \'%s\'', v_code, rec.args, a_text);
        EXECUTE v_name;
        RAISE NOTICE '%', v_name;
      END LOOP;
    ELSE
      EXECUTE ws.sprintf(E'COMMENT ON %s %s IS \'%s\'', v_name, v_code, a_text);
    END IF;
  END;
$_$;
SELECT pg_c('f', 'pg_c', 'Создать комментарий к объекту БД');

/* ------------------------------------------------------------------------- */
SELECT 
  pg_c('f', 'sprintf', 'Порт функции sprintf')
, pg_c('f', 'pg_cs', 'Текущая (первая) схема БД в пути поиска', $_$если задан аргумент, он и '.' добавляются к имени схемы$_$)
, pg_c('f', 'reserved_args', 'Зарезервированные имена аргументов методов')
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION notice (a_text TEXT) RETURNS VOID LANGUAGE 'plpgsql' AS
$_$
  -- вызов RAISE NOTICE из скриптов и sql
  BEGIN
    RAISE NOTICE '%', a_text;
  END
$_$ ;
SELECT pg_c('f', 'notice', 'Вывод предупреждения посредством RAISE NOTICE', $_$/*
Метод позволяет вызывать NOTICE из SQL-запросов и скриптов psql.
Кроме прочего, используется в скриптах 9?_*.sql для передачи в pgctl.sh названия теста
*/$_$);



