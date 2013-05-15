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
CREATE OR REPLACE FUNCTION system_acl(a__sid d_sid DEFAULT NULL) RETURNS SETOF d_acl STABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    r_session acc.session_info;
  BEGIN
    SELECT INTO r_session
      *
      FROM acc.sid_info_internal(a__sid)
    ;
    IF NOT FOUND THEN
      RETURN NEXT 1::ws.d_acl; -- Неавторизованный пользователь
      RETURN;
    END IF;
    RETURN NEXT 2::ws.d_acl; -- Авторизованный пользователь

    IF r_session.team_id IS NOT NULL AND r_session.team_id = acc.const_team_id_admin() THEN
      RETURN NEXT 4::ws.d_acl; -- Оператор
    END IF;
    --TODO: Сервис?
    RETURN;
  END
$_$;
SELECT pg_c('f', 'system_acl', 'ACL sid для системы');

/* ------------------------------------------------------------------------- */
-- вернуть описание сервера, отвечающего за экземпляр текущего класса
CREATE OR REPLACE FUNCTION system_server() RETURNS SETOF server STABLE LANGUAGE 'sql' AS
$_$
  SELECT * FROM ws.server WHERE id = 1
$_$;


/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION system_permission_view() RETURNS SETOF acc.permission_attr STABLE LANGUAGE 'sql' AS
$_$
  SELECT *
    FROM acc.permission_attr 
  ;
$_$;
SELECT pg_c('f', 'system_permission_view', 'Просмотр разрешений');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION system_permission_role(id d_id DEFAULT NULL) RETURNS SETOF acc.role_info STABLE LANGUAGE 'sql' AS
$_$
-- id: Идентификатор разрешения 
  SELECT *
    FROM acc.role_info
    WHERE id IN (SELECT role_id FROM wsd.role_permission WHERE perm_id = $1)
  ;
$_$;
SELECT pg_c('f', 'system_permission_role', 'Роли относящиеся к разрешению');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION system_permission_acl(id d_id DEFAULT NULL) RETURNS SETOF acc.permission_acl_attr STABLE LANGUAGE 'sql' AS
$_$
  SELECT *
    FROM acc.permission_acl_attr 
    WHERE id = $1
  ;
$_$;
SELECT pg_c('f', 'system_permission_acl', 'Описание разрешения');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION system_class_acl(id d_code DEFAULT NULL) RETURNS SETOF acc.permission_acl_attr STABLE LANGUAGE 'sql' AS
$_$
  SELECT *
    FROM acc.permission_acl_attr 
    WHERE class_code = $1
  ;
$_$;
SELECT pg_c('f', 'system_class_acl', 'Описание уровней доступа класса');

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
CREATE OR REPLACE FUNCTION system_role_permission(id d_id) RETURNS SETOF acc.permission_attr STABLE LANGUAGE 'sql' AS
$_$
  SELECT *
    FROM acc.permission_attr
    WHERE id IN (SELECT perm_id FROM wsd.role_permission WHERE role_id = $1)
    ORDER BY id
  ;
$_$;
SELECT pg_c('f', 'system_role_permission', 'Описание разрешений относящихся к роли');

/* ------------------------------------------------------------------------- */
