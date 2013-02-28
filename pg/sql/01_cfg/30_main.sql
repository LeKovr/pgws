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

    Методы блока управления свойствами
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_info(a_code cfg.d_prop_code DEFAULT NULL, a_is_mask BOOL DEFAULT false) RETURNS SETOF prop STABLE LANGUAGE 'plpgsql' AS
$_$
-- a_code: код свойства
-- a_is_mask: признак атомарности свойства
  DECLARE
    v_code TEXT;
  BEGIN
    IF a_is_mask THEN
      v_code := COALESCE(a_code, ''); -- аргумент не может быть "''", только d_prop_code или NULL
      v_code := v_code || '%';
      RETURN QUERY SELECT * FROM cfg.prop WHERE lower(code) LIKE lower(v_code);
    ELSE
      -- TODO: RAISE IF a_code IS NULL
      RETURN QUERY SELECT * FROM cfg.prop WHERE lower(code) = lower(a_code);
    END IF;
    RETURN;
  END;
$_$;
SELECT pg_c('f', 'prop_info', 'Описание свойства или списка свойств');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_value(
  a_pogc TEXT
, a_poid d_id
, a_code cfg.d_prop_code
, a_date date DEFAULT CURRENT_DATE
) RETURNS text STABLE LANGUAGE 'sql' AS
$_$
-- a_pogc: код группы владельцев
-- a_poid: код владельца
-- a_code: код свойства
-- a_date: дата получения значения свойства
  SELECT value
    FROM wsd.prop_value
    WHERE pogc = $1 /* a_pogc */
      AND poid = $2 /* a_poid */
      AND code = $3 /* a_code */
      AND valid_from <= COALESCE($4, CURRENT_DATE) /* a_date */
      ORDER BY valid_from DESC
      LIMIT 1
$_$;
SELECT pg_c('f', 'prop_value', 'Значение свойства');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_value_list(
  a_pogc        TEXT
, a_poid        d_id
, a_prefix      text DEFAULT ''
, a_prefix_keep bool DEFAULT TRUE
, a_date        date DEFAULT CURRENT_DATE
, a_prefix_new      text DEFAULT ''
, a_mark_default text DEFAULT '%s'
) RETURNS SETOF t_hashtable STABLE LANGUAGE 'sql' AS
$_$
-- a_pogc: код группы владельцев
-- a_poid: код владельца
-- a_prefix: часть кода свойства до '.'
-- a_prefix_keep:признак замены в результате a_prefix на a_prefix_new
-- a_date: дата получения значения свойства
-- a_prefix_new: добавочный префикс
-- a_mark_default: метка для не атомарного свойства
  SELECT
    $6 || CASE WHEN $3 /* a_prefix */ = '' OR $4 /* a_prefix_keep */
      THEN code
      ELSE regexp_replace (code, '^' || $3 || E'\\.', '')
    END as code
  , COALESCE(cfg.prop_value($1, $2, code, $5), ws.sprintf($7 /* a_mark_default */, def_value))
    FROM cfg.prop
    WHERE $1 = ANY(pogc_list)
      AND NOT is_mask
      AND ($3 = '' OR code LIKE $3 || '.%')
  UNION SELECT
    $6 || CASE WHEN $3 /* a_prefix */ = '' OR $4 /* a_prefix_keep */
      THEN tmp.code
      ELSE regexp_replace (tmp.code, '^' || $3 || E'\\.', '')
    END as code
  , COALESCE(tmp.value, ws.sprintf($7 /* a_mark_default */, p.def_value))
    FROM (
      SELECT code, value, row_number() over (partition by pogc, poid, code order by valid_from desc)
        FROM wsd.prop_value v
        WHERE pogc = $1 AND poid = $2 AND valid_from <= COALESCE($5, CURRENT_DATE)
      ) tmp
      , cfg.prop p
      WHERE tmp.row_number = 1 /* самая свежая по началу действия строка */
        AND ($3 = '' OR tmp.code ~ ws.mask2regexp(p.code))
        AND p.is_mask
        AND $1 = ANY(p.pogc_list)
  ORDER BY code
$_$;
SELECT pg_c('f', 'prop_value_list', 'Значения свойств по части кода (до .)');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_group_value_list(
  a_pogc        TEXT
, a_poid        d_id DEFAULT 0
, a_prefix      text DEFAULT ''
, a_prefix_keep bool DEFAULT TRUE
, a_date        date DEFAULT CURRENT_DATE
, a_prefix_new      text DEFAULT ''
, a_mark_default text DEFAULT '%s'
) RETURNS SETOF t_hashtable STABLE LANGUAGE 'plpgsql' AS
$_$
-- a_pogc: код группы владельцев
-- a_poid: код владельца
-- a_prefix: часть кода свойства до '.'
-- a_prefix_keep:признак замены в результате a_prefix на a_prefix_new
-- a_date: дата получения значения свойства
-- a_prefix_new: добавочный префикс
-- a_mark_default: метка для не атомарного свойства
DECLARE
  r wsd.prop_owner;
  v_prefix_add TEXT;
BEGIN
  FOR r IN SELECT * FROM wsd.prop_owner WHERE pogc = a_pogc AND a_poid IN (poid, 0) ORDER BY sort
  LOOP
    v_prefix_add := CASE
      WHEN a_poid = 0 THEN r.poid || '.'
      ELSE ''
    END;
    RETURN QUERY SELECT * FROM cfg.prop_value_list(r.pogc, r.poid, a_prefix, a_prefix_keep, a_date, a_prefix_new || v_prefix_add, a_mark_default);
  END LOOP;
  RETURN;
END;
$_$;
SELECT pg_c('f', 'prop_group_value_list', 'Значения свойств по части кода (до .), в разрезе владельцев свойств');
