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

    Таблицы API
*/

/* ------------------------------------------------------------------------- */
/*
CREATE OR REPLACE VIEW team_account_attr AS SELECT
  ta.*
  , t.name AS team_name
  , a.name AS account_name
  FROM wsd.team_account ta
    JOIN wsd.account a ON (a.id = ta.account_id)
    JOIN wsd.team t ON (t.id = ta.team_id)
;
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW account_attr AS SELECT
  a.* 
, a.created_at::date AS registration_date 
, ws.class_status_name('account', a.status_id) AS status_name
, cfg.prop_value(acc.const_account_group_prop(), a.id, 'abp.person.gender') AS gender
  FROM wsd.account a
;
SELECT pg_c('v', 'account_attr', 'Атрибуты учетной записи')
, pg_c('c', 'account_attr.registration_date', 'Дата регистрации пользователя')
, pg_c('c', 'account_attr.status_name',       'Название статуса')
, pg_c('c', 'account_attr.gender',            'Пол')
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW account_attr_info AS SELECT
  a.* 
, a.created_at::date AS registration_date 
, r.id AS role_id
, t.id AS team_id
, r.name AS role_name
, t.name AS team_name
, ws.class_status_name('account', a.status_id) AS status_name
, cfg.prop_value(acc.const_account_group_prop(), a.id, 'abp.person.gender') AS gender
  FROM wsd.account a
    JOIN wsd.account_team ar ON (a.id = ar.account_id)
    JOIN wsd.role r ON (r.id = ar.role_id)
    JOIN wsd.team t ON (t.id = ar.team_id)
    WHERE ar.is_default
;
SELECT pg_c('v', 'account_attr_info', 'Атрибуты учетной записи')
, pg_c('c', 'account_attr_info.registration_date', 'Дата регистрации пользователя')
, pg_c('c', 'account_attr_info.status_name',       'Название статуса')
, pg_c('c', 'account_attr_info.gender',            'Пол')
;
/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW session_info AS SELECT
  s.*
  , a.status_id
  , a.name AS account_name
  , r.name AS role_name
  , t.name AS team_name
  FROM wsd.session s
    JOIN wsd.account a ON (a.id = s.account_id)
    JOIN wsd.role r ON (r.id = s.role_id)
    JOIN wsd.team t ON (t.id = s.team_id)
;
SELECT pg_c('v', 'session_info', 'Атрибуты сессии')
, pg_c('c', 'session_info.account_name',  'Имя пользователя')
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW account_team AS SELECT
  ar.*
, t.name AS team_name
, r.name AS role_name
  FROM wsd.account_team ar
    JOIN wsd.role r ON r.id = ar.role_id
    JOIN wsd.team t ON t.id = ar.team_id
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW account_permission_attr AS SELECT
  p.*
, FALSE AS is_enabled
  FROM wsd.permission p
;
SELECT pg_c('v', 'account_permission_attr', 'Атрибуты разрешений пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW team_account_attr AS SELECT
  a.*
, t.id AS team_id
, r.id AS role_id
, t.name AS team_name
, r.name AS role_name
, acc.last_visit(a.id, t.id) AS last_visit
  FROM acc.account_attr a
    JOIN wsd.account_team ar ON a.id = ar.account_id
    JOIN wsd.role r ON r.id = ar.role_id
    JOIN wsd.team t ON t.id = ar.team_id
;
SELECT pg_c('v', 'team_account_attr', 'Аттрибуты участников команды');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW team_attr AS SELECT
  t.*
, t.created_at::date AS registration_date
, ws.class_status_name('team', t.status_id) AS status_name
, cfg.prop_value(acc.const_team_group_prop(), t.id, 'abp.anno') AS anno
  FROM wsd.team t
;
SELECT pg_c('v', 'team_attr', 'Атрибуты команды')
, pg_c('c', 'team_attr.registration_date',  'Дата регистрации команды')
, pg_c('c', 'team_attr.status_name',        'Название статуса')
, pg_c('c', 'team_attr.anno',               'Описание')
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW role_info AS SELECT
  r.id
, (r.team_id IS NOT NULL AND r.id != acc.const_role_id_login()) AS is_team_only
, r.name
, r.anno
, r.team_id
, t.name AS team_name
  FROM wsd.role r
    LEFT JOIN wsd.team t ON t.id = r.team_id
;
SELECT pg_c('v', 'role_info', 'Информация по ролям');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW role_attr AS SELECT
  r.id
, (r.team_id IS NOT NULL AND r.id != acc.const_role_id_login()) AS is_team_only
, r.name
, r.anno
, t.id AS team_id
  FROM wsd.role r, wsd.team t
  WHERE (r.team_id IS NULL OR r.team_id = t.id OR r.id = acc.const_role_id_login())
;
SELECT pg_c('v', 'role_attr', 'Атрибуты ролей');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW team_role_number AS SELECT
  t.team_id
, t.role_id
, COUNT(1) AS account_number
  FROM wsd.account_team t
  GROUP BY role_id, team_id
;
SELECT pg_c('v', 'team_role_number', 'Количество участников пары команда-роль');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW perm_info AS SELECT
 pa.perm_id || '. ' || p.name AS perm
, r.id || '. ' || r.name AS role
, pa.class_id || '. ' || ws.class_code(pa.class_id) AS class
, team_link_id || '. ' || acc.team_link_name(team_link_id) AS team_link
, link_id || '. ' || acc.class_link_name(pa.class_id, pa.link_id) AS class_link
, acl_id || '. ' || (ws.class_acl(pa.class_id, acl_id)).name AS acl --, rp.anno 
  FROM wsd.permission_acl pa 
   JOIN wsd.role_permission rp ON (pa.perm_id = rp.perm_id)
   JOIN wsd.role r ON (rp.role_id = r.id)
   JOIN wsd.permission p ON (pa.perm_id = p.id)
  ORDER BY pa.perm_id, r.id, pa.class_id, team_link_id, link_id
;
/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW permission_attr AS SELECT
  p.*
, t.name AS team_name
  FROM wsd.permission p
    LEFT JOIN wsd.team t ON t.id = p.team_id
  ORDER BY p.id
;
SELECT pg_c('v', 'permission_attr', 'Атрибуты разрешений');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW permission_acl_attr AS SELECT
  pa.perm_id AS id
, p.name
, ws.class_code(pa.class_id) AS class_code
, (ws.class(pa.class_id)).name AS class_name
, pa.team_link_id
, acc.team_link_name(team_link_id) AS team_link
, pa.link_id
, acc.class_link_name(pa.class_id, pa.link_id) AS class_link
, pa.acl_id
, (ws.class_acl(pa.class_id, acl_id)).name AS acl_name
  FROM wsd.permission_acl pa 
    JOIN wsd.permission p ON p.id = pa.perm_id
  ORDER BY class_name, acl_id, team_link_id, link_id, name
;
SELECT pg_c('v', 'permission_acl_attr', 'Описание разрешений');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW account_contact AS SELECT
  act.name
, ac.*
  FROM wsd.account_contact ac
    JOIN acc.account_contact_type act ON ac.contact_type_id = act.id
  WHERE ac.deleted_at IS NULL
  ORDER BY account_id, name, created_at
;
SELECT pg_c('v', 'account_contact', 'Контакты пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW account_contact_type_attr AS SELECT
  *
  FROM acc.account_contact_type
;
SELECT pg_c('v', 'account_contact_type_attr', 'Типы контактов пользователя');

/* ------------------------------------------------------------------------- */
