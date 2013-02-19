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
CREATE DOMAIN d_pg_argnames AS text[];    -- pg_catalog.pg_proc.proargnames

/* ------------------------------------------------------------------------- */
CREATE TYPE t_pg_object AS ENUM ('h', 'r', 'v', 'c', 't', 'd', 'f', 'a', 's'); -- see pg_comment

/* ------------------------------------------------------------------------- */
CREATE TYPE t_pg_proc_info AS (
  schema      text
, name        text
, anno        text
, rt_oid      oid
, rt_name     text
, is_set      bool
, args        text
, args_pub    text
);
        
/* ------------------------------------------------------------------------- */
CREATE TYPE t_pg_view_info AS (
  rel         text  -- имя view из аргументов ф-и (схема.объект)
, code        text  -- имя столбца (без значения rel)
, rel_src     text  -- имя (схема.объект) источника комментария без имени столбца)
, rel_src_col text  -- имя столбца источника комментария
, status_id   int   -- результат поиска (1 - найден коммент, 2 - у источника коммент не задан, 3 - расчетное поле, 4 - ошибка, 5 - неподдерживаемый формат поля в представлении) 
, anno        text  -- зависит от status_d: 1 - комментарий, 2 - null, 3 - текст формулы, 4- описание "иного" 
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
CREATE OR REPLACE FUNCTION pg_schema_oid(a_name text) RETURNS oid STABLE LANGUAGE 'sql' AS
$_$
  SELECT oid FROM pg_namespace WHERE nspname = $1
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_exec_func(a_name text) RETURNS text STABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v TEXT;
  BEGIN
    EXECUTE 'SELECT * FROM ' || a_name || '()' INTO v;
    RETURN v;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_exec_func(a_schema TEXT, a_name TEXT) RETURNS TEXT STABLE LANGUAGE 'sql' AS
