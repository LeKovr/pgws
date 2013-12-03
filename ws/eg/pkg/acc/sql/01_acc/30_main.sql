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

    Методы, используемые представлениями
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION class_link_name(
  a_class_id d_class
, a_id       d_id32
) RETURNS d_string STABLE LANGUAGE 'sql' AS
$_$
  -- a_class_id: ID класса
  -- a_id:       ID связи
  SELECT name FROM acc.class_link WHERE class_id = $1 AND id = $2;
$_$;
SELECT pg_c('f', 'class_link_name', 'Название связи класса');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION team_link_name(a_id d_id32) RETURNS d_string STABLE LANGUAGE 'sql' AS
$_$
  -- a_id: ID связи
  SELECT name FROM acc.team_link WHERE id = $1
$_$;
SELECT pg_c('f', 'team_link_name', 'Название связи команды');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION last_visit(
  a_id      d_id
, a_team_id d_id DEFAULT NULL
) RETURNS timestamp STABLE LANGUAGE 'sql' AS
$_$
  -- a_id:      ID пользователя
  -- a_team_id: ID команды
  SELECT 
      MAX(updated_at) 
    FROM wsd.session 
    WHERE account_id = $1
      AND (team_id = $2 OR $2 IS NULL)
  ;
$_$;
SELECT pg_c('f', 'last_visit', 'Последнее посещение сайта пользователем');
