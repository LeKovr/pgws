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
  -- a_path: путь поиска
  DECLARE
    v_sql TEXT;
  BEGIN
    v_sql := 'SET LOCAL search_path = ' || a_path;
    EXECUTE v_sql;
  END;
$_$;
SELECT pg_c('f', 'set_search_path', 'установить переменную search_path');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION set_lang(a_lang TEXT DEFAULT NULL) RETURNS TEXT LANGUAGE 'plpgsql' AS
$_$
  -- a_lang:  язык
  DECLARE
    v_lang     TEXT;
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
SELECT pg_c('f', 'set_lang', 'установить локаль');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION normalize_type_name(a_type TEXT) RETURNS TEXT LANGUAGE 'sql' AS
$_$
  -- a_type:  тип
  SELECT CASE
    WHEN $1 ~ E'^timestamp[\\( ]' THEN
      'timestamp' -- clean "timestamp(0) without time zone"
    WHEN $1 ~ E'^time[\\( ]' THEN
      'time' -- clean "time without time zone"
    WHEN $1 ~ E'^numeric\\(' THEN
      'numeric' -- clean "numeric(14,4)"
    WHEN $1 ~ E'^double' THEN
      'double' -- clean "double precision"
    WHEN $1 ~ E'^character( varying)?' THEN
      'text' -- TODO: allow length
    ELSE
      $1 
    END
$_$;
SELECT pg_c('f', 'normalize_type_name', 'нормализует название типа');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.pg_register_proarg_old(a_code ws.d_code) RETURNS ws.d_code VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- a_code:  название функции
  DECLARE
    v_names TEXT[];
    v_types oidvector;
    v_i     INTEGER;
    v_name  TEXT;
    v_type  TEXT;
    v_code  d_code;
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
SELECT pg_c('f', 'pg_register_proarg_old', 'регистрация в ws.dt и ws.dt_part');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.pg_proarg_arg_anno(
  a_src     TEXT
, a_argname TEXT
) RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  -- a_src:     путь к функции
  -- a_argname: название аргумента
  SELECT (regexp_matches($1, E'--\\s+' || $2 || E':\\s+(.*)$', 'gm'))[1];
$_$;
SELECT pg_c('f', 'pg_proarg_arg_anno', 'возвращает описание аргумента');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.pg_register_proarg(a_code ws.d_code) RETURNS ws.d_code VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- a_code:  название функции
  DECLARE
    v_i          INTEGER;
    v_code       ws.d_code;
    v_args       TEXT;
    v_src        TEXT;
    v_arg_anno   TEXT;
    v_defs       TEXT[];
    v_def        TEXT;
    v_name       TEXT;
    v_type       TEXT;
    v_default    TEXT;
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
      v_type := ws.pg_dt_registered(v_type);
      v_arg_anno := COALESCE(ws.pg_proarg_arg_anno(v_src, split_part(v_def, ' ', 2)), '');
      RAISE NOTICE '   column name=%, type=%, def=%, null=%, anno=%', v_name, v_type, v_default, v_allow_null, v_arg_anno;
      INSERT INTO ws.dt_part (dt_code, part_id, code, parent_code, anno, def_val, allow_null)
        VALUES (v_code, v_i, v_name, v_type, v_arg_anno, v_default, v_allow_null)
      ;
    END LOOP;
    RETURN v_code;
  END;
$_$;
SELECT pg_c('f', 'pg_register_proarg', 'регистрация в ws.dt и ws.dt_part по названию');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION dt_code_extract(
  a_anno     TEXT
, OUT o_type TEXT
, OUT o_anno TEXT
) IMMUTABLE LANGUAGE 'plpgsql' AS
$_$
  -- a_anno:  описание
  -- o_type:  возвращаемый тип
  -- o_anno:  возвращаемое описание 
  DECLARE
    v_pos INTEGER;
  BEGIN
    v_pos := position(',' IN a_anno);
    IF v_pos > 1 THEN
      o_type := substring(a_anno from 1 for v_pos -1);
      o_anno := ltrim(substring(a_anno from v_pos + 1));
      IF o_type !~ E'^[a-z][0-9a-z_\\.]+$' THEN
        o_type := NULL;
      END IF;
    END IF;
    IF o_type IS NULL THEN
      o_anno := a_anno;
    END IF;
  END;
$_$;
SELECT pg_c('f', 'dt_code_extract', 'возвращает тип и описание');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_register_class(a_oid oid) RETURNS ws.d_code VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- a_oid:  OID
  DECLARE
    r_pg_type pg_catalog.pg_type;
    v_code    TEXT;
    v_type    TEXT;
    v_type1   TEXT;
    v_tpnm    TEXT;
    v_islist  BOOLEAN;
    v_schm    TEXT;
    v_anno    TEXT;
    rec       RECORD;
  BEGIN
    SELECT INTO r_pg_type * FROM pg_catalog.pg_type WHERE oid = a_oid;
    v_code := ws.pg_type_name(a_oid);
