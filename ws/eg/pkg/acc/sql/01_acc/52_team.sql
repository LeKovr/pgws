
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

    Методы API
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION team_role(
  a_id        d_id
, a_role_id   d_id    DEFAULT NULL
, a_team_only BOOLEAN DEFAULT FALSE
) RETURNS SETOF acc.role_attr STABLE LANGUAGE 'sql' AS
$_$
-- a_id:        ID команды
-- a_role_id:   ID роли
-- a_team_only: Не включать общие роли
  SELECT *
    FROM acc.role_attr
    WHERE team_id = $1
      AND (is_team_only OR NOT $3)
      AND (id = $2 OR $2 IS NULL)
  ;
$_$;
SELECT pg_c('f', 'team_role', 'Список ролей команды');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION team_role_number(
  a_id      d_id
, a_role_id d_id DEFAULT 0
) RETURNS SETOF acc.team_role_number STABLE LANGUAGE 'plpgsql' AS
$_$
-- a_id:        ID команды
-- a_role_id:   ID роли
  BEGIN
    IF a_role_id = acc.const_role_id_login() THEN
      RETURN QUERY SELECT 
        team_id
      , acc.const_role_id_login()
      , sum(account_number)::BIGINT
      FROM acc.team_role_number
      WHERE team_id = a_id
      GROUP BY team_id;
    ELSE
      RETURN QUERY SELECT *
      FROM acc.team_role_number
      WHERE team_id = a_id
      AND a_role_id IN (role_id, 0)
      ;
    END IF;
  END;
$_$;
SELECT pg_c('f', 'team_role_number', 'Количество пользователей команды и роли');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION team_role_members(
  a_id      d_id
, a_role_id d_id
) RETURNS SETOF acc.team_account_attr STABLE LANGUAGE 'sql' AS
$_$
-- a_id:        ID команды
-- a_role_id:   ID роли
  SELECT *
    FROM acc.team_account_attr
    WHERE team_id = $1
      AND role_id = $2
  ;
$_$;
SELECT pg_c('f', 'team_role_members', 'Список пользователей команды с указанной ролью');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION team_role_save(
  a_id      d_id
, a_name    d_string
, a_anno    d_text
, a_role_id d_id      DEFAULT NULL
) RETURNS d_id LANGUAGE 'plpgsql' AS
$_$
-- a_id:      ID команды
-- a_name:    название роли
-- a_anno:    описание
-- a_role_id: ID роли (NULL для создания новой)
  DECLARE 
    v_id ws.d_id;
  BEGIN
    IF a_role_id IS NULL THEN
      INSERT INTO wsd.role(name, anno, team_id)
        VALUES (a_name, a_anno, a_id)
        RETURNING id INTO v_id
    ;
    ELSE
      UPDATE wsd.role
        SET name = a_name
          , anno = a_anno
        WHERE id = a_role_id
          AND team_id = a_id
      ;
      v_id := a_role_id;
    END IF;
    RETURN v_id;
  END
$_$;
SELECT pg_c('f', 'team_role_save', 'Сохранение роли');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION team_role_del(
  a_id      d_id
, a_role_id d_id
) RETURNS BOOLEAN LANGUAGE 'plpgsql' AS
$_$
-- a_id:      ID команды
-- a_role_id: ID роли
  BEGIN
    -- TODO: проверить, что нет пользователей с этой ролью
    DELETE FROM wsd.role WHERE team_id = $1 AND id = $2;
    RETURN FOUND;
  END
$_$;
SELECT pg_c('f', 'team_role_del', 'Удаление роли');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION team_by_name(a_name d_string DEFAULT '') RETURNS SETOF acc.team_attr STABLE LANGUAGE 'sql' AS
$_$
-- a_name:    название команды
  SELECT * FROM acc.team_attr WHERE name ~ $1;
