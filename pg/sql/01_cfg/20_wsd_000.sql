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

    Схема изменяемых в процессе эксплуатации данных и ее базовые объекты
*/

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.prop_value (
  pogc        TEXT
, poid        INTEGER
, code        TEXT
, valid_from  DATE
, value       TEXT
, CONSTRAINT  prop_value_pkey PRIMARY KEY (pogc, poid, code, valid_from)
);

SELECT pg_c('r', 'wsd.prop_value',       'Значения свойств объектов')
, pg_c('c', 'wsd.prop_value.pogc',       'Код группы (Property Owner Group Code)')
, pg_c('c', 'wsd.prop_value.poid',       'ID владельца (Property Owner ID)')
, pg_c('c', 'wsd.prop_value.code',       'Код свойства')
, pg_c('c', 'wsd.prop_value.valid_from', 'Дата начала действия')
, pg_c('c', 'wsd.prop_value.value',      'Значение свойства')
;

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.pkg_default_protected (pkg, schema, wsd_rel, wsd_col, func) VALUES
  ('ws', 'cfg', 'prop_value', 'valid_from', 'cfg.const_valid_from_date()')
;


