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

\set WID wiki.const_class_id()      -- wiki class id

INSERT INTO i18n_def.page (code, up_code, class_id, action_id, sort, uri, tmpl, id_fixed, name) VALUES
  ('wiki.wk',         'main',         :WID, 1, 1,    'wk$',             'wiki/index',   wiki.id_by_code('wk'), wiki.name_by_code('wk'))
, ('wiki.wk.doc',     'wiki.wk',      :WID, 1, 1,    '(wk):u$',         'wiki/index',   wiki.id_by_code('wk'), wiki.name_by_code('wk'))
, ('wiki.wk.edit',    'wiki.wk.doc',  :WID, 3, NULL, '(wk):u/edit$',    'wiki/edit',    wiki.id_by_code('wk'), 'Редактирование')
, ('wiki.wk.history', 'wiki.wk.doc',  :WID, 1, NULL, '(wk):u/history$', 'wiki/history', wiki.id_by_code('wk'), 'История изменений')
, ('wiki.wk.file',    'wiki.wk.doc',  :WID, 1, NULL, '(wk):u/file/:i/:s$','wiki/file_redirect', wiki.id_by_code('wk'), 'Файл')
;

/*
-- тестирование нового функционала общего назначения
INSERT INTO i18n_def.page (code, up_code, class_id, action_id, sort, uri, tmpl, name) VALUES
  ('wikitab',       'main',     2, 1, NULL, 'wikitest$',             NULL,           'TabTest')
, ('wikitab.index', 'wikitab',  2, 1, 1,    'wikitab$',       'wiki/eg/tabs', 'Main' )
, ('wikitab.tab1',  'wikitab',  2, 1, 2,    'wikitab/tab1$',  'wiki/eg/tabs',  'Tab1')
, ('wikitab.tab2',  'wikitab',  2, 1, 3,    'wikitab/tab2$',  'wiki/eg/tabs',  'Tab2')
;
*/
