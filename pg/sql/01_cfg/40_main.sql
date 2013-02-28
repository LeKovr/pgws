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
  FROM wsd.prop_owner po
    JOIN wsd.prop_group AS pog USING (pogc)
  ORDER BY pog_sort, sort
;
SELECT pg_c('v', 'prop_owner_attr', 'Владельцы свойств');

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
, pv.pogc
, pv.poid
, pv.valid_from
, pv.pkg as value_pkg
, pv.value
  FROM cfg.prop p
  , wsd.prop_value pv
  WHERE pv.pogc = ANY (p.pogc_list)
    AND p.is_mask
    AND pv.code ~ ws.mask2regexp(p.code)
  UNION SELECT
  p.*
, po.pogc
, po.poid
, '2000-01-02'::DATE AS valid_from
, po.pkg as value_pkg
, (SELECT value FROM wsd.prop_value WHERE pogc = po.pogc AND poid = po.poid AND code = p.code) AS value
  FROM cfg.prop p
  , wsd.prop_owner po
  WHERE po.pogc = ANY (p.pogc_list)
    AND NOT p.is_mask
  ORDER BY pogc, poid, code, valid_from
;
SELECT pg_c('v', 'prop_attr', 'Атрибуты свойств');
