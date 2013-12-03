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

    Функции объектов класса system
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION system_status() RETURNS d_id32 STABLE LANGUAGE 'sql' AS
$_$
  SELECT 1::ws.d_id32 -- TODO: брать актуальный статус из таблицы (после готовности поддержки статуса "Обслуживание")
$_$;
SELECT pg_c('f', 'system_status', 'Статус системы');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION system_acl(a__sid d_sid DEFAULT NULL) RETURNS SETOF d_acl STABLE LANGUAGE 'sql' AS
$_$
  -- a__sid:     ID сессии
  SELECT * FROM acc.object_acl(acc.const_system_class_id(), 0, $1);
$_$;
SELECT pg_c('f', 'system_acl', 'ACL к системе',$_$
    link_id: всегда "свой"
    team_link_id: всегда "чужой"
$_$);

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION system_link_id(
  a_id   d_id
, a__sid d_sid DEFAULT NULL
) RETURNS d_link STABLE LANGUAGE 'sql' AS
$_$
  -- a_id:       ID пользователя
  -- a__sid:     ID сессии    
  SELECT acc.const_link_id_owner();
$_$;
SELECT pg_c('f', 'system_link_id', 'Связь пользователя с системой (Свой)');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION system_team_link_id(
  a_id      d_id
, a_team_id d_id
) RETURNS d_link STABLE LANGUAGE 'sql' AS
$_$
  -- a_id:          ID пользователя
  -- a_team_id:     ID команды
-- TODO: определить текущую команду пользователя
  SELECT acc.const_team_link_id_other()
$_$;
SELECT pg_c('f', 'system_team_link_id', 'Связь команды пользователя с командой учетной записи');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION system_server() RETURNS SETOF server STABLE LANGUAGE 'sql' AS
$_$
  SELECT * FROM ws.server WHERE id = 1
$_$;
SELECT pg_c('f', 'system_server', 'Описание сервера, отвечающего за экземпляр текущего класса');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION system_permission_view() RETURNS SETOF acc.permission_attr STABLE LANGUAGE 'sql' AS
$_$
  SELECT *
    FROM acc.permission_attr 
  ;
$_$;
SELECT pg_c('f', 'system_permission_view', 'Просмотр разрешений');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION system_permission_role(a_id d_id DEFAULT NULL) RETURNS SETOF acc.role_info STABLE LANGUAGE 'sql' AS
$_$
-- id: Идентификатор разрешения 
  SELECT *
    FROM acc.role_info
    WHERE id IN (SELECT role_id FROM wsd.role_permission WHERE perm_id = $1)
  ;
$_$;
SELECT pg_c('f', 'system_permission_role', 'Роли относящиеся к разрешению');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION system_permission_acl(a_id d_id DEFAULT NULL) RETURNS SETOF acc.permission_acl_attr STABLE LANGUAGE 'sql' AS
$_$
-- id: Идентификатор разрешения роли
  SELECT *
    FROM acc.permission_acl_attr 
    WHERE id = $1
  ;
$_$;
SELECT pg_c('f', 'system_permission_acl', 'Описание разрешения');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION system_class_permission_acl(a_id d_code DEFAULT NULL) RETURNS SETOF acc.permission_acl_attr STABLE LANGUAGE 'sql' AS
$_$
-- id: Код класса
  SELECT *
    FROM acc.permission_acl_attr 
    WHERE class_code = $1
  ;
$_$;
SELECT pg_c('f', 'system_class_permission_acl', 'Описание уровней доступа класса');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION system_role() RETURNS SETOF acc.role_info STABLE LANGUAGE 'sql' AS
$_$
  SELECT *
    FROM acc.role_info
    ORDER BY team_id ASC NULLS FIRST, id
  ;
$_$;
SELECT pg_c('f', 'system_role', 'Описание ролей');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION system_role_permission(a_id d_id) RETURNS SETOF acc.permission_attr STABLE LANGUAGE 'sql' AS
$_$
-- id: ID роли
  SELECT *
    FROM acc.permission_attr
    WHERE id IN (SELECT perm_id FROM wsd.role_permission WHERE role_id = $1)
    ORDER BY id
  ;
$_$;
SELECT pg_c('f', 'system_role_permission', 'Описание разрешений относящихся к роли');
