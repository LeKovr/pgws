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

\set SID 1

/* ------------------------------------------------------------------------- */
INSERT INTO class (id, up_id, id_count, is_ext, sort, code, name) VALUES
  (:SID, NULL, DEFAULT, FALSE, '1', 'system', 'Система')  -- акции могут зависеть от пользователя или статуса системы
;

/* ------------------------------------------------------------------------- */
INSERT INTO class_status (class_id, id, sort, name) VALUES
  (:SID, 1, '11', 'Онлайн')
 ,(:SID, 2, '12', 'На обслуживании')
;

/* ------------------------------------------------------------------------- */
INSERT INTO class_action (class_id, id, sort, name) VALUES
  (:SID, 1, '11', 'Чтение онлайн')
 ,(:SID, 3, '13', 'Системное чтение')
 ,(:SID, 5, '15', 'Системная запись')
 ,(:SID, 6, '16', 'Обслуживание')
 ,(:SID, 7, '17', 'Использование онлайн') -- чтение и запись динамики
;
/* ------------------------------------------------------------------------- */
/* comment SQL:
select ',('||class_id||', '||status_id||', '||action_id||') -- '||class||' - '||status||' - '||action
from ws.csa order by class_id,status_id,action_id;
*/

INSERT INTO class_status_action (class_id, status_id, action_id) VALUES
  (:SID, 1, 3) -- Система - Онлайн - Системное чтение
 ,(:SID, 1, 5) -- Система - Онлайн - Системная запись
 ,(:SID, 1, 7) -- Система - Онлайн - Использование онлайн
 ,(:SID, 2, 3) -- Система - На обслуживании - Системное чтение
 ,(:SID, 2, 5) -- Система - На обслуживании - Системная запись
 ,(:SID, 2, 6) -- Система - На обслуживании - Обслуживание
;

/* ------------------------------------------------------------------------- */
INSERT INTO class_acl (class_id, id, is_sys, sort, name) VALUES
  (:SID, 3, true, '13', 'Сервис')
;

/* ------------------------------------------------------------------------- */
/* comment SQL:
select ',('||class_id||', '||action_id||', '||acl_id||') -- '||class||' - '||action||' - '||acl
from ws.caa order by class_id,action_id,acl_id;
*/
INSERT INTO class_action_acl (class_id, action_id, acl_id) VALUES
  (:SID, 1, 3) -- Система - Чтение онлайн - Сервис
 ,(:SID, 3, 3) -- Система - Системное чтение - Сервис
 ,(:SID, 5, 3) -- Система - Системная запись - Сервис
;

/* ------------------------------------------------------------------------- */
