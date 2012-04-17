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

*/
-- 89_reg.sql - Регистрация методов и страниц
/* ------------------------------------------------------------------------- */
\qecho '-- FD: pg:ws:89_reg.sql / 23 --'

/* ------------------------------------------------------------------------- */

INSERT INTO method (code, class_id , action_id, cache_id, rvf_id, code_real, args_exam) VALUES
   ('info.date',                  2, 1, 2, 3, pg_cs('date_info'), '')
  ,('info.month',                 2, 1, 2, 3, pg_cs('month_info'), '')
  ,('info.year_months',           2, 1, 2, 5, pg_cs('year_months'), '')
  ,('info.ref_info',              2, 1, 2, 7, pg_cs('ref_info'), 'id=65')
  ,('info.ref',                   2, 1, 2, 7, pg_cs('ref'), 'id=65')
;

INSERT INTO method (code, class_id , action_id, cache_id, rvf_id, is_i18n, args_exam) VALUES
   ('ws.page_by_code',            2, 1, 2, 3, true, 'code=api.smd')
  ,('ws.page_path',               2, 1, 2, 7, true, 'code=api.smd')
  ,('ws.page_childs',             2, 1, 2, 7, true, 'code=api')
  ,('ws.page_by_action',          2, 1, 2, 3, true, '')
;

INSERT INTO method (code, class_id , action_id, cache_id, rvf_id, args_exam) VALUES
   ('ws.page_tree',               2, 1, 2, 7, '')
  ,('ws.class',                   2, 1, 2, 5, '')
  ,('ws.method_lookup',           2, 1, 2, 7, '')
;

INSERT INTO method (code, class_id , action_id, cache_id, rvf_id, is_i18n) VALUES
   ('ws.page_by_uri',             2, 1, 2, 3, true)
  ,('ws.error_info',              2, 1, 2, 3, true)
;

INSERT INTO method (code, class_id , action_id, cache_id, rvf_id) VALUES
  ('ws.method_rvf',              2, 1, 2, 4)
  ,('ws.method_by_code',          2, 1, 2, 7)
  ,('ws.method_by_action',        2, 1, 2, 7)
  ,('ws.facet',                   2, 1, 2, 5)
  ,('ws.dt_facet',                2, 1, 2, 7)
  ,('ws.dt_part',                 2, 1, 2, 7)
  ,('ws.class_status_action_acl', 2, 1, 2, 7)
  ,('ws.cache',                   2, 1, 2, 5)
  ,('ws.class_action',            2, 1, 2, 3)
  ,('ws.class_status',            2, 1, 2, 3)
  ,('ws.class_acl',               2, 1, 2, 3)
  ,('ws.dt',                      2, 1, 2, 7)
  ,('ws.dt_by_code',              2, 1, 5, 7)
  ,('ws.acls_eff_ids',            2, 1, 2, 6)
  ,('ws.acls_eff',                2, 1, 2, 4)
;

INSERT INTO method (code, class_id , action_id, cache_id, rvf_id, code_real) VALUES
   ('system.status',              2, 1, 2, 2, pg_cs('system_status'))
  ,('system.acl',                 2, 1, 2, 6, pg_cs('system_acl'))
  ,('info.status',                2, 1, 2, 2, pg_cs('info_status'))
  ,('info.acl',                   2, 1, 2, 6, pg_cs('info_acl'))
;

INSERT INTO method (code, class_id , action_id, cache_id, rvf_id, code_real, is_sql, arg_dt_id, rv_dt_id, name) VALUES
   ('info.acl_check',      2, 1, 4, 3, 'System::ACL::check',        false, dt_id('z_acl_check'),   dt_id('d_acls'), 'Получение acl на объект')
  ,('ws.cache_reset1',     2, 1, 1, 2, 'System::Cache::reset',      false, dt_id('z_cache_reset'), dt_id('d_id32'), 'Сброс кэша по 1 ключу')
  ,('ws.cache_reset2',     2, 1, 1, 2, 'System::Cache::reset',      false, dt_id('z_cache_reset'), dt_id('d_id32'), 'Сброс кэша по 2 ключам')
  ,('ws.cache_reset_mask', 2, 1, 1, 2, 'System::Cache::reset_mask', false, dt_id('z_cache_reset'), dt_id('d_id32'), 'Сброс кэша по маске')
;

/* ------------------------------------------------------------------------- */
INSERT INTO i18n_def.page (code, up_code, class_id, action_id, sort, uri, tmpl, name) VALUES
  ('main',      NULL, 2, 1, 0, '$',            'app/index',          'API')
;

/* ------------------------------------------------------------------------- */
-- ошибки уровня приложения. Коды синхронизированы с кодами PostgreSQL
-- см. "http://www.postgresql.org/docs/8.4/static/errcodes-appendix.html"

INSERT INTO i18n_def.error (code, id_count, message) VALUES
   ('Y0001', 0, 'не задано обязательное значение')
  ,('Y0002', 2, 'значение не соответствует условию "%s %s"')
  ,('Y0003', 1, 'значение не соответствует шаблону "%s"')
  ,('Y0010', 0, 'нет данных')
  ,('Y0021', 1, 'нет доступа к результату суммы при а = %i')
  ,('Y0022', 1, 'нет данных по a = %i')
  ,('Y0051', 0, 'Указанный логин уже занят. Выберите другой логин')
  ,('Y0101', 1, 'недопустимый код acl "%s"')
  ,('Y0102', 1, 'внешний доступ к методу с "%s" запрещен')
  ,('Y0103', 0, 'необходима авторизация (не задан идентификатор сессии)')
  ,('Y0104', 1, 'некорректный идентификатор сессии "%s"')
  ,('Y0105', 1, 'не найдена проверка для acl "%s"')
  ,('Y0106', 1, 'некорректный идентификатор статуса "%s"')
;
/* ------------------------------------------------------------------------- */
\qecho '-- FD: pg:ws:89_reg.sql / 110 --'
