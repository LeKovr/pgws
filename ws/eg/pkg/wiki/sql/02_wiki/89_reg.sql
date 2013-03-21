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

    Регистрация методов и страниц
*/

/* ------------------------------------------------------------------------- */
\set WID wiki.const_class_id()      -- wiki class id
\set DID wiki.const_doc_class_id()  -- doc class id

/* ------------------------------------------------------------------------- */

INSERT INTO ws.method (code, class_id , action_id, cache_id, rvf_id) VALUES
  ('wiki.status',                2, 1, 3, 2) --, pg_cs('wiki_status'))
, ('wiki.acl',                   2, 1, 3, 6) --, pg_cs('wiki_acl'))

, ('wiki.id_by_code',       :WID, 1, 3, 2)
, ('wiki.doc_id_by_code',   :WID, 1, 3, 2)
, ('wiki.doc_by_name',      :WID, 1, 3, 7)
, ('wiki.keyword_by_name',  :WID, 1, 3, 6)


, ('wiki.doc_info',         :DID, 1, 3, 3)
, ('wiki.doc_keyword',      :DID, 1, 3, 6)
, ('wiki.doc_src',          :DID, 1, 3, 2)
, ('wiki.doc_extra',        :DID, 1, 3, 3)
, ('wiki.doc_link',         :DID, 1, 3, 7)
, ('wiki.doc_file',         :DID, 1, 3, 7)
, ('wiki.doc_diff',         :DID, 1, 3, 3)
;

INSERT INTO ws.method (code, class_id , action_id, cache_id, rvf_id, code_real) VALUES
  ('doc.status',                2, 1, 3, 2, pg_cs('doc_status'))
, ('doc.acl',                   2, 1, 3, 6, pg_cs('doc_acl'))
;

INSERT INTO ws.method (code, class_id , action_id, cache_id, rvf_id, is_write) VALUES
  ('wiki.doc_create',       :WID, 4, 1, 2, true)

, ('wiki.doc_update_src',   :DID, 3, 1, 2, true)
, ('wiki.doc_update_attr',  :DID, 3, 1, 2, true)
, ('wiki.doc_file_del',     :DID, 3, 1, 2, true)
;

INSERT INTO ws.method (code, class_id , action_id, cache_id, rvf_id, is_write, realm_code) VALUES
  ('wiki.doc_file_add',     :DID, 3, 1, 3, true, ws.const_realm_upload())
;

INSERT INTO ws.method (code, class_id , action_id, cache_id, rvf_id, code_real, arg_dt_code, rv_dt_code, name, args_exam) VALUES
  ('doc.format', :DID, 1, 3, 2, 'wiki:format', dt_code('z_format'), dt_code('text'), 'Форматирование wiki в html','a_text="*Hello* _world_"')
;

INSERT INTO ws.method (code, class_id , action_id, cache_id, rvf_id, code_real, arg_dt_code, rv_dt_code, is_write, name) VALUES
  ('wiki.add',  :WID, 3, 3, 2, 'wiki:add',    dt_code('z_add'), dt_code('text'), true, 'Создание статьи wiki')
, ('doc.save',  :DID, 3, 3, 2, 'wiki:save',   dt_code('z_save'), dt_code('text'), true, 'Сохранение статьи wiki')
;

/* ------------------------------------------------------------------------- */
INSERT INTO i18n_def.error (code, id_count, message) VALUES
  ('Y9901', 1, 'Не найдена группа "%s"')
, ('Y9902', 1, 'Версия документа (%s) не актуальна и(или) устарела')
, ('Y9903', 1, 'Документ с таким адресом уже создан (%s)')
, ('Y9904', 0, 'Документ не содержит изменений')
, ('Y9905', 0, 'Документ не найден')
;
