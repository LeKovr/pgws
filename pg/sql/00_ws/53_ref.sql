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

    Методы работы со справочниками
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ref(a_code d_code_like DEFAULT '%', a__acl d_acls DEFAULT NULL) RETURNS SETOF i18n_def.ref STABLE LANGUAGE 'sql' AS
$_$
  -- a_code: Код справочника
  SELECT * FROM ref WHERE code ilike $1 || '%' AND (acls IS NULL OR acls && $2) ORDER BY code ;
$_$;
SELECT pg_c('f', 'ref', 'Атрибуты справочника', $_$Функция требует SEARCH_PATH$_$);

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ref_data(a_code d_code) RETURNS SETOF ref_data STABLE LANGUAGE 'sql' AS
$_$
  -- a_code: Код справочника
  SELECT * FROM ws.ref_data WHERE code = $1;
$_$;
SELECT pg_c('f', 'ref_data', 'Внутренние атрибуты справочника');


/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ref_is_allowed(a_code d_code, a__acl d_acls) RETURNS BOOL STABLE LANGUAGE 'sql' AS
$_$
  -- a_code: Код справочника
  -- a__acl: Список acl (данные ядра)
  SELECT COALESCE (
    (SELECT acls IS NULL OR acls && $2 FROM ws.ref_data WHERE code = $1)
  , FALSE
  );
$_$;
SELECT pg_c('f', 'ref_is_allowed', 'Справочник доступен для чтения');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ref_is_allowed_upd(a_code d_code, a__acl d_acls) RETURNS BOOL STABLE LANGUAGE 'sql' AS
$_$
  -- a_code: Код справочника
  -- a__acl: Список acl (данные ядра)
  SELECT COALESCE (
    (SELECT acls_upd && $2 FROM ws.ref_data WHERE code = $1)
  , FALSE
  );
$_$;
SELECT pg_c('f', 'ref_is_allowed_upd', 'Справочник доступен для изменения');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ref_item(
  a_code          d_code
, a_item_code     TEXT DEFAULT NULL
, a_group_id      d_id32 DEFAULT 0
, a__acl          d_acls DEFAULT NULL
, a_page          ws.d_cnt DEFAULT 0
, a_by            ws.d_cnt DEFAULT 0
) RETURNS SETOF i18n_def.ref_item STABLE LANGUAGE 'plpgsql' AS
$_$
  -- a_code: Код справочника
  -- a_item_code: Код позиции
  -- a_group_id: ID группы
  -- a__acl: Список acl (данные ядра)
  DECLARE
    r_ref_data ws.ref_data%ROWTYPE;
    v_method_code TEXT;
  BEGIN
    SELECT * INTO STRICT r_ref_data FROM ws.ref_data(a_code);
    -- проверить доступ
    IF NOT ws.ref_is_allowed(a_code, a__acl) THEN
      RAISE EXCEPTION '%', ws.e_noaccess();
    END IF;
    -- смаршрутизировать источник
    IF r_ref_data.is_dt_vary THEN
      -- нестандартная структура - для доступа надо вызывать другую ф-ю (method_code)
      RAISE EXCEPTION '%', ws.e_nodata();
    ELSIF r_ref_data.method_code IS NOT NULL THEN
      -- данные получаем из другой функции
      v_method_code := COALESCE (ws.method_code_real(r_ref_data.method_code), r_ref_data.method_code);
      RETURN QUERY EXECUTE 'SELECT * FROM ' || v_method_code || '($1, $2, $3, $4, $5, $6)' USING a_code, a_item_code, a_group_id, a__acl, a_page, a_by;
    ELSE 
      -- стандартный справочник
      RETURN QUERY
        SELECT *
          FROM i18n_def.ref_item
          WHERE code = a_code
            AND COALESCE(a_item_code, item_code) = item_code
            AND a_group_id IN (group_id, 0)
          ORDER BY sort
          OFFSET a_page * a_by
          LIMIT NULLIF(a_by, 0)
      ;
    END IF;
    IF NOT FOUND THEN
      RAISE EXCEPTION '%', ws.e_nodata();
    END IF;
    RETURN;
  END;
