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

    Функции ядра
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION page_group_name(a_id d_id32) RETURNS TEXT STABLE STRICT LANGUAGE 'sql' AS
$_$
  -- a_id:  ID группы страниц
  SELECT name FROM page_group WHERE id = $1;
$_$;
SELECT pg_c('f', 'page_group_name', 'Название группы страниц', $_$Функция требует SEARCH_PATH$_$);

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION page_by_uri(a_uri TEXT DEFAULT '') RETURNS SETOF t_page_info STABLE LANGUAGE 'sql' AS
$_$
  -- a_uri:  идентификатор ресурса
  SELECT *
    , lower($1)
    , ws.uri_args(lower($1), uri_re)
    , ws.page_group_name(group_id)
    FROM page WHERE $1 ~* ('^' || uri_re) ORDER BY uri_re DESC LIMIT 1;
$_$;
SELECT pg_c('f', 'page_by_uri', 'Атрибуты страницы по uri', $_$Функция требует SEARCH_PATH$_$);

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION page_by_code(
  a_code TEXT
, a_id   TEXT DEFAULT NULL
, a_id1  TEXT DEFAULT NULL
, a_id2  TEXT DEFAULT NULL
, a_id3  TEXT DEFAULT NULL
) RETURNS SETOF t_page_info STABLE LANGUAGE 'sql' AS
$_$
  -- a_code:  Идентификатор страницы
  -- a_id:    Идентификатор
  -- a_id1:   Идентификатор
  -- a_id2:   Идентификатор
  -- a_id3:   Идентификатор
  SELECT *
    , ws.sprintf(uri_fmt, $2, $3, $4, $5)
    , ws.uri_args(ws.sprintf(uri_fmt, $2, $3, $4, $5), uri_re)
    , ws.page_group_name(group_id)
    FROM page WHERE code LIKE $1 ORDER BY sort;
$_$;
SELECT pg_c('f', 'page_by_code', 'Атрибуты страницы  по маске кода и идентификаторам', $_$Функция требует SEARCH_PATH$_$);

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION page_by_action(
  a_class_id  d_class DEFAULT 0
, a_action_id d_id32 DEFAULT 0
, a_id        TEXT DEFAULT NULL
, a_id1       TEXT DEFAULT NULL
, a_id2       TEXT DEFAULT NULL
) RETURNS SETOF t_page_info STABLE LANGUAGE 'sql' AS
$_$
  -- a_class_id:  ID класса
  -- a_action_id: ID акции
  -- a_id:        Идентификатор
  -- a_id1:       Идентификатор
  -- a_id2:       Идентификатор
  SELECT *
    , ws.sprintf(uri_fmt, $3, $4, $5)
    , ws.uri_args(ws.sprintf(uri_fmt, $3, $4, $5), uri_re)
    , ws.page_group_name(group_id)
    FROM page WHERE $1 IN (class_id, 0) AND $2 IN (action_id, 0) ORDER BY code;
$_$;
SELECT pg_c('f', 'page_by_action', 'Атрибуты страницы  по акции и идентификаторам', $_$Функция требует SEARCH_PATH$_$);

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION page_path(
  a_code TEXT DEFAULT NULL
, a_id   TEXT DEFAULT NULL
, a_id1  TEXT DEFAULT NULL
, a_id2  TEXT DEFAULT NULL
) RETURNS SETOF t_page_info STABLE LANGUAGE 'plpgsql' AS
$_$
  -- a_code:    Идентификатор страницы
  -- a_id:      Идентификатор
  -- a_id1:     Идентификатор
  -- a_id2:     Идентификатор
  DECLARE
    r ws.t_page_info;
  BEGIN
    r.up_code := a_code;
    LOOP
      SELECT INTO r
        *
        , ws.sprintf(uri_fmt, $2, $3, $4)
        , ws.uri_args(ws.sprintf(uri_fmt, $2, $3, $4), uri_re)
        , ws.page_group_name(group_id)
        FROM page
        WHERE code = r.up_code
      ;
      EXIT WHEN NOT FOUND;
      RETURN NEXT r;
    END LOOP;
    RETURN;
  END;
