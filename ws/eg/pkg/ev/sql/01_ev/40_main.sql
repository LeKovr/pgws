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

    Представления пакета
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW signup_joined AS SELECT 
  ers_at.*
, es.account_id AS signup_account_id -- пользователь из личных настроек общей роли
, es.role_id AS signup_role_id -- общая роль, использованная в настройках
, es.spec_id AS signup_spec_id
, es.is_on AS signup_is_on
, es.prio  AS signup_prio
FROM
(SELECT ers.*
, at.account_id  -- пользователь из связи с командой 
, at.role_id AS team_role_id -- роль пользователя из связи с командой 
, at.team_id AS team_id -- роль пользователя из связи с командой 
FROM wsd.event_role_signup ers 
  LEFT OUTER JOIN wsd.account_team at ON (ers.role_id = at.role_id)
) ers_at
LEFT OUTER JOIN wsd.event_signup es ON (ers_at.kind_id = es.kind_id AND ers_at.role_id = es.role_id 
AND (ers_at.account_id IS NULL OR ers_at.account_id = es.account_id))
-- WHERE (ers_at.account_id IS NULL OR es.account_id IS NULL OR ers_at.account_id = es.account_id)
;
-- TODO: spec_id добавить в JOIN или переделать в массив
-- TODO: добавление reason_id возможно отменяет потребность в  prio
SELECT pg_c('v', 'signup_joined', 'Полные атрибуты подписки')
--, pg_c('c', 'account_attr_info.registration_date', 'Дата регистрации пользователя')
;
/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW signup AS SELECT 
  role_id
, kind_id
, COALESCE (signup_account_id, account_id) AS account_id
, COALESCE (signup_spec_id,spec_id) AS spec_id -- TODO: пока не поддерживаются значения <>0
, COALESCE (signup_is_on, is_on) AS is_on
, (signup_is_on IS NOT NULL) AS is_own -- т
, team_id -- NULL означает данные из ли
FROM ev.signup_joined
WHERE COALESCE (signup_account_id, account_id) IS NOT NULL
;
SELECT pg_c('v', 'signup', 'Атрибуты подписки')
, pg_c('c', 'signup.is_own', 'Флаг подписки задан в персональных настройках')
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW kind_info AS SELECT 
  ek.*
, ekg.sort AS group_sort
, ekg.name AS group_name
  FROM ev.kind ek 
  JOIN ev.kind_group ekg ON ek.group_id = ekg.id
  ORDER BY ekg.sort, ek.id
;
SELECT pg_c('v', 'kind_info', 'Виды событий подписки')
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW signup_info AS SELECT 
  s.*
, ek.name AS kind_name
, ek.group_id
, ek.group_sort
, ek.group_name
  FROM ev.signup s JOIN ev.kind_info ek ON s.kind_id = ek.id
  ORDER BY group_sort, kind_id
;
SELECT pg_c('v', 'signup_info', 'Расширенные атрибуты подписки')
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW role_signup_info AS SELECT 
  ers.role_id
, ers.spec_id
, ers.is_on
, ers.prio
, ek.*
, ekg.name AS group_name
  FROM wsd.event_role_signup ers 
  JOIN ev.kind ek ON ek.id = ers.kind_id
  JOIN ev.kind_group ekg ON ek.group_id = ekg.id
  ORDER BY role_id, ekg.sort, ek.id
;
SELECT pg_c('v', 'role_signup_info', 'Подписки ролей')
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW signup_role_info AS SELECT 
  r.*
, ers.kind_id
, ers.spec_id
, ers.is_on
, ers.prio 
  FROM wsd.event_role_signup ers 
  JOIN wsd.role r ON ers.role_id = r.id
;
SELECT pg_c('v', 'signup_role_info', 'Роли, подписанные на вид события')
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW team_role_signup AS SELECT 
  ra.*
, ers.kind_id
, ers.spec_id
, ers.is_on
, ers.prio
, ek.name AS kind_name
, ek.group_id
, ek.group_sort
, ek.group_name
  FROM acc.role_attr ra
    JOIN wsd.event_role_signup ers ON ra.id = ers.role_id
    JOIN ev.kind_info ek ON ers.kind_id = ek.id
  ORDER BY team_id, role_id
;
SELECT pg_c('v', 'team_role_signup', 'Подписки ролей')
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW event_info AS SELECT 
  e.*
, ek.name
, en.account_id
, ws.sprintf(ek.name_fmt, e.arg_name, e.arg_name2) AS event
FROM wsd.event e 
JOIN ev.kind ek ON e.kind_id = ek.id
JOIN wsd.event_notify en ON e.id = en.event_id
ORDER BY e.created_at DESC
;
SELECT pg_c('v', 'event_info', 'События подписки')
, pg_c('c', 'event_info.event', 'Текст события')
;