$_$;
SELECT pg_c('f', 'team_by_name', 'Список команд по имени');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION team_lookup_fetch(
  c_cursor REFCURSOR
, a_col    TEXT
) RETURNS SETOF acc.team_attr STABLE LANGUAGE 'plperl' AS
$_$ #
while (defined (my $row = spi_fetchrow($_[0]))) {
  delete $row->{$_[1]};
  return_next($row);
}
return;
$_$;
SELECT ws.pg_c('f', 'team_lookup_fetch', 'служебная ф-я для team_lookup - кастинг');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION team_lookup(
  a_name    d_string  DEFAULT ''
, a_page    ws.d_cnt  DEFAULT 0
, a_by      ws.d_cnt  DEFAULT 0
, a_need_rc REFCURSOR DEFAULT NULL
) RETURNS SETOF acc.team_attr STABLE LANGUAGE 'plpgsql' AS
$_$
  -- a_name:    фильтр по названию команды
  -- a_page:    номер страницы (>= 0)
  -- a_by:      количество строк на странице
  -- a_need_rc: вернуть результат в хэше { need_rc =, rows =}, где need_rc - общее количество строк в выборке
  DECLARE
    v_rc  CURSOR FOR 
      SELECT *, COUNT(1) OVER() AS _cnt
        FROM acc.team_attr
        WHERE 
--          name ~* $1
          lower(name) LIKE lower($1 ||'%')  -- CREATE INDEX tbl_col_text_pattern_ops_idx2 ON wsd.team(lower(name) text_pattern_ops);
          AND NOT id IN (acc.const_team_id_system(), acc.const_team_id_admin())
        ORDER BY name
        OFFSET $2 * $3
        LIMIT NULLIF($3, 0)
    ;
    v_r RECORD;
  BEGIN
    OPEN v_rc;
    -- BEGIN
    FETCH v_rc INTO v_r;
    MOVE PRIOR FROM v_rc;
    -- EXCEPTION
    --   WHEN invalid_regular_expression THEN
        -- TODO: повторить запрос добавив слеши? вернуть 0?
    -- END;    
    IF a_need_rc IS NOT NULL THEN
      OPEN a_need_rc FOR EXECUTE 'SELECT ' || COALESCE(v_r._cnt, 0);
    END IF;
    RETURN QUERY SELECT * FROM acc.team_lookup_fetch(v_rc, '_cnt');
  END;
$_$;
SELECT ws.pg_c('f', 'team_lookup', 'Поиск команды по названию');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION team_profile(a_id d_id) RETURNS SETOF acc.team_attr STABLE LANGUAGE 'sql' AS
$_$
-- a_id:      ID команды
  SELECT * FROM acc.team_attr WHERE id = $1;
$_$;
SELECT pg_c('f', 'team_profile', 'Профиль команды');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION team_acl(
  a_id   d_id
, a__sid d_sid DEFAULT NULL
) RETURNS SETOF d_acl STABLE LANGUAGE 'sql' AS
$_$
-- a_id:        ID команды
-- a__sid:      ID сессии
  SELECT * FROM acc.object_acl(acc.const_team_class_id(), $1, $2);
$_$;
SELECT pg_c('f', 'team_acl', 'ACL команды');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION team_status(a_id d_id) RETURNS d_id32 STABLE LANGUAGE 'sql' AS
$_$
-- a_id:      ID команды
  SELECT status_id::ws.d_id32 FROM wsd.team WHERE id = $1;
$_$;
SELECT pg_c('f', 'team_status', 'Статус команды');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION team_account_attr(
  a_id         d_id
, a_account_id d_id DEFAULT 0
) RETURNS SETOF team_account_attr LANGUAGE 'sql' AS
$_$
-- a_id:              ID команды
-- a_account_id:      ID пользователя
  SELECT 
    ac.* 
    FROM acc.team_account_attr ac
    WHERE ac.team_id = $1 AND $2 IN (0, ac.id)
