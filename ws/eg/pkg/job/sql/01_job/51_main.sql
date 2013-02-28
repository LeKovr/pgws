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
CREATE OR REPLACE FUNCTION current2past (DATE) RETURNS SETOF wsd.job LANGUAGE 'sql' AS
$_$ -- current2past - Удаление и возврат из wsd.job завершенных задач для помещения в wsd.job_past, валидных до наступления заданной даты
-- Вызов:
--   INSERT INTO wsd.job_past SELECT * FROM job.current2past(r_t.arg_date);
  DELETE FROM wsd.job USING job.status s, job.handler c
    WHERE status_id = s.id AND s.can_arc
      AND handler_id = c.id AND c.dust_days = 0
      AND validfrom < ($1 + 1)::timestamp
  RETURNING wsd.job.*
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION current2dust (DATE) RETURNS SETOF wsd.job LANGUAGE 'sql' AS
$_$ -- current2dust - Удаление и возврат из wsd.job завершенных задач для помещения в wsd.job_dust, валидных до наступления заданной даты
-- вызывается после current2past, поэтому строк с arc_days = 0 уже нет
  DELETE FROM wsd.job USING job.status s -- , job.handler c
    WHERE status_id = s.id AND s.can_arc
      -- AND handler_id = c.id AND c.arc_days > 0
      AND validfrom < ($1 + 1)::timestamp
  RETURNING wsd.job.*
$_$;