--raise warning 'VT % -- %',v_code,(select array_agg(code::text)::text from ws.dt where code like '%d_prop_code');

    IF r_pg_type.typtype IN ('c', 'd', 'p') THEN
      v_tpnm := CASE
        WHEN r_pg_type.typtype = 'c' THEN
          'Composite'
        WHEN r_pg_type.typtype = 'd' THEN
          'Domain'
        WHEN r_pg_type.typtype = 'p' THEN
          'Void'
        END;
      RAISE NOTICE 'Registering "%" type: % (%)', v_tpnm, v_code, a_oid;      
      v_islist := FALSE;
      IF r_pg_type.typtype = 'd' THEN
        -- проверить необходимость регистрации родительского домена
        v_type := ws.pg_type_name(r_pg_type.typbasetype);
        IF v_type ~ E'\\[\\]$' THEN
          v_islist := TRUE;
          v_type := split_part(btrim(v_type, '[]'),' ', 1);
        END IF;
        v_type := ws.normalize_type_name(v_type);
        IF NOT EXISTS(SELECT 1 FROM ws.dt WHERE code = v_type) THEN
          IF position('.' IN v_type) = 0 THEN
            RAISE EXCEPTION 'Parent type for domain % is base and unknown (%)', v_code, v_type;
          END IF;
          v_type := ws.pg_register_type(v_type);
        END IF;
        IF v_type IS NULL THEN
          RAISE EXCEPTION 'Parent type for domain % is unknown', v_code;
        END IF;
      END IF;
      INSERT INTO ws.dt (code, anno, is_complex, parent_code, is_list)
        VALUES (v_code, COALESCE(obj_description(r_pg_type.typrelid, 'pg_class'), obj_description(a_oid, 'pg_type'), v_code), 
          CASE WHEN r_pg_type.typtype = 'c' THEN true ELSE false END
        , v_type, v_islist)
      ;
      IF r_pg_type.typtype = 'd' THEN
        PERFORM ws.pg_register_class_facet(a_oid);
        RETURN v_code;
      ELSIF r_pg_type.typtype = 'p' THEN
        RETURN v_code;
      END IF;
      
      FOR rec IN
        -- TODO: перенести в 18_pg, возвращать refcursor
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
        v_islist := case when rec.format_type ~ E'\\[\\]$' THEN TRUE ELSE FALSE END;
        SELECT INTO v_type, v_anno * FROM ws.dt_code_extract(rec.anno);
        IF v_type IS NULL THEN
          v_type := btrim(rec.format_type, '[]');
          v_type := ws.normalize_type_name(v_type);
          RAISE NOTICE '   column % %', rec.attname, v_type;
        ELSE
          RAISE NOTICE '   column % % (%)', rec.attname, v_type, rec.format_type;
        END IF;
        BEGIN
          v_type := ws.pg_dt_registered(v_type);
          EXCEPTION
            WHEN raise_exception THEN
              RAISE EXCEPTION 'Unknown type %:%', v_code, v_type
          ;
        END;
        BEGIN
          INSERT INTO ws.dt_part (dt_code, part_id, code, parent_code, anno, def_val, allow_null, is_list)
            VALUES (v_code, rec.attnum, rec.attname, v_type, COALESCE(v_anno, rec.attname), rec.def_val, NOT rec.attnotnull,v_islist)
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
SELECT pg_c('f', 'pg_register_class', 'регистрация в ws.dt и ws.dt_part по OID-у');

/* ------------------------------------------------------------------------- */

