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

    Реестр свойств. Дополнение
*/

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.prop_value (pogc, poid, code, value) VALUES
  (acc.const_account_group_prop(), 1,  'abp.name.short',     'Admin')
, (acc.const_account_group_prop(), 2,  'abp.name.short',     'Job')
, (acc.const_account_group_prop(), 3,  'abp.name.short',     'Первый пользователь')
, (acc.const_account_group_prop(), 4,  'abp.name.short',     'Второй пользователь')
, (acc.const_account_group_prop(), 5,  'abp.name.short',     'Третий пользователь')
, (acc.const_account_group_prop(), 6,  'abp.name.short',     'Четвертый пользователь')
, (acc.const_account_group_prop(), 7,  'abp.name.short',     'Пятый пользователь')
, (acc.const_account_group_prop(), 8,  'abp.name.short',     'Шестой пользователь')

, (acc.const_team_group_prop(),    acc.const_team_system_id(),  'abp.name.short', 'System team')
, (acc.const_team_group_prop(),    acc.const_team_admin_id(),  'abp.name.short', 'Admin team')
, (acc.const_team_group_prop(),    3,  'abp.name.short', 'One team')
, (acc.const_team_group_prop(),    4,  'abp.name.short', 'Two team')

, (acc.const_team_group_prop(),    acc.const_team_system_id(),  'abp.anno', 'Системная команда')
, (acc.const_team_group_prop(),    acc.const_team_admin_id(),  'abp.anno', 'Команда аднинистраторов')
, (acc.const_team_group_prop(),    3,  'abp.anno', 'Первая тестовая команда')
, (acc.const_team_group_prop(),    4,  'abp.anno', 'Вторая тестовая команда')
;

