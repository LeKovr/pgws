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
-- 50_pkg.sql - Компиляция и установка пакетов
/* ------------------------------------------------------------------------- */
\qecho '-- FD: pgws:ws:50_pkg.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION compile_errors_chk() RETURNS TEXT STABLE LANGUAGE 'plpgsql' AS
$_$  -- FD: pgws:ws:50_pkg.sql / 27 --
  DECLARE
    v_t TIMESTAMP := CURRENT_TIMESTAMP;
  BEGIN
    SELECT INTO v_t stamp FROM ws.compile_errors WHERE stamp = v_t LIMIT 1;
      IF FOUND THEN
        RAISE EXCEPTION '***************** Errors found *****************';
      END IF;
    RETURN 'Ok';
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg_oper_add(a_code TEXT, a_ver TEXT) RETURNS VOID LANGUAGE 'sql' AS
$_$  -- FD: pgws:ws:50_pkg.sql / 41 --
  INSERT INTO ws_data.pkg_oper (code, ver) VALUES ($1, $2);
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg_oper_add(a_code TEXT) RETURNS VOID LANGUAGE 'sql' AS
$_$  -- FD: pgws:ws:50_pkg.sql / 47 --
  INSERT INTO ws_data.pkg_oper (code, ver) VALUES ($1, DEFAULT);
$_$;
/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg(a_code TEXT) RETURNS ws.pkg STABLE LANGUAGE 'sql' AS
$_$  -- FD: pgws:ws:50_pkg.sql / 52 --
  SELECT * FROM ws.pkg WHERE code = $1;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg_is_core_only() RETURNS BOOL STABLE LANGUAGE 'plpgsql' AS
$_$  -- FD: pgws:ws:50_pkg.sql / 58 --
  DECLARE
    v_pkgs TEXT;
  BEGIN
    SELECT INTO v_pkgs
      array_to_string(array_agg(code),', ')
      FROM ws.pkg
      WHERE code <> 'pgws'
    ;
    IF v_pkgs IS NOT NULL THEN
      RAISE EXCEPTION '***************** There are app packages installed (%) *****************', v_pkgs;
    END IF;
    RETURN TRUE;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg_add(a_code TEXT, a_ver TEXT, a_log_name TEXT, a_user_name TEXT, a_ssh_client TEXT) RETURNS TEXT VOLATILE LANGUAGE 'plpgsql' AS
$_$  -- FD: pgws:ws:50_pkg.sql / 76 --
  DECLARE
    r_pkg ws.pkg%ROWTYPE;
  BEGIN
    r_pkg := ws.pkg(a_code);
    IF r_pkg IS NULL THEN
      INSERT INTO ws.pkg (id, code, ver, log_name, user_name, ssh_client)
        VALUES (NEXTVAL('ws.pkg_id_seq'), a_code, a_ver, a_log_name, a_user_name, a_ssh_client)
        RETURNING * INTO r_pkg;
        INSERT INTO ws.pkg_log VALUES (r_pkg.*);
      RETURN 'Ok';
    END IF;
    RAISE EXCEPTION '***************** Package % (%) installed already at % (%) *****************'
      , a_code, a_ver, r_pkg.stamp, r_pkg.id;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg_make(a_code TEXT, a_ver TEXT, a_log_name TEXT, a_user_name TEXT, a_ssh_client TEXT) RETURNS TEXT VOLATILE LANGUAGE 'plpgsql' AS
$_$  -- FD: pgws:ws:50_pkg.sql / 95 --
  DECLARE
    r_pkg ws.pkg%ROWTYPE;
  BEGIN
    UPDATE ws.pkg SET
      id            = NEXTVAL('ws.pkg_id_seq') -- runs after rule
      , log_name    = a_log_name
      , user_name   = a_user_name
      , ssh_client  = a_ssh_client
      , stamp       = now()
      , op          = '.'
      WHERE code = a_code
        AND ver  = a_ver
        RETURNING * INTO r_pkg
    ;
    IF NOT FOUND THEN
      RAISE EXCEPTION '***************** Package % ver % does not found *****************'
        , a_code, a_ver
      ;
    END IF;
    INSERT INTO ws.pkg_log VALUES (r_pkg.*);
    RETURN 'Ok';
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg_del(a_code TEXT, a_ver TEXT, a_log_name TEXT, a_user_name TEXT, a_ssh_client TEXT) RETURNS TEXT VOLATILE LANGUAGE 'plpgsql' AS
$_$  -- FD: pgws:ws:50_pkg.sql / 122 --
  DECLARE
    r_pkg ws.pkg%ROWTYPE;
    v_id  INTEGER;
  BEGIN
    r_pkg := ws.pkg(a_code);
    IF a_ver = r_pkg.ver THEN
      INSERT INTO ws.pkg_log (id, code, ver, log_name, user_name, ssh_client, op)
        VALUES (NEXTVAL('ws.pkg_id_seq'), a_code, a_ver, a_log_name, a_user_name, a_ssh_client, '-')
      ;
      DELETE FROM ws.pkg
        WHERE code = a_code
      ;
      RETURN 'Ok';
    END IF;

    RAISE EXCEPTION '***************** Package % (%) is not actial (%) *****************'
      , a_code, a_ver, r_pkg.ver
    ;
  END
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg_require(a_code TEXT) RETURNS TEXT STABLE LANGUAGE 'plpgsql' AS
$_$  -- FD: pgws:ws:50_pkg.sql / 146 --
  BEGIN
    RAISE NOTICE 'TODO: function needs code';
    RETURN NULL;
  END
$_$;

/* ------------------------------------------------------------------------- */
\qecho '-- FD: pgws:ws:50_pkg.sql / 154 --'
