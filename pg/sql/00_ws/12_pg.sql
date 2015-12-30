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

    Примитивы, использующие особенности Postgresql
*/

/* ------------------------------------------------------------------------- */
CREATE DOMAIN d_pg_argtypes AS oidvector; -- pg_catalog.pg_proc.proargtypes
CREATE DOMAIN d_pg_argnames AS TEXT[];    -- pg_catalog.pg_proc.proargnames

/* ------------------------------------------------------------------------- */
CREATE TYPE t_pg_object AS ENUM ('h', 'r', 'v', 'c', 't', 'd', 'f', 'a', 's'); -- see pg_comment
CREATE TYPE t_pkg_op AS ENUM ('init', 'make', 'drop', 'erase', 'done'); -- see 50_pkg.sql

/* ------------------------------------------------------------------------- */
CREATE TYPE t_pg_proc_info AS (
  schema      TEXT
, name        TEXT
, anno        TEXT
, rt_oid      oid
, rt_name     TEXT
, is_set      BOOL
, args        TEXT
, args_pub    TEXT
);
        
/* ------------------------------------------------------------------------- */
CREATE TYPE t_pg_view_info AS (
  rel         TEXT  -- имя view из аргументов ф-и (схема.объект)
, code        TEXT  -- имя столбца (без значения rel)
, rel_src     TEXT  -- имя (схема.объект) источника комментария без имени столбца)
, rel_src_col TEXT  -- имя столбца источника комментария
, status_id   INT   -- результат поиска (1 - найден коммент, 2 - у источника коммент не задан, 3 - расчетное поле, 4 - ошибка, 5 - неподдерживаемый формат поля в представлении) 
, anno        TEXT  -- зависит от status_d: 1 - комментарий, 2 - null, 3 - текст формулы, 4- описание "иного" 
);

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_cs(TEXT DEFAULT '') RETURNS name STABLE LANGUAGE 'sql' AS
$_$
 SELECT (current_schema() || CASE WHEN COALESCE($1, '') = '' THEN '' ELSE '.' || $1 END)::name
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION sprintf (TEXT, TEXT DEFAULT '', TEXT DEFAULT '', TEXT DEFAULT '', TEXT DEFAULT '') RETURNS TEXT IMMUTABLE LANGUAGE 'plperl' AS
$_$ #
    my ($fmt, @args) = @_; my $str = sprintf($fmt, @args); return $str;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_schema_oid(a_name TEXT) RETURNS oid STABLE LANGUAGE 'sql' AS
$_$
  -- a_name: название пакета
  SELECT oid FROM pg_namespace WHERE nspname = $1
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_exec_func(a_name TEXT) RETURNS TEXT STABLE LANGUAGE 'plpgsql' AS
$_$
  -- a_name:  имя функции
  DECLARE
    v TEXT;
  BEGIN
    EXECUTE 'SELECT * FROM ' || a_name || '()' INTO v;
    RETURN v;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_exec_func(
  a_schema TEXT
, a_name   TEXT
) RETURNS TEXT STABLE LANGUAGE 'sql' AS
$_$
  -- a_schema: название пакета
  -- a_name:   имя функции
  SELECT ws.pg_exec_func($1 || '.' || $2)
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_schema_by_oid(a_oid oid) RETURNS TEXT STABLE LANGUAGE 'sql' AS
$_$
  -- a_oid:  OID
  SELECT nspname::TEXT FROM pg_namespace WHERE oid = $1
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.pg_type_name(a_oid oid) RETURNS TEXT STABLE LANGUAGE 'sql' AS
$_$
  -- a_oid:  OID
  SELECT CASE WHEN nspname = 'pg_catalog' THEN pg_catalog.format_type($1, NULL) ELSE  nspname || '.' || typname END
    FROM (
      SELECT (SELECT nspname FROM pg_namespace WHERE oid = typnamespace) as nspname, typname FROM pg_type WHERE oid = $1
    ) AS pg_type_name_temp
$_$;
      
