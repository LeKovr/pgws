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
CREATE OR REPLACE FUNCTION file_add (
  a_account_id  INTEGER
, a__path       TEXT
, a__size       INTEGER
, a__csum       TEXT
, a_name        TEXT
, a_ctype       TEXT
, a_anno        TEXT DEFAULT NULL
) RETURNS INTEGER LANGUAGE 'plpgsql' AS
$_$
  -- a_account_id:  ID сессии
  -- a__path:       Путь к файлу в хранилище nginx
  -- a__size:       Размер (байт)
  -- a__csum:       Контрольная сумма (sha1)
  -- a_id:          ID статьи
  -- a_name:        Внешнее имя файла
  -- a_ctype:       Content type
  -- a_anno:        Комментарий
  DECLARE
    v_account_id INTEGER;
    v_code TEXT;
    v_file_id INTEGER;
  BEGIN
    INSERT INTO wsd.file (path, name, size, ctype, created_by, csum, anno, link_cnt) VALUES
      (a__path, a_name, a__size, a_ctype, a_account_id, a__csum, a_anno, 1) -- TODO: move doc_cnt calc into doc_file trigger
      RETURNING file_id INTO v_file_id
    ;
    RETURN v_file_id;
  END;
$_$;
SELECT pg_c('f', 'file_add', 'Добавление загруженного файла');


/* ------------------------------------------------------------------------- */