$_$;
SELECT pg_c('f', 'ref_item', 'Позиции справочника', $_$Функция требует SEARCH_PATH$_$);

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ref_log(
  a_code          d_code
, a_item_code     TEXT DEFAULT NULL
, a__lang         d_lang DEFAULT ws.const_lang_default()
, a_updated_after d_stamp DEFAULT NULL
, a__acl          d_acls DEFAULT NULL
) RETURNS SETOF wsd.ref_update STABLE LANGUAGE 'sql' AS
$_$
  -- a_code: Код справочника
  -- a_updated_after: Минимальный момент времени изменения позиции
  SELECT * FROM wsd.ref_update
    WHERE code = $1
      AND ws.ref_is_allowed(code, $5)
      AND COALESCE($2, item_code) = item_code
      AND lang = COALESCE($3, ws.const_lang_default())
      AND updated_at >= COALESCE($4, ws.const_update_timestamp())
    ORDER BY code, lang, updated_at
  ;
$_$;
SELECT pg_c('f', 'ref_log', 'Журнал изменений справочника начиная с updated_at');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ref_op_register(
  a_code        d_code
, a_item_code   d_string
, a_updated_at  d_stamp DEFAULT NULL
, a_op          d_codei DEFAULT ws.const_ref_op_insert()
, a__lang       d_lang DEFAULT  ws.const_lang_default()
) RETURNS BOOL VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- a_code:        Код справочника
  -- a_item_code:   Код позиции
  -- a_updated_at:  Момент изменения
  -- a_op:          Операция изменения
  -- a__lang:       Язык справочника (данные ядра)
  DECLARE
    r_ref_update wsd.ref_update%ROWTYPE;
  BEGIN
    IF a_updated_at IS NULL THEN
      IF a_op = ws.const_ref_op_insert() THEN
        -- первичный insert не регистрируется
        RETURN TRUE;
      ELSE
        -- updated_at обязателен, если op<>insert
        RAISE EXCEPTION '%', ws.e_noaccess();
      END IF;
    END IF;

    -- проверить изменение на дубль
    SELECT INTO r_ref_update *
      FROM wsd.ref_update
        WHERE code = a_code
          AND item_code = a_item_code
          AND lang = a__lang
    ;
    IF FOUND THEN
      IF r_ref_update.op = a_op AND r_ref_update.updated_at = a_updated_at THEN
        RETURN FALSE;
      ELSE
        UPDATE wsd.ref_update SET
          updated_at = a_updated_at
        , op = a_op
          WHERE code = a_code
            AND item_code = a_item_code
            AND lang = a__lang
        ;
      END IF;
    ELSE  
      INSERT INTO wsd.ref_update (code, item_code, lang, op, updated_at) VALUES
        (a_code, a_item_code, a__lang, a_op, a_updated_at)
      ;
    END IF;
    -- PERFORM pg_notify('sync', a_code || ', ' || a_item_code);
    RETURN TRUE;
  END;
