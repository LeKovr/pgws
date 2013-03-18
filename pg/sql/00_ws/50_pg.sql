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

    Функции ядра, метаданные Postgresql
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION set_search_path(a_path TEXT) RETURNS VOID LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_sql TEXT;
  BEGIN
    v_sql := 'SET LOCAL search_path = ' || a_path;
    EXECUTE v_sql;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION set_lang(a_lang TEXT DEFAULT NULL) RETURNS TEXT LANGUAGE 'plpgsql' AS
$_$
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
CREATE OR REPLACE FUNCTION ws.pg_register_proarg_old(a_code ws.d_code) RETURNS ws.d_code VOLATILE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_names text[];
    v_types oidvector;
    v_i INTEGER;
    v_name TEXT;
    v_type TEXT;
    v_code d_code;
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

    v_code := split_part(a_code, '.', 1) || '.z_' || split_part(a_code, '.', 2);

    INSERT INTO ws.dt (code, anno, is_complex)
      VALUES (v_code, 'Aргументы метода ' || a_code, true)
    ;

    FOR v_i IN 0 .. pg_catalog.array_upper(v_types, 1) LOOP
      v_type := pg_catalog.format_type(v_types[v_i], NULL);
      IF COALESCE(v_names[v_i + 1], '') = '' THEN
        -- аргумент без имени - автогенерация невозможна
        RAISE EXCEPTION 'No required arg name for % arg id %',a_code, v_i;
      END IF;
      v_name := regexp_replace(v_names[v_i + 1], '^a_', '');
      RAISE NOTICE '   column % %', v_name, v_type;
      INSERT INTO ws.dt_part (dt_code, part_id, code, parent_code, anno, def_val, allow_null)
        VALUES (v_code, v_i + 1, v_name, v_type, v_name, null, false)
      ;
    END LOOP;
    RETURN v_code;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.pg_proarg_arg_anno(a_src TEXT, a_argname TEXT) RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT (regexp_matches($1, E'--\\s+' || $2 || E':\\s+(.*)$', 'gm'))[1];
