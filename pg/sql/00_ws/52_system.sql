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

    Функции объектов класса system
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION system_status() RETURNS d_id32 STABLE LANGUAGE 'sql' AS
$_$
  SELECT 1::ws.d_id32 -- TODO: брать актуальный статус из таблицы (после готовности поддержки статуса "Обслуживание")
$_$;
SELECT pg_c('f', 'system_status', 'Статус системы');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION system_acl(a__sid d_sid DEFAULT NULL) RETURNS SETOF d_acl STABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
  BEGIN
    -- проверки прав сессии на объект
    IF COALESCE(a__sid, '') = '' THEN
      RETURN NEXT 1::ws.d_acl;
      RETURN;
    END IF;

    RETURN NEXT 2::ws.d_acl; --TODO: Сервис, Админ, клиент?

    RETURN;
  END
$_$;
SELECT pg_c('f', 'system_acl', 'ACL sid для системы');

/* ------------------------------------------------------------------------- */
-- вернуть описание сервера, отвечающего за экземпляр текущего класса
CREATE OR REPLACE FUNCTION system_server() RETURNS SETOF server STABLE LANGUAGE 'sql' AS
$_$
  SELECT * FROM ws.server WHERE id = 1
$_$;


/* ------------------------------------------------------------------------- */
