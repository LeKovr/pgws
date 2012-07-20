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

    Функции триггеров
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION dt_insupd_trigger() RETURNS TRIGGER STABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_id ws.d_id32;
  BEGIN

    IF NEW.id = NEW.parent_id AND (NEW.is_complex OR NEW.is_list) THEN
      -- базовый тип - только скаляр
      RAISE EXCEPTION 'Unsupported value set: % % % %', NEW.id, NEW.parent_id, NEW.is_complex, NEW.is_list;
    END IF;

    IF NEW.parent_id IS NOT NULL THEN
      -- определить base_id если задан parent_id
      IF NEW.id = NEW.parent_id THEN
        NEW.base_id := NEW.id;
      ELSE
        v_id := ws.dt_parent_base_id(NEW.parent_id);
        IF v_id IS NULL THEN
          RAISE EXCEPTION 'Incorrect parent_id: %', NEW.parent_id;
        END IF;
        NEW.base_id := v_id;
      END IF;
    END IF;

    -- TODO: запретить изменение is_list и is_complex для parent

    -- NEW.anno := COALESCE(NEW.anno, NEW.code);

    RETURN NEW;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION dt_part_insupd_trigger() RETURNS TRIGGER STABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_id ws.d_id32;
  BEGIN
      -- проверить что в описании parent типа стоит is_complex

    IF NEW.parent_id IS NOT NULL THEN
      -- определить base_id если задан parent_id
      v_id := ws.dt_part_parent_base_id(NEW.parent_id);
      IF v_id IS NULL THEN
        RAISE EXCEPTION 'Incorrect parent_id: %', NEW.parent_id;
      END IF;
      NEW.base_id := v_id;
    END IF;
    -- NEW.anno := COALESCE(NEW.anno, NEW.code);

    RETURN NEW;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION dt_facet_insupd_trigger() RETURNS TRIGGER STABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_id ws.d_id32;
  BEGIN
    v_id := ws.dt_parent_base_id(NEW.id);
    IF v_id IS NULL THEN
      RAISE EXCEPTION 'Incorrect dt id: %', NEW.id;
    END IF;
    NEW.base_id := v_id;
    RETURN NEW;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION page_insupd_trigger() RETURNS TRIGGER IMMUTABLE LANGUAGE 'plpgsql' AS
$_$
  BEGIN
    IF NEW.uri_re IS NULL THEN
      NEW.uri_re := ws.mask2regexp(NEW.uri);
    END IF;
    IF NEW.uri_fmt IS NULL THEN
      NEW.uri_fmt := ws.mask2format(NEW.uri);
    END IF;
    RAISE NOTICE 'New page: %', NEW.uri_re;
    RETURN NEW;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION method_insupd_trigger() RETURNS TRIGGER VOLATILE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    r_proc ws.t_pg_proc_info;
    v_code text;
    v_dt_id ws.d_id32;
  BEGIN
    IF NEW.code_real ~ ':' THEN
      NEW.is_sql := FALSE;
      NEW.args := COALESCE(ws.dt_parts(NEW.arg_dt_id), '');
      -- TODO: check cache
      -- TODO: check plugin config
    ELSE
      -- проверим наличие функции
      NEW.code_real  := COALESCE(NEW.code_real, NEW.code);

      r_proc := ws.pg_proc_info(split_part(NEW.code_real, '.', 1), split_part(NEW.code_real, '.', 2));
      IF r_proc IS NULL THEN
        RAISE EXCEPTION 'Unknown internal func (%)', NEW.code_real;
        RETURN NULL;
      END IF;

      v_code := r_proc.rt_name;
  /*    IF r_proc.schema = ws.pg_cs('') THEN
         -- в этом случае схемы в имени не будет
         v_code := r_proc.schema || '.'|| v_code;
      END IF;
    */  v_dt_id := ws.dt_id(v_code);
      IF v_dt_id IS NOT NULL THEN
        NEW.rv_dt_id := v_dt_id;
      ELSE
        -- если это - таблицы, можем сделать авторегистрацию
        RAISE NOTICE 'Unknown rv_type: %', v_code;
        NEW.rv_dt_id := ws.pg_register_class(r_proc.rt_oid);
      END IF;

      IF NEW.arg_dt_id IS NULL THEN
        v_dt_id := ws.dt_id(split_part(NEW.code_real, '.', 1) ||'.z_'|| split_part(NEW.code_real, '.', 2)); -- NEW.code_real);
        IF v_dt_id IS NULL THEN
          -- авторегистрация типа аргументов
          v_dt_id := ws.pg_register_proarg(NEW.code_real);
        END IF;
        NEW.arg_dt_id    := v_dt_id;
      END IF;

      NEW.name := COALESCE(NEW.name, r_proc.anno);
      NEW.args := COALESCE(ws.dt_parts(v_dt_id), '');
      -- TODO: сравнить args с r_proc.args
    END IF;

    IF NEW.arg_dt_id IS NOT NULL AND NOT COALESCE(ws.dt_is_complex(NEW.arg_dt_id), false) THEN
        RAISE EXCEPTION 'Method arg type (%) must be complex', NEW.arg_dt_id;
    END IF;

    RAISE NOTICE 'New method: %(%) -> %.', NEW.code_real, NEW.arg_dt_id, NEW.rv_dt_id;
    RETURN NEW;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_calc_is_mask() RETURNS TRIGGER VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- prop_calc_is_mask: Расчет значения поля is_mask
  BEGIN
    NEW.is_mask := ws.mask_is_multi(NEW.code);
    RETURN NEW;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION wsd_prop_value_insupd_trigger() RETURNS TRIGGER IMMUTABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_rows INTEGER;
  BEGIN
    SELECT INTO v_rows
      count(1)
      FROM ws.prop
      WHERE NEW.pogc = ANY(pogc_list)
        AND NEW.code ~ ws.mask2regexp(code)
    ;
    IF v_rows = 0 THEN
      RAISE EXCEPTION 'Unknown code % in group %', NEW.code, NEW.pogc;
    ELSIF v_rows > 1 THEN
      RAISE EXCEPTION 'code % related to % props, but need only 1', NEW.code, v_rows;
    END IF;
    RETURN NEW;
  END;
$_$;
