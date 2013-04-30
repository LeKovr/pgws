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

    Первичные данные
*/


/* ------------------------------------------------------------------------- */
    INSERT INTO wsd.team(id, status_id) VALUES
      (1, acc.const_team_status_id_active())
    , (2, acc.const_team_status_id_active())
    , (3, acc.const_team_status_id_active())
    , (4, acc.const_team_status_id_active())
    ;

    SELECT setval('wsd.team_id_seq', (SELECT max(id) FROM wsd.team));

/* ------------------------------------------------------------------------- */
    INSERT INTO wsd.role(id, team_id, name, anno) VALUES
      (1,  1,     'Guest',             'Роль для неавторизованного пользователя')
    , (2,  1,     'User without team', 'Роль для авторизованного пользователя без команды')
    , (3,  1,     'Login user',        'Роль для авторизованного пользователя')
    , (5,  NULL,  'Writer',            'Создание новых статей и редактирование своих + чтение')
    , (6,  NULL,  'Editor',            'Редактирование статей своей команды + чтение')
    , (8,  NULL,  'Team admin',        'Администратор команды')
    , (9,  2,     'Sys admin',         'Администратор системы')
    , (10, 2,     'Service',           'Сервисы')
    ;

    SELECT setval('wsd.role_id_seq', (SELECT max(id) FROM wsd.role));
/* ------------------------------------------------------------------------- */
    INSERT INTO wsd.permission(id, team_id, name) VALUES
      (1, 2,  'Администрирование пользователей')
    , (2, 2,  'Администрирование команд')
    , (3, 2,  'Модерация статей пользователей')
    , (4, 2,  'Модерация статей системных вики')
    ;
    
    INSERT INTO wsd.permission(id, name) VALUES
      (10,  'Просмотр профайла пользователя')
    , (11,  'Просмотр своих настроек')
    , (12,  'Просмотр настроек пользователей своей команды')
    , (13,  'Изменение своих настроек')
    , (14,  'Изменение настроек пользователей своей команды')

    , (20,  'Просмотр информации о команде')
    , (21,  'Просмотр настроек своей команды')
    , (22,  'Изменение настроек своей команды')

    , (30,  'Читать статью')
    , (32,  'Создавать статьи своей команды')
    , (33,  'Редактировать свою статью')
    , (34,  'Редактировать статью своей команды')
    ;

    SELECT setval('wsd.permission_id_seq', (SELECT max(id) FROM wsd.permission));

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.role_permission(role_id, perm_id)
  SELECT 1, a FROM unnest(ARRAY[10, 20, 30]) a   UNION
  SELECT 2, a FROM unnest(ARRAY[10, 11, 13, 20, 30]) a UNION
  SELECT 3, a FROM unnest(ARRAY[10, 11, 12, 13, 20, 30]) a   UNION
  SELECT 5, a FROM unnest(ARRAY[32, 33]) a   UNION
  SELECT 6, a FROM unnest(ARRAY[34]) a   UNION
  SELECT 8, a FROM unnest(ARRAY[14, 21, 22]) a   UNION
  SELECT 9, a FROM unnest(ARRAY[1, 2, 3, 4]) a  
;
 
    -- права доступа к статьям вики определяются по правам группы статей
    INSERT INTO wsd.permission_acl(perm_id, class_id, link_id, team_link_id, acl_id) VALUES
      (1, ws.class_id('account'), 2, 1, 4)
    , (1, ws.class_id('account'), 2, 2, 4)
    , (2, ws.class_id('team'),    2, 1, 4)
    , (2, ws.class_id('team'),    2, 2, 4)

    , (3, ws.class_id('wiki'),    2, 2, 5)
    , (4, ws.class_id('wiki'),    2, 1, 5)

    , (10,  ws.class_id('account'), 2, 2, 1)
    , (10,  ws.class_id('account'), 2, 1, 1)
    , (10,  ws.class_id('account'), 1, 1, 1)

    , (11,  ws.class_id('account'), 1, 1, 2)
    , (12,  ws.class_id('account'), 2, 1, 2)
    , (13,  ws.class_id('account'), 1, 1, 3)
    , (14,  ws.class_id('account'), 2, 1, 4)

    , (20,  ws.class_id('team'),    2, 2, 1)
    , (20,  ws.class_id('team'),    2, 1, 1)
    , (21,  ws.class_id('team'),    2, 1, 2)
    , (22,  ws.class_id('team'),    2, 1, 3)

    , (30,  ws.class_id('wiki'),    2, 2, 2)
    , (30,  ws.class_id('wiki'),    2, 1, 2)
    , (32,  ws.class_id('wiki'),    2, 1, 4)
    , (33,  ws.class_id('doc'),     1, 1, 4)
    , (34,  ws.class_id('doc'),     1, 1, 4)
    , (34,  ws.class_id('doc'),     2, 1, 4)
    ;

