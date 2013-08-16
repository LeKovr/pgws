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

    Компиляция и установка пакетов
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION compile_errors_chk() RETURNS TEXT STABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_t TIMESTAMP := CURRENT_TIMESTAMP;
  BEGIN
    SELECT INTO v_t stamp FROM ws.compile_errors WHERE stamp = v_t LIMIT 1;
      IF FOUND THEN
        RAISE EXCEPTION '***************** Errors found *****************';
      END IF;
    RETURN 'Ok';
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION test(a_code d_code) RETURNS TEXT VOLATILE LANGUAGE 'plpgsql' AS
$_$
  BEGIN
    --t/test1_global_config.t .. ok
    --t/test2_run_config.t ..... ok
    IF a_code IS NULL THEN
      RAISE WARNING '::';
    ELSE
      RAISE WARNING '::%', rpad('t/'||a_code||' ', 30, '.');
    END IF;
    RETURN ' ***** ' || a_code || ' *****';
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg(a_code TEXT) RETURNS ws.pkg STABLE LANGUAGE 'sql' AS
$_$
  SELECT * FROM ws.pkg WHERE code = $1;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg_references(a_is_on BOOL, a_pkg name, a_schema name DEFAULT NULL) RETURNS SETOF TEXT VOLATILE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    r RECORD;
    v_sql TEXT;
    v_self_default TEXT;
  BEGIN
    -- defaults
    FOR r IN SELECT * 
      FROM wsd.pkg_default_protected
      WHERE pkg = a_pkg
        AND schema IS NOT DISTINCT FROM a_schema
        AND is_active = NOT a_is_on
    LOOP
      v_sql := CASE WHEN a_is_on THEN
        ws.sprintf('ALTER TABLE wsd.%s ALTER COLUMN %s SET DEFAULT %s'
          , quote_ident(r.wsd_rel) 
          , quote_ident(r.wsd_col) 
          , r.func
          )
      ELSE       
        ws.sprintf('ALTER TABLE wsd.%s ALTER COLUMN %s DROP DEFAULT'
        , quote_ident(r.wsd_rel) 
        , quote_ident(r.wsd_col) 
        )
      END;
      IF r.wsd_rel = 'pkg_default_protected' THEN
        v_self_default := v_sql; -- мы внутри цикла по этой же таблице
      ELSE
        EXECUTE v_sql;
      END IF;
      RETURN NEXT v_sql;
    END LOOP;
    IF v_self_default IS NOT NULL THEN
      EXECUTE v_self_default;
    END IF;
    UPDATE wsd.pkg_default_protected SET is_active = a_is_on
      WHERE pkg = a_pkg
        AND schema IS NOT DISTINCT FROM a_schema
        AND is_active = NOT a_is_on
    ;
    
    -- fkeys
    
        -- Перед удалением пакета - удаление всех присоединенных пакетом зарегистрированных FK
        -- rel in (select rel from wsd.pkg_fkey_required_by where required_by = a_pkg
        -- После создания пакета - создание всех еще несуществующих зарегистрированных FK присоединенных пакетом таблиц 
      --  NOT is_active AND rel not in (select rel from wsd.pkg_fkey_required_by where required_by not in (select code from ws.pkg)
    
    v_self_default := NULL;
    FOR r IN SELECT * 
      FROM wsd.pkg_fkey_protected
      WHERE is_active = NOT a_is_on
        AND CASE WHEN a_is_on THEN
          rel NOT IN (SELECT rel FROM wsd.pkg_fkey_required_by WHERE required_by NOT IN (SELECT code FROM ws.pkg))
            AND EXISTS (SELECT 1 FROM ws.pkg WHERE code = pkg)
          ELSE
          (pkg = a_pkg AND schema IS NOT DISTINCT FROM a_schema)
          OR rel IN (SELECT rel FROM wsd.pkg_fkey_required_by WHERE required_by = a_pkg)
        END
    LOOP
      v_sql := CASE WHEN a_is_on THEN
        ws.sprintf('ALTER TABLE wsd.%s ADD CONSTRAINT %s FOREIGN KEY (%s) REFERENCES %s'
          , quote_ident(r.wsd_rel)
          , r.wsd_rel || '_' || replace(regexp_replace(r.wsd_col, E'\\s','','g'), ',', '_') || '_fkey'
          , r.wsd_col -- может быть список колонок через запятую 
          , r.rel
          )
      ELSE       
        ws.sprintf('ALTER TABLE wsd.%s DROP CONSTRAINT %s'
          , quote_ident(r.wsd_rel)
          , r.wsd_rel || '_' || replace(regexp_replace(r.wsd_col, E'\\s','','g'), ',', '_') || '_fkey'
        )
      END;
      IF r.wsd_rel = 'pkg_fkey_protected' THEN
        v_self_default := v_sql; -- мы внутри цикла по этой же таблице
      ELSE
        EXECUTE v_sql;
      END IF;
      RETURN NEXT v_sql;
    END LOOP;
    IF v_self_default IS NOT NULL THEN
      EXECUTE v_self_default;
    END IF;
    UPDATE wsd.pkg_fkey_protected SET is_active = a_is_on
      WHERE is_active = NOT a_is_on
        AND CASE WHEN a_is_on THEN
          rel NOT IN (SELECT rel FROM wsd.pkg_fkey_required_by WHERE required_by NOT IN (SELECT code FROM ws.pkg))
            AND EXISTS (SELECT 1 FROM ws.pkg WHERE code = pkg)
          ELSE
          (pkg = a_pkg AND schema IS NOT DISTINCT FROM a_schema)
          OR rel IN (SELECT rel FROM wsd.pkg_fkey_required_by WHERE required_by = a_pkg)
        END
    ;
    RETURN;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg_op_before(a_op t_pkg_op, a_code name, a_schema name, a_log_name TEXT, a_user_name TEXT, a_ssh_client TEXT) RETURNS TEXT VOLATILE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    r_pkg ws.pkg%ROWTYPE;
    r RECORD;
    v_sql TEXT;
    v_self_default TEXT;
    v_pkgs TEXT;
  BEGIN
    r_pkg := ws.pkg(a_code);
    CASE a_op
      WHEN 'init' THEN
        IF r_pkg IS NOT NULL AND a_schema = ANY(r_pkg.schemas)THEN
          RAISE EXCEPTION '***************** Package % schema % installed already at % (%) *****************'
          , a_code, a_schema, r_pkg.stamp, r_pkg.id
          ;
        END IF;
        IF r_pkg IS NULL THEN
          INSERT INTO ws.pkg (id, code, schemas, log_name, user_name, ssh_client, op) VALUES 
            (NEXTVAL('ws.pkg_id_seq'), a_code, ARRAY[a_schema], a_log_name, a_user_name, a_ssh_client, a_op)
            RETURNING * INTO r_pkg
          ;
        ELSE 
          UPDATE ws.pkg SET
            id          = NEXTVAL('ws.pkg_id_seq') -- runs after rule
          , schemas     = array_append(schemas, a_schema)
          , log_name    = a_log_name
          , user_name   = a_user_name
          , ssh_client  = a_ssh_client
          , stamp       = now()
          , op          = a_op
          WHERE code = a_code
            RETURNING * INTO r_pkg
          ;
        END IF;
        r_pkg.schemas = ARRAY[a_schema]; -- save schema in log
        INSERT INTO ws.pkg_log VALUES (r_pkg.*);
      WHEN 'make' THEN
        UPDATE ws.pkg SET
          id            = NEXTVAL('ws.pkg_id_seq') -- runs after rule
        , log_name    = a_log_name
        , user_name   = a_user_name
        , ssh_client  = a_ssh_client
        , stamp       = now()
        , op          = a_op
        WHERE code = a_code
          RETURNING * INTO r_pkg
        ;
        IF NOT FOUND THEN
          RAISE EXCEPTION '***************** Package % schema % does not found *****************'
          , a_code, a_schema
          ;
        END IF;
        r_pkg.schemas = ARRAY[a_schema]; -- save schema in log
        INSERT INTO ws.pkg_log VALUES (r_pkg.*);
      WHEN 'drop', 'erase' THEN
        SELECT INTO v_pkgs
          array_to_string(array_agg(required_by::TEXT),', ')
          FROM ws.pkg_required_by 
          WHERE code = a_code
        ;
        IF v_pkgs IS NOT NULL THEN
          RAISE EXCEPTION '***************** Package % is required by others (%) *****************', a_code, v_pkgs;
        END IF;
        PERFORM ws.pkg_references(FALSE, a_code, a_schema);
        IF a_schema <> 'ws' OR a_code = 'ws' THEN
          -- удаляем описания ошибок, заданные в этой схеме
          -- кроме случая удаления схемы ws не в пакете ws
          DELETE FROM ws.error_data ed USING ws.pg_const c 
            WHERE c.code LIKE 'const_error%' 
              AND c.schema = a_schema
              AND ed.code = c.value
          ;
        END IF;

    END CASE;
    RETURN 'Ok';
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg_op_after(a_op t_pkg_op, a_code name, a_schema name, a_log_name TEXT, a_user_name TEXT, a_ssh_client TEXT) RETURNS TEXT VOLATILE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    r_pkg ws.pkg%ROWTYPE;
    r RECORD;
    v_sql TEXT;
    v_self_default TEXT;
  BEGIN
    r_pkg := ws.pkg(a_code);
    CASE a_op
      WHEN 'init' THEN
        IF a_code = 'ws' AND a_schema = 'ws' THEN
          INSERT INTO ws.pkg (id, code, schemas, log_name, user_name, ssh_client, op) VALUES 
            (NEXTVAL('ws.pkg_id_seq'), a_code, ARRAY[a_schema], a_log_name, a_user_name, a_ssh_client, a_op)
            RETURNING * INTO r_pkg
          ;
          r_pkg.schemas = ARRAY[a_schema]; -- save schema in log
          INSERT INTO ws.pkg_log VALUES (r_pkg.*);
        END IF;
        PERFORM ws.pkg_references(TRUE, a_code, a_schema);
        UPDATE ws.pkg SET op = 'done' WHERE code = a_code;
      WHEN 'drop', 'erase' THEN
        INSERT INTO ws.pkg_log (id, code, schemas, log_name, user_name, ssh_client, op)
          VALUES (NEXTVAL('ws.pkg_id_seq'), a_code, ARRAY[a_schema], a_log_name, a_user_name, a_ssh_client, a_op)
        ;
        IF a_schema <> 'ws' THEN
          DELETE FROM ws.method           WHERE pkg = a_schema;
          DELETE FROM ws.page_data        WHERE pkg = a_schema;
          -- удалить классы пакета
          DELETE FROM ws.class WHERE pkg = a_schema;
        END IF;  
        -- удалить неиспользуемые группы
        DELETE FROM i18n_def.page_group pg WHERE NOT EXISTS(SELECT code FROM ws.page_data WHERE group_id = pg.id);


        IF a_op = 'erase' AND a_schema <> 'ws' THEN
          DELETE FROM wsd.pkg_script_protected  WHERE pkg = a_schema;
          DELETE FROM wsd.pkg_default_protected WHERE pkg = a_schema;
          DELETE FROM wsd.pkg_fkey_protected    WHERE pkg = a_schema;
          DELETE FROM wsd.pkg_fkey_required_by  WHERE required_by = a_schema;
        END IF;
        DELETE FROM ws.pkg_required_by  WHERE required_by = a_schema;
        IF r_pkg.schemas = ARRAY[a_schema] THEN
          -- last/single schema
          DELETE FROM ws.pkg WHERE code = a_code;
        ELSE  
          UPDATE ws.pkg SET
            schemas = ws.array_remove(schemas, a_schema)
            WHERE code = a_code
          ;
        END IF;
      WHEN 'make' THEN
        NULL;
    END CASE;
    RETURN 'Ok';
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg_require(a_code TEXT) RETURNS TEXT STABLE LANGUAGE 'plpgsql' AS
$_$
  BEGIN
    RAISE NOTICE 'TODO: function needs code';
    RETURN NULL;
  END
$_$;

/* ------------------------------------------------------------------------- */
