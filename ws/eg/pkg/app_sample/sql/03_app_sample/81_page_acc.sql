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

    Регистрация страниц сайта
*/

/* ------------------------------------------------------------------------- */


\set AID acc.const_class_id()
\set TID acc.const_team_class_id()

INSERT INTO i18n_def.page (code, up_code, class_id, action_id, sort, uri, tmpl, name) VALUES
  ('login',                 'main',   1, 8, NULL, 'login$',   'acc/login',    'Вход')
, ('logout',                'main',   1, 2, NULL, 'logout$',  'acc/logout',   'Выход')
, ('group.team',            'main',   2, 1, 1,    NULL,       NULL,           'Команды')
, ('group.account',         'main',   2, 1, 2,    NULL,       NULL,           'Пользователи')

, ('team.index',            'group.team',          2, 1, 1, 'team$',                  'acc/team/index',               'Поиск')
, ('team.id',               'team.index',          :TID, 1, NULL, 'team/:i$',            'acc/team/-id/index',           'Команда')
, ('team.id.account',       'team.id',             :TID, 1, 1, 'team/:i/account$',       'acc/team/-id/account',         'Сотрудники')
, ('group.team.setup',      'team.id',             :TID, 2, 9, NULL,         NULL,       'Настройки')
-- , ('team.id.setup.common',  'group.team.setup',    :TID, 2, 1, 'team/:i/setup/common$',  'acc/team/-id/setup',           'Общие')
, ('team.id.setup.perm',    'group.team.setup',    :TID, 2, 3, 'team/:i/setup/perm$',    'acc/team/-id/perm',            'Разрешения')
, ('team.id.setup.role',    'group.team.setup',    :TID, 2, 5, 'team/:i/setup/role$',    'acc/team/-id/role/index',      'Роли')
, ('team.id.setup.role.id', 'team.id.setup.role',  :TID, 2, 1, 'team/:i/setup/role/:i$', 'acc/team/-id/role/-id/index',  'Роль')

, ('account.index',         'group.account',       2, 1, 1, 'account$',                   'acc/account/index',            'Поиск')
, ('account.id',            'account.index',       :AID, 1, NULL, 'account/:i$',          'acc/account/-id/index',        'Пользователь')
, ('group.account.setup',   'account.id',          :AID, 2, 9, NULL,       NULL,        'Настройки')
, ('account.id.setup.common','group.account.setup', :AID, 2, 1, 'account/:i/setup/common$', 'acc/account/-id/setup',        'Общие')
, ('account.id.setup.perm', 'group.account.setup', :AID, 2, 3, 'account/:i/setup/perm$', 'acc/account/-id/perm',         'Разрешения')
;


/* ------------------------------------------------------------------------- */
-- для всех классов, созданных на этот момент
INSERT INTO acc.class_link(class_id, id, name) 
  SELECT id, acc.const_link_id_owner(), 'Свой'
  FROM ws.class
  UNION
  SELECT id, acc.const_link_id_other(), 'Чужой'
  FROM ws.class
;
