/*
  -- FD: app:app:00_cleanup.sql / 2 --

  PGWS. Удаление данных из схемы ws

*/
/* ------------------------------------------------------------------------- */
\qecho '-- FD: app:app:00_cleanup.sql / 8 --'

DELETE FROM ws.page_data             WHERE code = 'api.test';

DELETE FROM ws.method           WHERE code = 'info.add';
--class_id IN (6,7,8) OR code ~ E'(tmpl|tender|offer)\.';


-- pg_cs('z_wikiformat')
DELETE FROM ws.dt_part          WHERE id IN (SELECT id FROM ws.dt WHERE code LIKE 'app.%');
DELETE from ws.dt               WHERE code LIKE 'app.%';

-- DELETE FROM ws.cache WHERE id IN (15, 16, 17);
