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

    Методы диспетчера EV
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION kind(a_id ws.d_id32 DEFAULT 0) RETURNS SETOF kind_info STABLE LANGUAGE 'sql' AS
$_$
-- a_id:      ID вида события
  SELECT * FROM ev.kind_info WHERE $1 IN (id, 0);
$_$;
SELECT pg_c('f', 'kind', 'Вид события по ID');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION kind_group(a_id d_id32 DEFAULT 0) RETURNS SETOF kind_group STABLE LANGUAGE 'sql' AS
$_$
-- a_id:      ID группы видов события
  SELECT * FROM ev.kind_group WHERE $1 IN (id,0) ORDER BY sort;
$_$; 
SELECT pg_c('f', 'kind_group', 'Группы видов событий');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION notification(a_id d_id) RETURNS SETOF event_info LANGUAGE 'sql' AS
$_$
  -- a_id: ID аккаунта пользователя
  SELECT * FROM ev.event_info WHERE account_id = $1;
$_$;
SELECT pg_c('f', 'notification', 'Список уведомлений пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION notification_count_new(a_id d_id) RETURNS BIGINT LANGUAGE 'sql' AS
$_$
  -- a_id: ID аккаунта пользователя
  SELECT COUNT(*) FROM wsd.event_notify WHERE account_id = $1 AND is_new = TRUE;
$_$;
SELECT pg_c('f', 'notification_count_new', 'Количество новых уведомлений пользователя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION signup_by_account_id(a_id d_id) RETURNS SETOF signup_info STABLE LANGUAGE 'sql' AS
$_$
  -- a_id: ID аккаунта пользователя
  SELECT * FROM ev.signup_info WHERE account_id = $1;
$_$;
SELECT pg_c('f', 'signup_by_account_id', 'Список подписок пользователя');


/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION signup_by_role_id(a_id d_id) RETURNS SETOF role_signup_info STABLE LANGUAGE 'sql' AS
$_$
  -- a_id: ID роли
  SELECT * FROM ev.role_signup_info WHERE role_id = $1;
$_$;
SELECT pg_c('f', 'signup_by_role_id', 'Список подписок роли');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION signup_by_team_role_id(a_id d_id, a_role_id d_id DEFAULT 0) RETURNS SETOF team_role_signup STABLE LANGUAGE 'sql' AS
$_$
  -- a_id: ID команды
  -- a_role_id: ID роли
  SELECT * FROM ev.team_role_signup WHERE team_id = $1 AND $2 IN (id, 0);
$_$;
SELECT pg_c('f', 'signup_by_team_role_id', 'Список подписок по команде и роли');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION signup_by_team_kind_id(a_id d_id, a_kind_id d_id DEFAULT 0) RETURNS SETOF team_role_signup STABLE LANGUAGE 'sql' AS
$_$
  -- a_id: ID команды
  -- a_kind_id: ID вида события
  SELECT * FROM ev.team_role_signup WHERE team_id = $1 AND $2 IN (kind_id, 0) ORDER BY team_id, group_sort, kind_id;
$_$;
SELECT pg_c('f', 'signup_by_team_kind_id', 'Список подписок по команде и виду события');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION role_signup_by_kind_id(a_id d_id, a_role_id d_id DEFAULT 0) RETURNS SETOF signup_role_info STABLE LANGUAGE 'sql' AS
$_$
  -- a_id: ID вида события
  -- a_role_id: ID роли
  SELECT * FROM ev.signup_role_info WHERE kind_id = $1 AND $2 IN (id, 0) ORDER BY id;
  -- TODO: добавить в wsd.role sort и везде в списках по нему сортировать роли
$_$;
SELECT pg_c('f', 'role_signup_by_kind_id', 'Список подписок по команде и роли');
