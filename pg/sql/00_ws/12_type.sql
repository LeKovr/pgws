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
SELECT pg_c('t','t_pg_proc_info', 'Параметры хранимой процедуры');

CREATE DOMAIN d_id AS INTEGER;
SELECT pg_c('d','d_id', 'Идентификатор');

CREATE DOMAIN d_id_positive AS INTEGER CHECK (VALUE > 0);
SELECT pg_c('d','d_id_positive', 'Целое > 0');

CREATE DOMAIN d_id32 AS INTEGER CHECK (VALUE > -32768 AND VALUE < 32767);
SELECT pg_c('d','d_id32', 'Идентификатор справочника');

CREATE DOMAIN d_acl AS d_id32; -- уровень доступа
SELECT pg_c('d','d_acl', 'Уровень доступа');

CREATE DOMAIN d_bitmask AS d_id32; -- уровень доступа
SELECT pg_c('d','d_bitmask', 'Битовая маска');

CREATE DOMAIN d_acls AS INTEGER[]; -- уровни доступа
SELECT pg_c('d','d_acls', 'Массив уровней доступа');

CREATE DOMAIN d_class AS d_id32; -- id класса
SELECT pg_c('d','d_class', 'ID класса');

CREATE DOMAIN d_non_neg_int AS INTEGER CHECK (VALUE >= 0);
SELECT pg_c('d','d_non_neg_int', 'Целое >= 0');

CREATE DOMAIN d_cnt AS d_non_neg_int CHECK (VALUE >= 0);  -- целое >= 0
SELECT pg_c('d','d_cnt', 'Количество элементов');

CREATE DOMAIN d_amount AS NUMERIC(11,3) CHECK (VALUE > 0);
SELECT pg_c('d','d_amount', 'Количество товара');

CREATE DOMAIN d_decimal_positive AS DECIMAL CHECK (VALUE > 0);  -- вещественное больше 0
SELECT pg_c('d','d_decimal_positive', 'Вещественное > 0');

CREATE DOMAIN d_decimal_non_neg AS DECIMAL CHECK (VALUE >= 0);  -- вещественное не меньше 0
SELECT pg_c('d','d_decimal_non_neg', 'Вещественное >= 0');

CREATE DOMAIN d_money AS DECIMAL(16,2);
SELECT pg_c('d','d_money', 'Деньги');

/*

NameChar    ::= Letter | Digit | '.' | '-' | '_' | ':' | CombiningChar | Extender
NCNameChar  ::= Letter | Digit | '.' | '-' | '_' | CombiningChar | Extender

NCName      ::= (Letter | '_') (NCNameChar)*
Name        ::= (Letter | '_' | ':') ( NameChar)*

*/

CREATE DOMAIN d_sid AS TEXT;
SELECT pg_c('d','d_sid', 'Идентификатор сессии');

CREATE DOMAIN d_login AS TEXT CHECK (VALUE ~ E'^[a-zA-Z0-9\\.+_@\\-]{5,}$');
SELECT pg_c('d','d_login', 'Логин');

CREATE DOMAIN d_text AS TEXT;
SELECT pg_c('d','d_text', 'Текст');

CREATE DOMAIN d_string AS TEXT CHECK (VALUE !~ E'\\n');
SELECT pg_c('d','d_string', 'Текстовая строка');

CREATE DOMAIN d_zip AS TEXT CHECK (VALUE ~ E'^[a-zA-Zа-яА-я0-9][a-zA-Zа-яА-я0-9 \-]{2,11}');
SELECT pg_c('d','d_zip', 'Почтовый индекс');

CREATE DOMAIN d_email AS TEXT CHECK (VALUE = '' OR VALUE ~ E'^[^ ]+@[^ ]+\\.[^ ]{2,6}');
SELECT pg_c('d','d_email', 'Адрес email');

