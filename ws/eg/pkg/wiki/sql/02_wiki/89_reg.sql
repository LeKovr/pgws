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

*/
-- 89_reg.sql - Регистрация методов и страниц
/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:89_reg.sql / 23 --'

/* ------------------------------------------------------------------------- */

INSERT INTO ws.method (code, class_id , action_id, cache_id, rvf_id) VALUES
  ('wiki.group_id_by_code',   2, 1, 3, 2)
  , ('wiki.ids_by_code',      2, 1, 3, 3)
  , ('wiki.doc_info',         2, 1, 3, 3)
  , ('wiki.doc_src',          2, 1, 3, 2)
  , ('wiki.doc_extra',        2, 1, 3, 3)
  , ('wiki.doc_link',         2, 1, 3, 7)
  , ('wiki.doc_by_name',      2, 1, 3, 7)
  , ('wiki.keyword_by_name',  2, 1, 3, 6)
  , ('wiki.doc_keyword',      2, 1, 3, 6)
  , ('wiki.doc_diff',         2, 1, 3, 3)
  , ('wiki.can_create',       2, 1, 3, 2)
;

INSERT INTO ws.method (code, class_id , action_id, cache_id, rvf_id, is_write) VALUES
  ('wiki.doc_create',         2, 1, 1, 2, true)
  , ('wiki.doc_update_src',   2, 1, 1, 2, true)
  , ('wiki.doc_update_attr',  2, 1, 1, 2, true)
;

INSERT INTO ws.method (code, class_id , action_id, cache_id, rvf_id, code_real, is_sql, arg_dt_id, rv_dt_id, name, args_exam) VALUES
  ('wiki.format', 2, 1, 3, 2, 'Wiki::format', false, dt_id('z_format'), dt_id('text'), 'Форматирование wiki в html','a_text="*Hello* _world_"')
;

INSERT INTO ws.method (code, class_id , action_id, cache_id, rvf_id, code_real, is_sql, arg_dt_id, rv_dt_id, is_write, name) VALUES
  ('wiki.save', 2, 1, 3, 2, 'Wiki::save', false, dt_id('z_save'), dt_id('text'), true, 'Сохранение wiki')
;

/* ------------------------------------------------------------------------- */
INSERT INTO i18n_def.page (code, up_code, class_id, action_id, sort, uri, tmpl, name) VALUES
  ('wiki.wk',           'main',     2, 1, 8,    '(wk):u$',      'wiki/index',          'Вики')
  , ('wiki.wk.edit',    'wiki.wk',  2, 1, NULL, '(wk):u/edit$', 'wiki/edit',           'Редактирование')
  , ('wiki.wk.history', 'wiki.wk',  2, 1, NULL, '(wk):u/history$', 'wiki/history',     'История изменений')
;

/* ------------------------------------------------------------------------- */
INSERT INTO i18n_def.error (code, id_count, message) VALUES
  (   'Y9901', 1, 'Не найдена группа "%s"')
  , ( 'Y9902', 1, 'Версия документа (%s) не актуальна и(или) устарела')
  , ( 'Y9903', 1, 'Документ с таким адресом уже создан (%s)')
  , ( 'Y9904', 0, 'Документ не содержит изменений')
  , ( 'Y9905', 0, 'Документ не найден')
;
/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:89_reg.sql / 71 --'
