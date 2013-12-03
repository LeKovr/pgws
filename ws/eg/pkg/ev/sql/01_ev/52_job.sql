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

    Обработчики JOB для диспетчера EV
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION send_notifications (a_id INTEGER) RETURNS INTEGER VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- handler_send_notifications - обработчик рассылки уведомлений
  -- a_id: ID задачи
  DECLARE
    r_job        wsd.job%ROWTYPE;
    v_account_id ws.d_id32;
    v_role_id    ws.d_id32;
    v_is_own    ws.d_id32;
    r_event      wsd.event%ROWTYPE;
  BEGIN
    r_job := job.current(a_id);
    SELECT * FROM wsd.event WHERE id = r_job.arg_id INTO r_event;

    -- определяем список адресатов события
    FOR v_account_id, v_role_id, v_is_own IN SELECT 
      s.account_id, s.role_id, CASE WHEN s.is_own THEN 1 ELSE 2 END 
        FROM ev.signup s
 --         JOIN wsd.event_spec es ON (es.event_id = r_event.id AND es.spec_id = s.spec_id) -- TODO: вернуть когда будет реализованно
        WHERE s.kind_id = r_event.kind_id AND s.is_on
    LOOP

      -- создаём уведомления
      INSERT INTO wsd.event_notify ( event_id, account_id, role_id, cause_id )
        VALUES ( r_event.id, v_account_id, v_role_id, v_is_own);

    END LOOP;
    -- TODO меняем статус события?
    -- TODO создаём задания на рассылку уведомлений согласно формату уведомлений

    RETURN job.const_status_id_success();
  END;
$_$;
SELECT pg_c('f', 'send_notifications', 'Создание уведомления');
