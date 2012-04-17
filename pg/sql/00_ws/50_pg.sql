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
-- 50_pg.sql - Функции ядра, метаданные Postgresql
/* ------------------------------------------------------------------------- */
\qecho '-- FD: pg:ws:50_pg.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION sprintf (TEXT, TEXT DEFAULT '', TEXT DEFAULT '', TEXT DEFAULT '', TEXT DEFAULT '') RETURNS TEXT IMMUTABLE LANGUAGE 'plperl' AS
$_$  # -- FD: pg:ws:50_pg.sql / 27 --
    my ($fmt, @args) = @_; my $str = sprintf($fmt, @args); return $str;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION notice (a_text TEXT) RETURNS VOID LANGUAGE 'plpgsql' AS
$_$ -- FD: pg:ws:50_pg.sql / 33 --
  -- вызов RAISE NOTICE из скриптов и sql
  BEGIN
    RAISE NOTICE '%', a_text;
  END
$_$ ;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION set_search_path(a_path TEXT) RETURNS VOID LANGUAGE 'plpgsql' AS
$_$ -- FD: pg:ws:50_pg.sql / 42 --
  DECLARE
    v_sql TEXT;
  BEGIN
    v_sql := 'SET LOCAL search_path = ' || a_path;
    EXECUTE v_sql;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION set_lang(a_lang TEXT DEFAULT NULL) RETURNS TEXT LANGUAGE 'plpgsql' AS
$_$ -- FD: pg:ws:50_pg.sql / 53 --
  DECLARE
    v_lang TEXT;
    v_path_old TEXT;
    v_path_new TEXT;
  BEGIN
    v_lang := COALESCE(NULLIF(a_lang, 'ru'), 'def');
    EXECUTE 'SHOW search_path' INTO v_path_old;
    IF v_path_old ~ E'i18n_\w+' THEN
      v_path_new := regexp_replace(v_path_old, E'i18n_\\w+', 'i18n_' || v_lang);
    ELSE
      v_path_new := 'i18n_' || v_lang || ', '|| v_path_old;
    END IF;
    PERFORM ws.set_search_path(v_path_new);
    RETURN v_path_old;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_cs(TEXT) RETURNS name IMMUTABLE LANGUAGE 'sql' AS
$_$ -- FD: pg:ws:50_pg.sql / 73 --
 SELECT (current_schema() || CASE WHEN $1 IS NULL THEN '' ELSE '.' || $1 END)::name
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_schema_oid(a_name text) RETURNS oid STABLE LANGUAGE 'sql' AS
$_$ -- FD: pg:ws:50_pg.sql / 79 --
  SELECT oid FROM pg_namespace WHERE nspname = $1
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_reserved_args() RETURNS text[] IMMUTABLE LANGUAGE 'sql' AS
$_$ -- FD: pg:ws:50_pg.sql / 85 --
  SELECT ARRAY['a__acl', 'a__sid', 'a__ip', 'a__cook', 'a__lang'];
$_$;


/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_proargs2str(a_names d_pg_argnames, a_types d_pg_argtypes, a_pub BOOL) RETURNS text STABLE LANGUAGE 'plpgsql' AS
$_$ -- FD: pg:ws:50_pg.sql / 92 --
  DECLARE
    v_reserved TEXT[];
    v_names TEXT[];
    v_i INTEGER;
  BEGIN
    v_reserved := ws.pg_reserved_args();
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
$_$ -- FD: pg:ws:50_pg.sql / 121 --
  SELECT $1
    , $2
    , obj_description(p.oid, 'pg_proc')
    , p.prorettype
    , pg_catalog.format_type(p.prorettype, NULL)
    , proretset
    , ws.pg_proargs2str(p.proargnames, p.proargtypes, false) -- proargtypes - only IN arguments
    , ws.pg_proargs2str(p.proargnames, p.proargtypes, true)
    FROM pg_catalog.pg_proc p
    WHERE p.pronamespace = ws.pg_schema_oid($1)
    AND p.proname = $2
  ;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.pg_register_proarg_old(a_code ws.d_code) RETURNS ws.d_id32 VOLATILE LANGUAGE 'plpgsql' AS
