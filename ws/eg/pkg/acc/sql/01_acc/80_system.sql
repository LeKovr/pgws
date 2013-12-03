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

*/
-- 80_system.sql - Класс system
/* ------------------------------------------------------------------------- */

\set SID acc.const_system_class_id()

/* ------------------------------------------------------------------------- */
INSERT INTO class_action (class_id, id, sort, name) VALUES
  (:SID, 2, '12', 'Авторизованное чтение')
 ,(:SID, 4, '14', 'Авторизованная запись')
 ,(:SID, 8, '18', 'Только для неавторизованных')
;

/* ------------------------------------------------------------------------- */
/* comment SQL:
select ',('||class_id||', '||status_id||', '||action_id||') -- '||class||' - '||status||' - '||action
from ws.csa order by class_id,status_id,action_id;
*/

INSERT INTO class_status_action (class_id, status_id, action_id) VALUES
  (:SID, 1, 1) -- Система - Онлайн - Чтение онлайн
 ,(:SID, 1, 2) -- Система - Онлайн - Авторизованное чтение
 ,(:SID, 1, 4) -- Система - Онлайн - Авторизованная запись
 ,(:SID, 1, 8) -- Система - Онлайн - Только для неавторизованных
 ,(:SID, 2, 2) -- Система - На обслуживании - Авторизованное чтение
;

/* ------------------------------------------------------------------------- */
INSERT INTO class_acl (class_id, id, is_sys, sort, name) VALUES
  (:SID, 1, true, '11', 'Неавторизованный пользователь')
 ,(:SID, 2, true, '12', 'Авторизованный пользователь')
 ,(:SID, 4, true, '14', 'Оператор')
;

/* ------------------------------------------------------------------------- */
/* comment SQL:
select ',('||class_id||', '||action_id||', '||acl_id||') -- '||class||' - '||action||' - '||acl
from ws.caa order by class_id,action_id,acl_id;
*/

INSERT INTO class_action_acl (class_id, action_id, acl_id) VALUES
  (:SID, 1, 1) -- Система - Чтение онлайн - Неавторизованный пользователь
 ,(:SID, 1, 2) -- Система - Чтение онлайн - Авторизованный пользователь
 ,(:SID, 1, 4) -- Система - Чтение онлайн - Оператор
 ,(:SID, 2, 2) -- Система - Авторизованное чтение - Авторизованный пользователь
 ,(:SID, 3, 4) -- Система - Системное чтение - Оператор
 ,(:SID, 4, 2) -- Система - Авторизованная запись - Авторизованный пользователь
 ,(:SID, 5, 4) -- Система - Системная запись - Оператор
 ,(:SID, 6, 4) -- Система - Обслуживание - Оператор
 ,(:SID, 7, 1) -- Система - Использование онлайн - Неавторизованный пользователь
 ,(:SID, 7, 2) -- Система - Использование онлайн - Авторизованный пользователь
 ,(:SID, 8, 1) -- Система - Только для неавторизованных - Авторизованный пользователь
;
