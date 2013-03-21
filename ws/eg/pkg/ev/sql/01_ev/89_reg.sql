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


INSERT INTO method ( code, class_id, action_id, cache_id, rvf_id, args_exam, name )
  VALUES ('ev.role_list',         2, 1,  1,      7,             '', 'Список ролей' ),
         ('ev.role_signup_list',  2, 1,  1,      7,    'role_id=1', 'Список подписок роли' ),
         ('ev.kind_list',         2, 1,  1,      7,             '', 'Список видов событий' ),
         ('ev.role_signup_ins',   2, 1,  1,      1, 'role_id=1&kind_id=2&spec_id=1', 'Создание подписки роли' ),
         ('ev.role_signup_del',   2, 1,  1,      1, 'role_id=1&kind_id=2&spec_id=1', 'Удаление подписки роли' ),
         ('ev.notifications_list',2, 1,  1,      7, 'account_id=1', 'Список уведомлений пользователя' ),
         ('ev.new_notifications_count',2, 1, 1, 1, 'account_id=1', 'Количество новых уведомлений пользователя' );

