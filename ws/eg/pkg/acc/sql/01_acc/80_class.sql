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

    Классы и акции
*/

/* ------------------------------------------------------------------------- */
INSERT INTO class (id, up_id, id_count, is_ext, sort, code, name) VALUES
  (acc.const_class_id(),      NULL, 1,        FALSE, '3', 'account',   'Учетная запись пользователя')
, (acc.const_team_class_id(), NULL, 1,        FALSE, '4', 'team',      'Группа пользователей')
;

/* ------------------------------------------------------------------------- */

INSERT INTO class_status (class_id, id, sort, name) VALUES
  (acc.const_class_id(), 1, '31', 'Не определен')
, (acc.const_class_id(), 2, '32', 'Регистрация')
, (acc.const_class_id(), 3, '32', 'Авторизация')
, (acc.const_class_id(), 4, '33', 'Активен')
, (acc.const_class_id(), 5, '34', 'Заблокирован')
, (acc.const_class_id(), 6, '35', 'Отключен')
;

/* ------------------------------------------------------------------------- */

INSERT INTO class_action (class_id, id, sort, name) VALUES
  (acc.const_class_id(), 1,  '31', 'Авторизация') -- Аутентификация доступна любому
, (acc.const_class_id(), 2,  '32', 'Просмотр публичных данных')
, (acc.const_class_id(), 3,  '33', 'Просмотр профиля')
, (acc.const_class_id(), 4,  '34', 'Изменение данных')  -- + logout
, (acc.const_class_id(), 5,  '35', 'Администрирование') -- Изменение статуса
;
/* ------------------------------------------------------------------------- */
/* comment SQL:
select ',('||class_id||', '||status_id||', '||action_id||') -- '||class||' - '||status||' - '||action
from ws.csa order by class_id,status_id,action_id;
*/

--INSERT INTO class_status_action (class_id, status_id, action_id) VALUES
--  (1, 1, 11) -- Система - Онлайн - Использование клиентом

/* ------------------------------------------------------------------------- */
--INSERT INTO class_acl (class_id, id, is_sys, sort, name) VALUES
--  (1, 11, false, '11', 'Сотрудник компании')
/* ------------------------------------------------------------------------- */
/* comment SQL:
select ',('||class_id||', '||action_id||', '||acl_id||') -- '||class||' - '||action||' - '||acl
from ws.caa order by class_id,action_id,acl_id;
*/

-- INSERT INTO class_action_acl (class_id, action_id, acl_id) VALUES
--   (1,11,11) -- Система - Использование клиентом - Сотрудник компании
/* ------------------------------------------------------------------------- */
