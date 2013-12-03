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

--асинхронность, создаём задание для job и выходим
/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ev.tr_send_notifications() RETURNS trigger LANGUAGE 'plpgsql' AS
$_$
  BEGIN
    PERFORM job.create( job.handler_id('ev.send_notifications'), NULL, -2, NULL, NEW.id );
    RETURN NEW;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ev.tr_fire_user_login()
  RETURNS trigger LANGUAGE 'plpgsql' AS
$_$
  DECLARE
   v_id INTEGER;
   v_name TEXT;
  BEGIN
    v_id := NEXTVAL('wsd.event_reason_seq');
    SELECT INTO v_name name FROM wsd.account WHERE id = NEW.account_id;
--    PERFORM ev.create(1, NEW.id, v_id, ev.const_status_id_draft(), NEW.account_id);
    PERFORM ev.create(1, NEW.id, v_id, ev.const_status_id_rcpt(), a_arg_id := NEW.account_id, a_arg_name := v_name);
    PERFORM ev.create(3, NEW.id, v_id, ev.const_status_id_rcpt(), a_arg_id := NEW.account_id, a_arg_id2 := NEW.id, a_arg_name := v_name, a_arg_name2 := NEW.id::TEXT);
    IF NEW.team_id IS NOT NULL THEN
      PERFORM ev.create(2, NEW.id, v_id, ev.const_status_id_rcpt(), a_arg_id := NEW.account_id, a_arg_id2 := NEW.team_id,
      a_arg_name := v_name, a_arg_name2 := (SELECT name FROM wsd.team WHERE id = NEW.team_id));
    END IF;
    RETURN NEW;
  END;
$_$;


/* ------------------------------------------------------------------------- */
/*
CREATE OR REPLACE FUNCTION ev.fire_user_login( a_user_id ws.d_id32 )
  RETURNS wsd.event LANGUAGE 'plpgsql' AS
$_$
  -- a_user_id: ID аккаунта, выполнившего вход в систему
  DECLARE
    r_account wsd.account;  
    r_event   wsd.event;
  BEGIN
      -- создаём событие user login
      INSERT INTO wsd.event( status_id, kind_id, created_by, class_id )
        VALUES ( ev.const_status_id_draft(), 1, a_user_id, 3 ) RETURNING * INTO r_event;
      -- выбираем пользователя с указанным в событии id
      SELECT * INTO r_account FROM wsd.account WHERE id = a_user_id;
      -- если логин начинается с pro_ то спецификация 1
      IF position('pro_' in r_account.login) = 1 THEN
        INSERT INTO wsd.event_spec ( event_id, spec_id ) VALUES ( r_event.id, 1 );
      -- иначе 0
      ELSE
        INSERT INTO wsd.event_spec ( event_id, spec_id ) VALUES ( r_event.id, 0 );
      END IF;
      UPDATE wsd.event SET status_id = ev.const_status_id_rcpt() WHERE id = r_event.id;
    RETURN r_event;
  END;
$_$;
*/
/* ------------------------------------------------------------------------- */
/*
CREATE OR REPLACE FUNCTION ev.create_user_login( a_user_id ws.d_id32 )
  RETURNS wsd.event LANGUAGE 'sql' AS
$_$
  -- a_user_id: ID аккаунта, выполнившего вход в систему
  -- создаём событие user login
  INSERT INTO wsd.event( status_id, kind_id, created_by, class_id )
    VALUES ( ev.const_status_id_draft(), 1, $1, 3 ) RETURNING *;
$_$;

*/