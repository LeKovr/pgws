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

    Реестр свойств. Добавление владельца

*/

/* ------------------------------------------------------------------------- */
INSERT INTO cfg.prop_group (pogc, sort, name) VALUES
  (job.const_job_group_prop(),   4, 'Демон Job')
;

/* ------------------------------------------------------------------------- */
INSERT INTO cfg.prop_owner (pogc, poid, sort, name) VALUES
  (job.const_job_group_prop(),   1,  1,  'Первичный Демон Job')
;

/* ------------------------------------------------------------------------- */
UPDATE cfg.prop SET pogc_list = array_append(pogc_list, job.const_job_group_prop()) WHERE code IN (
  'ws.daemon.startup.pm.n_processes'
, 'ws.daemon.startup.pm.die_timeout'
);

/* ------------------------------------------------------------------------- */
INSERT INTO cfg.prop (code,                 pogc_list,               def_value, name) VALUES
  ('ws.daemon.mgr.cron_every',          ARRAY[job.const_job_group_prop()],               '60',     'Запуск cron, если номер секунды в сутках кратен заданной')
, ('ws.daemon.mgr.cron_predict',        ARRAY[job.const_job_group_prop()],               '50',     'За сколько секунд до запуска cron резервировать процесс')
, ('ws.daemon.mgr.mem_size',            ARRAY[job.const_job_group_prop()],               '131072', 'Объем разделяемой памяти для очереди выполненных задач, байт')
, ('ws.daemon.mgr.reload_key',          ARRAY[job.const_job_group_prop()],               '',       'Пароль рестарта демона')

, ('ws.daemon.mgr.listen_wait',         ARRAY[job.const_job_group_prop()],               '60',     'Время ожидания уведомления внутри итерации, сек')
, ('ws.daemon.mgr.listen.job',          ARRAY[job.const_job_group_prop()],               '',       'Канал уведомлений (NOTIFY) о добавлении задания')

, ('ws.daemon.mgr.listen.stat',         ARRAY[job.const_job_group_prop()],               '',       'Канал команд (NOTIFY) об обновлении статистики процессов')
, ('ws.daemon.mgr.listen.reload',       ARRAY[job.const_job_group_prop()],               '',       'Канал команд (NOTIFY) о рестарте процессов')

,  ('ws.daemon.log.syslog.job.(default,call,sid,acl,cache,validate)',   ARRAY['fe'],  '3', 'Уровень отладки запросов JOB')
;

