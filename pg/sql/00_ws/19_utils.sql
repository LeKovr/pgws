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

    Вспомогательные функции
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION e_code(code d_errcode) RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  -- code: сообщение об ошибке
  SELECT ws.sprintf('[{"code": "%s"}]', $1);
$_$;
SELECT pg_c('f', 'e_code', 'возвращает сообщение об ошибке');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION e_noaccess() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT ws.sprintf('[{"code": "%s"}]', ws.const_rpc_err_noaccess());
$_$;
SELECT pg_c('f', 'e_noaccess', 'возвращает строку ошибки - нет доступа');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION e_nodata() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT ws.sprintf('[{"code": "%s"}]', ws.const_rpc_err_nodata());
-- P0002  no_data_found
$_$;
SELECT pg_c('f', 'e_nodata', 'возвращает строку ошибки - нет данных');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION error_str (
  code d_errcode
, arg  TEXT DEFAULT ''
) RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  -- code: сообщение об ошибке
  -- arg:  аргумент
  SELECT ws.sprintf('[{"code": "%s", "id":"%s", "arg": "%s"}]', $1::TEXT, '_', $2);
$_$;
SELECT pg_c('f', 'error_str', 'возвращает строку ошибки');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION perror_str (
  code       d_errcode
, param_name TEXT
, arg        TEXT DEFAULT ''
) RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  -- code:       сообщение об ошибке
  -- param_name: название параметра
  -- arg:        аргумент
  SELECT ws.sprintf('[{"code": "%s", "id":"%s", "arg": "%s"}]', $1::TEXT, $2, $3);
$_$;
SELECT pg_c('f', 'perror_str', 'возвращает строку ошибки');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION uri_args (
  a_uri  TEXT
, a_mask TEXT
) RETURNS TEXT[] IMMUTABLE LANGUAGE 'plperl' AS
$_$  #
    my ($uri, $mask) = @_; if ($uri =~ /$mask/) { return [$1, $2, $3, $4, $5]; } return undef;
$_$;
SELECT pg_c('f', 'uri_args', '..');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.epoch2timestamptz(a_epoch INTEGER DEFAULT 0) RETURNS TIMESTAMPTZ IMMUTABLE LANGUAGE 'sql' AS
$_$
  -- a_epoch:  количество секунд
SELECT CASE WHEN $1 = 0 THEN NULL ELSE TIMESTAMPTZ 'epoch' + $1 * INTERVAL '1 second' END;
$_$;
SELECT pg_c('f', 'epoch2timestamptz', 'возвращает TIMESTAMPTZ через заданное количество секунд');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.min(
  a TIMESTAMP
, b TIMESTAMP
) RETURNS TIMESTAMP IMMUTABLE LANGUAGE 'sql' AS
$_$
  -- a:  первый момент времени
  -- b:  второй момент времени
SELECT CASE WHEN $1 < $2 THEN $1 ELSE $2 END;
$_$;
SELECT pg_c('f', 'min', 'минимальный момент времени');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.max(
  a TIMESTAMP
, b TIMESTAMP
) RETURNS TIMESTAMP IMMUTABLE LANGUAGE 'sql' AS
$_$
  -- a:  первый момент времени
  -- b:  второй момент времени
SELECT CASE WHEN $1 < $2 THEN $2 ELSE $1 END;
$_$;
SELECT pg_c('f', 'max', 'максимальный момент времени');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.array_remove(
  a ANYARRAY
, b ANYELEMENT
) RETURNS ANYARRAY IMMUTABLE LANGUAGE 'sql' AS
$_$
  -- a: массив
  -- b: элемент
SELECT array_agg(x) FROM unnest($1) x WHERE x <> $2;
$_$;
SELECT pg_c('f', 'array_remove', 'удаляет элемент из массива');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.stamp2xml(
  a_stamp      TIMESTAMP
, a_msk_offset INTERVAL DEFAULT '0 HOURS'::INTERVAL
) RETURNS TEXT
  IMMUTABLE LANGUAGE 'plpgsql' AS
