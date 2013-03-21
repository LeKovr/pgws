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
, ws.class_status_name('account', a.status_id) AS status_name
  FROM wsd.account a
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW account_attr_pub AS SELECT
  id
, status_id
, name
, created_at
, status_name
  FROM acc.account_attr
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW session_info AS SELECT
  s.*
  , a.status_id
  , a.name AS account_name
  , r.name AS role_name
-- team_id
-- team_name
  FROM wsd.session s
    JOIN wsd.account a ON (a.id = s.account_id)
    JOIN wsd.role r ON (r.id = s.role_id)
;


/* ------------------------------------------------------------------------- */
