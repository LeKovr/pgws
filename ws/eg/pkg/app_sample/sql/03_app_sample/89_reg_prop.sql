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

    Регистрация методов и ошибок
*/


\set AID acc.const_class_id()
\set TID acc.const_team_class_id()

/* ------------------------------------------------------------------------- */
INSERT INTO method (code, class_id , action_id, cache_id, rvf_id, code_real) VALUES
  ('system.prop_attr',          1,    3, 4, 7, 'cfg.prop_attr_system')
, ('system.prop_owner_attr',    1,    3, 4, 7, 'cfg.prop_owner_attr')
, ('account.prop_abp_attr',     :AID, 2, 4, 7, 'acc.prop_attr_account_abp')
, ('account.prop_isv_attr',     :AID, 2, 4, 7, 'acc.prop_attr_account_isv')
, ('team.prop_abp_attr',        :TID, 2, 4, 7, 'acc.prop_attr_team_abp')
, ('team.prop_isv_attr',        :TID, 2, 4, 7, 'acc.prop_attr_team_isv')

, ('team.prop_isv_value',       :TID, 2, 3, 3, 'acc.prop_attr_team_isv')
, ('account.prop_isv_value',    :TID, 2, 3, 3, 'acc.prop_attr_account_isv')

, ('system.prop_history',       1,    3, 4, 7, 'cfg.prop_history')
, ('account.prop_history',      :AID, 2, 4, 7, 'acc.prop_history_account')
, ('team.prop_history',         :TID, 2, 4, 7, 'acc.prop_history_team')
;
