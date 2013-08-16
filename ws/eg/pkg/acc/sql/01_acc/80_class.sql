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
\set AID acc.const_class_id()
\set TID acc.const_team_class_id()
\set RID acc.const_role_class_id()

/* ------------------------------------------------------------------------- */
INSERT INTO class (id, up_id, id_count, is_ext, sort, code, name) VALUES
  (:AID, NULL, 1,        FALSE, '3', 'account',   'Учетная запись пользователя')
;
/* ------------------------------------------------------------------------- */
INSERT INTO class_status (class_id, id, sort, name) VALUES
  (:AID, 1, '01', 'Активен')
, (:AID, 2, '02', 'Заблокирован')
, (:AID, 3, '02', 'Не активен') -- не отправлять уведомления
;
/* ------------------------------------------------------------------------- */
INSERT INTO class_action (class_id, id, sort, name) VALUES
  (:AID, 1, '01', 'Просмотр профайла')
, (:AID, 2, '02', 'Просмотр настроек')
, (:AID, 3, '03', 'Администрирование') -- set_status_locked(BOOL), изменение того, что пользователь не может менять сам
, (:AID, 4, '04', 'Изменение данных')  -- set_status_active(BOOL)
;
/* ------------------------------------------------------------------------- */
INSERT INTO class_status_action (class_id, status_id, action_id)
  SELECT :AID, 1, s.a FROM generate_series(1, 4) AS s(a) UNION
  SELECT :AID, 2, s.a FROM generate_series(1, 3) AS s(a) UNION
  SELECT :AID, 3, s.a FROM generate_series(1, 4) AS s(a)
;
/* ------------------------------------------------------------------------- */
INSERT INTO class_acl (class_id, id, is_sys, sort, name) VALUES
  (:AID, 1, FALSE, '01', 'Просмотр профайла')
, (:AID, 2, FALSE, '02', 'Просмотр настроек')
, (:AID, 3, FALSE, '03', 'Изменение настроек')
, (:AID, 4, FALSE, '04', 'Изменение системных атрибутов')
;
/* ------------------------------------------------------------------------- */
INSERT INTO class_action_acl (class_id, action_id, acl_id)
  SELECT :AID, 1, a FROM unnest(ARRAY[1]) a   UNION
  SELECT :AID, 2, a FROM unnest(ARRAY[2,3,4]) a UNION
  SELECT :AID, 3, a FROM unnest(ARRAY[4]) a   UNION
  SELECT :AID, 4, a FROM unnest(ARRAY[3,4]) a
;

/* ------------------------------------------------------------------------- */
INSERT INTO class (id, up_id, id_count, is_ext, sort, code, name) VALUES
  (:TID, NULL, 1,        FALSE, '4', 'team',      'Группа пользователей')
;
/* ------------------------------------------------------------------------- */
INSERT INTO class_status (class_id, id, sort, name) VALUES
  (:TID, 1, '01', 'Активна')
, (:TID, 2, '02', 'Заблокирована')
, (:TID, 3, '03', 'Удалена')
;
/* ------------------------------------------------------------------------- */
INSERT INTO class_action (class_id, id, sort, name) VALUES
  (:TID, 1, '01', 'Просмотр профайла')
, (:TID, 2, '02', 'Просмотр настроек')
, (:TID, 3, '03', 'Администрирование') -- функционал админа системы
, (:TID, 4, '04', 'Изменение данных')  -- функционал админа команды
;
/* ------------------------------------------------------------------------- */
INSERT INTO class_status_action (class_id, status_id, action_id)
  SELECT :TID, 1, s.a FROM generate_series(1, 4) AS s(a) UNION
  SELECT :TID, 2, s.a FROM generate_series(1, 3) AS s(a)
;
/* ------------------------------------------------------------------------- */
INSERT INTO class_acl (class_id, id, is_sys, sort, name) VALUES
  (:TID, 1, FALSE, '01', 'Гость')
, (:TID, 2, FALSE, '02', 'Участник')
, (:TID, 3, FALSE, '03', 'Администратор группы')
, (:TID, 4, FALSE, '04', 'Администратор системы')
;
/* ------------------------------------------------------------------------- */
INSERT INTO class_action_acl (class_id, action_id, acl_id)
  SELECT :TID, 1, a FROM unnest(ARRAY[1]) a   UNION
  SELECT :TID, 2, a FROM unnest(ARRAY[2,3,4]) a UNION
  SELECT :TID, 3, a FROM unnest(ARRAY[4]) a   UNION
  SELECT :TID, 4, a FROM unnest(ARRAY[3,4]) a
;

-- INSERT INTO class (id, up_id, id_count, is_ext, sort, code, name) VALUES
-- , (:RID, NULL, 1,        FALSE, '5', 'role',      'Роль пользователя')
-- ;
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
