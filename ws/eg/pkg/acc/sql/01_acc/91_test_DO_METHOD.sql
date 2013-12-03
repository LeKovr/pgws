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

    Тесты на выполнение пакетом АСС процедур, являющихся методами
*/

/* ------------------------------------------------------------------------- */
\set a_account_id -1
\set a_team_id -2
\set a_role_id -3
\set a_perm_id -4
\set a__sid '\'; \''
\set a__ip 'test_ip'
\set a_login 'test_method'
\set a_psw '1234'
\set a_code 'anno'
\set a_type_id 2
\set a_value 'gav@email.com'
\set a_all 'true'
\set a_psw_old '5678yuYU'
\set a_psw_new '5678yuYU'
\set a_psw_new_repeat '5678yuYU'
\set a_file_code ''
\set a_team_only 'true'
\set save_stamp 'true'
\set a_name 'ACC-Test'
\set a_object_team_id -2
\set a_account_team_id -2
\set id 'account'
\set a_account_code 'abp.person.gender'
\set a_team_code 'abp.name.short'

 INSERT INTO wsd.team (id, name, status_id) VALUES (:a_team_id, :'a_name', acc.const_team_status_id_active()) ;
 INSERT INTO wsd.role (id, team_id, name,anno) VALUES (:a_role_id, :a_team_id, 'test','тест') ;
 INSERT INTO wsd.account (id, login, psw,name) VALUES (:a_account_id,:'a_login', :'a_psw', :'a_name');
 INSERT INTO wsd.account_team (account_id, team_id, role_id, is_default) VALUES (:a_account_id, :a_team_id, :a_role_id, TRUE) ;
 INSERT INTO wsd.permission (id, team_id, name, pkg) VALUES (:a_perm_id, :a_team_id, 'test', 'acc');
 INSERT INTO wsd.role_permission (role_id, perm_id) VALUES (:a_role_id, :a_perm_id);
 INSERT INTO wsd.permission_acl (perm_id, class_id, link_id, team_link_id, acl_id) VALUES
  (:a_perm_id, acc.const_class_id(), 1, 1, (SELECT id FROM ws.class_acl WHERE class_id = acc.const_class_id() AND name ~ 'Просмотр настроек'))
 ;
 INSERT INTO wsd.prop_value (pogc, poid, code, valid_from, value) VALUES
        (acc.const_account_group_prop(), :a_account_id, :'a_account_code', cfg.const_valid_from_date(), 'male');
 INSERT INTO wsd.prop_value (pogc, poid, code, valid_from, value) VALUES
        (acc.const_team_group_prop(), :a_team_id, :'a_team_code', cfg.const_valid_from_date(), 'test_team');

 SELECT ws.test('acc.account_contact_add');
 SELECT acc.account_contact_add(:a_account_id,:a_type_id,:'a_value');

 SELECT ws.test('acc.account_contact_type_attr');
 SELECT acc.account_contact_type_attr(:a_type_id);

 SELECT ws.test('acc.account_contact_view');
 SELECT name, account_id, contact_type_id, value from acc.account_contact_view(:a_account_id,:'a_all');

 SELECT ws.test('acc.account_link_id');
 SELECT acc.account_link_id(:a_account_id,:'a__sid');

 SELECT ws.test('acc.account_lookup');
 SELECT id, status_id, login, psw, name, is_psw_plain, is_ip_checked from acc.account_lookup('Test');

 SELECT ws.test('acc.login');
 SELECT  account_id, role_id, team_id, sid, ip, is_ip_checked from acc.login(:'a__ip',:'a_login',:'a_psw',:'a__sid');

 SELECT ws.test('acc.account_password_change');
 SELECT acc.account_password_change(:a_account_id,:'a_psw_new',:'a_psw_new_repeat', TRUE);

 SELECT ws.test('acc.account_password_change_own');
 SELECT acc.account_password_change_own(:a_account_id,:'a_psw_old',:'a_psw_new',:'a_psw_new_repeat', TRUE);

 SELECT ws.test('acc.sid_info');
 SELECT  account_id, role_id, team_id, sid, ip, is_ip_checked from acc.sid_info(:'a__sid',:'a__ip',:'save_stamp');

 SELECT ws.test('acc.account_permission');
 SELECT * FROM acc.account_permission(:a_account_id,:a_team_id) WHERE id=:a_perm_id;

 SELECT ws.test('acc.account_profile');
 SELECT status_id, login, psw, name, is_psw_plain, is_ip_checked from acc.account_profile(:a_account_id);

 SELECT ws.test('acc.account_status');
 SELECT acc.account_status(:a_account_id);

 SELECT ws.test('acc.account_team');
 SELECT acc.account_team(:a_account_id);

 SELECT ws.test('acc.account_team_link_id');
 SELECT acc.account_team_link_id(:a_account_id,:a_team_id);

 SELECT ws.test('acc.logout');
 SELECT acc.logout(:'a__sid');

 SELECT ws.test('acc.prop_account_isv');
 SELECT acc.prop_account_isv(:a_account_id,'show') ;

 SELECT ws.test('acc.prop_attr_account_abp');
 SELECT * from acc.prop_attr_account_abp(:a_account_id) WHERE pkg='acc' ORDER BY code;

 SELECT ws.test('acc.prop_attr_account_isv');
 SELECT * from acc.prop_attr_account_isv(:a_account_id) WHERE pkg='acc' ORDER BY code;

 SELECT ws.test('acc.prop_attr_team_abp');
 SELECT code, pkg, def_value, name, anno, pogc, poid, owner_name, value 
   FROM acc.prop_attr_team_abp(:a_team_id) 
   WHERE pkg='acc' 
   ORDER BY code;

 SELECT ws.test('acc.prop_attr_team_isv');
 SELECT code, pkg, def_value, name, anno, pogc, poid, owner_name, value 
   FROM acc.prop_attr_team_isv(:a_team_id) 
   WHERE pkg='acc' 
   ORDER BY code;

 SELECT ws.test('acc.prop_history_account');
 SELECT acc.prop_history_account(:a_account_id,:'a_account_code');

 SELECT ws.test('acc.prop_history_team');
 SELECT acc.prop_history_team(:a_team_id, :'a_team_code');


 SELECT ws.test('acc.system_link_id');
 SELECT acc.system_link_id(:a_account_id,:'a__sid');

 SELECT ws.test('acc.system_permission_role');
 SELECT acc.system_permission_role(:a_perm_id);

 SELECT ws.test('acc.system_permission_view');
 SELECT * FROM acc.system_permission_view()  WHERE id=:a_perm_id;

 SELECT ws.test('acc.system_role');
 SELECT * FROM acc.system_role()  WHERE id=:a_role_id;

 SELECT ws.test('acc.system_role_permission');
 SELECT acc.system_role_permission(:a_role_id);

 SELECT ws.test('acc.system_status');
 SELECT acc.system_status();

 SELECT ws.test('acc.system_team_link_id');
 SELECT acc.system_team_link_id(:a_account_id,:a_team_id);

 SELECT ws.test('acc.team_account_attr');
 SELECT status_id, login, psw, name, is_psw_plain, is_ip_checked from acc.team_account_attr(:a_team_id,:a_account_id);

 SELECT ws.test('acc.team_by_name');
 SELECT status_id, name from acc.team_by_name('test_team');

 SELECT ws.test('acc.team_link_id');
 SELECT acc.team_link_id(:a_account_id,:'a__sid');

 SELECT ws.test('acc.team_lookup');
 SELECT id, status_id,  name from acc.team_lookup('test_team');

 SELECT ws.test('acc.team_permission');
 SELECT acc.team_permission(:a_team_id,:a_role_id);

 SELECT ws.test('acc.team_profile');
 SELECT status_id,  name from acc.team_profile(:a_team_id);

 SELECT ws.test('acc.team_role');
 SELECT acc.team_role(:a_team_id,:a_role_id,:'a_team_only');

 SELECT ws.test('acc.team_role_members');
 SELECT id, status_id, login, psw, name, is_psw_plain, is_ip_checked from acc.team_role_members(:a_team_id,:a_role_id);

 SELECT ws.test('acc.team_role_number');
 SELECT acc.team_role_number(:a_team_id,:a_role_id);

 SELECT ws.test('acc.team_status');
 SELECT acc.team_status(:a_team_id);

 SELECT ws.test('acc.team_team_link_id');
 SELECT acc.team_team_link_id(:a_object_team_id,:a_account_team_id);

 DELETE FROM wsd.permission_acl  WHERE perm_id=:a_perm_id ;
 DELETE FROM wsd.role_permission  WHERE role_id=:a_role_id ;
 DELETE FROM wsd.permission  WHERE id=:a_perm_id ;
 DELETE FROM wsd.account_team  WHERE account_id=:a_account_id ;
 DELETE FROM wsd.session  WHERE role_id=:a_role_id ;
 DELETE FROM wsd.role  WHERE id=:a_role_id ;
 DELETE FROM wsd.team  WHERE id=:a_team_id ; 
 DELETE FROM wsd.account_contact  WHERE account_id=:a_account_id ;
 DELETE FROM wsd.account  WHERE id=:a_account_id ;
 DELETE FROM wsd.prop_value  WHERE poid=:a_account_id ;
 DELETE FROM wsd.prop_value  WHERE poid=:a_team_id ;