/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION reserved_args() RETURNS TEXT[] IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT ARRAY['a__acl', 'a__sid', 'a__ip', 'a__cook', 'a__lang'];
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_proargs2str(
  a_names d_pg_argnames
, a_types d_pg_argtypes
, a_pub   BOOL
) RETURNS TEXT STABLE LANGUAGE 'plpgsql' AS
$_$
  -- a_names:  список аргументов
  -- a_types:  список OID-ов
  -- a_pub:    флаг
  DECLARE
    v_reserved TEXT[];
    v_names    TEXT[];
    v_i        INTEGER;
  BEGIN
    v_reserved := ws.reserved_args();
    FOR v_i IN 0 .. pg_catalog.array_upper(a_types, 1) LOOP
      CONTINUE WHEN a_pub AND a_names[v_i + 1] = ANY (v_reserved);
      v_names[v_i] := pg_catalog.format_type(a_types[v_i], NULL);
      IF a_names IS NOT NULL THEN
        IF a_pub AND COALESCE(a_names[v_i + 1], '') = '' THEN
          RETURN ''; -- аргумент без имени => не формируем строку публичных аргументов
        END IF;
        v_names[v_i] := CASE
          WHEN COALESCE(a_names[v_i + 1], '') = '' THEN ''
          WHEN a_pub THEN regexp_replace(a_names[v_i + 1], '^a_', '') || ' '
          ELSE a_names[v_i + 1] || ' '
          END || v_names[v_i];
      ELSIF a_pub THEN
        RETURN ''; -- аргументы без имен => не формируем строку публичных аргументов
      END IF;
    END LOOP;
    RETURN array_to_string(v_names, ', ');
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_proc_info(
  a_ns   TEXT
, a_name TEXT
) RETURNS SETOF t_pg_proc_info STABLE LANGUAGE 'sql' AS
$_$
  -- a_ns:   название пакета
  -- a_name: название функции
  SELECT $1
  , $2
  , obj_description(p.oid, 'pg_proc')
  , p.prorettype
  , ws.pg_type_name(p.prorettype)
  , proretset
  , ws.pg_proargs2str(p.proargnames, p.proargtypes, false) -- proargtypes - only IN arguments
  , ws.pg_proargs2str(p.proargnames, p.proargtypes, true)
    FROM pg_catalog.pg_proc p
    WHERE p.pronamespace = ws.pg_schema_oid($1)
      AND p.proname = $2
  ;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.pg_view_comments_get_tbl(a_code TEXT) RETURNS TEXT VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- a_code: имя объекта
  DECLARE
    v_ret    TEXT;
    R        record;
    v_schema TEXT[];
    v_table  TEXT;
    _i       INT;
  BEGIN
    IF a_code ~ E'\\.' THEN -- схема передана в вводном параметре
      v_schema := ARRAY[split_part(a_code, '.', 1)];
      v_table  := split_part(a_code, '.', 2);
    ELSE -- схема ищется в search_path
      v_schema := current_schemas(TRUE);
      v_table  := a_code;
    END IF;
    FOR _i IN array_lower(v_schema, 1)..array_upper(v_schema, 1) LOOP
      FOR R IN 
        SELECT table_schema, table_name
          FROM information_schema.tables
          WHERE (table_schema = v_schema[_i] AND table_name = v_table)
        LOOP       
        IF v_ret IS NOT NULL THEN
          RETURN NULL;
        END IF;
        v_ret := R.table_schema || '.' || R.table_name;
      END LOOP;
      IF v_ret IS NOT NULL THEN
        EXIT;
      END IF;
    END LOOP;
    RETURN v_ret;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.pg_view_comments(a_code TEXT) RETURNS SETOF ws.t_pg_view_info VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- a_code: имя объекта
  DECLARE
    v_code     TEXT[];
    v_def      TEXT;
    v_def_arr  TEXT[];
    r_         record;
    v_i        INT;
    v_j        INT;
    v_k        INT;
    v_viewname TEXT;    
    v_ret_1    TEXT[];
    v_ret_2    TEXT[];
    v_ret_3    TEXT[];
    v_ret_4    TEXT[];
    v_ret_5    INT[];
    v_ret_6    TEXT[];
  BEGIN
    RAISE DEBUG 'PROCESSING: View %', a_code;
    v_code := string_to_array(a_code, '.');
    FOR r_ in
     (SELECT schemaname || '.' || viewname as vname, lower(definition) as _def from pg_views
      WHERE (array_length(v_code, 1) = 2 and schemaname = v_code[1] and viewname = v_code[2])
      or (array_length(v_code, 1) = 1 and viewname = v_code[1]))
    LOOP
      IF v_def is not null THEN
        RAISE WARNING 'ERROR: Имя представления неоднозначно %', a_code;
        RETURN;
      END IF;
      v_def := r_._def;
      v_viewname := r_.vname;
    END LOOP;
    v_def := REGEXP_REPLACE(REGEXP_REPLACE(TRANSLATE(TRIM(v_def), E'\n', ' '), E'\\s+', ' ', 'g'), E' +([()]) +', E'\\1', 'g');
    IF v_def is null THEN
      RAISE WARNING 'ERROR: Представление не найдено %', a_code;
      RETURN;
    END IF;
    v_def_arr := string_to_array(v_def, ' union ');
    FOR v_j in array_lower(v_def_arr, 1)..array_upper(v_def_arr, 1) LOOP
      DECLARE
         v_list       TEXT;
         v_list_check TEXT;
         v_field      TEXT;
         v_brac       INT;  -- индекс подсчета скобок
         v_temp       TEXT[];
      BEGIN
        v_def := ' ' ||  trim(trim(v_def_arr[v_j]), ';') || ' ';
        IF position(' except ' in v_def) > 0 THEN
          v_def := trim(substring(v_def from 1 FOR position(' except ' in v_def)));
        END IF;
        -- v_list: список полей в тексте запроса между select/from избегая вложенные выборки
        v_list := substring(v_def from position('select' in v_def) + 7);
        v_temp := string_to_array(v_list, ' from ');
        v_brac := 1;
        v_list := v_temp[v_brac];
        LOOP
          v_brac = v_brac + 1;
          IF length(replace(v_list, '(', '')) = length(replace(v_list, ')', '')) or v_brac > array_length(v_temp, 1) THEN
            EXIT;
          ELSE
            v_list := v_list || v_temp[v_brac];
          END IF;
        END LOOP;
        -- представить поля текста запроса в виде массива
        -- необходимо разбить по "," принимая во внимание что некоторые поля имеют формулы с "," внутри "()"
        v_i := 1;
        v_brac := 0;
        v_temp := string_to_array(v_list, ',');
        v_code := null;
        FOR v_k in array_lower(v_temp, 1)..array_upper(v_temp, 1) LOOP
          v_temp[v_k] := trim(v_temp[v_k]);
          v_code[v_i] := coalesce(v_code[v_i], '') || v_temp[v_k];
          v_brac := v_brac + length(replace(v_temp[v_k], '(', '')) - length(replace(v_temp[v_k], ')', ''));
          IF v_brac = 0 THEN
            v_i := v_i + 1;
          END IF;
        END LOOP;
        -- ошибка данной ф-ции если длина массива отлична от макс номера поля в представлении
        IF (select max(attnum) FROM pg_attribute WHERE attrelid = v_viewname::regclass) <> array_length(v_code, 1) THEN
          RAISE WARNING 'FATAL ERROR: Ошибка подсчета количества полей "%"', a_code;
          RETURN;
        END IF;
        -- обработать поля
        FOR v_i in array_lower(v_code, 1)..array_upper(v_code, 1) LOOP
          DECLARE
            v_const_1 TEXT := ' as ';         
            v_const_2 TEXT := '.';
            v_fld     TEXT; -- поле "A.B" или "A.B as C"
            v_exp     TEXT; -- A.B A.B
            v_tbl     TEXT; -- A   A
            v_col     TEXT; -- B   B
            v_als     TEXT; -- B   C
            v_res_1   TEXT;
            v_res_2   TEXT;
            v_res_3   TEXT;
            v_res_4   TEXT;
            v_res_5   INT;
            v_res_6   TEXT;
            v__debug  TEXT;
          BEGIN
            v_fld := trim(v_code[v_i]);
            v_exp := split_part(v_fld, v_const_1, 1);
            v_tbl := split_part(v_exp, v_const_2, 1);
            -- v_exp - должно быть вида таблица.колонка иначе комментарий не будет вычеслен. проверка введена для отслеживания
            IF length(v_exp) - length(replace(v_exp, v_const_2, '')) = length(v_const_2) THEN
              v_col := split_part(v_exp, v_const_2, 2);
            END IF;
            v_als := case when length(v_fld) - length(replace(v_fld, v_const_1, '')) <> length(v_const_1) then v_col else split_part(v_fld,v_const_1, 2) end;
            v_res_1 = v_viewname;
            v_res_2 = v_als;
            IF v_exp ~ '^[''.0-9]|null*' or v_exp ~ E'\\(' THEN
              v_res_5 = 3;
              v_res_6 = v_exp;      
            ELSE
              DECLARE
                v_src TEXT; -- таб. источник
              BEGIN
                -- v_pos: позиция v_tbl в строке выборки v_def в порядке определенном v_const_3
                DECLARE
                  v_const_3 TEXT[][] = ARRAY[[' ',' '],[' ',','],['.',''],['','']];
                  v_srh     TEXT;
                  v_x       INT;
                  v_pos     INT;
                  v_l       TEXT;
                  v_r       TEXT;
                BEGIN
                  FOR v_x in array_lower(v_const_3,1)..array_upper(v_const_3,1) LOOP
                    v_srh := v_const_3[v_x][1] || v_tbl || v_const_3[v_x][2];
                    v_pos := position(v_srh in v_def);
                    IF v_pos > 0 THEN 
                      EXIT;
                    END IF;
                  END LOOP;
                  IF v_pos > 0 THEN
                    -- v_l = одно слово слева от v_pos (с убранными 'join|from|select')
                    -- v_r = одно слово справа от v_pos
                    -- строка выборки слева/справа
                    v_l = trim(substring(v_def from 1 for v_pos));
                    v_r = trim(substring(v_def from v_pos));
                    -- последнее/пеорвое слово
                    v_l := split_part(v_l, ' ', 1 + length(trim(v_l)) - length(replace(trim(v_l), ' ', '')));
                    v_r := split_part(v_r, ' ', 1);
                    -- убрать join,from,select если они оказались слева
                    v_l := case when v_l ~ 'join|from|select' then split_part(v_l, '.', 2) else v_l END;
                    -- убрать символы ().
                    v_l := btrim(v_l, '(.');
                    v_r := btrim(v_r, ').');
                    IF v_l = '' THEN
                      v_src := v_r;
                    ELSIF v_r = '' or (length(v_l) - length(replace(v_l, v_const_2, '')) = length(v_const_2) or 
                      (v_r = v_tbl and v_l ~ '^pg_*')) THEN
                      v_src := v_l;
                    ELSIF length(v_l) - length(replace(v_l, v_const_2, '')) = 0 and v_r = v_tbl and substring(v_def from v_pos for 1) <> v_const_2 THEN
                      v_src = v_l;
                    ELSIF v_r <>  v_tbl or substring(v_def from v_pos for 1) = v_const_2 THEN 
                      v_src := v_l || '.' || v_r;
                    END IF;
                    -- v_src не содержит точку, значит нет схемы. получить схема.таблица из pg_view_comments_get_tbl
                    IF length(v_src) - length(replace(v_src, v_const_2, '')) <> length(v_const_2) THEN
                      v_src := ws.pg_view_comments_get_tbl(v_src);
                    END IF;
                  END IF;
                  v__debug = v_l || '~' || v_r || '~' || v_tbl || '~' || v_pos::TEXT;
                END;
                v_res_3 := v_src;
                v_res_4 := v_col;
                IF v_src is not null and length(v_src) - length(replace(v_src, v_const_2, '')) = length(v_const_2) THEN
                  -- дополнительная проверка: если v_src определена неправильно не будет ошибки выполнения запроса (превентивная, частных случаев нет)
                  PERFORM 1 FROM information_schema.tables WHERE table_schema = split_part(v_src, '.', 1) AND table_name = split_part(v_src, '.', 2);
                  IF FOUND THEN
                    v_res_6 := 
                      (SELECT col_description
                      ((SELECT (v_src)::regclass::oid)::INT,
                      (SELECT attnum FROM pg_attribute WHERE attrelid = (v_src)::regclass AND attname = v_col)));
                    v_res_5 := case when v_res_6 is not null THEN 1 ELSE 2 END;
                  END IF;
                END IF;
              END;
              IF v_res_5 is null then
                v_res_5 := 4;
                v_res_6 := 'Ошибка определения комментария для: ' || v_code[v_i] || v_def;
              END IF;
            END IF;
            IF coalesce(v_ret_5[v_i],0) <> 1 THEN
              v_ret_1[v_i] := v_res_1;
              v_ret_2[v_i] := v_res_2;
              v_ret_3[v_i] := v_res_3;
              v_ret_4[v_i] := v_res_4;
              v_ret_5[v_i] := v_res_5;
              v_ret_6[v_i] := v_res_6;
              RAISE DEBUG 'ROW: %|%|%|%|%|%|%', v_res_1, v_res_2, v_res_3, v_res_4, v_res_5, v__debug, v_res_6;
            END IF;
          END;
        END LOOP;
      END;
    END LOOP;
    FOR v_i in array_lower(v_ret_1,1)..array_upper(v_ret_1,1) loop
      r_ := ROW(
        coalesce(v_ret_1[v_i], ''),
        coalesce(v_ret_2[v_i], ''),
        coalesce(v_ret_3[v_i], ''),
        coalesce(v_ret_4[v_i], ''),
        coalesce(v_ret_5[v_i], 0),
        coalesce(v_ret_6[v_i], ''));
      RETURN NEXT r_;
    END LOOP;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.pg_c(
  a_type ws.t_pg_object
, a_code name
, a_text TEXT
, a_anno TEXT DEFAULT NULL
) RETURNS void VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- a_type: тип объекта (из перечисления ws.t_pg_object)
  -- a_code: имя объекта
  -- a_text: комментарий
  -- a_anno: аннотация (не сохраняется, предназначено для размещения описания рядом с кодом)
  DECLARE
    v_code TEXT;
    v_name TEXT;
    rec    ws.t_pg_proc_info;
    r_view RECORD;

  BEGIN
    -- определить схему объекта, если не задана
    IF split_part(a_code, '.', 2) = '' AND a_type NOT IN ('h')
      OR a_type IN ('c','a') AND split_part(a_code, '.', 3) = '' THEN
      v_code := ws.pg_cs(a_code); -- добавить имя текущей схемы
    ELSE
      v_code := a_code;
    END IF;

    IF a_type = 'v' THEN
      FOR r_view in select * from ws.pg_view_comments(v_code) LOOP
        IF r_view.status_id = 1 THEN
          PERFORM ws.pg_c('c', r_view.rel || '.' || r_view.code, r_view.anno);
        END IF;
      END LOOP;
    END IF;

    v_name := CASE
      WHEN a_type = 'h' THEN 'SCHEMA'
      WHEN a_type = 'r' THEN 'TABLE'
      WHEN a_type = 'v' THEN 'VIEW'
      WHEN a_type = 'c' THEN 'COLUMN'
      WHEN a_type = 't' THEN 'TYPE'
      WHEN a_type = 'd' THEN 'DOMAIN'
      WHEN a_type = 'f' THEN 'FUNCTION'
      WHEN a_type = 's' THEN 'SEQUENCE'
      ELSE NULL -- a_type = 'a'
    END;
    RAISE DEBUG 'COMMENT FOR % %: % (%)', v_name, v_code, a_text, a_anno;
    IF v_name IS NULL THEN
      -- a(rgument)
      UPDATE ws.dt_part SET anno = a_text
        WHERE dt_code = split_part(v_code, '.', 1)||'.'||split_part(v_code, '.', 2)
          AND code = split_part(v_code, '.', 3)
      ;
    ELSIF a_type = 'f' THEN
      -- получить списки аргументов и прописать коммент каждой ф-и с этим именем
      FOR rec IN SELECT * FROM ws.pg_proc_info(split_part(v_code, '.', 1), split_part(v_code, '.', 2)) LOOP
        v_name := ws.sprintf(E'COMMENT ON FUNCTION %s(%s) IS \'%s\'', v_code, rec.args, a_text);
        EXECUTE v_name;
        RAISE DEBUG '%', v_name;
      END LOOP;
    ELSE
      EXECUTE ws.sprintf(E'COMMENT ON %s %s IS \'%s\'', v_name, v_code, a_text);
    END IF;
  END;
