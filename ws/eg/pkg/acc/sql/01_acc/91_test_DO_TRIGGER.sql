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

    Тесты на выполнение пакетом АСС процедур, являющихся триггерами
*/

/* ------------------------------------------------------------------------- */
\set a_id -1
\set a_team_id -2
\set a_login 'test_method'
\set a_psw '1234'
\set a_name 'reg_name'
\set a_email 'gav@email.com'
\set a_new_email 'new_gav@email.com'
\set a_fax '1234456'
\set a_phone '7890123'

 INSERT INTO wsd.team (id, name, status_id) VALUES (:a_team_id, :'a_name', acc.const_team_status_id_active()) ;
 INSERT INTO wsd.account (id, login, psw, name) VALUES (:a_id,:'a_login', :'a_psw', :'a_name');

 SELECT ws.test('add_verified_date');
 SELECT acc.account_contact_add(:a_id,2,:'a_email');
 SELECT account_id , contact_type_id ,     value FROM wsd.account_contact WHERE account_id=:a_id;
 DELETE FROM wsd.account_contact  WHERE account_id=:a_id;

 SELECT ws.test('add_verified_date');
 SELECT acc.account_contact_add(:a_id,2,:'a_email');
 SELECT account_id , contact_type_id ,     value FROM wsd.account_contact WHERE account_id=:a_id;
 UPDATE wsd.account_contact SET value=:'a_new_email'  WHERE account_id=:a_id AND contact_type_id=2;
 SELECT account_id , contact_type_id ,     value FROM wsd.account_contact WHERE account_id=:a_id;

 SELECT ws.test('value_copy_into_account');
 SELECT id, login, psw, name FROM wsd.account WHERE id=:a_id;
 INSERT INTO wsd.prop_value (pogc, poid, code, valid_from, value) VALUES
        (acc.const_account_group_prop(), :a_id, 'abp.name.short', cfg.const_valid_from_date(), 'NEW_NAME');
 SELECT id, login, psw, name FROM wsd.account WHERE id=:a_id;

 SELECT ws.test('value_copy_into_team');
 SELECT id  , status_id ,   name FROM wsd.team WHERE id=:a_team_id;
 INSERT INTO wsd.prop_value (pogc, poid, code, valid_from, value) VALUES
        (acc.const_team_group_prop(), :a_team_id, 'abp.name.short', cfg.const_valid_from_date(), 'NEW_NAME_TEAM');
 SELECT id  , status_id ,   name FROM wsd.team WHERE id=:a_team_id;

 SELECT ws.test('value_copy_into_account');
 SELECT id, login, psw, name FROM wsd.account WHERE id=:a_id;
 UPDATE wsd.prop_value SET value='NEW_NAME_2' WHERE poid=:a_id AND code LIKE 'abp.name.short' AND pogc=acc.const_account_group_prop();
 SELECT id, login, psw, name FROM wsd.account WHERE id=:a_id;

 SELECT ws.test('value_copy_into_team');
 SELECT id  , status_id ,   name FROM wsd.team WHERE id=:a_team_id;
 UPDATE wsd.prop_value SET value='NEW_NAME_TEAM_2' WHERE poid=:a_team_id AND code LIKE 'abp.name.short' AND pogc=acc.const_team_group_prop();
 SELECT id  , status_id ,   name  FROM wsd.team WHERE id=:a_team_id;

 DELETE FROM wsd.team  WHERE id=:a_team_id ; 
 DELETE FROM wsd.account_contact  WHERE account_id=:a_id ;
 DELETE FROM wsd.account  WHERE id=:a_id ;
 DELETE FROM wsd.prop_value  WHERE poid=:a_id ;
 DELETE FROM wsd.prop_value  WHERE poid=:a_team_id ;