$_$
/*
   -- a_stamp:      метка времени
   -- a_msk_offset: (опционально) смещение относительно московского времени

   Возвращает метку времени в виде текста для использования в XML-документах (для выгрузки на ООС):
   YYYY-MM-DD"T"HH24:MI:SS+04:00

   "+04:00" -- смещение относительно UTC

*/
  DECLARE
    v_msk_utc_offset    INTERVAL := '+4 HOURS';
    v_utc_offset        INTERVAL := v_msk_utc_offset + a_msk_offset;
    v_utc_offset_hh24mi TEXT;
    v_stamp_xml         TEXT;
  BEGIN
    -- если бы TO_CHAR(INTERVAL, 'HH:MI') можно было нормально использовать
    -- для отрицательных значений INTERVAL, все было бы гораздо проще.
    v_utc_offset_hh24mi :=
      CASE WHEN v_utc_offset  >= '0 HOURS'::INTERVAL THEN '+' ELSE '-' END
      || LPAD(ABS(DATE_PART('HOURS', v_utc_offset))::TEXT, 2, '0')
      || ':'
      || TO_CHAR(v_utc_offset, 'MI')
    ;
    SELECT INTO v_stamp_xml
      TO_CHAR(a_stamp + a_msk_offset, 'YYYY-MM-DD"T"HH24:MI:SS') || v_utc_offset_hh24mi
    ;
    RETURN v_stamp_xml;
  END;
$_$;
SELECT pg_c('f', 'stamp2xml', 'Возвращает метку времени в виде текста для использования в XML-документах');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.date2xml(a DATE) RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  -- a: дата
SELECT to_char($1, E'YYYY-MM-DD');
$_$;
SELECT pg_c('f', 'date2xml', 'Возвращает дату в виде текста для использования в XML-документах');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.mask2regexp(a_mask TEXT) RETURNS TEXT IMMUTABLE LANGUAGE 'plpgsql' AS
$_$
  -- a_mask:  шаблон
  DECLARE
    v TEXT;
  BEGIN
    v := a_mask;
    v := regexp_replace(v, ':i',    E'(\\d+)',        'g');
    v := regexp_replace(v, E'\\?',  E'\\?',           'g');
    v := regexp_replace(v, E'\\.',  E'\\.',           'g');
    v := regexp_replace(v, ':s',    '([^/:]+)',       'g');
    v := regexp_replace(v, ':u',    '((?:/[^/]+)*)',  'g');
    v := regexp_replace(v, ',',     '|',              'g');  -- allow mask with comma fro props
    RETURN v;
  END;
$_$;
SELECT pg_c('f', 'mask2regexp', 'Сформировать строку поиска по шаблону');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.mask_is_multi(a_mask TEXT) RETURNS BOOL IMMUTABLE LANGUAGE 'sql' AS
$_$
  -- a_mask:  шаблон
  SELECT $1 ~ E'(\\?|,|:)'
$_$;
SELECT pg_c('f', 'mask_is_multi', 'Шаблон соответствует нескольким значениям');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.mask2format(a_mask TEXT) RETURNS TEXT IMMUTABLE LANGUAGE 'plpgsql' AS
$_$
  -- a_mask:  шаблон
  DECLARE
    v TEXT;
  BEGIN
    v := a_mask;
    v := regexp_replace(v, '%',     '%%', 'g');
    v := regexp_replace(v, ':i',    '%i', 'g');
    v := regexp_replace(v, ':s',    '%s', 'g');
    v := regexp_replace(v, ':u',    '%s', 'g');
    v := regexp_replace(v, E'\\$',  '',   'g');
    v := regexp_replace(v, E'\\|',  '',   'g');
    v := regexp_replace(v, E'[()]', '',   'g');
    RETURN v;
  END;
$_$;
SELECT pg_c('f', 'mask2format', 'Сформировать строку формата по шаблону');