CREATE DOMAIN d_emails AS TEXT[]; --TODO: CHECK (VALUE = '' OR VALUE ~ E'^[^ ]+@[^ ]+\\.[^ ]{2,6}(,\\s+[^ ]+@[^ ]+\\.[^ ]{2,6})*');
SELECT pg_c('d','d_emails', 'Список адресов email');

CREATE DOMAIN d_code AS TEXT CHECK (VALUE ~ E'^[a-z\\d][a-z\\d\\.\\-_]*$') ;
SELECT pg_c('d','d_code', 'Имя переменной');

CREATE DOMAIN d_code_arg AS TEXT CHECK (VALUE ~ E'^[a-z\\d_][a-z\\d\\.\\-_]*$') ;
SELECT pg_c('d','d_code_arg', 'Имя аргумента');

CREATE DOMAIN d_codei AS TEXT CHECK (VALUE ~ E'^[a-z\\d][a-z\\d\\.\\-_A-Z]*$') ;
SELECT pg_c('d','d_codei', 'Имя переменной в любом регистре');

CREATE DOMAIN d_code_like AS TEXT CHECK (VALUE ~ E'^[a-z\\d\\.\\-_\\%]+$');
SELECT pg_c('d','d_code_like', 'Шаблон имени переменной');

CREATE DOMAIN d_sub AS TEXT CHECK (VALUE ~ E'^([a-z\\d][a-z\\d\\.\\-_]+)|([A-Z\\d][a-z\\d\\.\\-_\:A-Z]+)$') ;
SELECT pg_c('d','d_sub', 'Имя внешнего метода');

CREATE DOMAIN d_path AS TEXT CHECK (VALUE ~ E'^(|[a-z\\d_][a-z\\d\\.\\-_/]+)$') ;
SELECT pg_c('d','d_path', 'Относительный путь');

CREATE DOMAIN d_sort AS INTEGER CHECK (VALUE > -32768 AND VALUE < 32767);
SELECT pg_c('d','d_sort', 'Порядок сортировки');

CREATE DOMAIN d_regexp AS TEXT;
SELECT pg_c('d','d_regexp', 'Регулярное выражение');

CREATE DOMAIN d_lang AS TEXT CHECK (VALUE ~ E'^(?:ru|en)$');
SELECT pg_c('d','d_lang', 'Идентификатор языка');

CREATE DOMAIN d_stamp AS TIMESTAMP(0);
SELECT pg_c('d','d_stamp', 'Момент времени с точностью до секунды');

CREATE DOMAIN d_rating AS NUMERIC(4,3) CHECK (VALUE BETWEEN -2 AND 2);
SELECT pg_c('d','d_rating', 'Рейтинг компании');

CREATE DOMAIN d_ton AS bool CHECK (VALUE);
SELECT pg_c('d','d_ton', 'True Or Null'); -- в уникальном индексе будет только один TRUE, остальные - NULL

/* ------------------------------------------------------------------------- */
CREATE DOMAIN d_codea AS TEXT[] CHECK (array_to_string(VALUE,';') ~ E'^([a-z\\d][a-z\\d\\.\\-_]*)(;[a-z\\d][a-z\\d\\.\\-_]*)*$') ;
SELECT pg_c('d','d_codea', 'Массив d_code');

CREATE DOMAIN d_id32a AS INTEGER[] CHECK (-32768 < ALL(value) AND 32767 > ALL(value));
SELECT pg_c('d','d_id32a', 'Массив d_id32');

CREATE DOMAIN d_booleana AS boolean[];
SELECT pg_c('d','d_booleana', 'Массив boolean');

CREATE DOMAIN d_texta AS text[];
SELECT pg_c('d','d_texta', 'Массив text');

CREATE DOMAIN d_ida AS INTEGER[];
SELECT pg_c('d','d_ida', 'Массив d_id');

CREATE DOMAIN d_moneya AS DECIMAL(16,2)[];
SELECT pg_c('d','d_moneya', 'Массив d_money');

