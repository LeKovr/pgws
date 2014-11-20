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

    Тесты на выполнение пакетом WS процедур, являющихся методами
*/

/* ------------------------------------------------------------------------- */
SET search_path TO ws, i18n_def, public;
\set a_class_id 2
\set a_status_id 1
\set a_action_id 1
\set a_acl_ids '{1}'
\set a_acl_id 1
\set a_code 'info'
\set a_dt_code 'double'
\set a_facet_code 'oid'
\set a_part_code 'ws.dt'
\set a_part_id 1
\set a_err_code 'Y0003'
\set a_facet_id 3
\set a_method_code 'ws.facet'
\set a_code_lookup 'class'
\set a_rvf_id 3
\set a_page_code 'temp_root_main'

/* ------------------------------------------------------------------------- */
 SELECT ws.test('ws.acls_eff');
 SELECT ws.acls_eff(:a_class_id, :a_status_id, :a_action_id, :'a_acl_ids');

 SELECT ws.test('ws.acls_eff_ids');
 SELECT ws.acls_eff_ids(:a_class_id, :a_status_id, :a_action_id, :'a_acl_ids');

 SELECT ws.test('ws.class');
 SELECT ws.class(:a_class_id);

 SELECT ws.test('ws.class_acl');
 SELECT ws.class_acl(:a_class_id,:a_acl_id);

 SELECT ws.test('ws.class_action');
 SELECT ws.class_action(:a_class_id,:a_action_id);

 SELECT ws.test('ws.class_id');
 SELECT ws.class_id(:'a_code');

 SELECT ws.test('ws.class_status');
 SELECT ws.class_status(:a_class_id,:a_status_id);

 SELECT ws.test('ws.class_status_action_acl');
 SELECT ws.class_status_action_acl(:a_class_id, :a_status_id, :a_action_id, :a_acl_id);

 SELECT ws.test('ws.dt');
 SELECT ws.dt(:'a_dt_code');

 SELECT ws.test('ws.dt_facet');
 SELECT ws.dt_facet(:'a_facet_code');

 SELECT ws.test('ws.dt_part');
 SELECT * from ws.dt_part(:'a_part_code', :a_part_id);

 SELECT ws.test('ws.error_info');
 SELECT ws.error_info(:'a_err_code');

 SELECT ws.test('ws.facet');
 SELECT ws.facet(:a_facet_id);

 SELECT ws.test('ws.method_by_action');
 SELECT code, class_id, action_id, code_real, name 
   FROM ws.method_by_action(:a_class_id,:a_action_id) 
   WHERE code ~ '^ws.'
   ORDER BY code
 ;

 SELECT ws.test('ws.method_by_code');
 SELECT ws.method_by_code(:'a_method_code');

 SELECT ws.test('ws.method_lookup');
 SELECT ws.method_lookup(:'a_code_lookup') ;

 SELECT ws.test('ws.method_rvf');
 SELECT id,name FROM ws.method_rvf(:a_rvf_id);

 INSERT INTO i18n_def.page (code, up_code, class_id, action_id, sort, uri, tmpl, name) VALUES
  (:'a_page_code', NULL, 2, 1, 0, :'a_page_code' ||'$', 'app/index', 'API');
 INSERT INTO i18n_def.page (code, up_code, class_id, action_id, sort, uri, tmpl, name) VALUES
  ('login', :'a_page_code', 2, 1, 1, 'login$', 'acc/login', 'Вход');

 SELECT ws.test('ws.page_by_action');
 SELECT code, up_code, class_id, action_id, sort, uri, tmpl, is_hidden, uri_re, uri_fmt, pkg, name, req, args, group_name 
   FROM ws.page_by_action(:a_class_id,:a_action_id) 
 ;

 SELECT ws.test('ws.page_by_code');
 SELECT code, uri_re, uri_fmt, pkg, name, req 
   FROM ws.page_by_code(:'a_page_code')
 ;

 SELECT ws.test('ws.page_by_uri');
 SELECT code, uri_re, uri_fmt, pkg, name, req 
   FROM ws.page_by_uri(:'a_page_code')
 ;

 SELECT ws.test('ws.page_childs');
 SELECT code, up_code, class_id, action_id, sort, uri, tmpl, is_hidden, uri_re, uri_fmt, pkg, name, req, args, group_name
   FROM ws.page_childs(:'a_page_code')
 ;

 SELECT ws.test('ws.page_path');
 SELECT ws.page_path(:'a_page_code');

 SELECT ws.test('ws.page_tree');
 SELECT ws.page_tree(:'a_page_code');

 DELETE FROM ws.page_data WHERE code='login';
 DELETE FROM ws.page_data WHERE code=:'a_page_code';