$_$ -- FD: pg:ws:50_pg.sql / 138 --
  DECLARE
    v_names text[];
    v_types oidvector;
    v_i INTEGER;
    v_name TEXT;
    v_type TEXT;
    v_id ws.d_id32;
  BEGIN
    SELECT INTO v_names, v_types, v_i
      p.proargnames, p.proargtypes, p.pronargs
      FROM pg_catalog.pg_proc p
        WHERE p.pronamespace = ws.pg_schema_oid(split_part(a_code, '.', 1))
        AND p.proname = split_part(a_code, '.', 2)
    ;

    IF v_i = 0 THEN
      -- ф-я не имеет аргументов
      RETURN NULL;
    END IF;

    RAISE NOTICE 'New datatype: %', a_code;
    IF v_names IS NULL THEN
      RAISE EXCEPTION 'No required arg names for %', a_code;
    END IF;

    INSERT INTO ws.dt (code, anno, is_complex)
      VALUES (split_part(a_code, '.', 1) || '.z_' || split_part(a_code, '.', 2), 'Aргументы метода ' || a_code, true)
      RETURNING id INTO v_id
    ;

    FOR v_i IN 0 .. pg_catalog.array_upper(v_types, 1) LOOP
      v_type := pg_catalog.format_type(v_types[v_i], NULL);
      IF COALESCE(v_names[v_i + 1], '') = '' THEN
        -- аргумент без имени - автогенерация невозможна
        RAISE EXCEPTION 'No required arg name for % arg id %',a_code, v_i;
      END IF;
      v_name := regexp_replace(v_names[v_i + 1], '^a_', '');
      RAISE NOTICE '   column % %', v_name, v_type;
      INSERT INTO ws.dt_part (id, part_id, code, parent_id, anno, def_val, allow_null)
        VALUES (v_id, v_i + 1, v_name, ws.dt_id(v_type), v_name, null, false)
      ;
    END LOOP;
    RETURN v_id;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.pg_proarg_arg_anno(a_src TEXT, a_argname TEXT) RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$ -- FD: pg:ws:50_pg.sql / 187 --
  SELECT (regexp_matches($1, E'--\\s+' || $2 || E':\\s+(.*)$', 'gm'))[1];
$_$;
/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.pg_register_proarg(a_code ws.d_code) RETURNS ws.d_id32 VOLATILE LANGUAGE 'plpgsql' AS
$_$ -- FD: pg:ws:50_pg.sql / 192 --
  DECLARE
    v_i INTEGER;
    v_id ws.d_id32;

    v_args TEXT;
    v_src  TEXT;
    v_arg_anno TEXT;
    v_defs TEXT[];
    v_def TEXT;
    v_name TEXT;
    v_type TEXT;
    v_default TEXT;
    v_allow_null BOOL;
  BEGIN
    SELECT INTO v_args, v_src
      pg_get_function_arguments(oid), prosrc
      FROM pg_catalog.pg_proc p
        WHERE p.pronamespace = ws.pg_schema_oid(split_part(a_code, '.', 1))
        AND p.proname = split_part(a_code, '.', 2)
    ;
    IF v_args = '' THEN
      -- ф-я не имеет аргументов
      RETURN NULL;
    END IF;

    RAISE NOTICE 'New datatype: %', a_code;
    RAISE DEBUG 'args: %',v_args;

    INSERT INTO ws.dt (code, anno, is_complex)
      VALUES (split_part(a_code, '.', 1) || '.z_' || split_part(a_code, '.', 2), 'Aргументы метода ' || a_code, true)
      RETURNING id INTO v_id
    ;

    v_defs := regexp_split_to_array(v_args, E',\\s+');
    FOR v_i IN 1 .. pg_catalog.array_upper(v_defs, 1) LOOP
      v_def := v_defs[v_i];
      IF v_def !~ E'^(IN)?OUT ' THEN
        v_def := 'IN ' || v_def;
      END IF;
      IF split_part(v_def, ' ', 1) = 'OUT' THEN
        CONTINUE;
      END IF;
      IF split_part(v_def, ' ', 3) IN ('', 'DEFAULT') THEN
        -- аргумент без имени - автогенерация невозможна
        RAISE EXCEPTION 'No required arg name for % arg id %',a_code, v_i;
      END IF;

      v_allow_null := FALSE;
      IF split_part(v_def, ' ', 4) = 'DEFAULT' THEN
        v_default := substr(v_def, strpos(v_def, ' DEFAULT ') + 9);
        v_default := regexp_replace(v_default, '::[^:]+$', '');
        IF v_default = 'NULL' THEN
          v_default := NULL;
          v_allow_null := TRUE;
        ELSE
          v_default := btrim(v_default, chr(39)); -- '
        END IF;
      ELSE
        v_default := NULL;
      END IF;
      v_name := regexp_replace(split_part(v_def, ' ', 2), '^a_', '');
      v_type := split_part(v_def, ' ', 3);
      v_arg_anno := COALESCE(ws.pg_proarg_arg_anno(v_src, split_part(v_def, ' ', 2)), '');
      RAISE NOTICE '   column name=%, type=%, def=%, null=%, anno=%', v_name, v_type, v_default, v_allow_null, v_arg_anno;
      INSERT INTO ws.dt_part (id, part_id, code, parent_id, anno, def_val, allow_null)
        VALUES (v_id, v_i, v_name, ws.dt_id(v_type), v_arg_anno, v_default, v_allow_null)
      ;
    END LOOP;
    RETURN v_id;
  END;
