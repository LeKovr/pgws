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
CREATE OR REPLACE FUNCTION e_noaccess() RETURNS text IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT ws.sprintf('[{"code": "%s"}]', ws.const_rpc_err_noaccess());
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION e_nodata() RETURNS text IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT ws.sprintf('[{"code": "%s"}]', ws.const_rpc_err_nodata());
-- P0002  no_data_found
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION error_str (code d_errcode, arg TEXT DEFAULT '') RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT ws.sprintf('[{"code": "Y%s", "id":"%s", "arg": "%s"}]', $1::TEXT, '_', $2);
$_$;

--CREATE OR REPLACE FUNCTION error_str (code errcode, arg TEXT, arg1 TEXT) RETURNS TEXT AS $_$
--  SELECT sprintf('[{"code": "%s", "id":"%s", "arg": "%s", "arg1": "%s"}]', $1::TEXT, '_', $2, $3);
--$_$ IMMUTABLE LANGUAGE 'sql';

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION perror_str (code d_errcode, param_name TEXT, arg TEXT DEFAULT '') RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT ws.sprintf('[{"code": "Y%s", "id":"%s", "arg": "%s"}]', $1::TEXT, $2, $3);
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION uri_args (a_uri TEXT, a_mask TEXT) RETURNS text[] IMMUTABLE LANGUAGE 'plperl' AS
$_$  #
    my ($uri, $mask) = @_; if ($uri =~ /$mask/) { return [$1, $2, $3]; } return undef;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.epoch2timestamptz(a_epoch INTEGER DEFAULT 0) RETURNS TIMESTAMPTZ IMMUTABLE LANGUAGE 'sql' AS
$_$
SELECT CASE WHEN $1 = 0 THEN NULL ELSE TIMESTAMPTZ 'epoch' + $1 * INTERVAL '1 second' END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.epoch2timestamp(a_epoch INTEGER DEFAULT 0) RETURNS TIMESTAMP IMMUTABLE LANGUAGE 'sql' AS
$_$
SELECT CASE
  WHEN $1 = 0 THEN NULL
  ELSE timezone(
    (SELECT setting FROM pg_settings WHERE name = 'TimeZone')
    , (TIMESTAMPTZ 'epoch' + $1 * INTERVAL '1 second')::timestamptz
    )
END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.min(a TIMESTAMP, b TIMESTAMP) RETURNS TIMESTAMP IMMUTABLE LANGUAGE 'sql' AS
$_$
SELECT CASE WHEN $1 < $2 THEN $1 ELSE $2 END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.max(a TIMESTAMP, b TIMESTAMP) RETURNS TIMESTAMP IMMUTABLE LANGUAGE 'sql' AS
$_$
SELECT CASE WHEN $1 < $2 THEN $2 ELSE $1 END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.array_remove(a ANYARRAY, b ANYELEMENT) RETURNS ANYARRAY IMMUTABLE LANGUAGE 'sql' AS
$_$
SELECT array_agg(x) FROM unnest($1) x WHERE x <> $2;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.mask2regexp(a_mask TEXT) RETURNS TEXT IMMUTABLE LANGUAGE 'plpgsql' AS
$_$
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
  SELECT $1 ~ E'(\\?|,|:)'
$_$;
SELECT pg_c('f', 'mask_is_multi', 'Шаблон соответствует нескольким значениям');


/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION mask2format(a_mask TEXT) RETURNS TEXT IMMUTABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v TEXT;
  BEGIN
    v := a_mask;
    v := regexp_replace(v, '%',     '%%', 'g');
    v := regexp_replace(v, ':i',    '%i', 'g');
    v := regexp_replace(v, ':s',    '%s', 'g');
    v := regexp_replace(v, ':u',    '%s', 'g');
    v := regexp_replace(v, E'\\$$', ''       );
    v := regexp_replace(v, E'[()]', '',   'g');
    RETURN v;
  END;
$_$;
SELECT pg_c('f', 'mask2format', 'Сформировать строку формата по шаблону');
