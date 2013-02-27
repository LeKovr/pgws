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

    Данные основных таблиц пакета
*/

/* ------------------------------------------------------------------------- */
INSERT INTO arg_type (id, name) VALUES
  (job.const_arg_type_none(), 'Нет')
, (2, 'Дата документа')
, (3, 'ID учетной записи')
, (4, 'ID группы')
/*
, (3, 'Сумма документа')
, (4, 'Тариф')
, (5, 'Количество дней')
, (6, 'Дата завершения средств')
, (7, 'Дата завершения скидки 100%')
, (8, 'Количество месяцев')
, (9, 'Размер скидки')
, (10, 'Комментарий')
*/
;

/* ------------------------------------------------------------------------- */
INSERT INTO status (id, can_create, can_run, can_arc, name, anno) VALUES
  (/* 0*/  1, true,   false,  false,  'Черновик',       'задача в стадии создания')
, (/* 1*/  2, true,   true,   false,  'К исполнению',   'задача готова к исполнению')
, (/* 2*/  3, false,  true,   false,  'После ожидания', 'ожидавшаяся задача завершена')
, (/* 3*/  4, false,  true,   false,  'Выполняется',    'происходит выполнение задачи')
, (/* 4*/  5, false,  true,   false,  'Ожидает',        'ожидает выполнения связанной задачи')
, (/* 5*/  6, true,   false,  true,   'Недоступна',     'выполнение недоступно (например - по недостатку баланса)')
, (/* 6*/  7, true,   false,  false,  'Вне очереди',    'задача уже выполняется отдельным процессом')
, (/* 7*/  8, true,   false,  true,   'Заблокирована',  'выполнение класса заблокировано админом')
, (/* 8*/  9, true,   false,  false,  'Срочная',        'выполнение точно в заданный срок')
, (/*10*/ 10, false,  false,  true,   'Завершена',      'выполнение завершено успешно')
, (/*11*/ 11, true,   false,  true,   'Протокол',       'задача не предназначена для выполнения')
, (/*-1*/ 12, false,  false,  true,   'Ошибка',         'выполнение невозможно из-за ошибки')
, (/* */  13, false,  false,  true,   'Нет изменений',  'задача завершена, но действий не производилось')
;

/* ------------------------------------------------------------------------- */
INSERT INTO handler (id, code, def_prio, arg_date_type, dust_days, name) VALUES
  (1, 'stop',  86390, 1,  0, 'Остановка диспетчера')
, (2, 'clean',  1, 2,  7, 'Очистка списка текущих задач')
, (7, 'test_mgr',  3, 1,  100, 'Генерация тестовых задач')
, (8, 'test_run',  2, 1,  100, 'Обработка тестовой задачи')
, (9, 'today', 85800, 2,  7, 'Завершение дня')
;
