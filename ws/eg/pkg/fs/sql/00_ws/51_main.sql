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
CREATE OR REPLACE FUNCTION file_store (a_id INTEGER) RETURNS SETOF file_store STABLE LANGUAGE 'sql' AS
$_$
  SELECT * FROM fs.file_store WHERE id = $1;
$_$;
SELECT pg_c('f', 'file_store', 'Атрибуты хранения файла');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION file_folder (a_code TEXT) RETURNS SETOF wsd.file_folder STABLE LANGUAGE 'sql' AS
$_$
  SELECT * FROM wsd.file_folder WHERE code = $1;
$_$;
SELECT pg_c('f', 'file_folder', 'Атрибуты файловой папки');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION file_format (a_name TEXT) RETURNS SETOF file_format STABLE LANGUAGE 'sql' AS
$_$
  SELECT * FROM fs.file_format
    WHERE $1 ~* (E'\\.' || ext_mask || '$')
      OR code = fs.const_file_format_any()
    ORDER BY sort LIMIT 1;
$_$;
SELECT pg_c('f', 'file_format', 'Атрибуты формата по имени файла');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION file_format_code (a_name TEXT) RETURNS TEXT STRICT STABLE LANGUAGE 'sql' AS
$_$
  SELECT code FROM fs.file_format WHERE $1 ~* (E'\\.' || ext_mask || '$') ORDER BY sort LIMIT 1;
$_$;
SELECT pg_c('f', 'file_format_code', 'Код формата по имени файла');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION file_add (
  a_account_id  INTEGER
, a_folder_code TEXT
, a_obj_id      INTEGER
, a__path       TEXT
, a__size       INTEGER
, a__csum       TEXT
, a_name        TEXT
, a_id          INTEGER DEFAULT NULL
, a_ctype       TEXT DEFAULT NULL
, a_file_code   TEXT DEFAULT NULL
, a_anno        TEXT DEFAULT NULL
) RETURNS INTEGER LANGUAGE 'plpgsql' AS
$_$
  -- a_account_id:  ID сессии
  -- a_folder_code: Код папки
  -- a_obj_id:      ID объекта
  -- a__path:       Путь к файлу в хранилище nginx
  -- a__size:       Размер (байт)
  -- a__csum:       Контрольная сумма (sha1)
  -- a_name:        Внешнее имя файла
  -- a_id:          ID файла
  -- a_ctype:       Content type
  -- a_file_code:   Код файла
  -- a_anno:        Комментарий
  DECLARE
    r_folder wsd.file_folder;
    r_format fs.file_format;
    v_code TEXT;
    v_ver  INTEGER;
    v_file_id INTEGER;
  BEGIN
    r_folder := fs.file_folder(a_folder_code);
    r_format := fs.file_format(a_name);
    -- проверка наличия формата в списке разрешенных для папки
    SELECT INTO v_code
      format_code
      FROM wsd.file_folder_format
      WHERE folder_code = r_folder.code
        AND format_code IN (r_format.code, fs.const_file_format_any() )
      LIMIT 1
    ;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'illegal filename format (%) from folder (%)', a_name, a_folder_code;
    END IF;

    IF r_format.code = fs.const_file_format_any() THEN
      -- неизвестный формат - берем ctype из аргументов
      r_format.ctype = a_ctype;
    END IF;

    IF r_folder.has_file_code THEN
      v_code := COALESCE (a_code, '');
      -- TODO: check mask
    ELSE
      v_code := '';
    END IF;

    -- TODO: move link_cnt calc into doc_file trigger
    INSERT INTO wsd.file (id, path, name, size, format_code, ctype, created_by, csum, anno) VALUES
      (COALESCE(a_id, NEXTVAL('wsd.file_id_seq'))
      , a__path, a_name, a__size, r_format.code, r_format.ctype, a_account_id, a__csum, a_anno)
      RETURNING id INTO v_file_id
    ;

    IF r_folder.has_version THEN
      UPDATE wsd.file_link SET
        is_ver_last = FALSE
        WHERE class_id = r_folder.class_id
          AND obj_id = a_obj_id
          AND folder_code = r_folder.code
          AND format_code = r_format.code
          AND file_code = v_code
          AND is_ver_last
        RETURNING ver INTO v_ver
      ;
    ELSE
      DELETE FROM wsd.file_link
        WHERE class_id = r_folder.class_id
          AND obj_id = a_obj_id
          AND folder_code = r_folder.code
          AND format_code = r_format.code
          AND file_code = v_code
          AND is_ver_last
      ;
      v_ver := 1;
    END IF;

    INSERT INTO wsd.file_link (id, class_id, obj_id, folder_code, format_code, file_code, created_by, ver) VALUES
      (v_file_id, r_folder.class_id, a_obj_id, a_folder_code, r_format.code, v_code, a_account_id, COALESCE(v_ver + 1, 1))
    ;
    RETURN v_file_id;
  END;
