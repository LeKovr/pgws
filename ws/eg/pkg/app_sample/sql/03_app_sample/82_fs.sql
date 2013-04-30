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

    Интеграция с пакетом fs: данные
*/

\set AID acc.const_class_id()
\set TID acc.const_team_class_id()
\set WID wiki.const_doc_class_id()
/* ------------------------------------------------------------------------- */
INSERT INTO fs.folder (class_id, code, page_code, name) VALUES 
  (:AID, fs.const_folder_code_default(), 'account.fs', 'Избранные файлы')
, (:TID, fs.const_folder_code_default(), 'team.fs', 'Избранные файлы')
, (:WID, fs.const_folder_code_default(), 'wiki.fs', 'Файл статьи wiki')
;

/* ------------------------------------------------------------------------- */
INSERT INTO fs.folder_kind (class_id, code, kind_code) VALUES 
  (:AID, fs.const_folder_code_default(), fs.const_kind_code_any())
, (:TID, fs.const_folder_code_default(), fs.const_kind_code_any())
, (:WID, fs.const_folder_code_default(), fs.const_kind_code_any())
;
