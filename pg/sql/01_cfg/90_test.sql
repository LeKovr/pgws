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
-- begin add data
INSERT INTO cfg.prop_group (pogc, sort, is_id_required, name) VALUES ('test', 1, FALSE, 'Группа для теста');
INSERT INTO cfg.prop_owner (pogc, poid, sort, name) VALUES ('test',  1,  1,  'Владелец для свойства');
INSERT INTO cfg.prop (code, pogc_list, def_value, name) VALUES ('test.code.one',   ARRAY['test'], '', 'Первое свойство для теста');
INSERT INTO cfg.prop (code, pogc_list, def_value, name) VALUES ('test.code.two',   ARRAY['test'], '', 'Второе свойство для теста');
INSERT INTO cfg.prop (code, pogc_list, def_value, name) VALUES ('test.code.three', ARRAY['test'], '', 'Третье свойство для теста');

/* ------------------------------------------------------------------------- */
SELECT ws.test('prop_value_edit');
SELECT cfg.prop_value_edit('test', 1, 'test.code.one',   'one',   '2000-01-01');
SELECT cfg.prop_value_edit('test', 1, 'test.code.two',   'two',   '2000-01-01');
SELECT cfg.prop_value_edit('test', 1, 'test.code.three', 'three', '2000-01-01');
SELECT * FROM wsd.prop_value WHERE pogc = 'test' ORDER BY 1,2,3;
-- end add data

/* ------------------------------------------------------------------------- */
SELECT ws.test('prop_attr_system');
SELECT * FROM cfg.prop_attr_system('test', 1, 'test.code.one');

/* ------------------------------------------------------------------------- */
SELECT ws.test('prop_info');
SELECT * FROM cfg.prop_info('test.code.one', true);

/* ------------------------------------------------------------------------- */
SELECT ws.test('prop_owner_attr');
SELECT * FROM cfg.prop_owner_attr('test', 1);

/* ------------------------------------------------------------------------- */
SELECT ws.test('prop_value_list');
SELECT * FROM cfg.prop_value_list('test', 1, 'test.code', false, '2013-01-01', 'T.', '%s') ORDER BY 1,2,3;

SELECT * FROM cfg.prop_value_list('test', 1, 'test.code') ORDER BY 1,2,3;

/* ------------------------------------------------------------------------- */
SELECT ws.test('prop_group_value_list');
SELECT * FROM cfg.prop_group_value_list('test', 0, 'test.code', false, '2013-01-01', 'T.', '%s') ORDER BY 1,2,3; 

SELECT * FROM cfg.prop_group_value_list('test', 1) WHERE code LIKE 'test.code.%' ORDER BY 1,2,3;

/* ------------------------------------------------------------------------- */
-- begin deleted data
SELECT cfg.prop_cleanup_by_code(ARRAY['test.code.one']);
SELECT cfg.prop_cleanup_without_value(ARRAY['test']);
-- end deleted data
