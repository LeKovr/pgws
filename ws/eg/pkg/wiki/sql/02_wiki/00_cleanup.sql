/*
  -- FD: wiki:wiki:00_cleanup.sql / 2 --

  PGWS. Удаление данных из схемы ws

*/
/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:00_cleanup.sql / 8 --'

DELETE FROM ws.page_data             WHERE code LIKE 'wiki%' OR up_code='wiki'; -- lass_id IN (6,7,8) OR code ~ E'(tmpl|tender|offer)\.';

DELETE FROM ws.method           WHERE code_real LIKE 'wiki.%' OR code_real LIKE 'Wiki::%';
--class_id IN (6,7,8) OR code ~ E'(tmpl|tender|offer)\.';

DELETE FROM ws.class_action WHERE class_id IN (5);
DELETE FROM ws.class_status WHERE class_id IN (5);
DELETE FROM ws.class WHERE id IN (5);

-- pg_cs('z_wikiformat')
DELETE FROM ws.dt_part          WHERE id IN (SELECT id FROM ws.dt WHERE code LIKE 'wiki.%');
DELETE from ws.dt               WHERE code LIKE 'wiki.%';

-- DELETE FROM ws.cache WHERE id IN (15, 16, 17);

DELETE FROM ws.error_data WHERE code ~ E'^Y99';

/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:00_cleanup.sql / 28 --'
