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

    Создание объектов в схеме wsd
*/

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.pkg_script_protected (code, pkg, ver) VALUES (:'FILE', :'PKG', :'VER');

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.job (
  id          INTEGER PRIMARY KEY         -- ID задачи
, validfrom   TIMESTAMP(0)  NOT NULL      -- дата активации
, prio        INTEGER NOT NULL            -- фактический приоритет
, class_id    INTEGER NOT NULL            -- класс задачи (обработчика)
, status_id   INTEGER NOT NULL            -- текущий статус
, created_by  INTEGER                     -- id задачи/сессии, создавшей
, waiting_for INTEGER                     -- id задачи, которую ждем
, arg_id      INTEGER                     -- аргумент id
, arg_date    DATE                        -- аргумент date
, arg_num     DECIMAL                     -- аргумент num
, arg_more    TEXT                        -- аргумент more
, arg_id2     INTEGER                     -- аргумент id2
, arg_date2   DATE                        -- аргумент, 2я дата для периодов
, arg_id3     INTEGER                     -- аргумент id3
, created_at  TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP  -- время создания
, run_pid     INTEGER                     -- pid выполняющего процесса
, run_ip      INET                        -- ip хоста выполняющего процесса
, run_at      TIMESTAMP(0)                -- время начала выполнения
, exit_at     TIMESTAMP(0)                -- время завершения выполнения
, exit_code   INTEGER NOT NULL DEFAULT 0  -- код завершения (битовая маска: 0-wait, 1-ignore)
);
SELECT pg_c('r', 'wsd.job',  'Задачи текущего дня')
, pg_c('c', 'wsd.job.id'          , 'ID задачи')
, pg_c('c', 'wsd.job.validfrom'   , 'дата активации')
, pg_c('c', 'wsd.job.prio'        , 'фактический приоритет')
, pg_c('c', 'wsd.job.class_id'    , 'класс задачи (обработчика)')
, pg_c('c', 'wsd.job.status_id'   , 'текущий статус')
, pg_c('c', 'wsd.job.created_by'  , 'id задачи/сессии, создавшей')
, pg_c('c', 'wsd.job.waiting_for' , 'id задачи, которую ждем')
, pg_c('c', 'wsd.job.arg_id'      , 'аргумент id')
, pg_c('c', 'wsd.job.arg_date'    , 'аргумент date')
, pg_c('c', 'wsd.job.arg_num'     , 'аргумент num')
, pg_c('c', 'wsd.job.arg_more'    , 'аргумент more')
, pg_c('c', 'wsd.job.arg_id2'     , 'аргумент id2')
, pg_c('c', 'wsd.job.arg_date2'   , 'аргумент, 2я дата для периодов')
, pg_c('c', 'wsd.job.arg_id3'     , 'аргумент id3')
, pg_c('c', 'wsd.job.created_at'  , 'время создания')
, pg_c('c', 'wsd.job.run_pid'     , 'pid выполняющего процесса')
, pg_c('c', 'wsd.job.run_ip'      , 'ip хоста выполняющего процесса')
, pg_c('c', 'wsd.job.run_at'      , 'время начала выполнения')
, pg_c('c', 'wsd.job.exit_at'     , 'время завершения выполнения')
, pg_c('c', 'wsd.job.exit_code'   , 'код завершения (битовая маска: 0-wait, 1-ignore)')
;

/* ------------------------------------------------------------------------- */
CREATE SEQUENCE wsd.job_seq;
ALTER TABLE wsd.job ALTER COLUMN id SET DEFAULT NEXTVAL('wsd.job_seq');

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.job_todo (LIKE wsd.job INCLUDING ALL);
CREATE TABLE wsd.job_past (LIKE wsd.job INCLUDING CONSTRAINTS INCLUDING COMMENTS);
CREATE TABLE wsd.job_dust (LIKE wsd.job INCLUDING CONSTRAINTS INCLUDING COMMENTS);

SELECT
  pg_c('r', 'wsd.job_todo',  'Задачи будущих дней')
, pg_c('r', 'wsd.job_past',  'Архив выполненных задач')
, pg_c('r', 'wsd.job_dust',  'Временное хранение выполненных задач до удаления')
;
