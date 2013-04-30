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

    Тесты
*/

/* ------------------------------------------------------------------------- */
SELECT ws.test('prop_attr_system');
SELECT * FROM cfg.prop_attr_system('db', 1, 'ws.daemon.db.sql.0');

/* ------------------------------------------------------------------------- */
SELECT ws.test('prop_info');
SELECT * FROM cfg.prop_info('ws.daemon.db.sql', true);

/* ------------------------------------------------------------------------- */
SELECT ws.test('prop_owner_attr');
SELECT * FROM cfg.prop_owner_attr('cache', 4);

/* ------------------------------------------------------------------------- */
SELECT ws.test('prop_value_list');
SELECT * FROM cfg.prop_value_list('fe', 2, 'ws.daemon.fe', false, '2013-01-01', 'FE.', '%s');

SELECT * FROM cfg.prop_value_list('fe', 1, 'ws.daemon.log.debug');

/* ------------------------------------------------------------------------- */
SELECT ws.test('prop_group_value_list');
SELECT * FROM cfg.prop_group_value_list('db', 0, 'ws.daemon.db', false, '2013-01-01', 'DB.', '%s'); 

SELECT * FROM cfg.prop_group_value_list('fe', 1) WHERE code LIKE 'ws.daemon.log.debug.%';

/* ------------------------------------------------------------------------- */
SELECT ws.test('prop_value_edit');
INSERT INTO cfg.prop_group (pogc, sort, is_id_required, name) VALUES ('test', 1, FALSE, 'Группа для теста');
INSERT INTO cfg.prop_owner (pogc, poid, sort, name) VALUES ('test',  1,  1,  'Владелец для свойства');
INSERT INTO cfg.prop (code, pogc_list, def_value, name) VALUES ('test.code', ARRAY['test'], '', 'Свойство для теста');
SELECT cfg.prop_value_edit('test', 1, 'test.code', 'test_value', '2000-01-01');
SELECT * FROM wsd.prop_value WHERE pogc = 'test';

/* ------------------------------------------------------------------------- */