$_$
  SELECT ws.pg_exec_func($1 || '.' || $2)
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_schema_by_oid(a_oid oid) RETURNS TEXT STABLE LANGUAGE 'sql' AS
$_$
  SELECT nspname::TEXT FROM pg_namespace WHERE oid = $1
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.pg_type_name(a_oid oid) RETURNS text STABLE LANGUAGE 'sql' AS
$_$
  SELECT CASE WHEN nspname = 'pg_catalog' THEN pg_catalog.format_type($1, NULL) ELSE  nspname || '.' || typname END
    FROM (
      SELECT (SELECT nspname FROM pg_namespace WHERE oid = typnamespace) as nspname, typname FROM pg_type WHERE oid = $1
    ) AS pg_type_name_temp
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION reserved_args() RETURNS text[] IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT ARRAY['a__acl', 'a__sid', 'a__ip', 'a__cook', 'a__lang'];
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_proargs2str(a_names d_pg_argnames, a_types d_pg_argtypes, a_pub BOOL) RETURNS text STABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_reserved TEXT[];
    v_names TEXT[];
    v_i INTEGER;
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
CREATE OR REPLACE FUNCTION pg_proc_info(a_ns text, a_name text) RETURNS SETOF t_pg_proc_info STABLE LANGUAGE 'sql' AS
$_$
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
CREATE OR REPLACE FUNCTION ws.pg_view_comments_get_tbl(
  a_code text             -- имя объекта
) RETURNS name VOLATILE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_ret text;
    R record;
    v_schema text[];
    v_table text;
    _i int;
  BEGIN
    IF a_code ~ E'\\.' THEN -- схема передана в вводном параметре
      v_schema := ARRAY[split_part(a_code, '.', 1)];
      v_table  := split_part(a_code, '.', 2);
    ELSE -- схема выбирается из текущей, "i18n_def","public","pg_catalog" в том же порядке
      v_schema := ARRAY[ws.pg_cs(), 'i18n_def', 'public', 'pg_catalog'];
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
CREATE OR REPLACE FUNCTION ws.pg_view_comments(
  a_code text              -- имя объекта
) RETURNS SETOF t_pg_view_info VOLATILE LANGUAGE 'plpgsql' AS
$_$
  
  DECLARE
  
    v_code text[];
    v_def text;
    R record;
    v_list text;
    _i int;
    _j int;
    v_field text;
  
    v_brac int;
    v_temp text[];
    v_viewname text;
        
  BEGIN
    RAISE DEBUG 'PROCESSING: View %', a_code;
  
    v_code := string_to_array(a_code, '.');
    FOR R IN
      SELECT schemaname || '.' || viewname AS vname, lower(definition) AS _def 
        FROM pg_views
        WHERE (array_length(v_code, 1) = 2 AND schemaname = v_code[1] AND viewname = v_code[2])
          OR (array_length(v_code, 1) = 1 AND viewname = v_code[1])
      LOOP
  
      IF v_def IS NOT NULL THEN
        RAISE DEBUG 'ERROR: Имя представления неоднозначно %', a_code;
        RETURN;
      END IF;
      
      v_def := R._def;
      v_viewname := R.vname;
  
    END LOOP;
  
    IF v_def IS NULL THEN
      RAISE DEBUG 'ERROR: Представление не найдено %', a_code;
      RETURN;
    END IF;
  
    -- v_list: список полей в тексте запроса между select/from
    v_list := substring(v_def FROM position('select' IN v_def) + 7);
    v_list := trim(substring(v_list FROM 1 FOR position(' from ' IN v_list) - 1));
  
    -- v_def: текст запроса после "from", содержащий таблицы
    -- если есть "union" - выбрать только первую часть
    IF position(' union ' IN v_def) > 0 THEN
      v_def := trim(substring(v_def FROM 1 FOR position(' union ' IN v_def)));
    END IF;
    v_def := ' ' || trim(trim(substring(v_def FROM position(' from ' IN v_def) + 6)), ';') || ' ';
  
  
    -- представить поля текста запроса в виде массива
    -- необходимо разбить по "," принимая во внимание что некоторые поля имеют формулы с "," внутри "()"
    _i := 1;
    v_brac := 0;
    v_temp := string_to_array(v_list, ',');
    v_code := null;
    FOR _j IN array_lower(v_temp, 1)..array_upper(v_temp, 1) LOOP
  
      v_temp[_j] := trim(v_temp[_j]);
      v_code[_i] := coalesce(v_code[_i], '') || v_temp[_j];
      v_brac := v_brac + length(replace(v_temp[_j], '(', '')) - length(replace(v_temp[_j], ')', ''));
      IF v_brac = 0 THEN
        _i := _i + 1;
      END IF;
      
    END LOOP;
  
    -- бросить ошибку если длина массива отлична от макс номера поля в представлении
    IF (
         SELECT max(attnum)
         FROM   pg_attribute 
         WHERE  attrelid = v_viewname::regclass
       ) <> array_length(v_code, 1) THEN
       RAISE DEBUG 'FATAL ERROR: Ошибка подсчета количества полей "%"', a_code;
       RETURN;
    END IF;
  
    -- обработать поля по одному
    FOR _i IN array_lower(v_code, 1)..array_upper(v_code, 1) LOOP
  
      DECLARE
  
        v_col text;
        v_table text;
        v_com text;
  
        _sub text;
        _arr text[];
        _pos int;
        
      BEGIN
  
        -- получить значения v_field и поле v_col из колонки ("A.B as C" - значение=A.B поле=C; "A.B" - значение=A.B поле=B)
        v_field = trim(v_code[_i]);      
        _arr = string_to_array(v_field, ' as ');  
        v_col = case when array_length(_arr,1) = 2 THEN _arr[2] ELSE '' END;
        _arr = string_to_array(_arr[1], '.');
        IF v_col = '' THEN
           v_col = _arr[array_length(_arr,1)];
        END IF;
  
        -- значение является формулой
        IF v_field ~ '^[''.0-9]|null*' OR v_field ~ E'\\(' THEN
  
          R = ROW(v_viewname, v_col,null::text,null::text,3::int,v_field::text);
          RETURN NEXT R;
        
          RAISE DEBUG 'INFO: значение является формулой "%"', v_field;
  
        -- значение является колонкой таблицы
        ELSE
  
          -- значение должно быть в форме таблица/псевдоимя.поле (иметь '.') как в выборке pg_views, иначе ошибка
          IF array_length(_arr,1) = 2 THEN
  
            -- найти позицию таблица/псевдоимя в тексте запроса (окруженную ' ', ',' и тд)
            _pos = position(' ' || trim(_arr[1]) || ' ' in v_def);
            IF _pos = 0 THEN
              _pos = position(' ' || trim(_arr[1]) || ',' in v_def);
            END IF;
            IF _pos = 0 THEN
              _pos = position(trim(_arr[1]) || ' ' in v_def);
            END IF;         
            IF _pos = 0 THEN
              _pos = position(trim(_arr[1]) in v_def);
            END IF;
  
            -- _ref = строка запроса до позиции таблицы/псевдоимя
            _sub = trim(trim(substring(v_def from 1 FOR _pos - 1)), '(');
  
            _arr[1] = trim(_arr[1]);
  
            -- если последний символ _ref = '.' - значит в тексте указана схема
            IF substring(_sub from length(_sub) FOR 1) = '.' THEN 
              -- "схема.таблица" из текста запроса
              v_table = trim(trim(trim(split_part(trim(_sub), ' ', 1 + length(trim(_sub)) - length(replace(trim(_sub), ' ', ''))), '('), '.')) || '.' || _arr[1];
  
            ELSE
              -- определить значение предшествующее позиции таблицы. оно будет либо схема, либо укажет что схема не указана
              _sub = trim(trim(substring(v_def from 1 FOR _pos - 1)), '(');
              _sub = trim(trim(trim(split_part(trim(_sub), ' ', 1 + length(trim(_sub)) - length(replace(trim(_sub), ' ', ''))), '('), '.'));
  
              -- если вверху нашелся 'join','from' или '' - значит в тексте запроса схема перед таблицей не указана
              -- получить схема.таблица через ф-ю pg_view_comments_get_tbl
              v_table = ws.pg_view_comments_get_tbl(case when _sub in ('join','from','') THEN _arr[1] ELSE _sub END);
  
            END IF;
  
            -- получить комментарий если схема.таблица успешно определены
            IF v_table is not null THEN
              
              v_com = (SELECT col_description
                (
                  (SELECT (v_table)::regclass::oid)::int,
                  (
                    SELECT attnum FROM pg_attribute 
                    WHERE  attrelid = (v_table)::regclass
                    AND    attname  = _arr[2]
                  )
                )
              );
     
              RAISE DEBUG 'COMMENT: % % = %', v_table, v_col, v_com;
              R = ROW(
                v_viewname, v_col,v_table,_arr[2]::text,
                case when v_com is not null THEN 1 ELSE 2 END::int,
                case when v_com is not null THEN v_com ELSE 'Комментарий отсутствует для: ' || v_code[_i] END::text
              );
  
              RETURN NEXT R;
              
            -- таблица из текста запроса не определена. возможна проблема в данной ф-ции
            ELSE
  
              R = ROW(v_viewname, v_col,null::text,null::text,4::int, 'Ошибка определения комментария для: ' || v_code[_i]);
              RETURN NEXT R;
              
              RAISE DEBUG 'ERROR: Ошибка определения комментария для "%"', v_field;
            END IF;
          ELSE
            -- неподдерживаемый формат. все определения полей хранятся как таблица/псевдоимя.поле данная ошибка может возникнуть при непредвиденном изменении в pg_views
            R = ROW(v_viewname, null::text,null::text,null::text,5::int, 'Поле хранится в неподдерживающемся формате: ' || v_field);
            RETURN NEXT R;
            RAISE DEBUG 'ERROR: Поле хранится в неподдерживающемся формате: "%"', v_field;
          END IF;
    
        END IF;
      END;
    END LOOP;
    
  END;
