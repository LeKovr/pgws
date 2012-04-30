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
\qecho '-- FD: pg:ws:50_pkg.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION compile_errors_chk() RETURNS TEXT STABLE LANGUAGE 'plpgsql' AS
$_$  -- FD: pg:ws:50_pkg.sql / 27 --
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
CREATE OR REPLACE FUNCTION pkg_add(a_code TEXT, a_ver TEXT, a_log_name TEXT, a_user_name TEXT, a_ssh_client TEXT) RETURNS TEXT VOLATILE LANGUAGE 'plpgsql' AS
$_$  -- FD: pg:ws:50_pkg.sql / 41 --
  DECLARE
    r_pkg ws.pkg%ROWTYPE;
  BEGIN
    SELECT INTO r_pkg * FROM ws.pkg
      WHERE code = a_code AND ver = a_ver
      ORDER BY id DESC
      LIMIT 1
    ;
    IF FOUND THEN
      IF r_pkg.is_add THEN -- rm_id IS NULL after ORDER BY
        RAISE EXCEPTION '***************** Package % (%) installed already at % (%) *****************'
          , a_code, a_ver, r_pkg.stamp, r_pkg.id;
      END IF;
    END IF;
    INSERT INTO ws.pkg (code, ver, log_name, user_name, ssh_client)
      VALUES (a_code, a_ver, a_log_name, a_user_name, a_ssh_client)
    ;
    RETURN 'Ok';
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg_actual(a_code TEXT) RETURNS pkg STABLE LANGUAGE 'sql' AS
$_$  -- FD: pg:ws:50_pkg.sql / 65 --
  SELECT * FROM ws.pkg
      WHERE code = $1 AND is_add AND rm_id IS NULL
      ORDER BY id DESC
      LIMIT 1
    ;
$_$;


/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg_is_core_only() RETURNS BOOL STABLE LANGUAGE 'plpgsql' AS
$_$  -- FD: pg:ws:50_pkg.sql / 76 --
  DECLARE
    v_pkgs TEXT;
  BEGIN
    SELECT INTO v_pkgs
      array_to_string(array_agg(code),', ')
      FROM ws.pkg
      WHERE is_add AND rm_id IS NULL AND code <> 'pg'
    ;
    IF v_pkgs IS NOT NULL THEN
      RAISE EXCEPTION '***************** There are app packages installed (%) *****************', v_pkgs;
    END IF;
    RETURN TRUE;
  END;
$_$;


/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg_make(a_code TEXT, a_ver TEXT, a_log_name TEXT, a_user_name TEXT, a_ssh_client TEXT) RETURNS TEXT VOLATILE LANGUAGE 'plpgsql' AS
$_$  -- FD: pg:ws:50_pkg.sql / 95 --
  DECLARE
    r_pkg ws.pkg%ROWTYPE;
  BEGIN
    r_pkg := ws.pkg_actual(a_code);
    IF a_ver = r_pkg.ver THEN
      INSERT INTO ws.pkg (code, ver, log_name, user_name, ssh_client, is_add)
        VALUES (a_code, a_ver, a_log_name, a_user_name, a_ssh_client, NULL)
      ;
      RETURN 'Ok';
    END IF;
    r_pkg.ver := COALESCE (r_pkg.ver, 'NONE');
    RAISE EXCEPTION '***************** Package % (%) has different version (%) *****************'
      , a_code, a_ver, r_pkg.ver
    ;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg_del(a_code TEXT, a_ver TEXT, a_log_name TEXT, a_user_name TEXT, a_ssh_client TEXT) RETURNS TEXT VOLATILE LANGUAGE 'plpgsql' AS
$_$  -- FD: pg:ws:50_pkg.sql / 115 --
  DECLARE
    r_pkg ws.pkg%ROWTYPE;
    v_id  INTEGER;
  BEGIN
    r_pkg := ws.pkg_actual(a_code);
    IF a_ver = r_pkg.ver THEN
      INSERT INTO ws.pkg (code, ver, log_name, user_name, ssh_client, is_add)
        VALUES (a_code, a_ver, a_log_name, a_user_name, a_ssh_client, FALSE)
        RETURNING id INTO v_id
      ;
      UPDATE ws.pkg SET
        rm_id = v_id
          WHERE id = r_pkg.id
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
$_$  -- FD: pg:ws:50_pkg.sql / 141 --
  BEGIN
    RAISE NOTICE 'TODO: function needs code';
    RETURN NULL;
  END
$_$;

/* ------------------------------------------------------------------------- */
\qecho '-- FD: pg:ws:50_pkg.sql / 149 --'
