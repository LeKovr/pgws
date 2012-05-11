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
-- 20_class.sql - Таблицы классов
/* ------------------------------------------------------------------------- */
\qecho '-- FD: pgws:ws:20_class.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE TABLE class (
  id           d_class  PRIMARY KEY
  , up_id      d_class            -- если задан => = существующему id и (id_count - parent_id_count) IN (0,1)
  , id_count   d_cnt    NOT NULL DEFAULT 0
  , is_ext     bool     NOT NULL -- true и задан parent_id и у parent такой же id_count => =parent.is_ext
  , sort       d_sort
  , code       d_code   NOT NULL UNIQUE
  , name       text     NOT NULL
);
COMMENT ON TABLE class IS 'Класс объекта';

/* ------------------------------------------------------------------------- */
CREATE TABLE class_status (
  class_id     d_class  REFERENCES class
  , id         d_id32   -- > 0
  , sort       d_sort
  , name       text     NOT NULL
  , CONSTRAINT class_status_pkey PRIMARY KEY (class_id, id)
);
COMMENT ON TABLE class_status IS 'Статус объекта';

/* ------------------------------------------------------------------------- */
CREATE TABLE class_action (
  class_id     d_class  REFERENCES class
  , id         d_id32
  , sort       d_sort
  , name       text     NOT NULL
  , CONSTRAINT class_action_pkey PRIMARY KEY (class_id, id)
);
COMMENT ON TABLE class_action IS 'Акция объекта';

/* ------------------------------------------------------------------------- */
CREATE TABLE class_status_action (
  class_id     d_class
  , status_id  d_id32
  , action_id  d_id32
  , CONSTRAINT class_status_action_pkey PRIMARY KEY (class_id, status_id, action_id)
  , CONSTRAINT class_status_action_class_id_status_id_fkey FOREIGN KEY (class_id, status_id) REFERENCES class_status
  , CONSTRAINT class_status_action_class_id_action_id_fkey FOREIGN KEY (class_id, action_id) REFERENCES class_action
);
COMMENT ON TABLE class_status_action IS 'Акция по статусу объекта';

/* ------------------------------------------------------------------------- */
CREATE TABLE class_acl (
  class_id     d_class  REFERENCES class
  , id         d_acl
  , is_sys     bool     NOT NULL -- не показывать публично
  , sort       d_sort
  , name       text     NOT NULL
  , CONSTRAINT class_acl_pkey PRIMARY KEY (class_id, id)
);
COMMENT ON TABLE class_acl IS 'Уровень доступа к объекту';

/* ------------------------------------------------------------------------- */
CREATE TABLE class_action_acl (
  class_id     d_class
  , action_id  d_id32
  , acl_id     d_acl
  , CONSTRAINT class_action_acl_pkey PRIMARY KEY (class_id, action_id, acl_id)
  , CONSTRAINT class_action_acl_class_id_action_id_fkey FOREIGN KEY (class_id, action_id) REFERENCES class_action
  , CONSTRAINT class_action_acl_class_id_acl_id_fkey FOREIGN KEY (class_id, acl_id) REFERENCES class_acl
);
COMMENT ON TABLE class_action_acl IS 'Уровень доступа для акции объекта';

/* ------------------------------------------------------------------------- */
CREATE TABLE class_status_action_acl_addon (
  class_id     d_class
  , status_id  d_id32
  , action_id  d_id32
  , acl_id     d_acl
  , is_addon   BOOL NOT NULL DEFAULT FALSE -- TRUE добавляем, FALSE - исключаем
  , CONSTRAINT class_status_action_acl_addon_pkey PRIMARY KEY (class_id, status_id, action_id, acl_id)
  , CONSTRAINT class_status_action_acl_addon_class_id_status_id_fkey FOREIGN KEY (class_id, status_id) REFERENCES class_status
  , CONSTRAINT class_status_action_acl_addon_class_id_action_id_fkey FOREIGN KEY (class_id, action_id) REFERENCES class_action
  , CONSTRAINT class_status_action_acl_addon_class_id_acl_id_fkey FOREIGN KEY (class_id, acl_id) REFERENCES class_acl
);
COMMENT ON TABLE class_status_action_acl_addon IS 'Дополнения (+/-) к итоговым разрешениям';

/* ------------------------------------------------------------------------- */
\qecho '-- FD: pgws:ws:20_class.sql / 105 --'
