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

    Функции поддержки классов
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION class_id(a_code d_code) RETURNS d_class STABLE STRICT LANGUAGE 'sql' AS
$_$
  -- a_code: название класса
  SELECT id FROM ws.class WHERE code = $1;
$_$;
SELECT pg_c('f', 'class_id', 'ID класса по коду');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION class_code(a_id d_class) RETURNS d_code STABLE STRICT LANGUAGE 'sql' AS
$_$
  -- a_id: ID класса
  SELECT code FROM ws.class WHERE id = $1;
$_$;
SELECT pg_c('f', 'class_code', 'Код класса по ID');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION class(a_id d_class DEFAULT 0) RETURNS SETOF class STABLE STRICT LANGUAGE 'sql' AS
$_$
  -- a_id: ID класса
  SELECT * FROM ws.class WHERE $1 IN (id, 0) ORDER BY id;
$_$;
SELECT pg_c('f', 'class', 'Атрибуты классов по ID');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION class_by_code(a_code d_code) RETURNS SETOF class STABLE STRICT LANGUAGE 'sql' AS
$_$
  -- a_code: название класса
  SELECT * FROM ws.class WHERE code = $1 ORDER BY name;
$_$;
SELECT pg_c('f', 'class_by_code', 'Атрибуты классов по коду');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION acls_eff_ids(
  class_id  d_class
, status_id d_id32
, action_id d_id32
, acl_ids   d_acls
) RETURNS SETOF d_acl STABLE LANGUAGE 'sql' AS
$_$
  -- class_id:   ID класса
  -- status_id:  ID статуса
  -- action_id:  ID акции
  -- acl_ids:    список ACL_ID
SELECT acl_id FROM ws.class_status_action_acl
  WHERE class_id = $1 AND status_id = $2 AND action_id = $3 AND acl_id = ANY ($4::ws.d_acls)
$_$;
SELECT pg_c('f', 'acls_eff_ids', 'Список id эффективных ACL');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION acls_eff(
  class_id  d_class
, status_id d_id32
, action_id d_id32
, acl_ids   d_acls
) RETURNS SETOF t_hashtable STABLE LANGUAGE 'sql' AS
$_$
  -- class_id:   ID класса
  -- status_id:  ID статуса
  -- action_id:  ID акции
  -- acl_ids:    список ACL_ID
SELECT ca.id::text, ca.name FROM ws.class_status_action_acl csaa
  JOIN ws.class_acl ca
  ON (ca.class_id = csaa.class_id AND ca.id = csaa.acl_id)
  WHERE csaa.class_id = $1 AND status_id = $2 AND action_id = $3 AND acl_id = ANY ($4::ws.d_acls)
$_$;
SELECT pg_c('f', 'acls_eff', 'Список эффективных ACL');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION class_action(
  a_class_id d_class DEFAULT 0
, a_id       d_id32 DEFAULT 0
) RETURNS SETOF class_action STABLE LANGUAGE 'sql' AS
$_$
  -- a_class_id:   ID класса
  -- a_id:         ID акции
  SELECT * FROM ws.class_action WHERE $1 IN (class_id, 0) AND $2 IN (id, 0) ORDER BY 1,2;
$_$;
SELECT pg_c('f', 'class_action', 'Описание акции класса');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION class_status(
  a_class_id d_class DEFAULT 0
, a_id       d_id32 DEFAULT 0
) RETURNS SETOF class_status STABLE LANGUAGE 'sql' AS
$_$
  -- a_class_id:   ID класса
  -- a_id:         ID статуса
  SELECT * FROM ws.class_status WHERE $1 IN (class_id, 0) AND $2 IN (id, 0) ORDER BY 1,2;
$_$;
SELECT pg_c('f', 'class_status', 'Описание статуса класса');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION class_status_name(
  a_class_code d_code
, a_id         d_id32
) RETURNS TEXT STABLE STRICT LANGUAGE 'sql' AS
$_$
  -- a_class_code:   название класса
  -- a_id:           ID статуса
  SELECT name FROM ws.class_status WHERE class_id = ws.class_id($1) AND $2 = id;
$_$;
SELECT pg_c('f', 'class_status_name', 'Название статуса по ID и коду класса');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION class_acl(
  a_class_id d_class DEFAULT 0
, a_id       d_id32 DEFAULT 0
) RETURNS SETOF class_acl STABLE LANGUAGE 'sql' AS
$_$
  -- a_class_id:   ID класса
  -- a_id:         ID уровня доступа
  SELECT * FROM ws.class_acl WHERE $1 IN (class_id, 0) AND $2 IN (id, 0) ORDER BY 1,2;
$_$;
SELECT pg_c('f', 'class_acl', 'Описание уровней доступа класса');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION class_status_action_acl(
  a_class_id  d_class DEFAULT 0
, a_status_id d_id32 DEFAULT 0
, a_action_id d_id32 DEFAULT 0
, a_acl_id    d_id32 DEFAULT 0
) RETURNS SETOF csaa STABLE LANGUAGE 'sql' AS
$_$
  -- a_class_id:   ID класса
  -- a_status_id:  ID статуса
  -- a_action_id:  ID акции
  -- a_acl_id:     ID уровня доступа
  SELECT * FROM ws.csaa WHERE $1 IN (class_id, 0) AND $2 IN (status_id, 0) AND $3 IN (action_id, 0) AND $4 IN (acl_id, 0) ORDER BY 1, 2, 3, 4;
$_$;
SELECT pg_c('f', 'class_status_action_acl', 'Статусы и ACL для заданной акции');
