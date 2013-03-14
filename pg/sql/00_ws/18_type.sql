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

    Типы данных и домены
*/

/* ------------------------------------------------------------------------- */
CREATE DOMAIN d_id AS INTEGER;
COMMENT ON DOMAIN d_id IS 'Идентификатор';

CREATE DOMAIN d_id_positive AS INTEGER CHECK (VALUE > 0);

CREATE DOMAIN d_id32 AS INTEGER CHECK (VALUE > -32768 AND VALUE < 32767);

CREATE DOMAIN d_acl  AS d_id32; -- уровень доступа
CREATE DOMAIN d_bitmask AS d_id32; -- уровень доступа

CREATE DOMAIN d_acls  AS INTEGER[]; -- уровни доступа

CREATE DOMAIN d_class  AS d_id32; -- id класса

CREATE DOMAIN d_cnt AS INTEGER CHECK (VALUE >= 0);  -- целое >= 0
CREATE DOMAIN d_amount AS NUMERIC(11,3) CHECK (VALUE > 0);

CREATE DOMAIN d_decimal_positive AS DECIMAL CHECK (VALUE > 0);  -- вещественное больше 0
CREATE DOMAIN d_decimal_non_neg AS DECIMAL CHECK (VALUE >= 0);  -- вещественное не меньше 0

CREATE DOMAIN d_money  AS DECIMAL(16,2);

/*

NameChar    ::= Letter | Digit | '.' | '-' | '_' | ':' | CombiningChar | Extender
NCNameChar  ::= Letter | Digit | '.' | '-' | '_' | CombiningChar | Extender

NCName      ::= (Letter | '_') (NCNameChar)*
Name        ::= (Letter | '_' | ':') ( NameChar)*

*/

CREATE DOMAIN d_sid AS TEXT;
COMMENT ON DOMAIN d_sid IS 'Идентификатор сессии';

CREATE DOMAIN d_login AS TEXT CHECK (VALUE ~ E'^[a-zA-Z0-9\\.+_@\\-]{5,}$');

CREATE DOMAIN d_text AS TEXT;
CREATE DOMAIN d_string AS TEXT CHECK (VALUE !~ E'\\n');

CREATE DOMAIN d_zip AS TEXT CHECK (VALUE ~ E'^[a-zA-Zа-яА-я0-9][a-zA-Zа-яА-я0-9 \-]{2,11}');

CREATE DOMAIN d_email AS TEXT CHECK (VALUE = '' OR VALUE ~ E'^[^ ]+@[^ ]+\\.[^ ]{2,6}');

CREATE DOMAIN d_emails AS TEXT[]; --TODO: CHECK (VALUE = '' OR VALUE ~ E'^[^ ]+@[^ ]+\\.[^ ]{2,6}(,\\s+[^ ]+@[^ ]+\\.[^ ]{2,6})*');

CREATE DOMAIN d_code AS TEXT CHECK (VALUE ~ E'^[a-z\\d][a-z\\d\\.\\-_]*$') ;

CREATE DOMAIN d_code_arg AS TEXT CHECK (VALUE ~ E'^[a-z\\d_][a-z\\d\\.\\-_]*$') ;

CREATE DOMAIN d_codei AS TEXT CHECK (VALUE ~ E'^[a-z\\d][a-z\\d\\.\\-_A-Z]*$') ;
CREATE DOMAIN d_code_like AS TEXT CHECK (VALUE ~ E'^[a-z\\d\\.\\-_\\%]+$');

CREATE DOMAIN d_sub AS TEXT CHECK (VALUE ~ E'^([a-z\\d][a-z\\d\\.\\-_]+)|([A-Z\\d][a-z\\d\\.\\-_\:A-Z]+)$') ;

CREATE DOMAIN d_path AS TEXT CHECK (VALUE ~ E'^(|[a-z\\d_][a-z\\d\\.\\-_/]+)$') ;

CREATE DOMAIN d_sort AS INTEGER CHECK (VALUE > -32768 AND VALUE < 32767);

CREATE DOMAIN d_regexp AS TEXT;
COMMENT ON DOMAIN d_regexp IS 'Регулярное выражение';

