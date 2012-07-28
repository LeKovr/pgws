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
\set WID wiki.const_class_id()      -- wiki class id
\set DID wiki.const_doc_class_id()  -- doc class id

/* ------------------------------------------------------------------------- */
INSERT INTO class (id, up_id, id_count, is_ext, sort, code, name) VALUES
  (:WID, NULL, 1,        FALSE, '10', 'wiki',        'Вики')
, (:DID, NULL, 1,        FALSE, '11', 'doc',         'Статья Вики')
;

/* ------------------------------------------------------------------------- */
INSERT INTO class_status (class_id, id, sort, name) VALUES
  (:WID, wiki.const_status_id_online(), '101', 'Онлайн')
, (:WID, 2, '102', 'Архив')
, (:WID, 9, '109', 'Удалена')

, (:DID, 1, '111', 'Онлайн')
, (:DID, 2, '112', 'Архив')
, (:DID, wiki.const_doc_status_id_draft(), '113', 'Черновик')
, (:DID, 9, '119', 'Удалена')
;

/* ------------------------------------------------------------------------- */
INSERT INTO class_action (class_id, id, sort, name) VALUES
  (:WID, 1,  '101', 'Чтение')
, (:WID, 2,  '102', 'Комментирование')
, (:WID, 3,  '103', 'Редактирование')
, (:WID, 4,  '104', 'Создание')
, (:WID, 5,  '105', 'Модерация')
, (:DID, 1,  '111', 'Чтение')
, (:DID, 2,  '112', 'Комментирование')
, (:DID, 3,  '113', 'Редактирование')
, (:DID, 5,  '115', 'Модерация')
;

/* ------------------------------------------------------------------------- */
INSERT INTO class_status_action (class_id, status_id, action_id)
  SELECT :WID, 1, s.a FROM generate_series(1, 5) AS s(a)
  UNION
  SELECT :DID, 1, s.a FROM generate_series(1, 3) AS s(a)

;
INSERT INTO class_status_action (class_id, status_id, action_id) VALUES
  (:WID, 2, 1)
, (:DID, 1, 5)
, (:DID, 3, 3)
, (:DID, 3, 5)
;

/* ------------------------------------------------------------------------- */
INSERT INTO class_acl (class_id, id, is_sys, sort, name) VALUES
  (:WID, 1, false, '101', 'Гость')     -- не участник группы
, (:WID, 2, false, '102', 'Читатель')
, (:WID, 3, false, '103', 'Комментатор')
, (:WID, 4, false, '104', 'Писатель')
, (:WID, 5, false, '105', 'Модератор')
, (:DID, 1, false, '101', 'Гость')     -- не участник группы
, (:DID, 2, false, '102', 'Читатель')
, (:DID, 3, false, '103', 'Комментатор')
, (:DID, 4, false, '104', 'Писатель')
, (:DID, 5, false, '105', 'Модератор')
;

/* ------------------------------------------------------------------------- */
INSERT INTO class_action_acl (class_id, action_id, acl_id)
  SELECT :WID, 1, s.a FROM generate_series(2, 5) AS s(a)
  UNION
  SELECT :WID, 2, s.a FROM generate_series(3, 5) AS s(a)
  UNION
  SELECT :WID, 3, s.a FROM generate_series(4, 5) AS s(a)
  UNION
  SELECT :WID, 4, s.a FROM generate_series(4, 5) AS s(a)
;

INSERT INTO class_action_acl (class_id, action_id, acl_id) VALUES
  (:WID, 5, 5)
;

INSERT INTO class_action_acl (class_id, action_id, acl_id)
  SELECT :DID, action_id, acl_id FROM class_action_acl
    WHERE class_id = :WID AND action_id <> 4
;

INSERT INTO ws.class_status_action_acl_addon (class_id, status_id, action_id, acl_id, is_addon) VALUES
-- Добавим исключение
  (:DID, wiki.const_doc_status_id_draft(), 1, 4, true)
, (:DID, wiki.const_doc_status_id_draft(), 1, 5, true)
;