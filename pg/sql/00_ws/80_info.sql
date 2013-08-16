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
-- 80_class.sql - Данные классов и акций
/* ------------------------------------------------------------------------- */

\set IID ws.const_info_class_id()

/* ------------------------------------------------------------------------- */
INSERT INTO class (id, up_id, id_count, is_ext, sort, code, name) VALUES
  (:IID, NULL, DEFAULT, FALSE, '2', 'info', 'Информация') -- акции всем всегда доступны
;

/* ------------------------------------------------------------------------- */
INSERT INTO class_status (class_id, id, sort, name) VALUES
  (:IID, 1, '01', 'Онлайн')
;

/* ------------------------------------------------------------------------- */
INSERT INTO class_action (class_id, id, sort, name) VALUES
  (:IID, 1, '01', 'Публичное чтение')
;

/* ------------------------------------------------------------------------- */
INSERT INTO class_status_action (class_id, status_id, action_id) VALUES
  (:IID, 1, 1) -- Информация - Онлайн - Публичное чтение
;

/* ------------------------------------------------------------------------- */
INSERT INTO class_acl (class_id, id, is_sys, sort, name) VALUES
  (:IID, 1, true, '01', 'Любой пользователь')
;

INSERT INTO class_action_acl (class_id, action_id, acl_id) VALUES
 (:IID, 1, 1) -- Информация - Публичное чтение - Любой пользователь
;

/* ------------------------------------------------------------------------- */