$_$;
SELECT pg_c('f', 'pg_c', 'Создать комментарий к объекту БД');

/* ------------------------------------------------------------------------- */
SELECT 
  pg_c('f', 'sprintf',                  'Порт функции sprintf')
, pg_c('f', 'pg_cs',                    'Текущая (первая) схема БД в пути поиска', $_$если задан аргумент, он и '.' добавляются к имени схемы$_$)
, pg_c('f', 'reserved_args',            'Зарезервированные имена аргументов методов')
, pg_c('f', 'pg_view_comments',         'получить комментарии полей view из таблиц запроса')
, pg_c('f', 'pg_schema_oid',            'получить OID по названию пакета')
, pg_c('f', 'pg_exec_func',             'вызов функции')
, pg_c('f', 'pg_schema_by_oid',         'получить название пакета по OID-у')
, pg_c('f', 'pg_type_name',             'получить название типа по OID-у')
, pg_c('f', 'pg_proargs2str',           'сформировать список аргументов в строку')
, pg_c('f', 'pg_proc_info',             'информация о функции')
, pg_c('f', 'pg_view_comments_get_tbl', 'получить из названия строку схема.название')
, pg_c('d', 'd_pg_argtypes',            'список OID-ов')
, pg_c('d', 'd_pg_argnames',            'список аргументов')
, pg_c('t', 't_pg_object',              'типы объектов')
, pg_c('t', 't_pkg_op',                 'стадии')
, pg_c('t', 't_pg_view_info',           'информация о представлении')
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.pg_type_search(a_code TEXT) RETURNS TEXT STABLE LANGUAGE 'sql' AS
$_$
  -- a_code: название типа
  SELECT tmp.sch || '.' || t.typname 
    FROM (SELECT row_number() OVER () AS rn, sch FROM unnest(current_schemas(TRUE)) sch) tmp
    , pg_catalog.pg_type t 
    WHERE tmp.sch = ws.pg_schema_by_oid(t.typnamespace)
      AND t.typname = $1 /* a_code */
    ORDER BY tmp.rn, t.typname
    LIMIT 1
