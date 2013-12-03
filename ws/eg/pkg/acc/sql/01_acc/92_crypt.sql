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

    Тесты на выполнение пакетом АСС корректного шифрования
*/

/* ------------------------------------------------------------------------- */
\set SID1 '\'1; \''
\set SID2 '\'2; \''
\set SID3 '\'3; \''
\set SID4 '\'4; \''
\set LOGIN 'TEST_USER'
\set a_psw '1234'
\set TEAM -1
\set ROLE -1
\set ACC -1
 INSERT INTO wsd.team (id, name, status_id) VALUES (:TEAM, 'ACC-Test', acc.const_team_status_id_active());
 INSERT INTO wsd.role (id, name, anno) VALUES (:ROLE, 'Tests', '');
 INSERT INTO wsd.account (id, status_id, login, psw, name) VALUES
   (:ACC, acc.const_status_id_active(), :'LOGIN', :'a_psw', 'test_crypt_user');
 SELECT acc.team_account_add(:TEAM, :ACC, :ROLE);

 SELECT ws.test('test_crypt');
--Исходное состояние таблицы account для пользователя TEST_USER
 SELECT login,psw,is_psw_plain FROM wsd.account where login like 'TEST_USER';

--Тест № 1 - Смена незашифрованного пароля acc.account_password_change()
 SELECT acc.account_password_change(:ACC,'Fn4orU_vunqQ5G5i','Fn4orU_vunqQ5G5i');
--   Таблица account для пользователя TEST_USER 
 SELECT login,is_psw_plain FROM wsd.account where login like 'TEST_USER';
--Логин и выход
 SELECT account_id, role_id, team_id, sid, ip, is_ip_checked, status_id, account_name , role_name, team_name FROM acc.login('4.12.345.6789','TEST_USER','Fn4orU_vunqQ5G5i', :SID1);
 SELECT acc.logout(:SID1);

--Тест № 2 - Смена зашифрованного пароля acc.account_password_change()
 SELECT acc.account_password_change(:ACC,'n4orU_vunqQ5G5i','n4orU_vunqQ5G5i');
--Таблица account для пользователя TEST_USER 
 SELECT login,is_psw_plain FROM wsd.account where login like 'TEST_USER';
--Логин и выход
 SELECT account_id, role_id, team_id, sid, ip, is_ip_checked, status_id, account_name , role_name, team_name FROM acc.login('4.12.345.6789','TEST_USER','n4orU_vunqQ5G5i', :SID2);
 SELECT acc.logout(:SID2);

--Тест № 3 - Смена незашифрованного пароля acc.account_password_change_own()
 UPDATE wsd.account SET psw=:'a_psw',is_psw_plain='true' WHERE login like 'TEST_USER';
 SELECT login,psw,is_psw_plain FROM wsd.account where login like 'TEST_USER';
 SELECT acc.account_password_change_own(:ACC,:'a_psw','0kyXNAr4h8Ytgy','0kyXNAr4h8Ytgy');
--Таблица account для пользователя TEST_USER 
 SELECT login,is_psw_plain FROM wsd.account where login like 'TEST_USER';
--Логин и выход
 SELECT account_id, role_id, team_id, sid, ip, is_ip_checked, status_id, account_name , role_name, team_name FROM acc.login('4.12.345.6789','TEST_USER','0kyXNAr4h8Ytgy', :SID3);
 SELECT acc.logout(:SID3);

--Тест № 4 - Смена зашифрованного пароля acc.account_password_change_own()
 SELECT acc.account_password_change_own(:ACC,'0kyXNAr4h8Ytgy','0kyXNAr4h8Ytg','0kyXNAr4h8Ytg');
--Таблица account для пользователя TEST_USER 
 SELECT login,is_psw_plain FROM wsd.account where login like 'TEST_USER';
--Логин и выход
 SELECT account_id, role_id, team_id, sid, ip, is_ip_checked, status_id, account_name , role_name, team_name FROM acc.login('4.12.345.6789','TEST_USER','0kyXNAr4h8Ytg', :SID4);
 SELECT acc.logout(:SID4);