CREATE OR REPLACE FUNCTION pg_register_class_facet(
  a_oid oid
, a_exe BOOLEAN DEFAULT TRUE
) RETURNS BOOLEAN VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- a_oid:  OID
  -- a_exe:  флаг
  DECLARE
    v_cstr  TEXT;
    v_type  TEXT;
    v_tpnm  TEXT;
    v_facet TEXT;
  BEGIN
    v_cstr := (SELECT consrc FROM pg_constraint WHERE contypid = a_oid);
    v_type := ws.pg_type_name(a_oid);
    IF coalesce(v_cstr, '') = '' THEN
      RETURN TRUE;
    ELSIF position(' AND ' in upper(v_cstr)) > 0 OR position(' OR ' in upper(v_cstr)) > 0 THEN
      RAISE NOTICE 'Констрейнт c > 1 частью не поддерживается, домен OID: %', a_oid;
      RETURN FALSE;
    ELSE
      v_cstr := btrim(v_cstr, '()');
      IF position('VALUE ~ ' in upper(v_cstr)) > 0 THEN
        v_facet := replace(v_cstr, 'VALUE ~ ''', '');
        v_facet := replace(v_facet, '''::text', '');
        v_facet := replace(v_facet, E'\\\\', E'\\'); -- TODO строка добавлена для совместимости с PG 9.0
        IF a_exe THEN
         INSERT INTO ws.dt_facet (code, facet_id, value) VALUES (v_type, facet_id('pattern'), v_facet);
        END IF;
        RETURN TRUE;
      ELSE
        DECLARE
          v_i    INT;
          v_oper TEXT[] = ARRAY['>=','=<','>','<'];
          v_fct  TEXT[] = ARRAY['minInclusive','maxInclusive','minExclusive','maxExclusive'];
        BEGIN
          FOR v_i in array_lower(v_oper,1)..array_upper(v_oper,1) LOOP
            IF position('VALUE ' || v_oper[v_i] in v_cstr) > 0 THEN
              v_facet := replace(v_cstr, 'VALUE ' || v_oper[v_i], '');
              v_facet := split_part(v_facet, '::', 1);
              v_facet := btrim(v_facet, ' ()');
              IF a_exe THEN
                INSERT INTO ws.dt_facet (code, facet_id, value) VALUES (v_type, facet_id(v_fct[v_i]), v_facet);
              END IF;
              RETURN TRUE;
            END IF;
          END LOOP;
        END;
      END IF;
    END IF;
    RAISE NOTICE 'Неподдерживаемый констрейнт, домен OID: %', a_oid;
    RETURN FALSE;
  END;
$_$;
SELECT pg_c('f', 'pg_register_class_facet', 'регистрация в ws.dt_facet по OID-у');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_dt_registered(a_type d_code) RETURNS d_code LANGUAGE 'plpgsql' AS
$_$
  -- a_type:  тип
  DECLARE
    v_type TEXT;
  BEGIN
    IF NOT EXISTS(SELECT 1 FROM ws.dt WHERE code = a_type) THEN
      -- в текущем виде тип не найден
      IF position('.' IN a_type) = 0 THEN
        -- схема не указана, но должна быть в search_path
        v_type := ws.pg_type_search(a_type);
        IF v_type IS NULL THEN
          RAISE EXCEPTION 'Type % not found', a_type;
        END IF;
        IF NOT EXISTS(SELECT 1 FROM ws.dt WHERE code = v_type) THEN
          -- тип существует, но не зарегистрирован
          RETURN ws.pg_register_type(v_type);
        END IF;
        RETURN v_type; 
      ELSE
        -- регистрируем тип
        RETURN ws.pg_register_type(a_type);
      END IF;
    END IF;
    RETURN a_type;
  END;
$_$;
SELECT pg_c('f', 'pg_dt_registered', 'проверка и регистрация типа');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_register_type(a_type ws.d_code) RETURNS ws.d_code VOLATILE LANGUAGE 'sql' AS
$_$
  -- a_type:  тип
  SELECT ws.pg_register_class(ws.pg_type_oid($1));
$_$;
SELECT pg_c('f', 'pg_register_type', 'регистрация типа');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.pg_const(a_code d_code DEFAULT NULL) RETURNS SETOF t_hashtable STABLE LANGUAGE 'sql' AS
$_$
  -- a_code: название константы
  SELECT schema || '_' || code, value FROM ws.pg_const WHERE CASE WHEN $1 IS NULL THEN TRUE ELSE (schema || '_' || code) = $1 END ORDER BY 1;
$_$;
SELECT pg_c('f', 'pg_const', 'Константы PGWS для использования вне бэкенда');

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
SELECT pg_c('f', 'tr_notify', 'триггер на INSERT/UPDATE таблицы wsd.job');

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
$_$;
SELECT pg_c('f', 'tr_exception', 'триггер на UPDATE таблицы wsd.job и wsd.job_todo');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION replace_table_desc(
  a_name        TEXT
, a_pattern     TEXT
, a_replacement TEXT
) RETURNS SETOF t_hashtable VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- a_name:        название таблицы
  -- a_pattern:     паттерн
  -- a_replacement: новый комментарий
DECLARE
  v_schema  TEXT;
  v_table   TEXT;
  v_rec     RECORD;
  v_desc    TEXT;
  v_changed BOOL;
BEGIN
  v_schema := split_part(a_name, '.', 1);
  v_table := split_part(a_name, '.', 2);
  FOR v_rec IN
    SELECT
      attnum AS column_number
    , attname AS column_name
    , col_description(attrelid, attnum) AS description
      FROM pg_catalog.pg_attribute
      WHERE attrelid = a_name::regclass
        AND attnum > 0
        AND NOT attisdropped
  LOOP
    v_desc := regexp_replace(v_rec.description, a_pattern, a_replacement);
    v_changed := (v_desc <> v_rec.description);
    IF v_changed THEN
      EXECUTE ws.sprintf(E'COMMENT ON COLUMN %s.%s IS \'%s\'', a_name, v_rec.column_name, v_desc); 
    END IF;
    RETURN QUERY
      SELECT CASE WHEN v_changed THEN '1' ELSE '0' END, v_desc;
  END LOOP;
  RETURN;
END
$_$;
SELECT pg_c('f', 'replace_table_desc', 'Изменение комментариев всех столбцов таблицы по регулярному выражению');
