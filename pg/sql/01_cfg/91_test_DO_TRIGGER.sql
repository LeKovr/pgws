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

    Тесты на выполнение пакетом CFG процедур, являющихся триггерами
*/

/* ------------------------------------------------------------------------- */
\set a_code 'test_code'

/* ------------------------------------------------------------------------- */
 SELECT ws.test('cfg.prop_calc_is_mask');
 INSERT INTO cfg.prop (code, pkg, pogc_list, def_value, name) VALUES (:'a_code', 'cfg', ARRAY['db'], '000', 'тест');
 SELECT * FROM cfg.prop WHERE code=:'a_code';

/* ------------------------------------------------------------------------- */
 DELETE FROM cfg.prop WHERE code=:'a_code';
