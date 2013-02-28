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
CREATE OR REPLACE FUNCTION prop_clean_pkg (a_pkg TEXT, a_wsd_clean BOOLEAN) RETURNS void VOLATILE LANGUAGE 'plpgsql' AS
$_$
-- a_pkg: пакет для которого производится чистка
-- a_wsd_clean: признак удаления атрибутов свойств в схеме wsd
  BEGIN

    -- удаление списка свойств для пакета a_pkg
    DELETE FROM cfg.prop WHERE pkg = $1;
    UPDATE cfg.prop SET pogc_list = ws.array_remove(pogc_list::text[], $1) WHERE $1 = ANY(pogc_list);

    -- удаление значений свойств и владельцев из схемы wsd
    IF $2 THEN
      DELETE FROM wsd.prop_value WHERE pkg = $1;
      DELETE FROM wsd.prop_owner WHERE pkg = $1;
      DELETE FROM wsd.prop_group WHERE pkg = $1;
    END IF;

  END
$_$;
SELECT pg_c('f', 'prop_clean_pkg', 'Удаление свойств для отдельного пакета');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_clean_value (a_prop_value TEXT) RETURNS void VOLATILE LANGUAGE 'plpgsql' AS
$_$
-- a_prop_value: значение свойства
  BEGIN

    DELETE FROM wsd.prop_value WHERE code = $1;

  END
$_$;
SELECT pg_c('f', 'prop_clean_value', 'Удаление значения свойства');

/* ------------------------------------------------------------------------- */
