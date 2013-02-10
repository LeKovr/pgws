/*

  Внутренние константы пакета. Используются хранимым кодом.
  См. также:
    select * from ws.pg_const WHERE schema='bt';
*/

/* ------------------------------------------------------------------------- */
SET LOCAL search_path = fs, ws, i18n_def, public;
/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_file_format_any() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT '*'::TEXT
$_$;
SELECT pg_c('f', 'const_file_format_any', 'Файл любого формата');

/* ------------------------------------------------------------------------- */
