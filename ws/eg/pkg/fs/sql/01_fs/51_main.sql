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
CREATE OR REPLACE FUNCTION name2uri (a_name d_string) RETURNS d_string IMMUTABLE LANGUAGE 'sql' AS
$_$
-- a_name: имя файла
-- TODO: translit?
-- TODO: RETURNS d_path?
  SELECT lower(regexp_replace($1, E'\\s', '_', 'g'))::ws.d_string;
$_$;
SELECT pg_c('f', 'name2uri', 'Суффикс uri файла по его имени');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION file_store (a_id d_id) RETURNS SETOF file_store STABLE LANGUAGE 'sql' AS
$_$
-- a_id: ID файла
  SELECT * FROM fs.file_store WHERE id = $1;
$_$;
SELECT pg_c('f', 'file_store', 'Атрибуты хранения файла');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION folder (a_class_id d_class, a_code d_code) RETURNS SETOF folder STABLE LANGUAGE 'sql' AS
$_$
-- a_class_id: ID класса
-- a_code: Код папки
  SELECT * FROM fs.folder WHERE class_id = $1 AND COALESCE ($2, code) = code ORDER BY sort;
$_$;
SELECT pg_c('f', 'folder', 'Атрибуты файловой папки');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION mime_type (a_name TEXT) RETURNS SETOF mime_type STABLE LANGUAGE 'sql' AS
$_$
-- a_name: Имя файла
  SELECT * FROM fs.mime_type
    WHERE $1 ~* (E'\\.' || ext || '$')
$_$;
SELECT pg_c('f', 'mime_type', 'Атрибуты типа по имени файла');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION file_add (
  a_account_id  ws.d_id
, a_class_id    ws.d_class
, a_folder_code ws.d_code
, a_obj_id      ws.d_id
, a__path       ws.d_path
, a__size       ws.d_id_positive
, a__csum       ws.d_string
, a_name        ws.d_string
, a_id          ws.d_id DEFAULT NULL
, a_ctype       ws.d_string DEFAULT NULL
, a_file_code   ws.d_string DEFAULT NULL -- wsd.file_link.code
, a_anno        ws.d_text DEFAULT NULL
) RETURNS d_string LANGUAGE 'plpgsql' AS
$_$
  -- a_account_id:  ID сессии
  -- a_class_id:    ID класса
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
    r_folder          fs.folder;
    r_mtype           fs.mime_type;
    v_kind_code       ws.d_code;
    v_code            ws.d_string; -- ws.d_code;
    v_ver             ws.d_cnt;
    v_file_id         ws.d_id;
    v_job_handler_id  ws.d_id32;
  BEGIN
    r_folder := fs.folder(a_class_id, a_folder_code);
    r_mtype  := fs.mime_type(a_name);

    IF r_mtype IS NULL THEN
      -- неизвестный тип файла
      r_mtype.kind_code := fs.const_kind_code_any();
      r_mtype.ctype := a_ctype;
      r_mtype.ext := lower(substring(a_name from E'[^\\.]+$'));
    END IF;

    -- проверка наличия формата в списке разрешенных для папки
    SELECT INTO v_job_handler_id
      job_handler_id
      FROM fs.folder_kind
      WHERE class_id = a_class_id
        AND code = a_folder_code
        AND kind_code IN (r_mtype.kind_code, fs.const_kind_code_any())
      ORDER BY kind_code -- не "any" будет первым, если есть
      LIMIT 1
    ;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'folder % of class % does not allow file % kind (%)', a_folder_code, a_class_id, a_name, r_mtype.kind_code;
    END IF;

    -- TODO: если линкуем существующий, не делать INSERT
    INSERT INTO wsd.file (id, path, name, size, csum, kind_code, ctype, created_by, anno) VALUES
      (COALESCE(a_id, NEXTVAL('wsd.file_id_seq'))
        , a__path
        , a_name
        , a__size
        , a__csum
        , r_mtype.kind_code
        , r_mtype.ctype
        , a_account_id
        , a_anno)
      RETURNING id INTO v_file_id
    ;

    v_code := COALESCE(a_file_code, v_file_id || '/' || fs.name2uri(a_name));

    IF r_folder.has_version THEN
      -- снять флаг is_ver_last у предыдущей версии
      UPDATE wsd.file_link SET
        is_ver_last = FALSE
        WHERE class_id = a_class_id
          AND obj_id = a_obj_id
          AND folder_code = a_folder_code
          AND code = v_code
          AND is_ver_last
        RETURNING ver INTO v_ver
      ;
    ELSE
      -- удалить файл с таким же file_code, если есть
      DELETE FROM wsd.file_link
        WHERE class_id = a_class_id
          AND obj_id = a_obj_id
          AND folder_code = a_folder_code
          AND code = v_code
        RETURNING ver INTO v_ver
      ;
    END IF;

    INSERT INTO wsd.file_link (file_id, class_id, obj_id, folder_code, code, ext, created_by, ver) VALUES
      (v_file_id, a_class_id, a_obj_id, a_folder_code, v_code, r_mtype.ext, a_account_id, COALESCE(v_ver + 1, 1))
    ;

    IF v_job_handler_id IS NOT NULL THEN
      -- TODO: создать задачу в job
    END IF;

    RETURN v_code;
  END;
