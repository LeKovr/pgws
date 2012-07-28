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
INSERT INTO run_type (id, name) VALUES
  (1, 'default')
, (2, 'cron')
, (3, 'shadow')
, (4, 'daily')
, (5, 'monthly')
, (6, 'yearly')
;

/* ------------------------------------------------------------------------- */
INSERT INTO arg_type (id,name) VALUES
  (0, 'Нет')
, (1, 'ID компании')
, (2, 'Дата документа')
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
INSERT INTO category (code, name) VALUES
  ('system',  'Система')
, ('tmpl',    'Темплейты')
, ('mail',    'Почта')
, ('billing', 'Биллинг')
;

/* ------------------------------------------------------------------------- */
INSERT INTO status (id, can_create, can_run, can_arc, name, anno) VALUES
  (0,   true,   false,  false,  'Черновик',       'Задача в стадии создания')
, (1,   true,   true,   false,  'К исполнению',   'задача готова к исполнению')
, (2,   false,  true,   false,  'После ожидания', 'ожидавшаяся задача завершена')
, (3,   false,  true,   false,  'Выполняется',    'происходит выполнение задачи')
, (4,   true,   true,   false,  'Ожидает',        'ожидает выполнения связанной задачи')
, (5,   true,   false,  true,   'Отменена',       'выполнение невозможно (например - по недостатку баланса)')
, (6,   true,   false,  false,  'Вне очереди',    'задача выполняется отдельным процессом')
, (7,   true,   false,  true,   'Отложена',       'выполнение класса заблокировано админом')
, (8,   true,   false,  false,  'Срочная',        'выполнение точно в заданный срок')
, (-1,  false,  false,  true,   'Ошибка',         'выполнение невозможно из-за ошибки')
, (10,  false,  false,  true,   'Завершена',      'Выполнение завершено')
, (11,  true,   false,  true,   'Протокол',       'Задача не предназначена для выполнения')
;

/* ------------------------------------------------------------------------- */
/*
INSERT INTO jq.class VALUES
  (1, 1, 1, true, 'noop', 'code', 0, 0, 0, 0, 0, 7, false, 'Пустая операция')
, (2, 1, 9, true, 'error', 'code', 0, 0, 0, 0, 0, 7, false, 'Пример ошибки')
, (3, 4, 10, true, 'daily', 'sql', 0,2,0,0, 0, 31, false, 'Ежедневный биллинг системы')
, (50, 4, 50, true, 'next', 'sql', 0,2,0,0, 0,7, false,'Активация биллинга следующего дня')
, (51, 4, 51, true, 'arc', 'sql', 0,2,0,0, 0,7, false, 'Перенос в архив и удаление')
;
*/