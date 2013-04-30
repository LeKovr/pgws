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

    Представления информации о свойствах
*/


/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW prop_owner_attr AS SELECT
  po.*
, pog.is_id_required
, pog.sort AS pog_sort
, pog.name AS pog_name
  FROM cfg.prop_owner po
    JOIN cfg.prop_group AS pog USING (pogc)
  ORDER BY pog_sort, sort
;
SELECT pg_c('v', 'prop_owner_attr', 'Владельцы свойств');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW prop_attr_owned_nomask AS SELECT
  p.*
, po.pogc
, po.poid
, po.name as owner_name
, COALESCE(cfg.prop_valid_from(po.pogc, po.poid, p.code), cfg.const_valid_from_date()) as valid_from
, cfg.prop_value(po.pogc, po.poid, p.code) as value
--, (SELECT value FROM cfg.prop_value_list(po.pogc, po.poid) WHERE code = p.code) as value
  FROM cfg.prop p
--    LEFT JOIN wsd.prop_value pv ON pv.code = p.code AND pv.pogc = ANY(p.pogc_list)
    JOIN cfg.prop_owner po ON po.pogc = ANY(p.pogc_list) 
  WHERE NOT p.is_mask
;  
SELECT pg_c('v', 'prop_attr_owned_nomask', 'Атрибуты свойств без маски')
, pg_c('c', 'prop_attr_owned_nomask.valid_from', 'Начало действия значения')
, pg_c('c', 'prop_attr_owned_nomask.value', 'Значение')
;

/* ------------------------------------------------------------------------- */

CREATE OR REPLACE VIEW prop_attr AS SELECT -- явно заданные значения с описаниями по маске
  pv.code --    p.*
, p.pkg
, p.pogc_list
, p.is_mask
, p.def_value
, p.name
, p.value_fmt
, p.anno
, p.has_log
, pv.pogc
, pv.poid
, po.name as owner_name
, pv.valid_from
, pv.value
  FROM prop p
  , wsd.prop_value pv
    JOIN cfg.prop_owner po ON po.pogc = pv.pogc
  WHERE pv.pogc = ANY (p.pogc_list)
    AND p.is_mask
    AND pv.code ~ ws.mask2regexp(p.code)
  UNION SELECT
    *
    FROM cfg.prop_attr_owned_nomask
  ORDER BY pogc, poid, code, valid_from
;
SELECT pg_c('v', 'prop_attr', 'Атрибуты свойств');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW prop_history AS SELECT
  pv.valid_from
, pv.value
  FROM wsd.prop_value pv
  ORDER BY valid_from DESC
;
SELECT pg_c('v', 'prop_history', 'Журнал значений свойств');

/* ------------------------------------------------------------------------- */