$_$;
/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.pg_register_proarg(a_code ws.d_code) RETURNS ws.d_code VOLATILE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_i INTEGER;
    v_code d_code;

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

    v_code := split_part(a_code, '.', 1) || '.z_' || split_part(a_code, '.', 2);

    INSERT INTO ws.dt (code, anno, is_complex)
      VALUES (v_code, 'Aргументы метода ' || a_code, true)
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
      IF NOT EXISTS(SELECT 1 FROM ws.dt WHERE code = dt_code(v_type)) THEN
        PERFORM ws.pg_register_type(v_type);
      END IF;     
      v_arg_anno := COALESCE(ws.pg_proarg_arg_anno(v_src, split_part(v_def, ' ', 2)), '');
      RAISE NOTICE '   column name=%, type=%, def=%, null=%, anno=%', v_name, v_type, v_default, v_allow_null, v_arg_anno;
      INSERT INTO ws.dt_part (dt_code, part_id, code, parent_code, anno, def_val, allow_null)
        VALUES (v_code, v_i, v_name, dt_code(v_type), v_arg_anno, v_default, v_allow_null)
      ;
    END LOOP;
    RETURN v_code;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_register_class(a_oid oid) RETURNS ws.d_code VOLATILE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    r_pg_type pg_catalog.pg_type;
    v_code TEXT;
    v_type TEXT;
    v_tpnm TEXT;
    v_islist boolean;
    rec RECORD;
  BEGIN
    SELECT INTO r_pg_type * FROM pg_catalog.pg_type WHERE oid = a_oid;
    v_code := ws.pg_type_name(a_oid);
    IF r_pg_type.typtype in ('c','b','d') THEN
      v_tpnm := CASE
        WHEN r_pg_type.typtype = 'c' THEN
          'Composite'
        WHEN r_pg_type.typtype = 'b' THEN
          'Base'
        WHEN r_pg_type.typtype = 'd' THEN
          'Domain'
        END;
      RAISE NOTICE 'Registering "%" type: % (%)', v_tpnm, v_code, a_oid;      
      v_islist := FALSE;
      IF r_pg_type.typtype = 'd' THEN
        v_type := 
         (SELECT pg_catalog.format_type(oid, typtypmod)
          FROM pg_type
          WHERE oid = r_pg_type.typbasetype);
        v_type := split_part(v_type, ' ', 1);
        v_islist := CASE WHEN v_type ~ '\[\]$' THEN TRUE ELSE FALSE END;
        v_type := split_part(btrim(v_type, '[]'),' ', 1);
        IF NOT EXISTS(SELECT 1 FROM ws.dt WHERE code = dt_code(v_type)) THEN
          v_type := ws.pg_register_type(split_part(btrim(v_type, '[]'),' ', 1));
        END IF;
        IF ws.dt_parent_base_code(v_type) is null THEN
          v_type := (select code from ws.dt where code = current_schema() || '.' || v_type);
        END IF;
        IF v_type IS NULL THEN
          RAISE EXCEPTION 'Parent type for domain % is unknown', v_code;
        END IF;
      END IF;
      INSERT INTO ws.dt (code, anno, is_complex, parent_code, is_list)
        VALUES (v_code, COALESCE(obj_description(r_pg_type.typrelid, 'pg_class'), obj_description(a_oid, 'pg_type'), v_code), 
          CASE WHEN r_pg_type.typtype = 'd' then false else true end
        , v_type, v_islist)
      ;
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
        v_islist := case when rec.format_type ~ '\[\]$' then true else false end;
        v_type := btrim(rec.format_type, '[]');
        IF v_type ~ E'^timestamp[\\( ]' THEN
          v_type := 'timestamp'; -- clean "timestamp(0) without time zone"
        ELSIF v_type ~ E'^time[\\( ]' THEN
          v_type := 'time'; -- clean "time without time zone"
        ELSIF v_type ~ E'^numeric\\(' THEN
          v_type := 'numeric'; -- clean "numeric(14,4)"
        ELSIF v_type ~ E'^double' THEN
          v_type := 'double'; -- clean "double precision"
        ELSIF v_type ~ E'^character varying' THEN
          v_type := 'text'; -- TODO: allow length
        END IF;
        RAISE NOTICE '   column % %', rec.attname, v_type;
        IF NOT EXISTS(SELECT 1 FROM ws.dt WHERE code IN ('ws.' || v_type, v_type)) THEN
          v_type := ws.pg_register_type(v_type);
          IF ws.dt_code(v_type) IS NULL THEN
            RAISE EXCEPTION 'Unknown type (%)', v_type;
          END IF;
        END IF;
        BEGIN
          INSERT INTO ws.dt_part (dt_code, part_id, code, parent_code, anno, def_val, allow_null, is_list)
            VALUES (v_code, rec.attnum, rec.attname, ws.dt_code(v_type), COALESCE(rec.anno, rec.attname), rec.def_val, NOT rec.attnotnull,v_islist)
          ;
          EXCEPTION
            WHEN CHECK_VIOLATION THEN
              RAISE EXCEPTION 'Unregistered % part type (%)', v_code, v_type
            ;
        END;
      END LOOP;
    ELSE
      RAISE EXCEPTION 'ERROR: OID = % неподдерживаемого типа "%"', a_oid, r_pg_type.typtype;
    END IF;
    RETURN v_code;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_register_type(a_type ws.d_code) RETURNS ws.d_code VOLATILE LANGUAGE 'sql' AS
$_$
  SELECT ws.pg_register_class(oid) FROM pg_type WHERE typname = $1 /* a_type */;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION tr_notify (
) RETURNS TRIGGER
LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_channel TEXT;
  BEGIN
    v_channel := TG_ARGV[0];
    PERFORM pg_notify(v_channel, NEW.id::TEXT);
    RETURN NEW;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION tr_exception (
) RETURNS TRIGGER
LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_text TEXT;
  BEGIN
    v_text := TG_ARGV[0];
    RAISE EXCEPTION '%', v_text;
    RETURN NEW;
  END;
$_$;/* ------------------------------------------------------------------------- */