$_$;
SELECT pg_c('f', 'page_path', 'Атрибуты страниц пути от заданной до корневой', $_$Функция требует SEARCH_PATH$_$);

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.is_ids_enough(
  a_class_id ws.d_class
, a_id       TEXT DEFAULT NULL
, a_id1      TEXT DEFAULT NULL
, a_id2      TEXT DEFAULT NULL
) RETURNS BOOL STABLE LANGUAGE 'plpgsql' AS
$_$
  -- a_class_id:  ID класса
  -- a_id:        Идентификатор
  -- a_id1:       Идентификатор
  -- a_id2:       Идентификатор
  DECLARE
    v_id_count ws.d_cnt;
  BEGIN
    SELECT INTO v_id_count id_count FROM ws.class WHERE id = a_class_id;
    RETURN CASE
      WHEN v_id_count > 0 AND a_id IS NULL THEN FALSE
      WHEN v_id_count > 1 AND a_id1 IS NULL THEN FALSE
      WHEN v_id_count > 2 AND a_id2 IS NULL THEN FALSE
      ELSE TRUE
    END;
  END
$_$;
SELECT pg_c('f', 'is_ids_enough', 'Достаточно ли заданных ID для идентификации экземпляра класса');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION page_childs(
  a_code     TEXT DEFAULT NULL
, a_id       TEXT DEFAULT NULL
, a_id1      TEXT DEFAULT NULL
, a_id2      TEXT DEFAULT NULL
, a_class_id d_class DEFAULT 0
) RETURNS SETOF t_page_info STABLE LANGUAGE 'sql' AS
$_$
  -- a_code: Идентификатор страницы верхнего уровня
  -- a_id:   Идентификатор
  -- a_id1:  Идентификатор
  -- a_id2:  Идентификатор
  SELECT *
    , ws.sprintf(uri_fmt, $2, $3, $4)
    , ws.uri_args(ws.sprintf(uri_fmt, $2, $3, $4), uri_re)
    , ws.page_group_name(group_id)
    FROM page WHERE sort IS NOT NULL AND up_code IS NOT DISTINCT FROM $1 AND ws.is_ids_enough(class_id, COALESCE(id_fixed::text,$2), $3, $4) AND $5 IN (class_id, 0) ORDER BY group_id, sort, code;
$_$;
SELECT pg_c('f', 'page_childs', 'Атрибуты страниц, имеющих предком заданную', $_$Функция требует SEARCH_PATH$_$);

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION page_tree(a_code TEXT DEFAULT NULL) RETURNS SETOF t_hashtable STABLE LANGUAGE 'sql' AS
$_$
  -- a_code:   Идентификатор страницы верхнего уровня
  -- http://explainextended.com/2009/07/17/postgresql-8-4-preserving-order-for-hierarchical-query/
  WITH RECURSIVE q AS (
    SELECT h, 1 AS level, ARRAY[sort::int] AS breadcrumb
      FROM ws.page_data h
      WHERE up_code IS NOT DISTINCT FROM $1
    UNION ALL
    SELECT hi, q.level + 1 AS level, breadcrumb || sort::int
      FROM q
      JOIN ws.page_data hi
      ON hi.up_code = (q.h).code
  )
  SELECT level::text, (q.h).code
    FROM q
    ORDER BY breadcrumb
;
$_$;
SELECT pg_c('f', 'page_tree', 'Иерархия страниц, имеющих предком заданную или main');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION method_by_code(a_code d_code) RETURNS SETOF method STABLE LANGUAGE 'sql' AS
$_$
  -- a_code:  внешнее имя метода
  SELECT * FROM ws.method WHERE code = $1 ORDER BY 2,3,1;
--  SELECT * FROM ws.method WHERE code LIKE $1 ORDER BY 2,3,1;
$_$;
SELECT pg_c('f', 'method_by_code', 'Атрибуты метода по коду');

/* ------------------------------------------------------------------------- */
-- служебная ф-я для внутренних вызовов
CREATE OR REPLACE FUNCTION method_code_real(a_code d_code) RETURNS ws.d_sub STABLE LANGUAGE 'sql' AS
$_$
  -- a_code:  внешнее имя метода
  SELECT code_real FROM ws.method WHERE code = $1;
$_$;
SELECT pg_c('f', 'method_code_real', 'возвращает имя вызываемого метода');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION method_by_action(
  a_class_id  d_class DEFAULT 0
, a_action_id d_id32 DEFAULT 0
) RETURNS SETOF method STABLE LANGUAGE 'sql' AS
$_$
  -- a_class_id:  ID класса
  -- a_action_id: ID акции
  SELECT *
    FROM ws.method WHERE $1 IN (class_id, 0) AND $2 IN (action_id, 0) ORDER BY 2,3,1;
