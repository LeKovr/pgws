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

    Тесты на заполнение пакетом АСС
*/

/* ------------------------------------------------------------------------- */
SELECT ws.test('ws.class');
SELECT *
  FROM ws.class 
  WHERE id IN (acc.const_class_id(),acc.const_team_class_id(),acc.const_system_class_id())
  ORDER BY id
;
SELECT ws.test('ws.class_status');
SELECT *
  FROM ws.class_status
  WHERE class_id IN (acc.const_class_id(),acc.const_team_class_id(),acc.const_system_class_id())
  ORDER BY class_id,id
;
SELECT ws.test('ws.class_action');
SELECT * 
  FROM ws.class_action
  WHERE class_id IN (acc.const_class_id(),acc.const_team_class_id(),acc.const_system_class_id()) AND id<9
  ORDER BY class_id,id
;
SELECT ws.test('ws.class_status_action');
SELECT * 
  FROM ws.class_status_action 
  WHERE class_id IN (acc.const_class_id(),acc.const_team_class_id(),acc.const_system_class_id()) AND action_id<9
  ORDER BY class_id,status_id,action_id
;
SELECT ws.test('ws.class_acl');
SELECT * 
  FROM ws.class_acl
  WHERE class_id IN (acc.const_class_id(),acc.const_team_class_id(),acc.const_system_class_id()) AND id<5
  ORDER BY class_id,id
;
SELECT ws.test('ws.class_action_acl');
SELECT *
  FROM ws.class_action_acl 
  WHERE class_id IN (acc.const_class_id(),acc.const_team_class_id(),acc.const_system_class_id()) AND action_id<9
  ORDER BY class_id,action_id,acl_id
;
SELECT ws.test('acc.team_link');
SELECT *
  FROM acc.team_link
  WHERE id IN (acc.const_team_link_id_owner(),acc.const_team_link_id_other(),acc.const_team_link_id_system())
  ORDER BY id
;
SELECT ws.test('acc.account_contact_type');
SELECT * 
  FROM acc.account_contact_type
  WHERE id IN (acc.const_account_contact_mobile_phone_id(),acc.const_account_contact_email_id())
  ORDER BY id
;
SELECT ws.test('cfg.prop_group');
SELECT * 
  FROM cfg.prop_group 
  WHERE pogc IN (acc.const_team_group_prop(),acc.const_account_group_prop())
  ORDER BY name
;
SELECT ws.test('cfg.prop');
SELECT code,pkg,is_mask,def_value,name,anno,has_log 
  FROM cfg.prop
  WHERE pkg LIKE 'acc'
  ORDER BY code
;
SELECT ws.test('wsd.pkg_default_protected');
SELECT pkg, wsd_rel, wsd_col, func, schema  
  FROM wsd.pkg_default_protected
  WHERE schema LIKE 'acc'
;
SELECT ws.test('ws.pkg_required_by');
SELECT * 
  FROM ws.pkg_required_by
  WHERE required_by LIKE 'acc'
  ORDER BY code
;
SELECT ws.test('ws.method');
SELECT code,code_real,name
  FROM ws.method 
  WHERE pkg LIKE 'acc'
  ORDER BY code
;
SELECT ws.test('i18n_def.error');
SELECT *
  FROM i18n_def.error
  WHERE code IN (acc.const_error_password(), acc.const_error_login(), acc.const_error_status(), acc.const_error_class()
               , acc.const_error_email_validation(), acc.const_error_mobile_phone_validation(), acc.const_error_passwords_match()
               , acc.const_error_badsid())
  ORDER BY code
;
SELECT ws.test('job.handler');
SELECT id, pkg, code, def_prio, def_status_id, dust_days, is_run_allowed, is_todo_allowed, name    
  FROM job.handler
  WHERE pkg LIKE 'acc'
;
SELECT ws.test('ws.dt_facet');
SELECT * 
  FROM ws.dt_facet
  WHERE code ~ 'acc.*'
;
