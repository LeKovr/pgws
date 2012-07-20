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
CREATE OR REPLACE FUNCTION sid_info(a__sid d_sid, a__ip INET) RETURNS SETOF wsd.session STABLE LANGUAGE 'sql' AS
$_$
  SELECT * FROM wsd.session WHERE deleted_at IS NULL AND sid::text = $1 /* AND ($2 IS NULL OR ip = $2) */ LIMIT 1;
$_$;
SELECT pg_c('f', 'sid_info', 'Атрибуты своей сессии');

/* ------------------------------------------------------------------------- */
-- вернуть описание сервера, отвечающего за экземпляр текущего класса
CREATE OR REPLACE FUNCTION sid_info_cook(a_cook TEXT, a__ip INET) RETURNS SETOF wsd.session STABLE LANGUAGE 'sql' AS
$_$
-- TODO: изменить a_cook на a__cook при переходе на тотальное использование cookie
  SELECT * FROM wsd.session WHERE deleted_at IS NULL AND sid = $1 /*AND ($2 IS NULL OR ip = $2)*/
    ORDER BY updated_at DESC LIMIT 1
$_$;
SELECT pg_c('f', 'sid_info_cook', 'Атрибуты своей сессии по cookie');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION logout (a__sid TEXT, a__ip TEXT) RETURNS INTEGER LANGUAGE 'plpgsql' AS
$_$
  -- a__sid: ID сессии
  -- a__ip: IP-адреса сессии
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
  a__cook TEXT
, a__ip TEXT
, a_login TEXT
, a_psw TEXT
, a__sid TEXT DEFAULT NULL
) RETURNS SETOF account_info LANGUAGE 'plpgsql' AS
$_$
  -- a__cook: ID cookie
  -- a__ip: IP-адреса сессии
  -- a_login: пароль
  -- a_psw: пароль
  -- a__sid: ID сессии, если есть
  DECLARE
    r_account_info acc.account_info;
    r_account_bad acc.account_info;
    v_key text;
  BEGIN
    SELECT INTO r_account_info
      *
      FROM wsd.account
      WHERE login = a_login
    ;
    IF FOUND THEN
      RAISE DEBUG 'Account % found', a_login;

      -- TODO: контроль IP
      IF r_account_info.is_psw_plain AND r_account_info.psw = a_psw
        OR NOT r_account_info.is_psw_plain AND r_account_info.psw = md5(a_psw) THEN
        RAISE DEBUG 'Password matched for %', a_login;
        -- прячем пароль
        r_account_info.psw := '***';
        -- определяем ключ авторизации
        IF a__sid IS NOT NULL THEN
          v_key = a__sid;
        ELSE
          v_key = a__cook;
        END IF;
        -- закрываем все сессии для этого v_key
        PERFORM acc.logout(v_key, a__ip);

        -- создаем сессию
        INSERT INTO wsd.session (account_id, ip, sid)
          VALUES (r_account_info.id, a__ip, v_key)
        ;
        RETURN NEXT r_account_info;
      ELSE
        -- TODO: журналировать потенциальный подбор пароля (это причина не делать EXCEPTION)
        RAISE DEBUG 'Password does not match for %', a_login;
        r_account_bad.status_id := acc.const_status_id_unknown();
        RETURN NEXT r_account_bad;
      END IF;
    ELSE
      RAISE DEBUG 'Unknown account %', a_login;
      r_account_bad.status_id := acc.const_status_id_unknown();
      RETURN NEXT r_account_bad;
    END IF;
    RETURN;
  END;
$_$;

SELECT pg_c('f', 'login', 'Авторизация пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION profile (a__sid TEXT, a__ip TEXT) RETURNS SETOF account_info LANGUAGE 'plpgsql' AS
$_$
  -- a__sid: ID сессии
  -- a__ip: IP-адреса сессии
  DECLARE
    v_account_id ws.d_id;
    r_account_info acc.account_info;
  BEGIN
    -- TODO: контроль IP?

    SELECT INTO v_account_id
      account_id
      FROM wsd.session
      WHERE sid = a__sid
        AND deleted_at IS NULL
    ;
    IF FOUND THEN
      SELECT INTO r_account_info
        *
        FROM acc.account_info
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