$_$;
SELECT pg_c('f', 'pg_type_search', 'Поиск схемы для типа по search_path');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.pg_type_oid(a_name TEXT) RETURNS oid STABLE LANGUAGE 'sql' AS
$_$
  -- a_name: название типа
  SELECT oid FROM pg_type
    WHERE typnamespace = ws.pg_schema_oid(split_part($1, '.', 1))
      AND typname = split_part($1, '.', 2)
$_$;
SELECT pg_c('f', 'pg_type_oid', 'OID типа по его схема.имя');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION raise (
  a_lvl TEXT DEFAULT 'EXCEPTION'
, a_msg TEXT DEFAULT 'Default error msg.'
) RETURNS void LANGUAGE plpgsql STRICT AS
$_$
  -- a_lvl: способ вызова
  -- a_msg: сообщение
  BEGIN
     a_msg := COALESCE(a_msg, 'Default error msg.');
     CASE upper(a_lvl)
         WHEN 'EXCEPTION' THEN RAISE EXCEPTION '%', a_msg;
         WHEN 'WARNING'   THEN RAISE WARNING   '%', a_msg;
         WHEN 'NOTICE'    THEN RAISE NOTICE    '%', a_msg;
         WHEN 'DEBUG'     THEN RAISE DEBUG     '%', a_msg;
         WHEN 'LOG'       THEN RAISE LOG       '%', a_msg;
         WHEN 'INFO'      THEN RAISE INFO      '%', a_msg;
         ELSE RAISE EXCEPTION 'ws.raise(): unexpected raise-level: "%"', a_lvl;
     END CASE;
  END;
