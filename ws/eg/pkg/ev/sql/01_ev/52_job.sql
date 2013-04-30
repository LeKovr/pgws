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

    Обработчики job для диспетчера Ev
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION process_login (a_id INTEGER)
  RETURNS INTEGER VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- handler_send_notifications - обработчик рассылки уведомлений
  -- a_id: ID задачи
  DECLARE
    r_job        wsd.job%ROWTYPE;
    v_account_id ws.d_id32; 
    v_role_id    ws.d_id32;  
    r_event      wsd.event%ROWTYPE;
  BEGIN
    r_job := job.current(a_id);
    FOR r_event IN SELECT * 
      FROM wsd.event 
      WHERE reason_id = r_job.arg_id
    LOOP
      INSERT INTO wsd.event_notify ( event_id, account_id, role_id, cause_id )
        SELECT r_event.id, account_id, role_id
        , CASE WHEN is_own THEN 1 ELSE 2 END 
        FROM ev.signup
        WHERE kind_id = r_event.kind_id
          AND is_on
      ;
      -- TODO: создать задачи на рассылку
      -- (обновить статус - триггер сделает остальное?)
    END LOOP;
    
    RETURN job.const_status_id_success();
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION send_notifications (a_id INTEGER)
  RETURNS INTEGER VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- handler_send_notifications - обработчик рассылки уведомлений
  -- a_id: ID задачи
  DECLARE
    r_job        wsd.job%ROWTYPE;
    v_account_id ws.d_id32; 
    v_role_id    ws.d_id32;  
		r_event      wsd.event%ROWTYPE;
  BEGIN
    r_job := job.current(a_id);
		SELECT * FROM wsd.event WHERE id = r_job.arg_id INTO r_event;
    -- определяем список адресатов события
    FOR v_account_id, v_role_id IN SELECT a.id, r.id FROM wsd.account a 
      JOIN wsd.account_team at ON at.account_id = a.id 
      JOIN wsd.role r ON r.id = at.role_id
      JOIN wsd.event_role_signup ers ON ers.role_id = at.role_id AND ers.kind_id = r_event.kind_id
      -- specification
      JOIN wsd.event_spec es ON es.event_id = r_event.id AND es.spec_id = ers.spec_id LOOP
      -- создаём системные уведомления
      INSERT INTO wsd.event_notify ( event_id, account_id, role_id, cause_id )
        VALUES ( r_event.id, v_account_id, v_role_id, 1 );
    END LOOP;
    -- TODO меняем статус события?
    -- TODO создаём задания на рассылку уведомлений согласно формату уведомлений
    RETURN job.const_status_id_success();
  END;
$_$;

