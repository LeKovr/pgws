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

    Тесты работы со справочниками
*/

/* ------------------------------------------------------------------------- */
\set TZ ws.const_ref_code_timezone()

SELECT ws.test('ref');

/* ------------------------------------------------------------------------- */

\set REF 'ws.test'
\set ACL ws.const_ref_acls_internal()
\set UPD = '2010-01-01'

/* ------------------------------------------------------------------------- */
-- создание справочника
INSERT INTO i18n_def.ref (code, name) VALUES
  (:'REF', 'Тестовый справочник')
;
SELECT * FROM ws.ref(:'REF', :ACL);

/* ------------------------------------------------------------------------- */
-- добавление значений
SELECT ws.ref_op(:'REF', 'code1', 1, 'Name1',  :ACL);
SELECT ws.ref_op(:'REF', 'code3', 3, 'Name3',  :ACL);
SELECT ws.ref_op(:'REF', 'code2', 2, 'Name2',  :ACL);

SELECT * FROM ws.ref_item(:'REF', a__acl := :ACL);

-- операции
SELECT ws.ref_op(:'REF', 'code3', 3, 'Name3 modified',  :ACL, a_op := ws.const_ref_op_update(), a_updated_at := :'UPD');
SELECT ws.ref_op(:'REF', 'code2', 0, 'N/A',             :ACL, a_op := ws.const_ref_op_delete(), a_updated_at := :'UPD');
SELECT ws.ref_sync_complete(:'REF');

SELECT * FROM ws.ref_item(:'REF', a__acl := :ACL);

SELECT ws.test('ref_log');
SELECT * FROM ws.ref_log(:'REF', NULL, ws.const_lang_default(), :'UPD', :ACL) ORDER BY 1,2,3;

-- Error trapping
-- http://www.ienablemuch.com/2010/12/return-results-from-anonymous-code.html
DO
$_$
BEGIN
 
 DROP TABLE IF EXISTS _test_result;
 CREATE TEMPORARY TABLE _test_result (id int, name text);

 BEGIN
  SELECT ws.ref_sync_complete('unknown.ref');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      INSERT INTO _test_result VALUES (1, 'sync_complete');
  END;
 
  -- TODO: аналогично примеру выше проверить остальные EXCEPTION ф-й из 53_ref.sql
END;
$_$;
 
SELECT * FROM _test_result; -- the temporary table will continue to exist on individual Postgres session
DROP TABLE _test_result;