CREATE DOMAIN d_lang AS TEXT CHECK (VALUE ~ E'^(?:ru|en)$');

CREATE DOMAIN d_stamp AS TIMESTAMP(0);

CREATE DOMAIN d_rating AS NUMERIC(4,3) CHECK (VALUE BETWEEN -2 AND 2);
COMMENT ON DOMAIN d_rating IS 'Рейтинг компании';

/* ------------------------------------------------------------------------- */
CREATE DOMAIN d_codea AS TEXT[] CHECK (array_to_string(VALUE,';') ~ E'^([a-z\\d][a-z\\d\\.\\-_]*)(;[a-z\\d][a-z\\d\\.\\-_]*)*$') ;
CREATE DOMAIN d_id32a AS INTEGER[] CHECK (-32768 < ALL(value) AND 32767 > ALL(value));
CREATE DOMAIN d_booleana AS boolean[];
CREATE DOMAIN d_texta AS text[];
CREATE DOMAIN d_ida AS INTEGER[];
CREATE DOMAIN d_moneya AS DECIMAL(16,2)[];

/* ------------------------------------------------------------------------- */
CREATE DOMAIN d_classcode AS char(2);
CREATE DOMAIN d_errcode AS char(5) CHECK (VALUE ~ E'^Y\\d{4}$') ;
CREATE DOMAIN d_format  AS text;

/* ------------------------------------------------------------------------- */
CREATE TYPE t_hashtable AS (
  id     text
  , name text
);

/* ------------------------------------------------------------------------- */
-- порядок полей должен совпадать с i18n_def.page
CREATE TYPE t_page_info AS (
  code          d_code
, up_code       d_code
, class_id      d_class
, action_id     d_id32
, group_id      d_id32
, sort          d_sort
, uri           d_regexp
, tmpl          d_path
, id_fixed      d_id
, id_session    d_code
, is_hidden     bool
, target        text
, uri_re        text
, uri_fmt       text
, pkg           text
, name          text
, req           text
, args          text[]
, group_name    text
);

/* ------------------------------------------------------------------------- */
CREATE TYPE t_acl_check AS (
  value int,
  id int,
  code text,
  name text
);

/* ------------------------------------------------------------------------- */
CREATE TYPE t_date_info AS (
  date            DATE
  , day           d_id32
  , month         d_id32
  , year          d_id32
  , date_month    DATE
  , date_year     DATE
  , date_name     TEXT
  , month_name    TEXT
  , date_name_doc TEXT
  , fmt_calend    TEXT
  , fmt_example   TEXT
);
SELECT pg_c('t', 't_date_info',         'Атрибуты даты')
, pg_c('c','t_date_info.month_name',    'месяц ГГГГ')
, pg_c('c','t_date_info.date_name',     'ДД месяц ГГГГ')
, pg_c('c','t_date_info.date_name_doc', '(ДД|0Д) месяц ГГГГ')
;

/* ------------------------------------------------------------------------- */
CREATE TYPE t_month_info AS (
  id                DATE
  , date_month_last DATE
  , date_month_prev DATE
  , date_month_next DATE
  , date_year       DATE
  , month           d_id32
  , year            d_id32
  , key             TEXT
  , month_name      TEXT
  , month_name_ic   TEXT
);
COMMENT ON TYPE t_month_info IS 'Атрибуты месяца';
COMMENT ON COLUMN t_month_info.id IS 'Дата - первое число месяца';
COMMENT ON COLUMN t_month_info.date_month_last IS 'Дата - последнее число месяца';
COMMENT ON COLUMN t_month_info.date_month_prev IS 'Дата - первое число предыдущего месяца';
COMMENT ON COLUMN t_month_info.date_month_next IS 'Дата - первое число следующего месяца';
COMMENT ON COLUMN t_month_info.date_year IS 'Дата - первое число года';
COMMENT ON COLUMN t_month_info.month IS 'Номер месяца';
COMMENT ON COLUMN t_month_info.year IS 'Год';
COMMENT ON COLUMN t_month_info.key IS 'ГГГГММ';
COMMENT ON COLUMN t_month_info.month_name IS 'месяц ГГГГ';
COMMENT ON COLUMN t_month_info.month_name_ic IS 'Месяц ГГГГ';
