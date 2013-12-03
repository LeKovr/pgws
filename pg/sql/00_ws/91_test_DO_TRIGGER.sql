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

    Тесты на выполнение пакетом WS процедур, являющихся триггерами
*/

/* ------------------------------------------------------------------------- */
\set a_code 'test_code'
\set a_parent_code 'test_code' 
\set a_new_parent_code 'text'
\set a_anno 'тестовый вариант'
\set a_new_type 'ws.d_code'
\set a_name_func 'ws.z_test_func'

 CREATE OR REPLACE FUNCTION ws.test_func(a_id ws.d_id32 DEFAULT 0) RETURNS INT STABLE LANGUAGE 'sql' AS
 $_$
   SELECT 1::INT;
 $_$;
 SELECT ws.pg_c('f', 'ws.test_func', 'тестовая ');

/* ------------------------------------------------------------------------- */
 SELECT ws.test('ws.method_insupd_trigger');
 INSERT INTO ws.method (code, class_id, action_id, cache_id, rvf_id) VALUES ('ws.test_func', 2, 1, 2, 5);
 SELECT * FROM ws.dt_part WHERE dt_code=:'a_name_func';
 SELECT * FROM ws.dt WHERE code=:'a_name_func';

/* ------------------------------------------------------------------------- */
 SELECT ws.test('ws.dt_insupd_trigger');
 INSERT INTO ws.dt (code, parent_code, anno) VALUES (:'a_code', :'a_parent_code', :'a_anno');
 SELECT * FROM ws.dt WHERE code=:'a_code';
 UPDATE ws.dt SET parent_code=:'a_new_parent_code'  WHERE code=:'a_code';
 SELECT * FROM ws.dt WHERE code=:'a_code';

/* ------------------------------------------------------------------------- */
 SELECT ws.test('ws.dt_part_insupd_trigger');
 SELECT * FROM ws.dt_part WHERE dt_code=:'a_name_func';
 UPDATE ws.dt_part SET parent_code=:'a_new_type'  WHERE dt_code=:'a_name_func';
 SELECT * FROM ws.dt_part WHERE dt_code=:'a_name_func';
 
/* ------------------------------------------------------------------------- */
 SELECT ws.test('ws.method_del_trigger');
 DELETE FROM ws.method WHERE code='ws.test_func';
 SELECT * FROM ws.dt_part WHERE dt_code=:'a_name_func';
 SELECT * FROM ws.dt WHERE code=:'a_name_func';

/* ------------------------------------------------------------------------- */
  SELECT ws.test('ws.dt_facet_insupd_trigger');
  INSERT INTO ws.dt_facet (code, facet_id, value, anno) VALUES (:'a_code', ws.facet_id('length'), 15, 'TEST');
  SELECT * FROM ws.dt_facet WHERE code=:'a_code';

/* ------------------------------------------------------------------------- */
 SELECT ws.test('ws.dt_part_del_trigger');
 INSERT INTO ws.dt_part (dt_code, part_id, code, parent_code, anno) VALUES 
(:'a_code', 1, 'id', ws.dt_code(:'a_code'), 'ID компании');
 SELECT * FROM ws.dt_part WHERE dt_code=:'a_code';
 SELECT * FROM ws.dt WHERE code=:'a_code';
 DELETE FROM ws.dt_part WHERE dt_code=:'a_code';
 SELECT * FROM ws.dt_part WHERE dt_code=:'a_code';
 SELECT * FROM ws.dt WHERE code=:'a_code';
 
/* ------------------------------------------------------------------------- */
  SELECT ws.test('ws.page_insupd_trigger');
  INSERT INTO i18n_def.page (code, up_code, class_id, action_id, sort, uri, tmpl, name) VALUES
    ('main', NULL, 2, 1, 0, '$', 'app/index', 'API');
  SELECT code, class_id, action_id, sort, uri, tmpl, is_hidden, uri_re FROM ws.page_data WHERE code='main';

/* ------------------------------------------------------------------------- */
 DELETE FROM ws.page_data WHERE code='main';
 DROP function ws.test_func(ws.d_id32); 