$_$;
SELECT pg_c('f', 'file_add', 'Добавление файла');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION file_new_path_mk (
  a_class_id    ws.d_class
, a_folder_code ws.d_code
, a_obj_id      ws.d_id
, a_name        ws.d_string
, a_code        ws.d_string DEFAULT NULL
) RETURNS ws.t_hashtable LANGUAGE 'plpgsql' AS
$_$
  -- a_class_id: ID класса
  -- a_folder_code: Код папки
  -- a_obj_id:      ID объекта
  -- a_name:        Внешнее имя файла
  -- a_code:        Код связи
  DECLARE
    r_folder fs.folder;
    v_file_id INTEGER;
    v_code            ws.d_string; -- d_code;
    r ws.t_hashtable;
  BEGIN
    r_folder := fs.folder(a_class_id, a_folder_code);
    v_file_id := NEXTVAL('wsd.file_id_seq');
    v_code := COALESCE(a_code, v_file_id || '_' || fs.name2uri(a_name));

    r.id := v_file_id::TEXT;
    r.name := 'apidata/' -- TODO: move to wsd.prop_value
      || ws.class_code(a_class_id) || '/'
      || a_obj_id::TEXT || '/'
      || a_folder_code || '/'
      || v_code
    ;

    RETURN r;
  END
$_$;
SELECT pg_c('f', 'file_new_path_mk', 'ID и путь хранения для формируемого файла');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION file_list (
  a_class_id    ws.d_class
, a_folder_code ws.d_code
, a_obj_id      ws.d_id
, a_file_code   ws.d_string DEFAULT NULL
, a_file_ver    ws.d_cnt DEFAULT NULL
) RETURNS SETOF fs.file_info STABLE LANGUAGE 'sql' AS
$_$
  -- a_class_id: ID класса
  -- a_folder_code: Код папки
  -- a_obj_id:      ID объекта
  -- a_file_code:   Код файла
  -- a_file_ver:    Версия файла
  SELECT *
    FROM fs.file_info
    WHERE class_id = $1
      AND folder_code = $2
      AND obj_id = $3
      AND ($4 IS NULL OR code = $4)
      AND CASE WHEN $5 /* a_file_ver */ IS NULL THEN is_ver_last ELSE ver = $5 END
    ORDER BY link_created_at
  ;
$_$;
SELECT pg_c('f', 'file_list', 'Список привязанных файлов');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION file_link_delete (
  a_class_id    ws.d_class
, a_folder_code ws.d_code
, a_obj_id      ws.d_id
, a_file_id     d_id DEFAULT 0
) RETURNS BOOLEAN VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- a_class_id: ID класса
  -- a_folder_code: Код папки
  -- a_obj_id:      ID объекта
  -- a_file_id:     ID файла
  BEGIN
    DELETE FROM wsd.file_link 
      WHERE class_id = a_class_id
        AND folder_code = a_folder_code
        AND obj_id = a_obj_id
        AND a_file_id IN (0, file_id)
    ;
    RETURN FOUND;
  END
$_$;
SELECT pg_c('f', 'file_link_delete', 'Удаление привязки к файлу');

