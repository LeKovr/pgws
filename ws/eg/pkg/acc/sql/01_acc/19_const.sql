/*
  FD: 11_crmisc.sql / 2 --

  PGWS. Вспомогательные функции

*/
/* ------------------------------------------------------------------------- */

SET LOCAL search_path = acc, ws, i18n_def, public;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_unknown() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 1
$_$;
SELECT pg_c('f', 'const_status_id_unknown', 'Константа: ID статуса для неизвестного аккаунта');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_active() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 2
$_$;
SELECT pg_c('f', 'const_status_id_active', 'Константа: ID статуса активного аккаунта');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_admin_psw_default() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'pgws'::TEXT
$_$;
SELECT pg_c('f', 'const_admin_psw_default', 'Константа: Первичный пароль администратора');


/* ------------------------------------------------------------------------- */
