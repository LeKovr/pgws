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

    Интеграция с пакетом ev: подписка на события авторизации
*/

INSERT INTO wsd.event_role_signup (role_id, kind_id, spec_id, is_on) VALUES 
  (2, 1, 0, FALSE) -- TODO: подписка для роли 2и3 всегда имеет NOT is_on - она включается только при  INSERT INTO wsd.event_signup
, (3, 1, 0, FALSE)
, (8, 2, 0, TRUE)
, (9, 3, 0, TRUE) -- этот вид позволяет задать spec_id - ID пользователя
;

/* Настройки подписок EV*/
INSERT INTO  wsd.event_signup (account_id, role_id, kind_id, spec_id, is_on, prio) values 
  (8, 8, 2, 0, false, 1) -- user 8 отменил подписку
, (7, 3, 1, 0, true,  1) -- user 7 включил подписку
;