$_$;
SELECT pg_c('f', 'raise', 'Вызов RAISE из SQL запросов', $_$/*
Метод позволяет вызывать RAISE из SQL-запросов и скриптов psql.
В отличие от прямого вызова, при таком выводится контекст 
(см. http://dba.stackexchange.com/questions/7214/generate-an-exception-with-a-context)
*/$_$);

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION notice (a_text TEXT) RETURNS VOID LANGUAGE 'sql' AS
$_$
  -- a_text: сообщение
  SELECT ws.raise('NOTICE', $1);
$_$ ;
SELECT pg_c('f', 'notice', 'Вывод предупреждения посредством RAISE NOTICE', $_$/*
Метод позволяет вызывать NOTICE из SQL-запросов и скриптов psql.
Кроме прочего, используется в скриптах 9?_*.sql для передачи в pgctl.sh названия теста
*/$_$);

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.pg_cast (
  a_type  TEXT
, a_value TEXT
) RETURNS TEXT LANGUAGE plpgsql STRICT AS
$_$
  -- a_type:  тип 
  -- a_value: значение
  DECLARE
  v_sql TEXT;
  BEGIN
    v_sql := ws.sprintf('SELECT $1::%s', a_type);
    EXECUTE v_sql USING a_value;
      RETURN NULL;
    EXCEPTION WHEN OTHERS THEN
      RETURN SQLSTATE;
  END;
$_$;
SELECT pg_c('f', 'pg_cast', 'Приведение значения к заданному типу');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.epoch2timestamp(a_epoch INTEGER DEFAULT 0) RETURNS TIMESTAMP IMMUTABLE LANGUAGE 'sql' AS
$_$
  -- a_epoch: количество секунд
SELECT CASE
  WHEN $1 = 0 THEN NULL
  ELSE timezone(
    (SELECT setting FROM pg_settings WHERE name = 'TimeZone')
    , (TIMESTAMPTZ 'epoch' + $1 * INTERVAL '1 second')::timestamptz
    )
END;
$_$;
SELECT pg_c('f', 'epoch2timestamp', 'преобразование секунд к типу TIMESTAMP');

