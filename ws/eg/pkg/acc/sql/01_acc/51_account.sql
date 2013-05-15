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
CREATE OR REPLACE FUNCTION sid_info_internal(a__sid d_sid DEFAULT NULL, a__ip TEXT DEFAULT NULL) RETURNS SETOF acc.session_info STABLE LANGUAGE 'sql' AS
$_$
  SELECT
    *
    FROM acc.session_info
    WHERE deleted_at IS NULL
      AND sid = $1
      AND (NOT is_ip_checked OR $2 IS NULL OR ip = $2)
    LIMIT 1
    ;
$_$;
SELECT pg_c('f', 'sid_info_internal', 'Атрибуты сессии (для внутренних вызовов)');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION sid_info(a__sid d_sid DEFAULT NULL, a__ip TEXT DEFAULT NULL, save_stamp BOOL DEFAULT TRUE) RETURNS SETOF acc.session_info VOLATILE LANGUAGE 'plpgsql' AS
$_$
  BEGIN
    RETURN QUERY SELECT * FROM acc.sid_info_internal(a__sid, a__ip);
    IF FOUND AND save_stamp THEN
      UPDATE wsd.session SET
        updated_at = CURRENT_TIMESTAMP
        WHERE sid = a__sid
      ;
    END IF;
    RETURN;
  END;
$_$;
SELECT pg_c('f', 'sid_info', 'Атрибуты своей сессии');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION sid_account_id (a__sid TEXT) RETURNS d_id LANGUAGE 'sql' AS
$_$
  SELECT
    account_id::ws.d_id
    FROM wsd.session
    WHERE sid = $1
      AND deleted_at IS NULL
    ;
$_$;
SELECT pg_c('f', 'sid_account_id', 'ID пользователя по SID');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION account_status(a_id d_id) RETURNS d_id32 STABLE LANGUAGE 'sql' AS
$_$
  SELECT status_id::ws.d_id32 FROM wsd.account WHERE id = $1
