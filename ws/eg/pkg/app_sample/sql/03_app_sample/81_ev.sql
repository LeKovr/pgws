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

\set AID ws.class_id('account')
\set TID ws.class_id('team')

INSERT INTO i18n_def.page (code, up_code, class_id, action_id, sort, uri, tmpl, name) VALUES
  ('info.notice',             'group.info.devel',   1,    3, 20,  'info/notice$',             'ev/kind/index',      'Категории событий')
, ('account.id.event',        'account.id',         :AID, 2, 1,   'account/:i/news$',         'ev/event/account',   'Уведомления')
, ('account.id.event.id',     'account.id',         :AID, 2, NULL,'account/:i/news/:i$',      'ev/event/id-item',   'Подробности')
, ('account.id.setup.signup', 'group.account.setup',:AID, 2, 4,   'account/:i/setup/signup$', 'ev/signup/account',  'Подписки')
, ('team.id.setup.signup',    'group.team.setup',   :TID, 2, 4,   'team/:i/setup/signup$',    'ev/signup/team',     'Подписки')
;
