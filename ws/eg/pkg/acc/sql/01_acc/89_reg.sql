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
\set IID ws.const_info_class_id()
\set SID acc.const_system_class_id()

\set AID acc.const_class_id()       -- account class id
\set TID acc.const_team_class_id()  -- team class id
\set RID acc.const_role_class_id()  -- role class id

/* ------------------------------------------------------------------------- */
-- тип данных пакета acc
-- INSERT INTO dt (parent_code, code, anno) VALUES (dt_code('ws.d_id32'), pg_cs('d_link'), 'Связь с объектом');

INSERT INTO method (code, class_id, action_id, cache_id, rvf_id, code_real) VALUES
  ('system.status',              :IID, 1, 2, 2, pg_cs('system_status'))
, ('system.acl',                 :IID, 1, 2, 6, pg_cs('system_acl'))
, ('system.team_link_id',        :IID, 1, 3, 2, pg_cs('system_team_link_id'))
, ('system.link_id',             :IID, 1, 3, 2, pg_cs('system_link_id'))
, ('system.role',                :IID, 1, 2, 7, pg_cs('system_role'))
, ('system.role_permission',     :IID, 1, 2, 7, pg_cs('system_role_permission'))
, ('system.permission_view',     :IID, 1, 2, 7, pg_cs('system_permission_view'))
, ('system.permission_role',     :IID, 1, 2, 7, pg_cs('system_permission_role'))
, ('system.permission_acl',      :IID, 1, 2, 7, pg_cs('system_permission_acl'))
, ('system.class_permission_acl',:IID, 1, 2, 7, pg_cs('system_class_permission_acl'))
;

INSERT INTO method (code, class_id, action_id, cache_id, rvf_id, code_real, args_exam) VALUES
  ('system.ref',                 :SID, 1, 2, 7, 'ws.ref', 'code=' || ws.const_ref_code_timezone())
, ('system.ref_item',            :SID, 1, 2, 7, 'ws.ref_item', 'code=' || ws.const_ref_code_timezone())
, ('system.ref_log',             :SID, 1, 2, 7, 'ws.ref_log', 'code=' || ws.const_ref_code_timezone())
;


INSERT INTO ws.method (code, class_id , action_id, cache_id, rvf_id, is_write, code_real) VALUES
  ('account.sid_info',        :IID, 1, 3, 3, TRUE, 'acc.sid_info')
, ('account.login',           :SID, 8, 1, 3, TRUE, 'acc.login')
, ('account.logout',          :SID, 2, 1, 2, TRUE, 'acc.logout')
;

INSERT INTO ws.method (code, class_id, action_id, cache_id, rvf_id, code_real) VALUES
  ('team.profile',     :TID, 1, 3, 3, 'acc.team_profile')
, ('team.status',      :IID, 1, 3, 2, 'acc.team_status')
, ('team.acl',         :IID, 1, 3, 6, 'acc.team_acl')
, ('team.team_link_id',:IID, 1, 3, 2, 'acc.team_team_link_id')
, ('team.link_id',     :IID, 1, 3, 2, 'acc.team_link_id')
, ('team.by_name',     :IID, 1, 3, 7, 'acc.team_by_name')
, ('team.account_attr',:TID, 1, 3, 7, 'acc.team_account_attr')
, ('team.role',        :TID, 1, 3, 7, 'acc.team_role')
, ('team.role_number', :TID, 1, 3, 7, 'acc.team_role_number')
, ('team.permission',  :TID, 1, 3, 7, 'acc.team_permission')
, ('team.role_members',:TID, 1, 3, 7, 'acc.team_role_members')
, ('team.lookup',      :IID, 1, 3, 7, 'acc.team_lookup')
;

INSERT INTO ws.method (code, class_id, action_id, cache_id, rvf_id, code_real) VALUES
  ('account.status',      :IID, 1, 3, 2, 'acc.account_status')
, ('account.acl',         :IID, 1, 3, 6, 'acc.account_acl')
, ('account.link_id',     :IID, 1, 3, 2, 'acc.account_link_id')
, ('account.team_link_id',:IID, 1, 3, 2, 'acc.account_team_link_id')
, ('account.profile',    :AID, 1, 3, 3, 'acc.account_profile')
, ('account.team',       :AID, 1, 4, 7, 'acc.account_team')
, ('account.permission', :AID, 1, 4, 7, 'acc.account_permission')
, ('account.lookup',     :IID, 1, 4, 7, 'acc.account_lookup')
, ('account.contact.view',:AID,1, 4, 7, 'acc.account_contact_view')
, ('account.contact.type',:IID, 1, 4, 7, 'acc.account_contact_type_attr')
;