$_$;
/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_register_class(a_oid oid) RETURNS ws.d_id32 VOLATILE LANGUAGE 'plpgsql' AS
$_$ -- FD: pg:ws:50_pg.sql / 266 --
  DECLARE
    r_pg_type pg_catalog.pg_type;
    v_code TEXT;
    v_type TEXT;
    rec RECORD;

    v_id ws.d_id32;
  BEGIN
    SELECT INTO r_pg_type * FROM pg_catalog.pg_type WHERE oid = a_oid;
    v_code := pg_catalog.format_type(a_oid, NULL);
      IF r_pg_type.typnamespace = ws.pg_schema_oid(current_schema()) THEN
         -- в этом случае схемы в имени не будет
         v_code := current_schema() || '.'|| v_code;
      END IF;

    RAISE NOTICE 'New datatype: %', v_code;
    INSERT INTO ws.dt (code, anno, is_complex)
      VALUES (v_code, COALESCE(obj_description(r_pg_type.typrelid, 'pg_class'), obj_description(a_oid, 'pg_type'), v_code), true);
    v_id := ws.dt_id(v_code);
    FOR rec IN
      SELECT a.attname
        , pg_catalog.format_type(a.atttypid, a.atttypmod)
        , (SELECT substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid) for 128)
          FROM pg_catalog.pg_attrdef d
          WHERE d.adrelid = a.attrelid AND d.adnum = a.attnum AND a.atthasdef) as def_val
        , a.attnotnull
        , a.attnum
        , pg_catalog.col_description(a.attrelid, a.attnum) as anno
      FROM pg_catalog.pg_attribute a
      WHERE a.attrelid = r_pg_type.typrelid AND a.attnum > 0 AND NOT a.attisdropped
      ORDER BY a.attnum
    LOOP
      v_type := rec.format_type;
      IF v_type ~ E'^timestamp[\\( ]' THEN
        v_type := 'timestamp'; -- clean "timestamp(0) without time zone"
      ELSIF v_type ~ E'^time[\\( ]' THEN
        v_type := 'time'; -- clean "time without time zone"
      ELSIF v_type ~ E'^numeric\\(' THEN
        v_type := 'numeric'; -- clean "numeric(14,4)"
      ELSIF v_type ~ E'^double' THEN
        v_type := 'double'; -- clean "double precision"
      END IF;
      RAISE NOTICE '   column % %', rec.attname, v_type;
      INSERT INTO ws.dt_part (id, part_id, code, parent_id, anno, def_val, allow_null)
        VALUES (v_id, rec.attnum, rec.attname, ws.dt_id(v_type), COALESCE(rec.anno, rec.attname), rec.def_val, NOT rec.attnotnull)
      ;

    END LOOP;
    RETURN v_id;
  END;
$_$;
/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_c(a_type t_pg_object, a_code d_code, a_text text) RETURNS void VOLATILE LANGUAGE 'plpgsql' AS
$_$ -- FD: pg:ws:50_pg.sql / 320 --
  DECLARE
    v_code TEXT;
    v_name TEXT;
    rec ws.t_pg_proc_info;
  BEGIN
    IF split_part(a_code, '.', 2) = '' OR a_type IN ('c','a') AND split_part(a_code, '.', 3) = '' THEN
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

SELECT
  pg_c('f', 'pg_c', 'Создать комментарий к объекту БД')
;

/* ------------------------------------------------------------------------- */
\qecho '-- FD: pg:ws:50_pg.sql / 366 --'
