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
INSERT INTO wsd.prop_value (pogc, poid, code,      value) VALUES
  ('fe',    1,  'ws.daemon.fe.tmpl.error',        'app_sample/error')
;

INSERT INTO wsd.prop_value (pogc, poid, code, value) VALUES 
  ('fe',    1,  'ws.daemon.fe.tmpl.layout_default', 'style02');
;

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.prop_value (pogc, poid, code, value) VALUES
  (acc.const_account_group_prop(), 1,  'abp.name',     'Admin')
, (acc.const_account_group_prop(), 2,  'abp.name',     'Job')
, (acc.const_account_group_prop(), 3,  'abp.name',     'Первый пользователь')
, (acc.const_account_group_prop(), 4,  'abp.name',     'Второй пользователь')
, (acc.const_account_group_prop(), 5,  'abp.name',     'Третий пользователь')
, (acc.const_account_group_prop(), 6,  'abp.name',     'Четвертый пользователь')
, (acc.const_account_group_prop(), 7,  'abp.name',     'Пятый пользователь')
, (acc.const_account_group_prop(), 8,  'abp.name',     'Шестой пользователь')

, (acc.const_team_group_prop(),    2,  'abp.geo.city', 'Город админа')
, (acc.const_team_group_prop(),    3,  'abp.geo.city', 'Третий город')

, (acc.const_team_group_prop(),    1,  'abp.name', 'System team')
, (acc.const_team_group_prop(),    2,  'abp.name', 'Admin team')
, (acc.const_team_group_prop(),    3,  'abp.name', 'One team')
, (acc.const_team_group_prop(),    4,  'abp.name', 'Two team')

, (acc.const_team_group_prop(),    1,  'abp.anno', 'Системная команда')
, (acc.const_team_group_prop(),    2,  'abp.anno', 'Команда аднинистраторов')
, (acc.const_team_group_prop(),    3,  'abp.anno', 'Первая тестовая команда')
, (acc.const_team_group_prop(),    4,  'abp.anno', 'Вторая тестовая команда')
;

