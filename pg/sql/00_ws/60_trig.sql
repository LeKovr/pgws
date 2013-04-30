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
CREATE OR REPLACE FUNCTION dt_insupd_trigger() RETURNS TRIGGER LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_code ws.d_code;
  BEGIN
    IF NEW.code = NEW.parent_code AND (NEW.is_complex OR NEW.is_list) THEN
      -- базовый тип - только скаляр
      RAISE EXCEPTION 'Unsupported value set: % % % %', NEW.code, NEW.parent_code, NEW.is_complex, NEW.is_list;
    END IF;
    IF NEW.parent_code IS NOT NULL THEN
      -- определить base_id если задан parent_code
      IF NEW.code = NEW.parent_code THEN
        NEW.base_code := NEW.code;
      ELSE
        v_code := ws.dt_parent_base_code(NEW.parent_code);
        IF v_code IS NULL then
           NEW.parent_code := ws.pg_dt_registered(NEW.parent_code);
           v_code := ws.dt_parent_base_code(NEW.parent_code);
        END IF;
        IF v_code IS NULL THEN
          RAISE EXCEPTION 'Incorrect parent_code: %', NEW.parent_code;
        END IF;
        NEW.base_code := v_code;
      END IF;
    END IF;
    -- TODO: запретить изменение is_list и is_complex для parent
    -- NEW.anno := COALESCE(NEW.anno, NEW.code);
    RETURN NEW;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION dt_part_del_trigger() RETURNS TRIGGER LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_code ws.d_code;
  BEGIN
    -- удалим parent текущего поля, если он больше не используется
    SELECT code into v_code FROM ws.dt d
     WHERE code = OLD.parent_code 
       AND ws.pg_register_class_facet((SELECT oid FROM pg_catalog.pg_type
                                       WHERE OLD.parent_code ~ E'\\.'
                                       AND   typname = split_part(OLD.parent_code, '.', 2)
                                       AND   typnamespace = (SELECT oid FROM pg_namespace
                                                              WHERE nspname = split_part(OLD.parent_code, '.', 1))), FALSE)
       AND NOT EXISTS (SELECT 1 FROM ws.method WHERE arg_dt_code = OLD.parent_code)
       AND NOT EXISTS (SELECT 1 FROM ws.method WHERE  rv_dt_code = OLD.parent_code)
       AND NOT EXISTS (SELECT 1 FROM ws.facet_dt_base f WHERE f.base_code = OLD.parent_code)
       AND NOT EXISTS (SELECT 1 FROM ws.dt where (OLD.parent_code IN (base_code, parent_code)))
       AND NOT EXISTS (SELECT 1 FROM ws.dt_part WHERE OLD.parent_code = base_code)
       AND NOT EXISTS (SELECT 1 FROM ws.dt_part WHERE OLD.parent_code = parent_code
                                                  AND NOT (dt_code = OLD.dt_code AND part_id = OLD.part_id))
       AND NOT is_list AND NOT is_complex;
    IF v_code IS NOT NULL THEN
      BEGIN
        CREATE LOCAL TEMPORARY TABLE dt_part_mark
         (dt_code ws.d_code NOT NULL,
          part_id ws.d_cnt NOT NULL)
          ON COMMIT DROP;
      EXCEPTION WHEN duplicate_table THEN
        NULL;
      END;
      IF NOT EXISTS(SELECT 1 FROM dt_part_mark WHERE dt_code = OLD.dt_code AND part_id = OLD.part_id) THEN
        INSERT INTO dt_part_mark (dt_code,part_id) VALUES(OLD.dt_code,OLD.part_id);
        DELETE FROM ws.dt_part WHERE dt_code = OLD.dt_code AND part_id = OLD.part_id;
        DELETE FROM ws.dt_facet WHERE code = v_code;
        DELETE FROM ws.dt WHERE code = v_code;
        RETURN NULL;
      END IF;
    END IF;
    RETURN OLD;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION dt_part_insupd_trigger() RETURNS TRIGGER LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_code ws.d_code;
  BEGIN
      -- проверить что в описании parent типа стоит is_complex

    IF NEW.parent_code IS NOT NULL THEN
      -- определить base_id если задан parent_code
      NEW.parent_code := ws.pg_dt_registered(NEW.parent_code);
      v_code := ws.dt_part_parent_base_code(NEW.parent_code);
      IF v_code IS NULL THEN
        RAISE EXCEPTION 'Incorrect part parent_code: %', NEW.parent_code;
      END IF;
      NEW.base_code := v_code;
    END IF;
    -- NEW.anno := COALESCE(NEW.anno, NEW.code);

    RETURN NEW;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION dt_facet_insupd_trigger() RETURNS TRIGGER LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_code ws.d_code;
  BEGIN
    v_code := ws.pg_dt_registered(NEW.code);
    NEW.base_code := ws.dt_parent_base_code(v_code);
    IF NEW.base_code IS NULL THEN
      RAISE EXCEPTION 'Incorrect dt id: %', NEW.code;
    END IF;
    NEW.code := v_code;
    RETURN NEW;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION page_insupd_trigger() RETURNS TRIGGER IMMUTABLE LANGUAGE 'plpgsql' AS
