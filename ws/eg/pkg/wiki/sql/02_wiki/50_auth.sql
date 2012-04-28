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
-- 50_add.sql - Метод API add
/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:50_auth.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION logout (a__sid TEXT, a__ip TEXT) RETURNS BOOL LANGUAGE 'plpgsql' AS
$_$  -- FD: wiki:wiki:50_auth.sql / 27 --
  -- a__sid: ID сессии
  -- a__ip: IP-адреса сессии
BEGIN
  UPDATE wiki.session SET
    deleted_at = now()
    WHERE sid = a__sid
  ;
  RETURN FOUND;
END;
$_$;

SELECT pg_c('f', 'logout', 'Завершение авторизации пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION login (
  a__sid TEXT
  , a__ip TEXT
  , a_login TEXT
  , a_psw TEXT
  ) RETURNS SETOF account_info LANGUAGE 'plpgsql' AS
$_$  -- FD: wiki:wiki:50_auth.sql / 48 --
  -- a__sid: ID сессии
  -- a__ip: IP-адреса сессии
  -- a_login: пароль
  -- a_psw: пароль
DECLARE
  r_account_info wiki.account_info;
  v_psw text;
BEGIN
  SELECT INTO r_account_info
    *
    FROM wiki.account
    WHERE login = a_login
  ;
  IF FOUND THEN
    RAISE DEBUG 'Account % found', a_login;

    -- TODO: контроль IP
    IF r_account_info.psw = md5(a_psw) THEN
      RAISE DEBUG 'Password matched for %', a_login;
      -- прячем пароль
      r_account_info.psw := '***';

      -- закрываем все сессии для этого sid
      PERFORM wiki.logout(a__sid, a__ip);

      -- создаем сессию
      INSERT INTO wiki.session (account_id, ip, sid)
        VALUES (r_account_info.id, a__ip, a__sid)
      ;
      -- добавляем название группы
      SELECT INTO r_account_info.group_name name FROM wiki.account_group WHERE id = r_account_info.group_id;

      RETURN NEXT r_account_info;
    ELSE
      -- TODO: журналировать потенциальный подбор пароля
      RAISE DEBUG 'Password does not match for %', a_login;
    END IF;
  ELSE
    RAISE DEBUG 'Unknown account %', a_login;
  END IF;
  RETURN;
END;
$_$;

SELECT pg_c('f', 'login', 'Авторизация пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION profile (a__sid TEXT, a__ip TEXT) RETURNS SETOF account_info LANGUAGE 'plpgsql' AS
$_$  -- FD: wiki:wiki:50_auth.sql / 97 --
  -- a__sid: ID сессии
  -- a__ip: IP-адреса сессии
DECLARE
  v_account_id ws.d_id;
  r_account_info wiki.account_info;
BEGIN
  -- TODO: контроль IP?

  SELECT INTO v_account_id
    account_id
    FROM wiki.session
    WHERE sid = a__sid
      AND deleted_at IS NULL
  ;
  IF FOUND THEN
    SELECT INTO r_account_info
      *
      FROM wiki.account_info
      WHERE id = v_account_id
    ;
    -- прячем пароль
    r_account_info.psw := '***';
    RETURN NEXT r_account_info;
  END IF;

  RETURN;
END;
$_$;

SELECT pg_c('f', 'profile', 'Профиль текущего пользователя');

/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:50_auth.sql / 130 --'