/* ------------------------------------------------------------------------- */
CREATE DOMAIN d_classcode AS char(2);
SELECT pg_c('d','d_classcode', 'Код класса');

CREATE DOMAIN d_errcode AS char(5) CHECK (VALUE ~ E'^Y\\d{4}$') ;
SELECT pg_c('d','d_errcode', 'Код ошибки');

CREATE DOMAIN d_format  AS text;
SELECT pg_c('d','d_format', 'Формат для printf');

/* ------------------------------------------------------------------------- */
CREATE TYPE t_hashtable AS (
  id     text
  , name text
);
SELECT pg_c('t','t_hashtable', 'Хэштаблица')
, pg_c('c','t_hashtable.id',    'ID')
, pg_c('c','t_hashtable.name',  'Название');

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
SELECT pg_c('t','t_page_info', 'Параметры страницы')
, pg_c('c', 't_page_info.code'      , 'Идентификатор страницы')
, pg_c('c', 't_page_info.up_code'   , 'идентификатор страницы верхнего уровня')
, pg_c('c', 't_page_info.class_id'  , 'ID класса, к которому относится страница')
, pg_c('c', 't_page_info.action_id' , 'ID акции, к которой относится страница')
, pg_c('c', 't_page_info.group_id'  , 'ID группы страниц для меню')
, pg_c('c', 't_page_info.sort'      , 'порядок сортировки в меню страниц одного уровня (NULL - нет в меню)')
, pg_c('c', 't_page_info.uri'       , 'мета-маска с именами переменных, которой должен соответствовать URI запроса (NULL - группировка страниц)')
, pg_c('c', 't_page_info.tmpl'      , 'файл шаблона (NULL для внешних адресов)')
, pg_c('c', 't_page_info.id_fixed'  , 'ID объекта взять из этого поля')
, pg_c('c', 't_page_info.id_session', 'ID объекта взять из этого поля сессии')
, pg_c('c', 't_page_info.is_hidden' , 'Запрет включения внешних блоков в разметку страницы')
, pg_c('c', 't_page_info.target'    , 'значение атрибута target в формируемых ссылках')
, pg_c('c', 't_page_info.uri_re'    , 'regexp URI, вычисляется триггером при insert/update')
, pg_c('c', 't_page_info.uri_fmt'   , 'строка формата для генерации URI, вычисляется триггером при insert/update')
, pg_c('c', 't_page_info.pkg'       , 'пакет, в котором зарегистрирована страница')
, pg_c('c', 't_page_info.name'      , 'Заголовок страницы')
, pg_c('c', 't_page_info.req'       , 'URI')
, pg_c('c', 't_page_info.args'      , 'Массив аргументов URI')
, pg_c('c', 't_page_info.group_name', 'Название группы страниц')
;

/* ------------------------------------------------------------------------- */
CREATE TYPE t_acl_check AS (
  value int,
  id int,
  code text,
  name text
);
SELECT pg_c('t','t_acl_check', 'Результат проверки ACL');

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
SELECT pg_c('t', 't_month_info',           'Атрибуты месяца')
, pg_c('c','t_month_info.id',              'Дата - первое число месяца')
, pg_c('c','t_month_info.date_month_last', 'Дата - последнее число месяца')
, pg_c('c','t_month_info.date_month_prev', 'Дата - первое число предыдущего месяца')
, pg_c('c','t_month_info.date_month_next', 'Дата - первое число следующего месяца')
, pg_c('c','t_month_info.date_year',       'Дата - первое число года')
, pg_c('c','t_month_info.month',           'Номер месяца')
, pg_c('c','t_month_info.year',            'Год')
, pg_c('c','t_month_info.key',             'ГГГГММ')
, pg_c('c','t_month_info.month_name',      'месяц ГГГГ')
, pg_c('c','t_month_info.month_name_ic',   'Месяц ГГГГ')
;

