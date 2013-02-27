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

    Методы диспетчера Job
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION today (a_id INTEGER) RETURNS INTEGER VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- today - Задача завершения дня. Arg_date этой задачи - текущая дата диспетчера
  -- a_id: ID задачи
  DECLARE
    r           wsd.job%ROWTYPE;
  BEGIN
    r := job.current(a_id);
    -- если есть задача с меньшим приоритетом - ждем ее
    IF job.wait_prio(a_id, r.handler_id, r.prio, r.arg_date) IS NOT NULL THEN
      RETURN job.const_status_id_waiting();
    END IF;

    -- создать задачу на очистку
    PERFORM job.create(job.handler_id('job.clean'), null, a_id, r.arg_date);

    -- создать задачу "сегодня" для следующего дня
    PERFORM job.create(r.handler_id, null, a_id, r.arg_date + 1);

    -- Перенести из wsd.job_todo задачи завтрашнего дня
    INSERT INTO wsd.job SELECT * FROM job.todo2current(r.arg_date + 1);

    -- TODO: для массовых расчетов может портебоваться ассинхронно получать статус
    -- PERFORM pg_notify('job_new_day', (r.arg_date + 1)::TEXT);

    RETURN job.const_status_id_success();
  END
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION clean (a_id INTEGER) RETURNS INTEGER VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- handler_core_clean - Очистка wsd.job от выполненных задач
  -- a_id: ID задачи
  DECLARE
    r           wsd.job%ROWTYPE;
  BEGIN
    r := job.current(a_id);
    -- В журнал если выполнено и handler.dust_days = 0
    INSERT INTO wsd.job_past SELECT * FROM job.current2past(r.arg_date);

    -- Оседание пыли (Удаляем устаревшее)
    DELETE FROM wsd.job_dust WHERE r.arg_date - validfrom::date > job.handler_dust_days(handler_id);

    -- В архив если выполнено
    INSERT INTO wsd.job_dust SELECT * FROM job.current2dust(r.arg_date);

    RETURN job.const_status_id_success();
  END
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION stop (a_id INTEGER) RETURNS INTEGER VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- handler_core_stop - Запрет выполнения всех классов задач.
  -- Применяется в тестах внутри транзакций, завершающихся ROLLBACK
  -- После остановки будут выполнены только ранее созданные задачи
  -- Новые задачи будут при создании получать статус 8
  -- Отмена действий обработчика производится вручную командой
  -- UPDATE job.handler SET is_run_allowed = TRUE WHERE NOT is_run_allowed;
  -- ВАЖНО: поле is_run_allowed предназначено только для обработчика job.stop
  -- перед созданием задачи надо убедиться, что оно везде = FALSE
  -- a_id: ID задачи
  DECLARE
    r           wsd.job%ROWTYPE;
    v_cnt INTEGER;
  BEGIN
    r := job.current(a_id);
    -- если есть задача с меньшим приоритетом - ждем ее
    IF job.wait_prio(a_id, r.handler_id, r.prio, r.arg_date) IS NOT NULL THEN
      RETURN job.const_status_id_waiting();
    END IF;

    UPDATE job.handler SET is_run_allowed = FALSE WHERE is_run_allowed;
    GET DIAGNOSTICS v_cnt = ROW_COUNT;
    IF v_cnt > 0 THEN
      RETURN job.const_status_id_success();
    ELSE
      RETURN job.const_status_id_idle();
    END IF;
  END
$_$;
