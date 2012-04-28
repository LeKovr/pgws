/*
  -- FD: apidoc:ws:00_cleanup.sql / 2 --

  PGWS. Удаление данных из схемы ws

*/
/* ------------------------------------------------------------------------- */
\qecho '-- FD: apidoc:ws:00_cleanup.sql / 8 --'

DELETE FROM ws.page_data             WHERE code LIKE 'api%';
