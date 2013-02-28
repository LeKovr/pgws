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

    Тесты
*/

/* ------------------------------------------------------------------------- */
\set SID '\'; \''

SELECT ws.test('job_single_server');

-- запуск тестов завершается ROLLBACK
TRUNCATE wsd.job, wsd.job_dust, wsd.job_past, wsd.job_todo;

SELECT
  job.create(job.handler_id('job.today'), NULL, -2, '2012-08-05') > 0 AS "today created"
  , job.create(job.handler_id('job.stop'), NULL, -2, '2012-08-14') > 0 AS "stop created"
;
SELECT job.server(-1) AS job_count;

SELECT validfrom, handler_id, status_id, arg_id, arg_date, arg_num, arg_more, arg_id2, arg_date2, arg_id3
  FROM wsd.job_dust
  WHERE handler_id < 10
    AND validfrom < '2012-08-20'
  ORDER BY id
;

SELECT validfrom, handler_id, status_id, arg_id, arg_date, arg_num, arg_more, arg_id2, arg_date2, arg_id3
  FROM wsd.job
  WHERE handler_id < 10
    AND validfrom < '2012-08-20'
  ORDER BY id
;

/*

-- запросить загрузку процессами статистики в БД
select job.mgr_stat_reload();

-- посмотреть статистику
select * from job.mgr_stat;
select * from job.mgr_error;

-- выполнить обработку 100 уведомлений
select job.mgr_test_event(1000, 1100);


select
  job.create(job.handler_id('job.today'), null, -2, '2012-08-05') > 0
  , job.create(job.handler_id('job.stop'), null, -2, '2012-08-14') > 0
;





select job.create(job.handler_id('acc.mailtest'), null, -2, '2012-08-16');

-- отправить команду рестарта процессов
SELECT pg_notify('job_reload', cfg.prop_value('job',1,'ws.daemon.mgr.reload_key'));

*/
