/*
  -- FD: acc:acc:00_cleanup.sql / 2 --

  PGWS. Удаление данных из схемы ws

*/
/* ------------------------------------------------------------------------- */
\qecho '-- FD: acc:acc:00_cleanup.sql / 8 --'

DELETE FROM ws.page_data             WHERE code LIKE 'acc%' OR up_code='acc';

DELETE FROM ws.page_data WHERE code IN ('login','logout');

DELETE FROM ws.method           WHERE code_real LIKE 'acc.%' OR code_real LIKE 'acc::%';
--class_id IN (6,7,8) OR code ~ E'(tmpl|tender|offer)\.';


-- pg_cs('z_wikiformat')
DELETE FROM ws.dt_part          WHERE id IN (SELECT id FROM ws.dt WHERE code LIKE 'acc.%');
DELETE from ws.dt               WHERE code LIKE 'acc.%';

-- DELETE FROM ws.cache WHERE id IN (15, 16, 17);
