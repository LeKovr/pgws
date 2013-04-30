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

    Функции работы с загружаемыми файлами
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION fs_files ( -- ВНИМАНИЕ! 
  a_id d_id
, a_file_code   ws.d_string DEFAULT NULL
) RETURNS SETOF fs.file_info STABLE LANGUAGE 'sql' AS
$_$
  -- a_id:    ID статьи
  -- a_file_id: ID файла
  SELECT * FROM fs.file_list(wiki.const_doc_class_id(), fs.const_folder_code_default(), $1, $2);
$_$;
SELECT pg_c('f', 'fs_files', 'Список файлов статьи', $_$
Этот метод должен регистрироваться в API с именем PAGE_CODE,
где
PAGE - код страницы выгрузки файла (есть в fs.folder)
CODE - код папки (fs.const_folder_code_default())
$_$);

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION fs_files_add (
  a__sid      text
, a_id        ws.d_id
, a__path     text
, a__size     integer
, a__csum     text
, a_name      text
, a_ctype     text
, a_anno      text DEFAULT NULL
  ) RETURNS SETOF fs.file_info LANGUAGE 'plpgsql' AS
$_$
  -- a__sid:  ID сессии
  -- a_id:    ID статьи
  -- a__path: Путь к файлу в хранилище nginx
  -- a__size: Размер (байт)
  -- a__csum: Контрольная сумма (sha1)
  -- a_name:  Внешнее имя файла
  -- a_ctype: Content type
  -- a_anno:  Комментарий
  DECLARE
    v_account_id  ws.d_id;
    v_path        ws.d_string; -- ws.d_path;
    v_file_code   ws.d_string;
  BEGIN
    -- TODO: content-type & extention control
    v_account_id := acc.sid_account_id(a__sid);
    v_path = substring(a__path from 2); -- TODO: удалять начальный слеш на уровне ядра
    v_file_code := fs.file_add(v_account_id, wiki.const_doc_class_id(), fs.const_folder_code_default(), a_id, v_path, a__size, a__csum, a_name, NULL, a_ctype, NULL, a_anno);
    RETURN QUERY SELECT * FROM wiki.fs_files(a_id, v_file_code);
    RETURN;
  END;
$_$;
SELECT pg_c('f', 'fs_files_add', 'Добавление в статью загруженного файла', $_$
Этот метод должен регистрироваться в API с именем PARENT_add,
где
PARENT - имя, под которым зарегистирован Список файлов статьи
$_$);

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION fs_files_del (
  a_id        ws.d_id
, a_file_id   ws.d_id
) RETURNS BOOL LANGUAGE 'sql' AS
$_$
  SELECT fs.file_link_delete(wiki.const_doc_class_id(), fs.const_folder_code_default(), $1, $2);
$_$;
SELECT pg_c('f', 'fs_files_del', 'Удаление файла из статьи', $_$
Этот метод должен регистрироваться в API с именем PARENT_del,
где
PARENT - имя, под которым зарегистирован Список файлов статьи
$_$);


/* ------------------------------------------------------------------------- */