$_$;

/* ------------------------------------------------------------------------- */
/* TODO
CREATE OR REPLACE FUNCTION file_unlink (
, a_folder_code TEXT
, a_obj_id      INTEGER
, a_id          INTEGER DEFAULT NULL
, a_file_code   TEXT DEFAULT NULL
) RETURNS INTEGER LANGUAGE 'plpgsql' AS
$_$
  -- a_folder_code: Код папки
  -- a_obj_id:      ID объекта
  -- a_code:        Код связи
  -- a_id:          ID файла
  -- a_anno:        Комментарий
  DECLARE
    r_folder wsd.file_folder;
    r_format fs.file_format;
    v_code TEXT;
    v_ver  INTEGER;
    v_file_id INTEGER;
  BEGIN
    r_folder := fs.file_folder(a_folder_code);
    r_format := fs.file_format(a_name);
    -- проверка наличия формата в списке разрешенных для папки
    SELECT INTO v_code
      format_code
      FROM wsd.file_folder_format
      WHERE folder_code = r_folder.code
        AND format_code IN (r_format.code, fs.const_file_format_any() )
      LIMIT 1
    ;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'illegal filename format (%) from folder (%)', a_name, a_folder_code;
    END IF;

    IF r_format.code = fs.const_file_format_any() THEN
      -- неизвестный формат - берем ctype из аргументов
      r_format.ctype = a_ctype;
    END IF;

    IF r_folder.has_file_code THEN
      v_code := COALESCE (a_code, '');
      -- TODO: check mask
    ELSE
      v_code := '';
    END IF;

    IF r_folder.has_version THEN
      UPDATE wsd.file_link SET
        is_ver_last = FALSE
        WHERE class_id = r_folder.class_id
          AND obj_id = a_obj_id
          AND folder_code = r_folder.code
          AND format_code = r_format.code
          AND file_code = v_code
          AND is_ver_last
        RETURNING ver INTO v_ver
      ;
    ELSE
      DELETE FROM wsd.file_link
        WHERE class_id = r_folder.class_id
          AND obj_id = a_obj_id
          AND folder_code = r_folder.code
          AND format_code = r_format.code
          AND file_code = v_code
          AND is_ver_last
      ;
      v_ver := 1;
    END IF;

    INSERT INTO wsd.file_link (id, class_id, obj_id, folder_code, format_code, file_code, created_by, ver) VALUES
      (v_file_id, r_folder.class_id, a_obj_id, a_folder_code, r_format.code, v_code, a_account_id, COALESCE(v_ver + 1, 1))
    ;
    RETURN v_file_id;
  END;
$_$;
*/
/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION file_new_path_mk (
  a_folder_code TEXT
, a_obj_id      INTEGER
, a_name        TEXT
, a_code        TEXT DEFAULT NULL
) RETURNS ws.t_hashtable LANGUAGE 'plpgsql' AS
$_$
  -- a_class_id:    ID класса
  -- a_obj_id:      ID объекта
  -- a_name:        Внешнее имя файла
  -- a_code:        Код связи
  DECLARE
    r_folder wsd.file_folder;
    v_file_id INTEGER;
    r ws.t_hashtable;
  BEGIN
    r_folder := fs.file_folder(a_folder_code);
    v_file_id := NEXTVAL('wsd.file_id_seq');
    IF r_folder.has_file_code AND a_code IS NULL THEN
      RAISE EXCEPTION 'file code is required for folder %', a_folder_code;
    END IF;
    r.id := v_file_id::TEXT;
    r.name := 'apidata/' -- TODO: move to wsd.prop_value
      || ws.class_code(r_folder.class_id) || '/'
      || a_obj_id::TEXT || '/'
      || r_folder.code || '/'
      || CASE WHEN r_folder.has_file_code THEN a_code || '/' ELSE '' END
      || v_file_id || '_' || a_name
    ;
    RETURN r;
  END
$_$;
SELECT pg_c('f', 'file_new_path_mk', 'ID и путь хранения для формируемого файла');

/* ------------------------------------------------------------------------- */