/*    INSERT INTO wsd.permission(role_id, class_id, acl_id, owner_level)
      SELECT s.a, acc.const_team_class_id(), 1, 1 FROM generate_series(1, 10) AS s(a)
      UNION
      SELECT s.a, wiki.const_class_id(), 2, 1 FROM generate_series(1, 10) AS s(a)
    ;
*/

/* ------------------------------------------------------------------------- */
    INSERT INTO wsd.account(id, status_id, login, psw) VALUES
      (1, acc.const_status_id_active(),   'admin',            :'PSW_DEFAULT')
    , (2, acc.const_status_id_active(),   'pgws-job-service', :'PSW_JOB') -- определяется при db init после make conf
    , (3, acc.const_status_id_active(),   'one',              :'PSW_DEFAULT')
    , (4, acc.const_status_id_active(),   'two',              :'PSW_DEFAULT')
    , (5, acc.const_status_id_active(),   'three',            :'PSW_DEFAULT')
    , (6, acc.const_status_id_active(),   'four',             :'PSW_DEFAULT')
    , (7, acc.const_status_id_active(),   'five',             :'PSW_DEFAULT')
    , (8, acc.const_status_id_active(),   'six',              :'PSW_DEFAULT')
    ;

    SELECT setval('wsd.account_id_seq', (SELECT max(id) FROM wsd.account));

/* ------------------------------------------------------------------------- */
    INSERT INTO wsd.account_team(account_id, team_id, role_id, is_default) VALUES
      (1, 2, 9, TRUE)
    , (2, 2, 10, TRUE)
    , (3, 3, 5, TRUE)
    , (4, 3, 6, TRUE)
    , (5, 3, 8, TRUE)
    , (6, 4, 5, TRUE)
    , (7, 4, 6, TRUE)
    , (8, 4, 8, TRUE)
    ;

/* Настройки подписок EV*/
INSERT INTO  wsd.event_signup (account_id, role_id, kind_id, spec_id, is_on, prio) values 
  (8, 8, 2, 0, false, 1) -- user 8 отменил подписку
, (7, 3, 1, 0, true,  1) -- user 7 включил подписку
;

SELECT wiki.doc_create_acc(1, wiki.id_by_code('help'), '', TRUE, wiki.name_by_code('help'), $__$
### Стартовая страница справки пользователя

Для ее наполнения еще предстоит:

* подготовить пример разметки
* сформулировать требования к wiki
* доработать функционал wiki, в т.ч.
  * поддержку внутренних ссылок
  * историю изменений
  * поиск по wiki
  
$__$);

SELECT wiki.doc_create_acc(1, wiki.id_by_code('devdocs'), '', TRUE, wiki.name_by_code('devdocs'), $__$

*PGWS* (Postgresql Web Services) is the gateway between Perl or stored Postgresql code and client side Javascript or server side templates.

There is only Russian documentation right now which is following below.

**PGWS** (Вебсервисы Postgresql) - шлюз между Perl или хранимым кодом Postgresql и клиентским Javascript или серверными шаблонами.

Данный программный продукт распространяется на условиях AGPL ([Стандартная общественная лицензия GNU Афферо](http://www.gnu.org/licenses/agpl.html))

## Документация

Ниже представлена предварительная версия документации PGWS, которая находится в процессе доработки и может не соответствовать исходному коду.

1. [Новости проекта](http://rm2.tender.pro/projects/pgws/news)

## Загрузка

Исходные файлы проекта доступны в репозитории git: [http://pgws.tender.pro/](http://pgws.tender.pro/)
$__$);
