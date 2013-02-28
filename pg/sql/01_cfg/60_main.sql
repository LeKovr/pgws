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