$_$;
SELECT pg_c('f', 'ref_op_register', 'Регистрация операции изменения справочника');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ref_op(
  a_code        d_code
, a_item_code   d_string
, a_sort        d_sort
, a_name        d_string
, a__acl        d_acls
, a_group_id    d_id32 DEFAULT 1
, a_code_addon  d_string DEFAULT NULL
, a_anno        d_text DEFAULT NULL
, a_updated_at  d_stamp DEFAULT NULL
, a_op          d_codei DEFAULT ws.const_ref_op_insert()
, a__lang       d_lang DEFAULT  ws.const_lang_default()
) RETURNS BOOL VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- a_code:        Код справочника
  -- a_item_code:   Код позиции
  -- a_sort:        Порядок сортировки
  -- a_name:        Название позиции
  -- a__acl:        Список acl (данные ядра)
  -- a_group_id:    Внутренний ID группы
  -- a_code_addon:  Дополнительный код (опция)
  -- a_anno:        Аннотация
  -- a_updated_at:  Момент изменения
  -- a_op:          Операция изменения
  -- a__lang:       Язык справочника (данные ядра)
  DECLARE
    r_ref_data    ws.ref_data%ROWTYPE;
    v_method_code TEXT;
    v_ret BOOL;
  BEGIN
    -- доступ
    IF NOT ws.ref_is_allowed_upd(a_code, a__acl) THEN
      RAISE EXCEPTION '%', ws.e_noaccess();
    END IF;
    -- проверить дубль
    IF NOT ws.ref_op_register(a_code, a_item_code, a_updated_at, a_op, a__lang) THEN
      -- такое изменение уже есть
      RETURN FALSE;
    END IF;

    SELECT * INTO STRICT r_ref_data FROM ws.ref_data(a_code);
    -- проверить доступ
    RAISE DEBUG 'ref_change: required acl: %, given: %', r_ref_data.acls_upd, a__acl;

    -- изменить справочник
    IF r_ref_data.is_dt_vary THEN
      -- нестандартная структура - для доступа надо вызывать другую ф-ю (method_code_upd)
      RAISE EXCEPTION '%', ws.e_nodata();
    ELSIF r_ref_data.method_code_upd IS NOT NULL THEN
      -- данные изменяем в другой функции
      -- мы уже проверили доступ и зарегистрировали. method_code_upd может не быть в API (или там надо это дублировать)
      v_method_code := COALESCE (ws.method_code_real(r_ref_data.method_code_upd), r_ref_data.method_code_upd);
      EXECUTE 'SELECT ' || v_method_code || '($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)'
        INTO v_ret
        USING a_code, a_item_code, a_sort, a_name, a__acl, a_group_id, a_code_addon, a_anno, a_updated_at, a_op, a__lang
      ;
      RETURN v_ret;
    ELSE
      -- стандартный справочник
      IF a_op = ws.const_ref_op_insert() THEN
        INSERT INTO ws.ref_item_data (code, item_code, group_id, code_addon) VALUES 
          (a_code, a_item_code, a_group_id, a_code_addon)
        ;
        INSERT INTO ref_item_name (code, item_code, sort, name, anno) VALUES
          (a_code, a_item_code, a_sort, a_name, a_anno)
        ;
      ELSIF a_op = ws.const_ref_op_update() THEN
        UPDATE ws.ref_item_data SET
          group_id = a_group_id
        , code_addon = a_code_addon
          WHERE code = a_code
            AND item_code = a_item_code
        ;
        UPDATE ref_item_name SET
          sort = a_sort
        , name = a_name
        , anno = a_anno
          WHERE code = a_code
            AND item_code = a_item_code
        ;
      ELSIF a_op = ws.const_ref_op_delete() THEN
        DELETE FROM ws.ref_item_data
          WHERE code = a_code
            AND item_code = a_item_code
        ;
        -- i18n_*.ref_item_name удаляются по ON DELETE CASCADE
      ELSE
        -- TODO: возвращать собственный код ошибки
        RAISE EXCEPTION '%', ws.e_noaccess();
      END IF;
    END IF;
    RETURN TRUE;
  END;
$_$;
SELECT pg_c('f', 'ref_op', 'Операция изменения справочника', $_$Функция требует SEARCH_PATH$_$);

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ref_sync_complete(a_code d_code, a_updated_at d_stamp DEFAULT NULL) RETURNS VOID VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- a_code: Код справочника
  BEGIN
    UPDATE ref_name SET synced_at = COALESCE(a_updated_at, CURRENT_TIMESTAMP)
      WHERE code = a_code
      RETURNING code INTO STRICT a_code
    ;
  END;
$_$;
SELECT pg_c('f', 'ref_sync_complete', 'Сохранение времени синхронизации справочника', $_$Функция требует SEARCH_PATH$_$);
