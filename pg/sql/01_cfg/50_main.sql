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

    Методы работы со свойствами
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_owner_attr(a_pogc TEXT DEFAULT NULL, a_poid INTEGER DEFAULT 0) RETURNS SETOF prop_owner_attr STABLE LANGUAGE 'sql' AS
$_$
-- a_pogc: код группы владельцев
-- a_poid: код владельца свойства
  SELECT * FROM cfg.prop_owner_attr
  WHERE COALESCE($1, pogc) = pogc
    AND $2 IN (0, poid)
$_$;
SELECT pg_c('f', 'prop_owner_attr', 'Атрибуты POID');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_attr_system(a_pogc TEXT DEFAULT NULL, a_poid INTEGER DEFAULT 0, a_code TEXT DEFAULT NULL) RETURNS SETOF prop_attr STABLE LANGUAGE 'sql' AS
$_$
-- a_pogc: код группы владельцев
-- a_poid: код владельца свойств
-- a_code: код свойства
  SELECT * FROM cfg.prop_attr
  WHERE COALESCE($1, pogc) = pogc
    AND $2 IN (0, poid)
    AND COALESCE($3, code) = code
$_$;
SELECT pg_c('f', 'prop_attr_system', 'Атрибуты свойств системных объектов');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_group_name(a_pogc TEXT) RETURNS TEXT STABLE LANGUAGE 'sql' AS
$_$
  SELECT name FROM cfg.prop_group WHERE pogc = $1;
$_$;
SELECT pg_c('f', 'prop_group_name', 'Название группы свойств');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION cfg.prop_attr(a_pogc TEXT, a_poid INTEGER, a_code TEXT DEFAULT NULL) RETURNS SETOF prop_attr STABLE LANGUAGE 'sql' AS
$_$
-- a_pogc: код группы владельцев
-- a_poid: код владельца свойств
-- a_code: код свойства
  SELECT 
  p.*
, $1 AS pogc
, $2 AS poid
, cfg.prop_group_name($1) as owner_name
, COALESCE(cfg.prop_valid_from($1, $2, p.code), cfg.const_valid_from_date()) as valid_from
, cfg.prop_value($1, $2, p.code) as value
--, (SELECT value FROM cfg.prop_value_list(po.pogc, po.poid) WHERE code = p.code) as value
  FROM cfg.prop p
--    LEFT JOIN wsd.prop_value pv ON pv.code = p.code AND pv.pogc = ANY(p.pogc_list)
  WHERE NOT p.is_mask
    AND $1 = ANY(p.pogc_list)
--    AND pv.pogc = $1
--    AND pv.poid = $2
    AND ($3 IS NULL OR p.code LIKE $3)
    ORDER BY code
  ;   
$_$;SELECT pg_c('f', 'prop_attr', 'Атрибуты свойств пользовательского объекта');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_value_edit(
  a_pogc text
, a_poid ws.d_id
, a_code cfg.d_prop_code
, a_prop_new_value text DEFAULT ''::text
, a_date date DEFAULT NULL
) RETURNS BOOLEAN LANGUAGE 'plpgsql' AS
$_$
-- a_pogc: код группы владельцев
-- a_poid: код владельца
-- a_code: код свойства
-- a_prop_new_value: новое значение свойства
-- a_date: дата начала действия нового значения свойства
  DECLARE
    v_log  BOOLEAN;
  BEGIN
-- TODO: обсудить вопрос, разрешаем ли менять значение у переменных a_ 
    SELECT INTO v_log
        has_log
      FROM cfg.prop
      WHERE $1 = ANY(pogc_list)
        AND $3 ~ ws.mask2regexp(code)
    ;

    IF NOT v_log THEN
      a_date := cfg.const_valid_from_date();
    ELSEIF a_date IS NULL THEN
      a_date := now();
    END IF;

    UPDATE wsd.prop_value SET
        value=$4
      WHERE pogc = $1
        AND poid = $2
        AND code = $3
        AND valid_from = $5
    ;

    IF NOT FOUND THEN
      INSERT INTO wsd.prop_value (pogc, poid, code, valid_from, value) VALUES
        ($1, $2, $3, $5, $4);
      RETURN TRUE;
    END IF;

    RETURN FALSE;
  END;
$_$;
SELECT pg_c('f', 'prop_value_edit', 'Редактирование значений свойств');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_is_pogc_system(a_pogc TEXT) RETURNS BOOLEAN STABLE LANGUAGE 'plpgsql' AS
$_$
-- a_pogc: код группы владельцев
  BEGIN
    IF $1 IN (SELECT pogc FROM cfg.prop_group WHERE is_system = true) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;
$_$;
SELECT pg_c('f', 'prop_is_pogc_system', 'Является ли группа системной');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION cfg.prop_history(a_pogc TEXT, a_poid INTEGER, a_code TEXT) RETURNS SETOF prop_history STABLE LANGUAGE 'sql' AS
$_$
-- a_pogc: код группы владельцев
-- a_poid: код владельца свойств
-- a_code: код свойства
  SELECT
      pv.valid_from
    , pv.value
    FROM wsd.prop_value pv
    WHERE pv.pogc = $1
      AND pv.poid = $2
      AND pv.code = $3
    ORDER BY pv.valid_from DESC
  ;
$_$;SELECT pg_c('f', 'prop_history', 'История значений свойств');

/* ------------------------------------------------------------------------- */
