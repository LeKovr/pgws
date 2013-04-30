/*
  FD: 11_crmisc.sql / 2 --

  PGWS. Вспомогательные функции

*/

/* ------------------------------------------------------------------------- */

CREATE OR REPLACE FUNCTION const_valid_from_date() RETURNS DATE IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT '2000-01-01'::DATE
$_$;
SELECT pg_c('f', 'const_valid_from_date', 'Константа: Дата начала действия настройки без логирования');

/* ------------------------------------------------------------------------- */
