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

    Триггеры
*/

CREATE OR REPLACE FUNCTION ev.tr_send_notifications()
  RETURNS trigger LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_account_id ws.d_id32; 
    v_role_id ws.d_id32;  
  BEGIN
    -- определяем список адресатов события
    FOR v_account_id, v_role_id IN SELECT a.id, r.id FROM wsd.account a 
      JOIN ev.account_role ar ON ar.account_id = a.id 
      JOIN ev.role r ON r.id = ar.role_id
      JOIN wsd.event_role_signup ers ON ers.role_id = ar.role_id AND ers.kind_id = NEW.kind_id
      -- specification
      JOIN wsd.event_spec es ON es.event_id = NEW.id AND es.spec_id = ers.spec_id LOOP
      -- создаём системные уведомления
      INSERT INTO wsd.event_notify ( event_id, account_id, role_id, cause_id )
        VALUES ( NEW.id, v_account_id, v_role_id, 1 );
    END LOOP;
    -- TODO меняем статус события?
    -- TODO создаём задания на рассылку уведомлений согласно формату уведомлений
    RETURN NEW;
  END;
$_$;

CREATE OR REPLACE FUNCTION ev.tr_fire_user_login()
  RETURNS trigger LANGUAGE 'plpgsql' AS
$_$
  BEGIN
    PERFORM ev.fire_user_login( NEW.account_id );
    RETURN NEW;
  END;
$_$;