$_$;
SELECT pg_c('f', 'team_account_attr', 'Атрибуты участников команды');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION team_account_add(
  a_id         d_id
, a_account_id d_id
, a_role_id    d_id
, a_is_default BOOLEAN DEFAULT TRUE
) RETURNS BOOLEAN LANGUAGE 'plpgsql' AS
$_$
-- a_id:              ID команды
-- a_account_id:      ID пользователя
-- a_role_id:         ID роли
-- a_is_default:      флаг апдейта
  BEGIN
    IF a_is_default THEN
      UPDATE wsd.account_team
        SET is_default = FALSE
        WHERE account_id = a_account_id
          AND is_default = TRUE
      ;
    END IF;
    INSERT INTO wsd.account_team(account_id, role_id, team_id, is_default)
      VALUES(a_account_id, a_role_id, a_id, a_is_default)
    ;
    RETURN TRUE;
  END
$_$;
SELECT pg_c('f', 'team_account_add', 'Добавление пользователя в команду');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION team_account_del(
  a_id         d_id
, a_account_id d_id
) RETURNS BOOLEAN LANGUAGE 'plpgsql' AS
$_$
-- a_id:              ID команды
-- a_account_id:      ID пользователя
  BEGIN
    DELETE FROM wsd.account_team 
      WHERE account_id = a_account_id
        AND team_id = a_id;
    RETURN FOUND;
  END
$_$;
SELECT pg_c('f', 'team_account_del', 'Удаление пользователя из команды');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION team_team_link_id(
  a_object_team_id  d_id
, a_account_team_id d_id
) RETURNS d_link IMMUTABLE LANGUAGE 'sql' AS
$_$
-- a_object_team_id:       ID команды пользователя
-- a_account_team_id:      ID заданной команды
  SELECT 
    CASE 
      WHEN $1 = $2 THEN acc.const_team_link_id_owner() 
      WHEN $1 = acc.const_team_id_system() THEN acc.const_team_link_id_system()
      ELSE acc.const_team_link_id_other() 
    END;
$_$;
SELECT pg_c('f', 'team_team_link_id', 'Связь команды пользователя с заданной командой');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION team_link_id(
  a_id   d_id
, a__sid d_sid DEFAULT NULL
) RETURNS d_link IMMUTABLE LANGUAGE 'sql' AS
$_$
-- a_id:        ID команды
-- a__sid:      ID сессии
  SELECT acc.const_link_id_other(); -- link_id пользователя к команде всегда такой, связь определяется team_team_link_id
$_$;
SELECT pg_c('f', 'team_link_id', 'Связь пользователя с командой');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION team_permission(
  a_id      d_id
, a_role_id d_id DEFAULT NULL
) RETURNS SETOF wsd.permission STABLE LANGUAGE 'sql' AS
$_$
-- a_id:              ID команды
-- a_role_id:         ID роли
-- TODO: сравнить с запросом
-- select rp.*,p.* from wsd.role_permission rp join wsd.permission p on p.id = rp.perm_id order by perm_id
-- вынести результат сравнения в представление
  SELECT
    p.* 
    FROM wsd.permission p
    WHERE (p.team_id = $1 OR p.team_id IS NULL)
      AND p.id IN (
        SELECT rp.perm_id 
          FROM wsd.role_permission rp
          WHERE NOT rp.role_id IN (acc.const_role_id_login(), acc.const_role_id_guest())
            AND (rp.role_id = $2 OR $2 IS NULL)
      )
    ORDER BY p.name
  ;
$_$;
SELECT pg_c('f', 'team_permission', 'Разрешения команды');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION get_team_id_by_name(a_name TEXT) RETURNS INTEGER STABLE LANGUAGE 'sql' AS
$_$
-- a_name: Название компании
  SELECT
    id
    FROM wsd.team
    WHERE name = $1
  ;
$_$;
SELECT pg_c('f', 'get_team_id_by_name', 'Получение ID компании по ее названию');

/* ------------------------------------------------------------------------- */