/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION todo2current (DATE) RETURNS SETOF wsd.job LANGUAGE 'sql' AS
$_$ -- Удаление и возврат из job.todo задач, валидных до завершения заданной даты
  DELETE FROM wsd.job_todo WHERE validfrom < ($1 + 1)::timestamp
  RETURNING *
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION create_at (
  a_validfrom TIMESTAMP
, a_handler_id  INTEGER
, a_status_id INTEGER
, a_parent    INTEGER
, a_date      DATE
, a_id        INTEGER DEFAULT NULL
, a_num       DECIMAL DEFAULT NULL
, a_more      TEXT    DEFAULT NULL
, a_date2     DATE    DEFAULT NULL
, a_id2       INTEGER DEFAULT NULL
, a_id3       INTEGER DEFAULT NULL
) RETURNS INTEGER
VOLATILE LANGUAGE 'plpgsql' AS
$_$
/*
  Создать задачу
  Вызов:
    job_id := job.create_at(handler_id, a_status, a_parent, a_date)
  Возвращаемое значение:
    id новой задачи, если у класса нет требования уникальности или задача с такими аргументами еще не зарегистрирована.
    Иначе - id зарегистрированной ранее задачи (с минусом, если она уже выполнена)
  TODO: проконтролировать соответствие аргументов описанию класса
  TODO: для status=11 exit_at=created_at=run_at
*/
  DECLARE
    v_status_id INTEGER;
    v_id        INTEGER;
    r_handler     job.handler%ROWTYPE;
    r           job.stored%ROWTYPE;
  BEGIN
    r_handler := job.handler(a_handler_id);
    IF r_handler IS NULL THEN
      RAISE EXCEPTION 'Unknown handler_id (%)',a_handler_id;
    END IF;
    IF r_handler.is_run_allowed THEN
      v_status_id := COALESCE(a_status_id, r_handler.def_status_id);
      IF NOT job.status_can_create(v_status_id) THEN
        RAISE EXCEPTION 'Incorrect initial status (%) for pkg.handler (%.%)', v_status_id, r_handler.pkg, r_handler.code;
      END IF;
    ELSE
      v_status_id := job.const_status_id_locked();
    END IF;

    IF r_handler.uk_bits > 0 THEN
      SELECT INTO r
        *
        FROM job.stored
        WHERE handler_id = a_handler_id
          AND status_id <> job.const_status_id_error()
          AND (r_handler.uk_bits &  1 = 0 OR arg_date   IS NOT DISTINCT FROM a_date)
          AND (r_handler.uk_bits &  2 = 0 OR arg_id     IS NOT DISTINCT FROM a_id)
          AND (r_handler.uk_bits &  4 = 0 OR arg_num    IS NOT DISTINCT FROM a_num)
          AND (r_handler.uk_bits &  8 = 0 OR arg_more   IS NOT DISTINCT FROM a_more)
          AND (r_handler.uk_bits & 16 = 0 OR arg_date2  IS NOT DISTINCT FROM a_date2)
          AND (r_handler.uk_bits & 32 = 0 OR arg_id2    IS NOT DISTINCT FROM a_id2)
          AND (r_handler.uk_bits & 64 = 0 OR arg_id3    IS NOT DISTINCT FROM a_id3)
      ;
      IF FOUND THEN
        -- оставляем как есть
        RETURN -r.id;
      END IF;
    END IF;
    -- TODO: проверка наличия всех ненулевых arg_*_type

    v_id := NEXTVAL('wsd.job_seq');

    IF a_validfrom::date > CURRENT_DATE AND r_handler.is_todo_allowed THEN
      INSERT INTO wsd.job_todo
        (id, status_id, prio, handler_id, created_by, validfrom, arg_date, arg_id, arg_num, arg_more, arg_date2, arg_id2, arg_id3)
        VALUES
        (v_id, v_status_id, r_handler.def_prio, a_handler_id, a_parent, a_validfrom, a_date, a_id, a_num, a_more, a_date2, a_id2, a_id3)
      ;
    ELSE
      INSERT INTO wsd.job
        (id, status_id, prio, handler_id, created_by, validfrom, arg_date, arg_id, arg_num, arg_more, arg_date2, arg_id2, arg_id3)
        VALUES
        (v_id, v_status_id, r_handler.def_prio, a_handler_id, a_parent, a_validfrom, a_date, a_id, a_num, a_more, a_date2, a_id2, a_id3)
      ;
    END IF;
    RETURN v_id;
  END
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION job.create (
  a_handler_id  INTEGER
, a_status_id INTEGER
, a_parent    INTEGER
, a_date      DATE
, a_id        INTEGER DEFAULT NULL
, a_num       DECIMAL DEFAULT NULL
, a_more      TEXT    DEFAULT NULL
, a_date2     DATE    DEFAULT NULL
, a_id2       INTEGER DEFAULT NULL
, a_id3       INTEGER DEFAULT NULL
) RETURNS INTEGER
VOLATILE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_date   DATE;
    r_handler job.handler%ROWTYPE;
  BEGIN
    v_date := COALESCE(a_date, CURRENT_DATE); -- если дата не указана - текущая
    r_handler := job.handler(a_handler_id);
    RETURN job.create_at(
      v_date + (r_handler.def_prio::TEXT || ' sec')::INTERVAL
    , a_handler_id
    , a_status_id
    , a_parent
    , v_date
    , a_id
    , a_num
    , a_more
    , a_date2
    , a_id2
    , a_id3
    );
  END
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION create_now (
  a_handler_id  INTEGER
, a_status_id INTEGER
, a_parent    INTEGER
, a_date      DATE    DEFAULT NULL
, a_id        INTEGER DEFAULT NULL
, a_num       DECIMAL DEFAULT NULL
, a_more      TEXT    DEFAULT NULL
, a_date2     DATE    DEFAULT NULL
, a_id2       INTEGER DEFAULT NULL
, a_id3       INTEGER DEFAULT NULL
) RETURNS INTEGER
VOLATILE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_date   DATE;
 BEGIN
    v_date := COALESCE(a_date, CURRENT_DATE); -- если дата не указана или NULL - используем текущую дату
    RETURN job.create_at(now()::timestamp - '1 sec'::interval, a_handler_id, a_status_id, a_parent, v_date, a_id, a_num, a_more, a_date2, a_id2, a_id3);
  END
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION next (a_pid INTEGER, a_id INTEGER DEFAULT 0) RETURNS SETOF wsd.job LANGUAGE 'plpgsql' AS
$_$
/*
  Выбрать следующую задачу для выполнения из числа имеющих статус 1 или 2 и validfrom меньше текущего момента.
  Если a_id<>0 - задачу с заданным task_id и статусом 6
  При успехе - зарегистрировать ее за процессом pid (если pid IS NOT NULL)
  Для задач со статусом 1, 2 и 8 производится контроль test.billing_stop

  Список задач сортируется по validfrom, prio, id
    Возвращаемое значение:
      описание задачи
  Вызов:
    SELECT * FROM job.task_next($$)
*/
  DECLARE
    v_stamp TIMESTAMP := CURRENT_TIMESTAMP;
    r  wsd.job%ROWTYPE;
  BEGIN
    IF a_id <> 0 THEN
      SELECT INTO r * FROM wsd.job
      WHERE id = a_id
        AND status_id IN (job.const_status_id_ready(), job.const_status_id_again(), job.const_status_id_forced())
      FOR UPDATE
      ;
    ELSE
      SELECT INTO r * FROM wsd.job
        WHERE status_id = job.const_status_id_urgent()
          AND validfrom <= v_stamp
        ORDER BY validfrom, prio, id
        LIMIT 1
        FOR UPDATE
      ;
      IF NOT FOUND THEN
        SELECT INTO r * FROM wsd.job
          WHERE status_id = job.const_status_id_again()
            AND validfrom <= v_stamp
          ORDER BY validfrom, prio, id
          LIMIT 1
          FOR UPDATE
        ;
        IF NOT FOUND THEN
          SELECT INTO r * FROM wsd.job
            WHERE status_id = job.const_status_id_ready()
              AND validfrom <= v_stamp
            ORDER BY validfrom, prio, id
            LIMIT 1
            FOR UPDATE
          ;
        END IF;
      END IF;
    END IF;

    IF NOT FOUND THEN
      RETURN;
    END IF;

    RETURN NEXT r;
    IF a_pid IS NULL THEN
      RETURN;
    END IF;
    UPDATE wsd.job SET
      run_pid = a_pid,
      run_ip = inet_client_addr(),
      run_at = clock_timestamp(), --CURRENT_TIMESTAMP,
      status_id = job.const_status_id_process()
      WHERE
        id = r.id
        AND status_id = r.status_id -- TODO: Удалить после проверки блокировки строки в FOR UPDATE
    ;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'ID %: cannot set process status', r.id;
    END IF;
    RETURN;
  END
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION wait_prio(
  a_job_id INTEGER
, a_handler_id INTEGER
, a_prio INTEGER
, a_date DATE DEFAULT NULL
, a_id INTEGER DEFAULT NULL
, a_num DECIMAL DEFAULT NULL
, a_more TEXT DEFAULT NULL
, a_date2 DATE DEFAULT NULL
, a_id2       INTEGER DEFAULT NULL
, a_id3       INTEGER DEFAULT NULL
) RETURNS INTEGER
VOLATILE LANGUAGE 'plpgsql' AS
$_$
/*
  Найти последнюю задачу того же типа, но с меньшим приоритетом,
  у которой статус <> 0 или 10
  и совпадают с указанными те аргументы, которые заданы (not null) при вызове функции
  При успехе - перевести текущую в режим ожидания найденной

    Вызов:
      IF job.wait_prio(a_id, r_t.handler_id, r_t.prio, r_t.arg_date, r_t.arg_id, r_t.arg_num, r_t.arg_more, r_t.arg_date2) IS NOT NULL THEN
        RETURN 1; -- задача отложена
      END IF;
    Возвращаемое значение:
      id найденной задачи или NULL
*/
  DECLARE
    v_id  INTEGER;
  BEGIN
    SELECT INTO v_id
      id
      FROM wsd.job
        WHERE job.status_can_run(status_id)
          AND prio < a_prio
          AND (a_date   IS NULL OR arg_date <= a_date)
          AND (a_id     IS NULL OR arg_id = a_id)
          AND (a_num    IS NULL OR arg_num = a_num)
          AND (a_more   IS NULL OR arg_more = a_more)
          AND (a_date2  IS NULL OR arg_date2 = a_date2)
          AND (a_id2    IS NULL OR arg_id2 = a_id2)
          AND (a_id3    IS NULL OR arg_id3 = a_id3)
        ORDER BY validfrom DESC, prio DESC, id DESC
        LIMIT 1
    ;
    IF FOUND THEN
      UPDATE wsd.job SET
        status_id = job.const_status_id_waiting()
      , waiting_for = v_id
        WHERE id = a_job_id
      ;
      RAISE DEBUG 'job.wait_prio: delay % for %', a_job_id, v_id;
      RETURN v_id;
    END IF;
    RETURN NULL;
  END
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION finish(a_id INTEGER, a_status_id INTEGER, a_exit_text TEXT) RETURNS BOOL VOLATILE LANGUAGE 'plpgsql' AS
$_$
/*
  Регистрация завершения выполнения задачи с указанным кодом. Если задача была активна - меняется статус ожидающих задач.
  Если задана текстовая информация - она сохраняется в отдельной таблице job.error
  Вызов:
    SELECT job.task_end(a_id, status_id, error_text)
  Возвращаемое значение:
    true, если указанная задача была активна

  TODO: реализовать вариант "отказ выполнения", который будет возвращать server() для не-sql задач
   (или сделать фильтрацию по классу задач)
*/
  DECLARE
    v_found BOOL;
    r           wsd.job%ROWTYPE;
  BEGIN

    IF a_status_id = job.const_status_id_waiting() THEN
      -- задача уже переведена в режим ожидания
      -- проверить, что та, которую ждем, еще не выполнилась
      SELECT INTO r * FROM wsd.job
        WHERE status_id = job.const_status_id_waiting()
          AND id = a_id
        FOR UPDATE
      ;
      IF FOUND THEN
        r := job.current(r.waiting_for);
        IF NOT job.status_can_run(r.status_id) THEN
          UPDATE wsd.job SET
            status_id = job.const_status_id_again()
            WHERE id = a_id
          ;
        END IF;
      END IF;
      RETURN FALSE;
    END IF;

    -- Сохраним новый статус
    UPDATE wsd.job SET
      status_id = a_status_id,
      exit_at = clock_timestamp()
      WHERE id = a_id
        AND status_id = job.const_status_id_process() -- статус меняем только у выполняющихся задач
    ;
    v_found := FOUND;
    -- Сохраним описание ошибки отдельно
    IF a_exit_text IS NOT NULL THEN
      INSERT INTO job.srv_error (job_id, status_id, exit_text)
        VALUES (a_id, a_status_id, a_exit_text)
      ;
    END IF;
    RETURN v_found;
  END
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION finished (a_id INTEGER) RETURNS VOID VOLATILE LANGUAGE 'sql' AS
$_$
  -- finished - Изменить статус ожидающим задачам
  UPDATE wsd.job SET
    status_id = job.const_status_id_again()
    WHERE waiting_for = $1 /* a_id */
      AND status_id = job.const_status_id_waiting()
  ;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION server (a_pid INTEGER, a_id INTEGER DEFAULT 0) RETURNS INTEGER VOLATILE LANGUAGE 'plpgsql' AS
