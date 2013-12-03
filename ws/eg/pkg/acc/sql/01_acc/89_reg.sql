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
INSERT INTO ws.method (code, class_id, action_id, cache_id, rvf_id, code_real) VALUES
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

INSERT INTO ws.method (code, class_id, action_id, cache_id, rvf_id, code_real, args_exam) VALUES
  ('system.ref',                 :SID, 1, 2, 7, 'ws.ref',          'code=' || ws.const_ref_code_timezone())
, ('system.ref_item',            :SID, 1, 2, 7, 'ws.ref_item',     'code=' || ws.const_ref_code_timezone())
, ('system.ref_log',             :SID, 1, 2, 7, 'ws.ref_log',      'code=' || ws.const_ref_code_timezone())
, ('account.acl',                :IID, 1, 3, 6, 'acc.account_acl',               'id=1')
, ('team.acl',                   :IID, 1, 3, 6, 'acc.team_acl',                  'id=2')
, ('team.prop_abp_attr',         :TID, 2, 4, 7, 'acc.prop_attr_team_abp',        'id=2')
, ('account.prop_abp_attr',      :AID, 2, 4, 7, 'acc.prop_attr_account_abp',     'id=1')
, ('team.prop_isv_value',        :TID, 2, 3, 3, 'acc.prop_attr_team_isv',        'id=2')
, ('team.prop_isv_attr',         :TID, 2, 4, 7, 'acc.prop_attr_team_isv' ,       'id=2')
, ('account.prop_isv_attr',      :AID, 2, 4, 7, 'acc.prop_attr_account_isv',     'id=1')
, ('account.prop_isv_value',     :AID, 2, 3, 3, 'acc.prop_attr_account_isv',     'id=1')
, ('team.account_attr',          :TID, 1, 3, 7, 'acc.team_account_attr',         'id=2')
, ('team.prop_history',          :TID, 2, 4, 7, 'acc.prop_history_team',         'id=2')
, ('account.prop_history',       :AID, 2, 4, 7, 'acc.prop_history_account',      'id=1')
, ('account.prop_isv',           :AID, 2, 4, 4, 'acc.prop_account_isv',          'id=1')
, ('team.role_number',           :TID, 1, 3, 7, 'acc.team_role_number',          'id=2')
, ('account.team',               :AID, 1, 4, 7, 'acc.account_team',              'id=1')
, ('team.lookup',                :IID, 1, 3, 7, 'acc.team_lookup',               'name=Комп')
, ('account.lookup',             :IID, 1, 4, 7, 'acc.account_lookup',            'name=Участ')
, ('account.contact.view',       :AID, 1, 4, 7, 'acc.account_contact_view',      'id=1')
, ('account.contact.type',       :IID, 1, 4, 7, 'acc.account_contact_type_attr', '')
, ('team.profile',               :TID, 1, 3, 3, 'acc.team_profile',              'id=2')
, ('account.profile',            :AID, 1, 3, 3, 'acc.account_profile',           'id=1')
, ('team.permission',            :TID, 1, 3, 7, 'acc.team_permission',           'id=2')
, ('account.permission',         :AID, 1, 4, 7, 'acc.account_permission',        'id=1,team_id=2')
, ('team.team_link_id',          :IID, 1, 3, 2, 'acc.team_team_link_id',         'object_team_id=3,account_team_id=2')
, ('account.team_link_id',       :IID, 1, 3, 2, 'acc.account_team_link_id',      'id=1,team_id=2')
, ('team.link_id',               :IID, 1, 3, 2, 'acc.team_link_id',              'id=1')
, ('account.link_id',            :IID, 1, 3, 2, 'acc.account_link_id',           'id=2')
, ('team.by_name',               :IID, 1, 3, 7, 'acc.team_by_name',              'name=Комп')
, ('team.role_members',          :TID, 1, 3, 7, 'acc.team_role_members',         'id=2,role_id=337')
, ('team.role',                  :TID, 1, 3, 7, 'acc.team_role',                 'id=2')
, ('team.fs_files',              :TID, 2, 4, 7, 'acc.team_fs_files',             'id=2')
, ('account.fs_files',           :AID, 2, 4, 7, 'acc.fs_files',                  'id=1')
, ('team.status',                :IID, 1, 3, 2, 'acc.team_status',               'id=2')
, ('account.status',             :IID, 1, 3, 2, 'acc.account_status',            'id=1')
;

INSERT INTO ws.method (code, class_id , action_id, cache_id, rvf_id, is_write, code_real, args_exam) VALUES
  ('account.sid_info',           :IID, 1, 3, 3, TRUE, 'acc.sid_info',            '')
, ('account.logout',             :SID, 2, 1, 2, TRUE, 'acc.logout',              '')
, ('account.contact.add',        :AID, 1, 1, 2, TRUE, 'acc.account_contact_add', 'id=1,type_id=1,value=2345678')
;

INSERT INTO ws.method (code, class_id, action_id, cache_id, rvf_id, code_real) VALUES
  ('team.get_id',      :IID, 1, 3, 2, 'acc.get_team_id_by_name')
;

INSERT INTO ws.method (code, class_id , action_id, cache_id, rvf_id, is_write, code_real) VALUES
  ('account.login',               :SID, 8, 1, 3, TRUE, 'acc.login')
, ('account.password.change',     :AID, 3, 1, 2, TRUE, 'acc.account_password_change' )
, ('account.password.change.own', :AID, 4, 1, 2, TRUE, 'acc.account_password_change_own')
, ('account.fs_files_del',        :AID, 4, 1, 2, true, 'acc.fs_files_del')
, ('team.fs_files_del',           :TID, 4, 1, 2, true, 'acc.team_fs_files_del')
;

INSERT INTO ws.method (code, class_id , action_id, cache_id, rvf_id, is_write, realm_code, code_real) VALUES
  ('account.fs_files_add',     :AID, 4, 1, 3, true, ws.const_realm_upload(), 'acc.fs_files_add')
, ('team.fs_files_add',        :TID, 4, 1, 3, true, ws.const_realm_upload(), 'acc.team_fs_files_add')
;

INSERT INTO ws.method (code, class_id , action_id, cache_id, rvf_id, code_real) VALUES
  ('system.prop_attr',          :SID, 3, 4, 7, 'cfg.prop_attr_system')
, ('system.prop_owner_attr',    :SID, 3, 4, 7, 'cfg.prop_owner_attr')
, ('system.prop_history',       :SID, 3, 4, 7, 'cfg.prop_history')
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

/* ------------------------------------------------------------------------- */
INSERT INTO job.handler (id, code, def_prio, arg_date_type, dust_days, is_sql, name) VALUES
  (4, 'mailtest', 20, 2, 31, false, 'Тест API')
;

/* ------------------------------------------------------------------------- */
UPDATE ws.dt_facet
  SET anno='прописные и строчные латинские буквы и цифры'
  WHERE code='acc.d_password';
