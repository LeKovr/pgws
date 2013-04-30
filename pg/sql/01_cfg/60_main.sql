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

    Функции триггеров пакета cfg
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_calc_is_mask() RETURNS TRIGGER VOLATILE LANGUAGE 'plpgsql' AS
$_$
  BEGIN
    NEW.is_mask := ws.mask_is_multi(NEW.code);
    RETURN NEW;
  END;
$_$;
SELECT pg_c('f', 'prop_calc_is_mask', 'Расчет значения поля is_mask');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_value_insupd_trigger() RETURNS TRIGGER IMMUTABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_rows INTEGER;
  BEGIN
    SELECT INTO v_rows
      count(1)
      FROM cfg.prop
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
SELECT pg_c('f', 'prop_value_insupd_trigger', 'Проверка наличия свойства в таблице prop');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_value_insupd_has_log() RETURNS TRIGGER IMMUTABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_log  BOOLEAN;
  BEGIN

    SELECT INTO v_log
      has_log
      FROM cfg.prop
      WHERE NEW.pogc = ANY(pogc_list)
        AND NEW.code ~ ws.mask2regexp(code)
    ;

    IF NOT v_log THEN
      RAISE EXCEPTION 'Incorrect valid from date';
    END IF;

    RETURN NEW;

  END;
$_$;
SELECT pg_c('f', 'prop_value_ins_has_log', 'Обработка логирования значений');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_value_system_owner_insupd() RETURNS TRIGGER IMMUTABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_rows INTEGER;
  BEGIN
      SELECT INTO v_rows
        count(1)
        FROM cfg.prop_owner
        WHERE NEW.pogc = pogc
          AND NEW.poid = poid
      ;

    IF v_rows = 0 THEN
      RAISE EXCEPTION 'Not system owner with poid=% in group %', NEW.poid, NEW.pogc;
    END IF;

    RETURN NEW;
  END;
$_$;
SELECT pg_c('f', 'prop_value_system_owner_insupd', 'Проверка наличия владельца системных свойств');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_validation_valid_from() RETURNS TRIGGER IMMUTABLE LANGUAGE 'plpgsql' AS
$_$
  BEGIN
    RAISE EXCEPTION 'Bad valid_from date';
  END;
$_$;
SELECT pg_c('f', 'prop_validation_valid_from', 'Проверка коректности даты начала действия');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_value_check_method_fkeys() RETURNS TRIGGER STABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_plug ws.d_code;
  BEGIN
    IF NEW.code_real ~ ':' THEN
      -- check plugin config
      v_plug := split_part(NEW.code_real, ':', 1);
      IF NOT EXISTS(SELECT 1 FROM wsd.prop_value WHERE code = 'ws.daemon.be.plugin.' || v_plug || '.lib') THEN
        RAISE EXCEPTION 'Unknown plugin (%) requested by method (%)', v_plug, NEW.code;
      END IF;
    END IF;
    -- check cache id
    IF NOT EXISTS(SELECT 1 FROM wsd.prop_value WHERE pogc='cache' AND code = 'ws.plugin.cache.code' AND poid = NEW.cache_id) THEN
      RAISE EXCEPTION 'Unknown cache id (%) requested by method (%)', NEW.cache_id, NEW.code;
    END IF;
    RETURN NEW;
  END;
$_$;
SELECT pg_c('f', 'prop_value_method_fkeys', 'Проверка наличия в prop_value внешних ключей таблицы ws.method');
