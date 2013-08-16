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
CREATE OR REPLACE FUNCTION prop_attr_account_abp(a_id INTEGER, a_code TEXT DEFAULT NULL) RETURNS SETOF cfg.prop_attr STABLE LANGUAGE 'sql' AS
$_$
-- a_poid: код владельца свойств
-- a_code: код свойства
  SELECT * FROM cfg.prop_attr(acc.const_account_group_prop(), $1, 'abp.' || $2) WHERE code ~ E'^abp\\.[\\w\\.]+$'
$_$;
SELECT pg_c('f', 'prop_attr_account_abp', 'Атрибуты открытых свойств пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_attr_account_isv(a_id INTEGER, a_code TEXT DEFAULT NULL) RETURNS SETOF cfg.prop_attr STABLE LANGUAGE 'sql' AS
$_$
-- a_poid: код владельца свойств
-- a_code: код свойства
  SELECT * FROM cfg.prop_attr(acc.const_account_group_prop(), $1, 'isv.' || $2) WHERE code ~ E'^isv\\.[\\w\\.]+$'
$_$;
SELECT pg_c('f', 'prop_attr_account_isv', 'Атрибуты служебных свойств пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_account_isv(a_id INTEGER, a_code TEXT DEFAULT NULL) RETURNS SETOF t_hashtable STABLE LANGUAGE 'sql' AS
$_$
-- a_poid: код владельца свойств
-- a_code: код свойства
  SELECT code, value FROM cfg.prop_value_list(acc.const_account_group_prop(), $1, 'isv.' || $2, false)
$_$;
SELECT pg_c('f', 'prop_account_isv', 'Значения служебных свойств пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_attr_team_abp(a_id INTEGER, a_code TEXT DEFAULT NULL) RETURNS SETOF cfg.prop_attr STABLE LANGUAGE 'sql' AS
$_$
-- a_poid: код владельца свойств
-- a_code: код свойства
  SELECT * FROM cfg.prop_attr(acc.const_team_group_prop(), $1, 'abp.' || $2) WHERE code ~ E'^abp\\.[\\w\\.]+$'
$_$;
SELECT pg_c('f', 'prop_attr_team_abp', 'Атрибуты открытых свойств команды');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_attr_team_isv(a_id INTEGER, a_code TEXT DEFAULT NULL) RETURNS SETOF cfg.prop_attr STABLE LANGUAGE 'sql' AS
$_$
-- a_poid: код владельца свойств
-- a_code: код свойства
  SELECT * FROM cfg.prop_attr(acc.const_team_group_prop(), $1, 'isv.' || $2) WHERE code ~ E'^isv\\.[\\w\\.]+$'
$_$;
SELECT pg_c('f', 'prop_attr_team_isv', 'Атрибуты служебных свойств команды');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_history_team(a_id INTEGER, a_code TEXT DEFAULT NULL) RETURNS SETOF cfg.prop_history STABLE LANGUAGE 'sql' AS
$_$
-- a_poid: код владельца свойств
-- a_code: код свойства
  SELECT * FROM cfg.prop_history(acc.const_team_group_prop(), $1, $2)
$_$;
SELECT pg_c('f', 'prop_history_team', 'Журнал значений свойств команды');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_history_account(a_id INTEGER, a_code TEXT DEFAULT NULL) RETURNS SETOF cfg.prop_history STABLE LANGUAGE 'sql' AS
$_$
-- a_poid: код владельца свойств
-- a_code: код свойства
  SELECT * FROM cfg.prop_history(acc.const_account_group_prop(), $1, $2)
$_$;
SELECT pg_c('f', 'prop_history_account', 'Журнал значений свойств пользователя');
