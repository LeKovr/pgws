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

-- тестирование нового функционала общего назначения
INSERT INTO i18n_def.page (code, up_code, class_id, action_id, sort, uri, tmpl, name) VALUES
  ('samples',       'main',     2, 1, 7,    'samples$',         'app_sample/samples/index',   'Примеры')
, ('sample.test',   'samples',  2, 1, 1,    'samples/test$',    :'PKG' || '/test',            'Тест API')
, ('sample.markup', 'samples',  2, 1, 2,    'samples/markup$',  'app_sample/samples/markup',  'Разметка страниц')
, ('sample.pager',  'samples',  2, 1, 3,    'samples/pager$',   'app_sample/samples/pager',   'Pager')
, ('sample.tabsjs', 'samples',  2, 1, 4,    'samples/tabsjs$',  'app_sample/samples/tabs_js', 'Вкладки (JS)')
, ('sample.tabs',   'samples',  2, 1, 5,    NULL,               NULL,                         'Вкладки')

, ('sample.tabs.index', 'sample.tabs',  2, 1, 1,    'samples/tabs$',      'app_sample/samples/tabs',    'Вкладки: Главная' )
, ('sample.tabs.tab1',  'sample.tabs',  2, 1, 2,    'samples/tabs/tab1$', 'app_sample/samples/tabs',    'Вкладки: Tab1')
, ('sample.tabs.tab2',  'sample.tabs',  2, 1, 3,    'samples/tabs/tab2$', 'app_sample/samples/tabs',    'Вкладки: Tab2')
;


