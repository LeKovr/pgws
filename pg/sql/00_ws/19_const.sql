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

    Константы
*/

/* ------------------------------------------------------------------------- */
SET LOCAL search_path = ws, i18n_def, public;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_rpc_err_nodata() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT '02000'::TEXT
$_$;
SELECT pg_c('f', 'const_rpc_err_nodata', 'Константа: RPC код ошибки отсутствия данных');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_rpc_err_noaccess() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT '42501'::TEXT
$_$;
SELECT pg_c('f', 'const_rpc_err_noaccess', 'Константа: RPC код ошибки отсутствия доступа');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_core_no_required_value() RETURNS d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y0001'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_core_no_required_value'          , 'не задано обязательное значение');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_core_value_not_match_rule() RETURNS d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y0002'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_core_value_not_match_rule'       , 'значение не соответствует условию');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_core_value_not_match_format() RETURNS d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y0003'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_core_value_not_match_format'     , 'значение не соответствует шаблону');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_core_no_data() RETURNS d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y0010'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_core_no_data'                    , 'нет данных');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_system_incorrect_acl_code() RETURNS d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y0101'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_system_incorrect_acl_code'       , 'недопустимый код acl');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_system_external_access_forbidden() RETURNS d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y0102'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_system_external_access_forbidden', 'внешний доступ к методу запрещен');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_system_auth_required() RETURNS d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y0103'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_system_auth_required'            , 'необходима авторизация (не задан идентификатор сессии)');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_system_incorrect_session_id() RETURNS d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y0104'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_system_incorrect_session_id'     , 'некорректный идентификатор сессии');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_system_acl_check_not_found() RETURNS d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y0105'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_system_acl_check_not_found'      , 'не найдена проверка для acl');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_system_incorrect_status_id() RETURNS d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y0106'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_system_incorrect_status_id'      , 'некорректный идентификатор статуса');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_realm_upload() RETURNS d_code IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'upload'::ws.d_code
$_$;
SELECT pg_c('f', 'const_realm_upload'      , 'область вызова методов загрузки файлов');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_info_class_id() RETURNS ws.d_class IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 2::ws.d_class;
$_$;
SELECT pg_c('f', 'const_info_class_id', 'Константа: ID класса info');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_ref_op_insert() RETURNS d_codei IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'INSERT'::ws.d_codei;
$_$;
SELECT pg_c('f', 'const_ref_op_insert', 'Константа: Код операции добавления позиции справочника');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_ref_op_update() RETURNS d_codei IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'UPDATE'::ws.d_codei;
$_$;
SELECT pg_c('f', 'const_ref_op_update', 'Константа: Код операции обновления позиции справочника');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_ref_op_delete() RETURNS d_codei IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'DELETE'::ws.d_codei;
$_$;
SELECT pg_c('f', 'const_ref_op_delete', 'Константа: Код операции удаления позиции справочника');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_update_timestamp() RETURNS timestamp IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT '2000-01-01'::timestamp;
$_$;
SELECT pg_c('f', 'const_update_timestamp', 'Константа: начальный timestamp изменений данных');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_ref_acls_internal() RETURNS d_acls IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT ARRAY[-1]::ws.d_acls;
$_$;
SELECT pg_c('f', 'const_ref_acls_internal', 'Константа: внутренний ACL обновления справочника');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_ref_code_timezone() RETURNS d_code IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'timezone'::ws.d_code;
$_$;
SELECT pg_c('f', 'const_ref_code_timezone', 'Константа: Код справочника часовых поясов');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_lang_default() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'ru'::TEXT;
$_$;
SELECT pg_c('f', 'const_lang_default', 'Константа: Код языка по умолчанию');
