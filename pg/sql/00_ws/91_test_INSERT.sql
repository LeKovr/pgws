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

    Тесты на заполнение пакетом WS
*/

/* ------------------------------------------------------------------------- */
SELECT ws.test('ws.class');
SELECT * FROM ws.class WHERE id=ws.const_info_class_id()
;
SELECT ws.test('ws.class_status');
SELECT * FROM ws.class_status WHERE class_id=ws.const_info_class_id();

SELECT ws.test('ws.class_action');
SELECT * FROM ws.class_action WHERE class_id=ws.const_info_class_id();

SELECT ws.test('ws.class_status_action');
SELECT * FROM ws.class_status_action WHERE class_id=ws.const_info_class_id();

SELECT ws.test('ws.class_acl');
SELECT * FROM ws.class_acl WHERE class_id=ws.const_info_class_id();

SELECT ws.test('ws.class_action_acl');
SELECT * FROM ws.class_action_acl WHERE class_id=ws.const_info_class_id();

SELECT ws.test('ws.method');
SELECT code,code_real,name FROM ws.method where code ~ '^ws.' ORDER BY code;

SELECT ws.test('ws.method_rv_format');
SELECT * FROM ws.method_rv_format ORDER BY id;

SELECT ws.test('ws.server');
SELECT * FROM ws.server;

SELECT ws.test('i18n_def.error');
SELECT * FROM i18n_def.error WHERE code ~ '^Y0(0|1)' ORDER BY code;

SELECT ws.test('i18n_def.ref');
SELECT * FROM i18n_def.ref WHERE code = 'timezone'; -- только этот есть в ws

SELECT ws.test('wsd.pkg_default_protected');
SELECT pkg, wsd_rel, wsd_col, func, schema FROM wsd.pkg_default_protected WHERE schema LIKE 'ws' ORDER BY 2,3;