$_$
  BEGIN
    IF NEW.uri IS NOT NULL THEN
      IF NEW.uri_re IS NULL THEN
        NEW.uri_re := ws.mask2regexp(NEW.uri);
      END IF;
      IF NEW.uri_fmt IS NULL THEN
        NEW.uri_fmt := ws.mask2format(NEW.uri);
      END IF;
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
    v_dt_code ws.d_code;
  BEGIN
    IF NEW.code_real ~ ':' THEN
      NEW.is_sql := FALSE;
      NEW.args := COALESCE(ws.dt_parts(NEW.arg_dt_code), '');
    ELSE
      -- проверим наличие функции
      NEW.code_real  := COALESCE(NEW.code_real, NEW.code);

      r_proc := ws.pg_proc_info(split_part(NEW.code_real, '.', 1), split_part(NEW.code_real, '.', 2));
      IF r_proc IS NULL THEN
        RAISE EXCEPTION 'Unknown internal func (%)', NEW.code_real;
        RETURN NULL;
      END IF;
      -- поиск и регистрация типа результата
      IF NEW.rv_dt_code IS NOT NULL THEN
        RAISE EXCEPTION 'Direct rv type () ignored (method: %)',NEW.rv_dt_code, NEW.code;
      END IF;
      v_code := r_proc.rt_name;
      IF v_code IS NOT NULL THEN
        IF NOT EXISTS(SELECT 1 FROM ws.dt WHERE code = v_code) THEN 
          NEW.rv_dt_code := ws.pg_register_class(r_proc.rt_oid);          
        ELSE
          NEW.rv_dt_code := v_code;
        END IF;
      END IF;
      -- поиск и регистрация типа аргументов
      IF NEW.arg_dt_code IS NOT NULL THEN
        RAISE EXCEPTION 'Direct arg type not supported (method: %)',NEW.code;
        -- TODO: для поддержки явного задания типа надо сделать проверку, что тип совпадает с аргументами ф-и
      END IF;
      v_dt_code := ws.dt_code(split_part(NEW.code_real, '.', 1) ||'.z_'|| split_part(NEW.code_real, '.', 2));
      IF v_dt_code IS NULL THEN
        -- авторегистрация типа аргументов
        v_dt_code := ws.pg_register_proarg(NEW.code_real);
      END IF;
      NEW.arg_dt_code    := v_dt_code;

      NEW.name := COALESCE(NEW.name, r_proc.anno);
      NEW.args := COALESCE(ws.dt_parts(v_dt_code), '');
      -- TODO: сравнить args с r_proc.args
    END IF;
    IF NEW.arg_dt_code IS NOT NULL AND NOT COALESCE(ws.dt_is_complex(NEW.arg_dt_code), false) THEN
        RAISE EXCEPTION 'Method arg type (%) must be complex', NEW.arg_dt_code;
    END IF;
    RAISE NOTICE 'New method: %(%) -> %.', NEW.code_real, NEW.arg_dt_code, NEW.rv_dt_code;
    RETURN NEW;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.method_del_trigger() RETURNS TRIGGER VOLATILE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_arr TEXT;
    v_a boolean;
    v_b boolean;
  BEGIN
    v_a := OLD.arg_dt_code IS NOT NULL
      AND NOT EXISTS(SELECT 1 FROM ws.method a1 WHERE OLD.arg_dt_code IN (a1.arg_dt_code, a1.rv_dt_code))
      AND NOT EXISTS (SELECT 1 from ws.facet_dt_base a2 WHERE OLD.arg_dt_code = a2.base_code)
      AND NOT EXISTS(SELECT 1 from ws.dt a3 WHERE a3.parent_code = OLD.arg_dt_code AND a3.code <> OLD.arg_dt_code)
      -- не удаляем если тип у кого-то parent или base
      AND NOT EXISTS(SELECT 1 from ws.dt_part a4 WHERE OLD.arg_dt_code IN (a4.parent_code, a4.base_code))
    ;
    v_b := OLD.rv_dt_code IS NOT NULL
      AND NOT EXISTS(SELECT 1 FROM ws.method b1 WHERE OLD.rv_dt_code IN (b1.arg_dt_code, b1.rv_dt_code) )
      AND NOT EXISTS (SELECT 1 from ws.facet_dt_base b2 WHERE OLD.rv_dt_code = b2.base_code)
      AND NOT EXISTS(SELECT 1 from ws.dt b3 WHERE parent_code = OLD.rv_dt_code AND b3.code <> OLD.rv_dt_code)
      -- -- не удаляем если тип у кого-то parent или base
      AND NOT EXISTS(SELECT 1 from ws.dt_part b4 WHERE OLD.rv_dt_code IN (b4.parent_code, b4.base_code))
    ;
    IF v_a or v_b THEN
      BEGIN
        CREATE LOCAL TEMPORARY TABLE method_mark
         (code ws.d_code NOT NULL)
          ON COMMIT DROP;
      EXCEPTION WHEN duplicate_table THEN
        NULL;
      END;
      IF NOT EXISTS(SELECT 1 FROM method_mark WHERE code = OLD.code) THEN
        DELETE FROM ws.dt_facet t
         WHERE EXISTS 
          (SELECT 1 FROM ws.dt d
            WHERE t.code = d.code and t.base_code = d.base_code
              AND ((d.code = OLD.arg_dt_code and v_a) OR (d.code = OLD.rv_dt_code and v_b)));
        DELETE FROM ws.dt_part t
         WHERE ((t.dt_code = OLD.arg_dt_code and v_a) OR (t.dt_code = OLD.rv_dt_code and v_b));
/*
        -- наличие потомков влечет запрет удаления родителя, а не удаление потомков
        DELETE FROM ws.dt_part WHERE parent_code = v_code;
        DELETE FROM ws.dt_part t 
         WHERE ((t.base_code = OLD.arg_dt_code and v_a) OR (t.base_code = OLD.rv_dt_code and v_b));
        DELETE FROM ws.dt_part t 
         WHERE ((t.parent_code = OLD.arg_dt_code and v_a) OR (t.parent_code = OLD.rv_dt_code and v_b));
*/        INSERT INTO method_mark (code) VALUES(OLD.code);
        DELETE FROM ws.dt t
         WHERE (code = OLD.arg_dt_code and v_a) OR (code = OLD.rv_dt_code and v_b);
        RETURN NULL;
      END IF;
    END IF;
    RETURN OLD;
  END;
$_$;