$_$;
SELECT pg_c('f', 'account_status', 'Статус учетной записи пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION account_acl(a_id d_id, a__sid d_sid DEFAULT NULL) RETURNS SETOF d_acl STABLE LANGUAGE 'sql' AS
$_$
  SELECT * FROM acc.object_acl(acc.const_class_id(), $1, $2);
$_$;
SELECT pg_c('f', 'account_acl', 'ACL к учетной записи пользователя',$_$
    Получить уровень доступа пользователя сессии a_sid на экземпляр a_id класса "user"
    Например: администратор отдела, в котором состоит заданный пользователь a_id
      или для ws.part_topic_message - пользователь является автором поста
$_$);

/* ------------------------------------------------------------------------- */
-- вернуть описание сервера, отвечающего за экземпляр текущего класса
CREATE OR REPLACE FUNCTION account_server(a_id d_id) RETURNS SETOF server STABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_id  ws.d_id32;
    r_srv ws.server;
  BEGIN
    v_id := 1; -- расчет id ответственного сервера по id компании
    RETURN QUERY
      SELECT *
        FROM ws.server
        WHERE id = v_id
    ;
    RETURN;
  END
$_$;
SELECT pg_c('f', 'account_server', 'Сервер учетной записи пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION logout (a__sid d_sid DEFAULT NULL) RETURNS INTEGER LANGUAGE 'plpgsql' AS
$_$
  -- a__sid: ID сессии
  DECLARE
    v_cnt INTEGER;
  BEGIN
    UPDATE wsd.session SET
      deleted_at = now()
      WHERE sid = a__sid
        AND deleted_at IS NULL
    ;
    GET DIAGNOSTICS v_cnt = ROW_COUNT;
    RETURN v_cnt;
  END;
$_$;
SELECT pg_c('f', 'logout', 'Завершить авторизации пользователя и вернуть количество завершенных');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION login (
  a__ip TEXT
, a_login TEXT
, a_psw TEXT
, a__cook TEXT DEFAULT NULL
) RETURNS SETOF session_info LANGUAGE 'plpgsql' AS
$_$
  -- a__cook: ID cookie
  -- a__ip: IP-адреса сессии
  -- a_login: пароль
  -- a_psw: пароль
  DECLARE
    r       wsd.account;
    v_team_id ws.d_id := NULL;                        -- значение, если нет команды
    v_role_id ws.d_id := acc.const_role_id_noteam();  -- значение, если нет команды
    v_key   TEXT;
    v_id    INTEGER;
  BEGIN
    SELECT INTO r
      *
      FROM wsd.account
      WHERE login = a_login
    ;
    IF FOUND THEN
      RAISE DEBUG 'Account % found', a_login;

      IF r.status_id NOT IN (acc.const_status_id_active(), acc.const_status_id_locked()) THEN
        RAISE EXCEPTION '%', ws.error_str(acc.const_error_status(), r.status_id::text);
      END IF;

      -- TODO: контроль IP
      IF r.is_psw_plain AND r.psw = a_psw
        OR NOT r.is_psw_plain AND r.psw = md5(a_psw) THEN
        RAISE DEBUG 'Password matched for %', a_login;

        v_id := NEXTVAL('wsd.session_id_seq');
        -- определяем ключ авторизации
        IF a__cook IS NOT NULL THEN
          v_key = a__cook;
          -- закрываем все сессии для этого v_key
          PERFORM acc.logout(v_key);
        ELSE
          v_key = (random() * 10 ^ 8)::INTEGER::TEXT || v_id;
        END IF;
        RAISE DEBUG 'Session ID = %, KEY = %', v_id, v_key;

        -- определяем роль пользователя
        SELECT INTO v_team_id, v_role_id
          team_id, role_id
          FROM wsd.account_team
          WHERE account_id = r.id
            AND is_default = TRUE
          LIMIT 1
        ;
        RAISE DEBUG 'Account TEAM = %, ROLE = %', v_team_id, v_role_id;

        -- создаем сессию
        INSERT INTO wsd.session (id, account_id, role_id, team_id, sid, ip, is_ip_checked)
          VALUES (v_id, r.id, v_role_id, v_team_id, v_key, a__ip, r.is_ip_checked)
        ;
        RETURN QUERY SELECT
          *
          FROM acc.session_info
          WHERE id = v_id
        ;
      ELSE
        -- TODO: журналировать потенциальный подбор пароля через cache
        RAISE EXCEPTION '%', ws.error_str(acc.const_error_password(), a_login::text);
      END IF;
    ELSE
      RAISE EXCEPTION '%', ws.error_str(acc.const_error_login(), a_login::text);
    END IF;
    RETURN;
  END;
$_$;

SELECT pg_c('f', 'login', 'Авторизация пользователя');


/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION account_profile(a_id d_id) RETURNS SETOF acc.account_attr STABLE LANGUAGE 'sql' AS
$_$
  SELECT * FROM acc.account_attr WHERE id = $1;
$_$;
SELECT pg_c('f', 'account_profile', 'Профиль пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION account_link_id(a_id d_id, a__sid d_sid DEFAULT NULL) RETURNS d_link STABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    r_session acc.session_info;
  BEGIN
    SELECT INTO r_session
      *
      FROM acc.sid_info_internal(a__sid)
    ;
    IF FOUND AND (a_id = r_session.account_id) THEN
      RETURN acc.const_link_id_owner();
    ELSE
      RETURN acc.const_link_id_other();
    END IF;
  END
$_$;
SELECT pg_c('f', 'account_link_id', 'Связь пользователя с учетной записью');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION account_team_link_id(a_id d_id, a_team_id d_id) RETURNS d_link STABLE LANGUAGE 'sql' AS
$_$
-- TODO: определить текущую команду пользователя
  SELECT CASE 
    WHEN EXISTS(SELECT 1 FROM wsd.account_team WHERE account_id = $1 AND team_id = $2) THEN acc.const_team_link_id_owner()
    ELSE acc.const_team_link_id_other()
  END;
$_$;
SELECT pg_c('f', 'account_team_link_id', 'Связь команды пользователя с командой учетной записи');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION account_team(a_id d_id) RETURNS SETOF acc.account_team STABLE LANGUAGE 'sql' AS
$_$
  SELECT
    *
    FROM acc.account_team
    WHERE account_id = $1
  ;
$_$;
SELECT pg_c('f', 'account_team', 'Команды и роли пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION account_permission(a_id d_id, a_team_id d_id) RETURNS SETOF acc.account_permission_attr STABLE LANGUAGE 'sql' AS
$_$
-- a_id:      Идентификатор пользователя
-- a_team_id: Идентификатор команды
  WITH aperm AS (   -- Account permissions
    SELECT DISTINCT p.id
      FROM wsd.permission p
        JOIN wsd.role_permission rp ON rp.perm_id = p.id
        LEFT JOIN wsd.account_team at ON rp.role_id = at.role_id
      WHERE (
          (at.account_id = $1 AND at.team_id = $2) 
          OR (rp.role_id = acc.const_role_id_login())
        )
        AND (p.team_id = $2 OR p.team_id IS NULL)
  )
  SELECT p.*, ap.id IS NOT NULL AS is_enabled
    FROM wsd.permission p
      LEFT JOIN aperm ap ON ap.id = p.id
  ;
$_$;
SELECT pg_c('f', 'account_permission', 'Разрешения пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION account_contact_add(a_id d_id, a_type_id d_id32, a_value d_string) RETURNS BOOLEAN VOLATILE LANGUAGE 'plpgsql' AS
$_$
-- a_id:      ID Пользователя
-- a_type_id: ID типа контакта
-- a_value:   Значение контакта
  DECLARE
    v_rows INTEGER;
  BEGIN

    SELECT INTO v_rows
      count(1)
      FROM wsd.account_contact
      WHERE account_id = $1
        AND value = $3
        AND contact_type_id = $2
        AND deleted_at IS NULL
    ;

    IF v_rows > 0 THEN
      RETURN FALSE;
    END IF;

    SELECT INTO v_rows
      count(1)
      FROM wsd.account_contact
      WHERE account_id = $1
        AND contact_type_id = $2
        AND deleted_at IS NULL
    ;

    IF v_rows > 0 THEN
      UPDATE wsd.account_contact SET
        deleted_at = now()
        WHERE account_id = $1
          AND contact_type_id = $2
          AND deleted_at IS NULL
      ;
    END IF;

    INSERT INTO wsd.account_contact (account_id, contact_type_id, value, created_at) VALUES
      ($1, $2, $3, NOW());

    RETURN TRUE;
  END
$_$;
SELECT pg_c('f', 'account_contact_add', 'Добавление контактов пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION account_contact_view(a_id d_id, a_all BOOLEAN DEFAULT TRUE) RETURNS SETOF acc.account_contact STABLE LANGUAGE 'sql' AS
$_$
-- a_id:       ID Пользователя
-- a_verified: Только подтвержденые или все
    SELECT *
      FROM acc.account_contact
      WHERE account_id = $1
        AND ((verified_at IS NOT NULL AND $2 = FALSE) OR ($2 = TRUE))
    ;
$_$;
SELECT pg_c('f', 'account_contact_view', 'Просмотр контактов пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION account_contact_type_attr(a_id d_id32 DEFAULT NULL) RETURNS SETOF acc.account_contact_type_attr STABLE LANGUAGE 'sql' AS
$_$
-- a_id:      ID типа контакта
    SELECT *
      FROM acc.account_contact_type_attr
      WHERE COALESCE($1, id) = id
    ;
$_$;
SELECT pg_c('f', 'account_contact_type_attr', 'Просмотр типов контактов');

/* ------------------------------------------------------------------------- */

CREATE OR REPLACE FUNCTION account_lookup_fetch(c_cursor REFCURSOR,  a_col TEXT) RETURNS SETOF acc.account_attr_info STABLE LANGUAGE 'plperl' AS
$_$ #
while (defined (my $row = spi_fetchrow($_[0]))) {
  delete $row->{$_[1]};
  return_next($row);
}
return;
$_$;

CREATE OR REPLACE FUNCTION account_lookup(
  a_name d_string DEFAULT ''
, a_page ws.d_cnt DEFAULT 0
, a_by ws.d_cnt DEFAULT 0
, a_need_rc REFCURSOR DEFAULT NULL
) RETURNS SETOF acc.account_attr_info STABLE LANGUAGE 'plpgsql' AS
$_$
  -- a_name:  фильтр по имени пользователя
  -- a_page:  номер страницы (>= 0)
  -- a_by:    количество строк на странице
  -- a_need_rc: вернуть результат в хэше { need_rc =, rows =}, где need_rc - общее количество строк в выборке
  DECLARE
    v_rc SCROLL CURSOR FOR 
      SELECT *, COUNT(1) OVER() AS _cnt
        FROM acc.account_attr_info
        WHERE name ~* $1
          AND NOT id IN (
            SELECT account_id
              FROM wsd.account_team 
              WHERE team_id IN (acc.const_team_id_system(), acc.const_team_id_admin())
          )
        ORDER BY name
        OFFSET $2 * $3
        LIMIT NULLIF($3, 0)
    ;
    v_r RECORD;
  BEGIN
    OPEN v_rc;
    FETCH v_rc INTO v_r;
    MOVE PRIOR FROM v_rc;
    IF a_need_rc IS NOT NULL THEN
      OPEN a_need_rc FOR EXECUTE 'SELECT ' || COALESCE(v_r._cnt, 0);
    END IF;
    RETURN QUERY SELECT * FROM acc.account_lookup_fetch(v_rc, '_cnt');
  END;
$_$;
SELECT ws.pg_c('f', 'account_lookup', 'Поиск пользователя по имени');

/* ------------------------------------------------------------------------- */