$_$
/*
  Тестовая версия сервера обработки задач
  Вызов:
    SELECT job.server($$, $task_id)
    Если $task_id<>0 - выполняется задача с заданным id
*/
  DECLARE
    v_job_count INTEGER :=0;
    r_job  wsd.job%ROWTYPE;
    r_handler job.handler%ROWTYPE;
    v_cmd  TEXT;
    v_err  TEXT;
    v_ret  INTEGER;
    v1 INTEGER;
    v2 INTEGER;
  BEGIN
    LOOP
      SELECT INTO r_job * FROM job.next(a_pid, a_id);
      IF NOT FOUND THEN --OR r_task.handler_id = 7 THEN
        EXIT;
      END IF;
      r_handler := job.handler(r_job.handler_id);
      RAISE DEBUG 'job.server C: % D: % ID: % NUM: % MORE: % D2: % (%) *************', r_job.handler_id, r_job.arg_date, r_job.arg_id, r_job.arg_num, r_job.arg_more, r_job.arg_date2, r_handler.name;
      v_err := NULL;
      IF r_handler.is_sql THEN
        v_cmd := ws.sprintf('SELECT %s.%s(%s)', r_handler.pkg, r_handler.code, r_job.id::text);
        BEGIN
          EXECUTE v_cmd INTO v_ret;
        EXCEPTION WHEN OTHERS THEN
          v_ret := job.const_status_id_error();
          v_err := SQLERRM;
        END;
      ELSE
        v_ret := job.const_status_id_idle();
      END IF;
      PERFORM job.finish(r_job.id, v_ret, v_err);
      PERFORM job.finished(r_job.id);
      IF v_err IS NULL THEN
        v_job_count := v_job_count + 1;
      END IF;
    END LOOP;
    RETURN v_job_count;
  END
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION cron() RETURNS VOID VOLATILE LANGUAGE 'sql' AS
$_$
  UPDATE wsd.job_cron SET
    prev_at = run_at
  , run_at = CURRENT_TIMESTAMP
    WHERE is_active
  ;
$_$;

/* ------------------------------------------------------------------------- */