$_$;
SELECT pg_c('f', 'method_by_action', 'Атрибуты страницы  по акции и идентификаторам');

/* ------------------------------------------------------------------------- */
/*
Вариант с индексом
CREATE INDEX company_title_like ON company (title text_pattern_ops);
подходит только если не ilike или 1й символ не буква (only if the pattern starts with non-alphabetic characters)
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION method_lookup_fetch(
  c_cursor REFCURSOR
, a_col    TEXT
) RETURNS SETOF ws.method STABLE LANGUAGE 'plperl' AS
$_$ #
while (defined (my $row = spi_fetchrow($_[0]))) {
  delete $row->{$_[1]};
  return_next($row);
}
return;
$_$;
SELECT ws.pg_c('f', 'method_lookup_fetch', 'служебная ф-я для method_lookup - кастинг');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION method_lookup(
  a_code    d_code_like DEFAULT '%'
, a_page    ws.d_cnt DEFAULT 0
, a_by      ws.d_cnt DEFAULT 0
, a_need_rc REFCURSOR DEFAULT NULL
) RETURNS SETOF ws.method STABLE LANGUAGE 'plpgsql' AS
$_$
  -- a_code:  фильтр по коду метода вида text[%]
  -- a_page:  номер страницы (>= 0)
  -- a_by:    количество строк на странице
  -- a_need_rc: вернуть результат в хэше { need_rc =, rows =}, где need_rc - общее количество строк в выборке
  DECLARE
    v_rc REFCURSOR;
    v_r  RECORD;
  BEGIN
    OPEN v_rc FOR SELECT *, COUNT(1) OVER() AS _cnt
      FROM ws.method
      WHERE code ilike '%' || $1 -- ищем по всему имени
--    WHERE lower(code) LIKE lower($1 ||'%') -- демоверсия поиска по началу с индексом
      ORDER BY 2,3,1 -- code
/*
      -- Вариант от Ташпулатова Рустама
      -- http://codeblow.com/questions/postgresql-parameterized-order-by-limit-in-table-function/
      ORDER BY
        CASE a_sort WHEN 1 THEN code END,
        CASE a_sort WHEN 2 THEN name END
*/
      OFFSET $2 * $3
      LIMIT NULLIF($3, 0)
    ;
    FETCH v_rc INTO v_r;
    MOVE PRIOR FROM v_rc;
    IF a_need_rc IS NOT NULL THEN
      OPEN a_need_rc FOR EXECUTE 'SELECT ' || v_r._cnt;
    END IF;
    RETURN QUERY SELECT * from ws.method_lookup_fetch(v_rc, '_cnt');
  END;
$_$;
SELECT ws.pg_c('f', 'method_lookup', 'Поиск метода по code');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION method_rvf(a_id d_id32 DEFAULT 0) RETURNS SETOF method_rv_format STABLE LANGUAGE 'sql' AS
$_$
  -- a_id:   ID формата
  SELECT * FROM ws.method_rv_format WHERE $1 IN (id, 0) ORDER BY 1;
$_$;
SELECT pg_c('f', 'method_rvf', 'Список форматов результата метода');


/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION error_info(a_code d_errcode) RETURNS error STABLE LANGUAGE 'sql' AS
$_$
  -- a_code:  Код ошибки
  SELECT * FROM error WHERE code = $1;
$_$;
SELECT pg_c('f', 'error_info', 'Описание ошибки');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION error_message_parse(
  a_code  d_errcode
, a_param TEXT[]
) RETURNS TEXT STABLE LANGUAGE 'plpgsql' AS
$_$
  -- a_code: Код ошибки
  -- a_param:  Строка с параметрами
  DECLARE
    v_error_text  TEXT;
    v_param_count INTEGER;
    v_query_arg   TEXT = '';
    v_i           INTEGER = 1;
    v_join_mes    TEXT;
    v_result      TEXT;
  BEGIN
    SELECT message INTO v_error_text FROM ws.error_info($1);
    SELECT INTO v_param_count array_length($2, 1);

    WHILE v_param_count >= v_i LOOP
      v_query_arg = format('%s, %L', v_query_arg, $2[v_i]);
      v_i = v_i+1;
    END LOOP;

    v_join_mes = format('SELECT ws.sprintf(%L%s);', v_error_text, v_query_arg);

    EXECUTE v_join_mes INTO v_result;
    RETURN v_result;
  END;
$_$;
SELECT ws.pg_c('f', 'error_message_parse', 'Получение текста ошибки с параметрами');
