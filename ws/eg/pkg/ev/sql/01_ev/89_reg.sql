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

    Регистрация методов пакета
*/

\set AID acc.const_class_id()
\set TID acc.const_team_class_id()

INSERT INTO method ( code, class_id, action_id, cache_id, rvf_id, args_exam, code_real )  VALUES 
  ('account.notify',        :AID, 2,  1,  7, 'id=1', pg_cs('notification'))
, ('account.notify_count',  :AID, 2,  1,  1, 'id=1', pg_cs('notification_count_new'))
, ('account.signup',        :AID, 2,  1,  7, 'id=1', pg_cs('signup_by_account_id'))

, ('team.role_signup',      :TID, 2,  1,  7, 'id=1', pg_cs('signup_by_team_role_id'))
, ('team.signup',           :TID, 2,  1,  7, 'id=1', pg_cs('signup_by_team_kind_id'))
, ('system.role_signup',    1,    1,  1,  7, 'id=1', pg_cs('signup_by_role_id'))

, ('system.event_kind',     1,    3,  1,  7,  '',       pg_cs('kind'))
, ('system.event_kind_role',     1,    3,  1,  7,  '',  pg_cs('role_signup_by_kind_id'))
, ('system.event_kind_group',    2,    1,  1,  7,  '',  pg_cs('kind_group'))
;
/*
, ('ev.role_signup_list',       2, 1,  1,      7,  'role_id=1',  'Список подписок роли' )
, ('ev.news_info',              2, 1,  1,      7,  '',           'Глобальный список уведомлений' )
, ('ev.kind_list_by_group_id',  2, 1,  1,      7,  'group_id=1', 'Список видов событий заданной группы событий' )
, ('ev.event_info_by_kind_id',  2, 1,  1,      7,  'kind_id=1',  'Список событий заданного вида' )
, ('ev.account_list_by_kind_group_id', 2, 1,  1,      7,  'group_id=1',  'Список подписчиков заданной группы видов событий' )
, ('ev.signup_list_by_account_id', 2, 1,  1,      7,  'account_id=1',  'Список подписок заданного аккаунта' )
, ('ev.role_signup_ins',        2, 1,  1,      1, 'role_id=1&kind_id=2&spec_id=1', 'Создание подписки роли' )
, ('ev.role_signup_del',        2, 1,  1,      1, 'role_id=1&kind_id=2&spec_id=1', 'Удаление подписки роли' )
, ('ev.team_signed_accounts_by_kind_id',     2, 1,  1,      7, 'team_id=1&kind_id=1', 'Аккаунты в выбранной команде, не отменившие подписку на заданный вид события' )
, ('ev.team_signed_roles_by_kind_id',     2, 1,  1,      7, 'team_id=1&kind_id=1', 'Ролевые подписки в выбранной команде' )
;

*/