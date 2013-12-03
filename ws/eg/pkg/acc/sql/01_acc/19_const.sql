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

  FD: 11_crmisc.sql / 2 --

  PGWS. Вспомогательные функции

*/
/*** CLASS ***/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_system_class_id() RETURNS ws.d_class IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 1::ws.d_class;
$_$;
SELECT pg_c('f', 'const_system_class_id', 'Константа: ID класса system');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_class_id() RETURNS ws.d_class IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 15::ws.d_class;
$_$;
SELECT pg_c('f', 'const_class_id', 'Константа: ID класса account');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_team_class_id() RETURNS ws.d_class IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 16::ws.d_class;
$_$;
SELECT pg_c('f', 'const_team_class_id', 'Константа: ID класса team');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_role_class_id() RETURNS ws.d_class IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 17::ws.d_class;
$_$;
SELECT pg_c('f', 'const_team_class_id', 'Константа: ID класса team');


/*** STATUS ***/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_active() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 1
$_$;
SELECT pg_c('f', 'const_status_id_active', 'Константа: ID статуса активного аккаунта');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_locked() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 2
$_$;
SELECT pg_c('f', 'const_status_id_locked', 'Константа: ID статуса заблокированного аккаунта');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_team_status_id_active() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 1;
$_$;
SELECT pg_c('f', 'const_team_status_id_active', 'Константа: ID статуса активной команды');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_team_status_id_locked() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 2;
$_$;
SELECT pg_c('f', 'const_team_status_id_locked', 'Константа: ID статуса заблокированной команды');

/*** LINK ***/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_link_id_owner() RETURNS d_link IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 1::acc.d_link
$_$;
SELECT pg_c('f', 'const_link_id_owner', 'Константа: ID связи своего объекта');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_link_id_other() RETURNS d_link IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 2::acc.d_link
$_$;
SELECT pg_c('f', 'const_link_id_other', 'Константа: ID связи чужого объекта');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_team_link_id_owner() RETURNS acc.d_link IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 1::acc.d_link;
$_$;
SELECT pg_c('f', 'const_team_link_id_owner', 'Константа: Уровень связи своей команды');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_team_link_id_other() RETURNS acc.d_link IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 2::acc.d_link;
$_$;
SELECT pg_c('f', 'const_team_link_id_other', 'Константа: Уровень связи чужой команды');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_team_link_id_system() RETURNS acc.d_link IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 3::acc.d_link;
$_$;
SELECT pg_c('f', 'const_team_link_id_system', 'Константа: Уровень связи системной команды');

/*** TEAM ***/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_team_id_system() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 1;
$_$;
SELECT pg_c('f', 'const_team_id_system', 'Константа: ID системной команды');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_team_id_admin() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 2;
$_$;
SELECT pg_c('f', 'const_team_id_system', 'Константа: ID админской команды');

/*** ROLE ***/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_role_id_guest() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 1
$_$;
SELECT pg_c('f', 'const_role_id_guest', 'Константа: ID роли неавторизованного пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_role_id_noteam() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 2
$_$;
SELECT pg_c('f', 'const_role_id_noteam', 'Константа: ID роли пользователя без команды');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_role_id_login() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 3
$_$;
SELECT pg_c('f', 'const_role_id_login', 'Константа: ID роли авторизованного пользователя');


/*** ERRORS ***/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_password() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT ('Y' || acc.const_class_id() || '01')::TEXT
$_$;
SELECT pg_c('f', 'const_error_password', 'Константа: Код ошибки авторизации с неправильным паролем');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_login() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT ('Y' || acc.const_class_id() || '02')::TEXT
$_$;
SELECT pg_c('f', 'const_error_login', 'Константа: Код ошибки авторизации с неизвестным логином');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_status() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT ('Y' || acc.const_class_id() || '03')::TEXT
$_$;
SELECT pg_c('f', 'const_error_status', 'Константа: Код ошибки авторизации с недопустимым статусом');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_class() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT ('Y' || acc.const_class_id() || '04')::TEXT
$_$;
SELECT pg_c('f', 'const_error_class', 'Константа: Код ошибки определения уровня доступа класса');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_team_group_prop() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'team'::TEXT;
$_$;
SELECT pg_c('f', 'const_team_group_prop', 'Константа: Название группы владельца свойств компании');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_account_group_prop() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'acc'::TEXT;
$_$;
SELECT pg_c('f', 'const_account_group_prop', 'Константа: Название группы владельца свойств пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_account_contact_mobile_phone_id() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 1
$_$;
SELECT pg_c('f', 'const_account_contact_mobile_phone_id()', 'Константа: ID типа контакта мобильный телефон');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_account_contact_email_id() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 2
$_$;
SELECT pg_c('f', 'const_account_contact_email_id()', 'Константа: ID типа контакта email');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_email_validation() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y' || acc.const_class_id() || '05'::TEXT
$_$;
SELECT pg_c('f', 'const_error_email_validation', 'Константа: Код ошибки валидации email');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_mobile_phone_validation() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y' || acc.const_class_id() || '06'::TEXT
$_$;
SELECT pg_c('f', 'const_error_mobile_phone_validation', 'Константа: Код ошибки валидации мобильного телефона');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_passwords_match() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y' || acc.const_class_id() || '07'::TEXT
$_$;
SELECT pg_c('f', 'const_error_passwords_match', 'Константа: Код ошибки ввода повторного пароля');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_badsid() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$ 
  SELECT ('Y' || acc.const_class_id() || '08')::TEXT
$_$;
SELECT pg_c('f', 'const_error_badsid', 'Некорректный sid');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_team_admin_id() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$ 
  SELECT 2
$_$;
SELECT pg_c('f', 'const_team_admin_id', 'ID команды администраторов системы');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_team_system_id() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$ 
  SELECT 1
$_$;
SELECT pg_c('f', 'const_team_system_id', 'ID системных команд');
