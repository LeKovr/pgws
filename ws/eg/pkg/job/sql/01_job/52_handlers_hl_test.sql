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

    Обработчики для тестов высокой нагрузки
*/

/* ------------------------------------------------------------------------- */
-- Запуск тестов
/*
DELETE FROM wsd.job      WHERE handler_id IN (1,2,7,8,9);
DELETE FROM wsd.job_dust WHERE handler_id IN (1,2,7,8,9);
DELETE FROM wsd.job_past WHERE handler_id IN (1,2,7,8,9);
DELETE FROM wsd.job_todo WHERE handler_id IN (1,2,7,8,9);
UPDATE job.handler SET is_run_allowed = TRUE WHERE NOT is_run_allowed;

SELECT 
  job.create(job.handler_id('job.test_mgr'), null, -2, '2013-01-20', a_id :=10, a_id2 :=100, a_id3 := 1)
, job.create(job.handler_id('job.today'), 2, -2, '2013-01-20')
, job.create(job.handler_id('job.stop'), NULL, -2, '2013-01-25')
;

*/

/* ------------------------------------------------------------------------- */
-- Анвлиз результатов
/*

SELECT arg_date, status_id, count(1), sum(exit_at-run_at), avg(exit_at-run_at), min(exit_at-run_at), max(exit_at-run_at) 
FROM wsd.job_dust WHERE handler_id=8 GROUP BY arg_date,status_id ORDER BY 1,2;

SELECT handler_id, count(1), sum(exit_at-run_at), avg(exit_at-run_at), min(exit_at-run_at), max(exit_at-run_at) 
FROM wsd.job_dust GROUP BY handler_id ORDER BY handler_id;

SELECT max(exit_at) - min(run_at) AS clock_time FROM wsd.job_dust WHERE handler_id IN (8,9);

*/
/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION test_mgr (a_id INTEGER) RETURNS INTEGER VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- test_mgr - генератор тестовых задач
  -- Применяется в нагрузочных тестах
  -- a_id: ID задачи

  -- Аргументы:
  -- arg_id --  значение arg_id создаваемых задач
  -- arg_id2 -- кол-во создаваемых задач 
  -- arg_id3 -- (если > 0) - значение pg_sleep после выполнения задачи

  DECLARE
    r           wsd.job%ROWTYPE;
    v_cnt INTEGER;
  BEGIN
    r := job.current(a_id);

    IF job.wait_prio(a_id, r.handler_id, r.prio, r.arg_date) IS NOT NULL THEN
      RETURN job.const_status_id_waiting();
    END IF;

    -- создать подзадачи количеством arg_id2
    -- передав каждой в arg_id значение arg_id3 (сколько раз выполниться)
    PERFORM job.create(job.handler_id('job.test_run'), null, a_id, r.arg_date, r.arg_id) FROM generate_series(1, r.arg_id2); 

    -- создать свою задачу следующей датой
    PERFORM job.create(r.handler_id, null, a_id, r.arg_date + 1, a_id := r.arg_id, a_id2 := r.arg_id2, a_id3 := r.arg_id3); 

    IF COALESCE(r.arg_id3, 0) > 0 THEN
      -- дадим диспетчеру время разгрузить очередь
      PERFORM pg_sleep(r.arg_id3);
    END IF;

    RETURN job.const_status_id_success();
  END
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION test_run (a_id INTEGER) RETURNS INTEGER VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- test_run - обработчик тестовой задачи
  -- Применяется в нагрузочных тестах
  -- a_id: ID задачи

  -- Аргументы:
  -- arg_id --  кол-во итераций "выполнился - создал новую"
  DECLARE
    r           wsd.job%ROWTYPE;
  BEGIN
    r := job.current(a_id);

    -- некоторая операция по изменению БД
    UPDATE wsd.job SET arg_num = COALESCE (arg_num, 0) + 1 WHERE id = r.created_by;

    IF r.arg_id > 1 THEN
      -- повторяем выполнение в новой задаче
      PERFORM job.create(r.handler_id, null, a_id, r.arg_date, r.arg_id - 1); 
    END IF;

    RETURN job.const_status_id_success();
  END
$_$;
