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

    Представления классов
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW class_status_action_ext AS SELECT
  sa.*
, cl.name AS class
, s.name AS status
, a.name AS action
  FROM class_status_action sa
    JOIN class cl ON (sa.class_id = cl.id)
    JOIN class_status s ON (sa.class_id = s.class_id AND sa.status_id = s.id)
    JOIN class_action a ON (sa.class_id = a.class_id AND sa.action_id = a.id)
;
SELECT pg_c('v', 'class_status_action_ext', 'class_status_action с именами class, status, action');
/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW csa AS SELECT * FROM class_status_action_ext;
SELECT pg_c('v', 'csa', 'Синоним class_status_action_ext');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW class_action_acl_ext AS SELECT
  aa.*
, cl.name  AS class
, a1.name AS action
, a2.name AS acl
  FROM class_action_acl aa
    JOIN class cl ON (aa.class_id = cl.id)
    JOIN class_action a1 ON (aa.class_id = a1.class_id AND aa.action_id = a1.id)
    JOIN class_acl a2 ON (aa.class_id = a2.class_id AND aa.acl_id = a2.id)
;
SELECT pg_c('v', 'class_action_acl_ext', 'class_action_acl с именами class, action, acl');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW caa AS SELECT * FROM class_action_acl_ext;
SELECT pg_c('v', 'caa', 'Синоним class_action_acl_ext');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW class_status_action_acl AS SELECT
  sa.*
, aa.acl_id
, NULL::BOOL AS is_addon -- NULL для результата JOIN, TRUE для строки из class_status_action_acl_addon
  FROM class_status_action sa
    JOIN class_action_acl aa USING (class_id, action_id)
  UNION SELECT * FROM class_status_action_acl_addon WHERE is_addon
  EXCEPT SELECT class_id, status_id, action_id, acl_id, NULL FROM class_status_action_acl_addon WHERE NOT is_addon
;
SELECT pg_c('v', 'class_status_action_acl', 'class_status_action_acl')
, pg_c('c', 'class_status_action_acl.is_addon',  'Строка является добавлением разрешения')
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW class_status_action_acl_ext AS SELECT
  csaa.*
, cl.name  AS class
, s.name AS status
, a1.name AS action
, a2.name AS acl
  FROM class_status_action_acl csaa
    JOIN class cl ON (csaa.class_id = cl.id)
    JOIN class_status s ON (csaa.status_id = s.id AND csaa.class_id = s.class_id)
    JOIN class_action a1 ON (csaa.action_id = a1.id AND csaa.class_id = a1.class_id)
    JOIN class_acl a2 ON (csaa.acl_id = a2.id  AND csaa.class_id = a2.class_id)
;
SELECT pg_c('v', 'class_status_action_acl_ext', 'class_status_action_acl с именами class, status, action, acl');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW csaa AS SELECT * FROM class_status_action_acl_ext;
SELECT pg_c('v', 'csaa', 'Синоним class_status_action_acl_ext');

