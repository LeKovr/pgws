/*
  FD: 11_crmisc.sql / 2 --

  PGWS. Вспомогательные функции

*/
/* ------------------------------------------------------------------------- */

SET LOCAL search_path = acc, ws, i18n_def, public;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_active() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 4
$_$;
SELECT pg_c('f', 'const_status_id_active', 'Константа: ID статуса активного аккаунта');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_active_locked() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 5
$_$;
SELECT pg_c('f', 'const_status_id_active', 'Константа: ID статуса активного аккаунта');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_role_id_guest() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 1
$_$;
SELECT pg_c('f', 'const_role_id_guest', 'Константа: ID роли неавторизованного пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_role_id_user() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 2
$_$;
SELECT pg_c('f', 'const_role_id_user', 'Константа: ID роли авторизованного пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_admin_psw_default() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'pgws'::TEXT
$_$;
SELECT pg_c('f', 'const_admin_psw_default', 'Константа: Первичный пароль администратора');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_password() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y0301'::TEXT
$_$;
SELECT pg_c('f', 'const_error_password', 'Константа: Код ошибки авторизации с неправильным паролем');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_login() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y0302'::TEXT
$_$;
SELECT pg_c('f', 'const_error_login', 'Константа: Код ошибки авторизации с неизвестным логином');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_status() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y0303'::TEXT
$_$;
SELECT pg_c('f', 'const_error_status', 'Константа: Код ошибки авторизации с недопустимым статусом');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_class_id() RETURNS ws.d_class IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 11::ws.d_class;
$_$;
SELECT pg_c('f', 'const_class_id', 'Константа: ID класса account');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_team_class_id() RETURNS ws.d_class IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 12::ws.d_class;
$_$;
SELECT pg_c('f', 'const_team_class_id', 'Константа: ID класса team');

/* ------------------------------------------------------------------------- */
