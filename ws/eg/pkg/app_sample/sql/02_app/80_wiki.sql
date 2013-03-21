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
INSERT INTO wsd.pkg_script_protected (code, ver) VALUES (:'FILE', :'VER');

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.doc_group (id, code, name, anno) VALUES
  (1, 'wk',   'Wiki', 'Public wiki')
, (2, 'sys',  'Help', 'Help system')
;

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.role_acl (role_id, class_id, object_id, acl_id) VALUES
  (4, wiki.const_class_id(), 1, 5)
, (acc.const_role_id_guest(), wiki.const_class_id(), 1, 2) -- доступ на чтение для неавторизованных
, (acc.const_role_id_user(),  wiki.const_class_id(), 1, 2) -- доступ на чтение для авторизованных
;

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.file_folder (code, class_id, has_version, has_file_code, page_code, name) VALUES
('wiki', wiki.const_doc_class_id(), FALSE, FALSE, 'wiki.wk.file', 'Файл статьи wiki')
;

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.file_folder_format(folder_code, format_code) VALUES
('wiki', fs.const_file_format_any())
;

