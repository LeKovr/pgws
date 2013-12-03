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

    Тесты
*/

\set CLASS 2
\set OBJ 1
\set FCODE test_folder

SELECT ws.test('fs.package_tests');

-- Begin: подготовка данных
  INSERT INTO i18n_def.page (code, up_code, class_id, action_id, sort, uri, tmpl, name) VALUES
   ('fs.test.file', NULL, :CLASS, 1, NULL, 'fs/test/:i/file/:s:u$','fs/file', 'Файл')
  ;

  INSERT INTO fs.folder (class_id, code, sort, page_code, name) VALUES (:CLASS, :'FCODE', 9999, 'fs.test.file', 'Тестовый каталог');

  INSERT INTO fs.folder_kind (class_id, code, kind_code) VALUES (:CLASS, :'FCODE', 'data');
-- End: подготовка данных

-- Begin: тест
  SELECT fs.file_add(1, :CLASS, :'FCODE', :OBJ, 'test/path', 34, 'csum', 'test1.json', -1, '*', 'test_file.json', 'test_anno1');
  SELECT id, path, size, csum, name, ctype from fs.file_store(-1);
  SELECT fs.file_add(1, :CLASS, :'FCODE', :OBJ, 'test/path', 35, 'csum', 'test2.json', -2, '*', 'test_file.json', 'test_anno2');
  SELECT fs.file_add(1, :CLASS, :'FCODE', :OBJ, 'test/path', 35, 'csum', 'test2.json', -3, '*', NULL, 'test_anno3');

/* ------------------------------------------------------------------------- */
  -- в wsd.file_link - только два файла
  SELECT id
  , size
  , csum
  , kind_code
  , created_by
  , name
  , anno
  , class_id
  , obj_id
  , folder_code
  , code
  , ext
  , ver
  , is_ver_last
  , folder_name
  , req
    FROM fs.file_list(:CLASS, :'FCODE', :OBJ)
    ORDER BY id DESC
  ;
  -- в wsd.file - три файла
  SELECT id, path, size, csum, name, ctype from wsd.file WHERE id IN (-1, -2, -3) ORDER BY id DESC;

/* ------------------------------------------------------------------------- */
  SELECT fs.file_link_delete(:CLASS, :'FCODE', :OBJ, -2);
  SELECT id, code FROM fs.file_list(:CLASS, :'FCODE', :OBJ);
  SELECT fs.file_link_delete(:CLASS, :'FCODE', :OBJ);
  SELECT id, code FROM fs.file_list(:CLASS, :'FCODE', :OBJ);

/* ------------------------------------------------------------------------- */
  SELECT id::INTEGER > 0 AS is_id_positive, name FROM fs.file_new_path_mk(:CLASS, :'FCODE', :OBJ, 'Тестовый каталог', 'name.ext');

/* ------------------------------------------------------------------------- */
  SELECT * FROM fs.folder(:CLASS, :'FCODE');

/* ------------------------------------------------------------------------- */
  SELECT * FROM fs.mime_type('test_file.jpg');

/* ------------------------------------------------------------------------- */
  SELECT * FROM fs.name2uri('test file');
-- End: тест
