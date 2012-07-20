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

SELECT ws.test('job_empty');

/*

-- запросить загрузку процессами статистики в БД
select job.mgr_stat_reload();

-- посмотреть статистику
select * from job.mgr_stat;
select * from job.mgr_error;

-- выполнить обработку 100 уведомлений
select job.mgr_test_event(1000, 1100);



-- отправить команду рестарта процессов
SELECT pg_notify('job_reload', ws.prop_value('job',1,'ws.daemon.mgr.reload_key'));

*/