$_$;  
 
/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.pg_c(
  a_type ws.t_pg_object    -- тип объекта (из перечисления ws.t_pg_object)
, a_code name              -- имя объекта
, a_text text              -- комментарий
, a_anno text DEFAULT NULL -- аннотация (не сохраняется, предназначено для размещения описания рядом с кодом)
) RETURNS void VOLATILE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_code TEXT;
    v_name TEXT;
    rec ws.t_pg_proc_info;
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
          PERFORM pg_c('c', r_view.rel || '.' || r_view.code, r_view.anno);
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
RAISE NOTICE 'COMMENT FOR % %: % (%)', v_name, v_code, a_text, a_anno;
    IF v_name IS NULL THEN
      -- a(rgument)
      UPDATE ws.dt_part SET anno = a_text
        WHERE id = dt_id(split_part(v_code, '.', 1)||'.'||split_part(v_code, '.', 2))
          AND code = split_part(v_code, '.', 3)
      ;
    ELSIF a_type = 'f' THEN
      -- получить списки аргументов и прописать коммент каждой ф-и с этим именем
      FOR rec IN SELECT * FROM ws.pg_proc_info(split_part(v_code, '.', 1), split_part(v_code, '.', 2)) LOOP
        v_name := ws.sprintf(E'COMMENT ON FUNCTION %s(%s) IS \'%s\'', v_code, rec.args, a_text);
        EXECUTE v_name;
        RAISE NOTICE '%', v_name;
      END LOOP;
    ELSE
      EXECUTE ws.sprintf(E'COMMENT ON %s %s IS \'%s\'', v_name, v_code, a_text);
    END IF;
  END;
$_$;
SELECT pg_c('f', 'pg_c', 'Создать комментарий к объекту БД');

/* ------------------------------------------------------------------------- */
SELECT 
  pg_c('f', 'sprintf', 'Порт функции sprintf')
, pg_c('f', 'pg_cs', 'Текущая (первая) схема БД в пути поиска', $_$если задан аргумент, он и '.' добавляются к имени схемы$_$)
, pg_c('f', 'reserved_args', 'Зарезервированные имена аргументов методов')
, pg_c('f', 'pg_view_comments','получить комментарии полей view из таблиц запроса')
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION notice (a_text TEXT) RETURNS VOID LANGUAGE 'plpgsql' AS
$_$
  -- вызов RAISE NOTICE из скриптов и sql
  BEGIN
    RAISE NOTICE '%', a_text;
  END
$_$ ;
SELECT pg_c('f', 'notice', 'Вывод предупреждения посредством RAISE NOTICE', $_$/*
Метод позволяет вызывать NOTICE из SQL-запросов и скриптов psql.
Кроме прочего, используется в скриптах 9?_*.sql для передачи в pgctl.sh названия теста
*/$_$);



