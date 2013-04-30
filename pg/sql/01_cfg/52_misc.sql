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

    Вспомогательные методы пакета CFG
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_cleanup_pkg (a_pogc TEXT[]) RETURNS void VOLATILE LANGUAGE 'plpgsql' AS
$_$
-- a_pogc: владельцы удаляемых свойств
  DECLARE
    v_item TEXT;
  BEGIN

    FOREACH v_item IN ARRAY $1 LOOP
      DELETE FROM cfg.prop WHERE v_item = ANY(pogc_list) AND array_length(pogc_list, 1) = 1;
      UPDATE cfg.prop SET pogc_list = ws.array_remove(pogc_list::text[], v_item) WHERE v_item = ANY(pogc_list);
    END LOOP;

    DELETE FROM cfg.prop_owner WHERE pogc = ANY($1);
    DELETE FROM cfg.prop_group WHERE pogc = ANY($1);

  END
$_$;
SELECT pg_c('f', 'prop_cleanup_pkg', 'Удаление владельцев и реестра свойств');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_cleanup_system_value_pkg (a_code TEXT[]) RETURNS void VOLATILE LANGUAGE 'plpgsql' AS
$_$
-- a_code: коды удаляемых свойств
  DECLARE
    v_item TEXT;
  BEGIN

    FOREACH v_item IN ARRAY $1 LOOP
      DELETE FROM cfg.prop WHERE code = v_item;
      DELETE FROM wsd.prop_value WHERE code ~ ws.mask2regexp(v_item::TEXT);
    END LOOP;

  END
$_$;
SELECT pg_c('f', 'prop_cleanup_system_value_pkg', 'Удаление системных свойств пакета');
/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_drop_pkg (a_pogc TEXT[], a_code TEXT DEFAULT NULL) RETURNS void VOLATILE LANGUAGE 'plpgsql' AS
$_$
-- a_pogc: владельцы удаляемых свойств
-- a_code: код свойства
  BEGIN

    DELETE FROM wsd.prop_value
      WHERE pogc IN (SELECT pogc FROM cfg.prop_group WHERE pogc = ANY($1))
        AND code = COALESCE($2, code)
    ;

  END
$_$;
SELECT pg_c('f', 'prop_drop_pkg', 'Удаление значениий не системных свойств пакета');

/* ------------------------------------------------------------------------- */

