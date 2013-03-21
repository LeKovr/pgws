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

    Регистрация методов и страниц
*/

/* ------------------------------------------------------------------------- */
INSERT INTO method (code, class_id, action_id, cache_id, rvf_id, code_real, args_exam) VALUES
   ('info.date',                  2, 1, 2, 3, pg_cs('date_info'), '')
  ,('info.month',                 2, 1, 2, 3, pg_cs('month_info'), '')
  ,('info.year_months',           2, 1, 2, 5, pg_cs('year_months'), '')
  ,('info.ref_info',              2, 1, 2, 7, pg_cs('ref_info'), 'id=65')
  ,('info.ref',                   2, 1, 2, 7, pg_cs('ref'), 'id=65')
;

INSERT INTO method (code, class_id, action_id, cache_id, rvf_id, is_i18n, args_exam) VALUES
   ('ws.page_by_code',            2, 1, 2, 3, true, 'code=api.smd')
  ,('ws.page_path',               2, 1, 2, 7, true, 'code=api.smd')
  ,('ws.page_childs',             2, 1, 2, 7, true, 'code=api')
  ,('ws.page_by_action',          2, 1, 2, 3, true, '')
;

INSERT INTO method (code, class_id, action_id, cache_id, rvf_id, args_exam) VALUES
   ('ws.page_tree',               2, 1, 2, 7, '')
  ,('ws.class',                   2, 1, 2, 5, '')
  ,('ws.method_lookup',           2, 1, 2, 7, '')
  ,('ws.class_id',                2, 1, 2, 2, 'code=system')
;

INSERT INTO method (code, class_id, action_id, cache_id, rvf_id, is_i18n) VALUES
   ('ws.page_by_uri',             2, 1, 2, 3, true)
  ,('ws.error_info',              2, 1, 2, 3, true)
;

INSERT INTO method (code, class_id, action_id, cache_id, rvf_id) VALUES
  ('ws.method_rvf',              2, 1, 2, 4)
  ,('ws.method_by_code',          2, 1, 2, 7)
  ,('ws.method_by_action',        2, 1, 2, 7)
  ,('ws.facet',                   2, 1, 2, 5)
  ,('ws.dt_facet',                2, 1, 2, 7)
  ,('ws.dt_part',                 2, 1, 2, 7)
  ,('ws.class_status_action_acl', 2, 1, 2, 7)
  ,('ws.class_action',            2, 1, 2, 3)
  ,('ws.class_status',            2, 1, 2, 3)
  ,('ws.class_acl',               2, 1, 2, 3)
  ,('ws.dt',                      2, 1, 2, 7)
  ,('ws.acls_eff_ids',            2, 1, 2, 6)
  ,('ws.acls_eff',                2, 1, 2, 4)
;

INSERT INTO method (code, class_id, action_id, cache_id, rvf_id, code_real) VALUES
   ('system.status',              2, 1, 2, 2, pg_cs('system_status'))
  ,('system.acl',                 2, 1, 2, 6, pg_cs('system_acl'))
  ,('info.status',                2, 1, 2, 2, pg_cs('info_status'))
  ,('info.acl',                   2, 1, 2, 6, pg_cs('info_acl'))
;

INSERT INTO method (code, class_id, action_id, cache_id, rvf_id, code_real, arg_dt_code, rv_dt_code, name) VALUES
   ('info.acl_check',      2, 1, 4, 3, 'acl:check',     dt_code('z_acl_check'), dt_code('d_acls'), 'Получение acl на объект')
  ,('ws.uncache',          2, 1, 1, 2, 'cache:uncache', dt_code('z_uncache'),   dt_code('d_id'), 'Сброс кэша метода')
/*
  ,('ws.store_get',        1, 3, 1, 2, 'store:get',     dt_code('z_store_get'), dt_code('d_id'), 'Получение данных из файлового хранилища')
  ,('ws.store_path',        1, 3, 1, 2, 'store:path',     dt_code('z_store_get'), dt_code('d_id'), 'Получение пути из файлового хранилища')
  ,('ws.store_set',        1, 5, 1, 3, 'store:set',     dt_code('z_store_set'), dt_code('d_id'), 'Сохранение данных в файловом хранилище')
*/
/*
  -- RESERVED
  ,('ws.cache_reset1',     2, 1, 1, 2, 'System::Cache::reset',      false, dt_code('z_cache_reset'), dt_code('d_id32'), 'Сброс кэша по 1 ключу')
  ,('ws.cache_reset2',     2, 1, 1, 2, 'System::Cache::reset',      false, dt_code('z_cache_reset'), dt_code('d_id32'), 'Сброс кэша по 2 ключам')
  ,('ws.cache_reset_mask', 2, 1, 1, 2, 'System::Cache::reset_mask', false, dt_code('z_cache_reset'), dt_code('d_id32'), 'Сброс кэша по маске')
*/
;

/* ------------------------------------------------------------------------- */
-- ошибки уровня приложения. Коды синхронизированы с кодами PostgreSQL
-- см. "http://www.postgresql.org/docs/8.4/static/errcodes-appendix.html"

INSERT INTO i18n_def.error (code                    , id_count, message) VALUES
  (ws.const_error_core_no_required_value()          , 0, 'не задано обязательное значение')
, (ws.const_error_core_value_not_match_rule()       , 2, 'значение не соответствует условию "%s %s"')
, (ws.const_error_core_value_not_match_format()     , 1, 'значение не соответствует шаблону "%s"')
, (ws.const_error_core_no_data()                    , 0, 'нет данных')
, (ws.const_error_system_incorrect_acl_code()       , 1, 'недопустимый код acl "%s"')
, (ws.const_error_system_external_access_forbidden(), 1, 'внешний доступ к методу с "%s" запрещен')
, (ws.const_error_system_auth_required()            , 0, 'необходима авторизация (не задан идентификатор сессии)')
, (ws.const_error_system_incorrect_session_id()     , 1, 'некорректный идентификатор сессии "%s"')
, (ws.const_error_system_acl_check_not_found()      , 1, 'не найдена проверка для acl "%s"')
, (ws.const_error_system_incorrect_status_id()      , 1, 'некорректный идентификатор статуса "%s"')
;