INSERT INTO ws.method (code, class_id, action_id, cache_id, rvf_id, is_write, code_real) VALUES
  ('account.contact.add',         :AID, 1, 1, 2, TRUE, 'acc.account_contact_add')
, ('account.password.change',     :AID, 3, 1, 2, TRUE, 'acc.account_password_change' )
, ('account.password.change.own', :AID, 4, 1, 2, TRUE, 'acc.account_password_change_own')
;
/* ------------------------------------------------------------------------- */
INSERT INTO method (code, class_id , action_id, cache_id, rvf_id, code_real) VALUES
  ('account.fs_files', :AID, 2, 4, 7, 'acc.fs_files')
, ('team.fs_files',    :TID, 2, 4, 7, 'acc.team_fs_files')
;
INSERT INTO ws.method (code, class_id , action_id, cache_id, rvf_id, is_write, code_real) VALUES
  ('account.fs_files_del',     :AID, 4, 1, 2, true, 'acc.fs_files_del')
, ('team.fs_files_del',        :TID, 4, 1, 2, true, 'acc.team_fs_files_del')
;

INSERT INTO ws.method (code, class_id , action_id, cache_id, rvf_id, is_write, realm_code, code_real) VALUES
  ('account.fs_files_add',     :AID, 4, 1, 3, true, ws.const_realm_upload(), 'acc.fs_files_add')
, ('team.fs_files_add',        :TID, 4, 1, 3, true, ws.const_realm_upload(), 'acc.team_fs_files_add')
;

INSERT INTO method (code, class_id , action_id, cache_id, rvf_id, code_real) VALUES
  ('system.prop_attr',          :SID, 3, 4, 7, 'cfg.prop_attr_system')
, ('system.prop_owner_attr',    :SID, 3, 4, 7, 'cfg.prop_owner_attr')
, ('system.prop_history',       :SID, 3, 4, 7, 'cfg.prop_history')
, ('account.prop_abp_attr',     :AID, 2, 4, 7, 'acc.prop_attr_account_abp')
, ('account.prop_isv_attr',     :AID, 2, 4, 7, 'acc.prop_attr_account_isv')
, ('account.prop_isv',          :AID, 2, 4, 4, 'acc.prop_account_isv')
, ('team.prop_abp_attr',        :TID, 2, 4, 7, 'acc.prop_attr_team_abp')
, ('team.prop_isv_attr',        :TID, 2, 4, 7, 'acc.prop_attr_team_isv')

, ('team.prop_isv_value',       :TID, 2, 3, 3, 'acc.prop_attr_team_isv')
, ('account.prop_isv_value',    :AID, 2, 3, 3, 'acc.prop_attr_account_isv')

, ('account.prop_history',      :AID, 2, 4, 7, 'acc.prop_history_account')
, ('team.prop_history',         :TID, 2, 4, 7, 'acc.prop_history_team')

, ('info.prop_def_value',       :SID, 2, 4, 2, 'cfg.prop_default_value')
;

/*
INSERT INTO ws.method (code, class_id, action_id, cache_id, rvf_id, is_write, code_real) VALUES
  ('account.role_add',       :AID, 6, 1, 2, true, 'acc.account_team_add')
, ('account.role_del',       :AID, 6, 1, 2, true, 'acc.account_team_del')
, ('team.update',        :TID, 3, 1, 2, true, 'acc.team_update')
, ('role.create',           1, 4, 1, 2, true, 'acc.role_save')
, ('role.update',        :RID, 1, 1, 2, true, 'acc.role_save')
, ('role.delete',        :RID, 2, 1, 2, true, 'acc.role_del')
;
*/

/* ------------------------------------------------------------------------- */
INSERT INTO i18n_def.error (code, id_count, message) VALUES
  (acc.const_error_password(),                0, 'неправильный пароль')
, (acc.const_error_login(),                   0, 'неизвестный логин')
, (acc.const_error_status(),                  1, 'статус пользователя (%s) не допускает авторизацию')
, (acc.const_error_class(),                   0, 'ошибка определения уровня доступа класса (%s)')
, (acc.const_error_email_validation(),        0, 'введите корректный email')
, (acc.const_error_mobile_phone_validation(), 0, 'введите корректный номер телефона')
, (acc.const_error_passwords_match(),         0, 'введенные пароли не совпадают')
, (acc.const_error_badsid(),                  0, 'ошибка аутентификации')
;

INSERT INTO job.handler (id, code, def_prio, arg_date_type, dust_days, is_sql, name) VALUES
  (4, 'mailtest', 20, 2, 31, false, 'Тест API')
;
--   ,('Y0051', 0, 'Указанный логин уже занят.  Выберите другой логин')

/* ------------------------------------------------------------------------- */
UPDATE ws.dt_facet
  SET anno='прописные и строчные латинские буквы и цифры'
  WHERE code='acc.d_password';
