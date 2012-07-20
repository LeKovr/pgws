/*
  FD: 11_crmisc.sql / 2 --

  PGWS. Вспомогательные функции

*/
/* ------------------------------------------------------------------------- */

SET LOCAL search_path = job, ws, i18n_def, public;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_pkg() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'job'::text
$_$;
SELECT pg_c('f', 'const_pkg', 'Константа: Кодовое имя пакета "job"');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_prop_group_id_system() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 1
$_$;
SELECT pg_c('f', 'const_prop_group_id_system', 'Константа: ID группы свойств "Система"');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_prop_group_id_branch() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 2
$_$;
SELECT pg_c('f', 'const_prop_group_id_branch', 'Константа: ID группы свойств "Представительство"');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_prop_group_id_targroup() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 3
$_$;
SELECT pg_c('f', 'const_prop_group_id_targroup', 'Константа: ID группы свойств "Тарифная группа"');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_prop_group_id_tariff() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 4
$_$;
SELECT pg_c('f', 'const_prop_group_id_tariff', 'Константа: ID группы свойств "Тариф"');


/* ------------------------------------------------------------------------- */
