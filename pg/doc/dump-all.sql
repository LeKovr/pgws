--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: acc; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA acc;


--
-- Name: app; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA app;


--
-- Name: cfg; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA cfg;


--
-- Name: SCHEMA cfg; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA cfg IS 'Конфигурация объектов';


--
-- Name: ev; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA ev;


--
-- Name: SCHEMA ev; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA ev IS 'Диспетчер событий';


--
-- Name: fs; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA fs;


--
-- Name: SCHEMA fs; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA fs IS 'Файл-сервер';


--
-- Name: i18n_def; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA i18n_def;


--
-- Name: SCHEMA i18n_def; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA i18n_def IS 'WebService (PGWS) default internationalization data';


--
-- Name: i18n_en; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA i18n_en;


--
-- Name: SCHEMA i18n_en; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA i18n_en IS 'WebService (PGWS) default internationalization data';


--
-- Name: job; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA job;


--
-- Name: SCHEMA job; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA job IS 'Диспетчер заданий';


--
-- Name: wiki; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA wiki;


--
-- Name: ws; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA ws;


--
-- Name: SCHEMA ws; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA ws IS 'WebService (PGWS) core';


--
-- Name: wsd; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA wsd;


--
-- Name: SCHEMA wsd; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA wsd IS 'WebService (PGWS) data';


--
-- Name: plperl; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: -
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plperl;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = cfg, pg_catalog;

--
-- Name: d_prop_code; Type: DOMAIN; Schema: cfg; Owner: -
--

CREATE DOMAIN d_prop_code AS text
	CONSTRAINT d_prop_code_check CHECK ((VALUE ~ '^([a-z\d_]+)(\.((:?[a-z\d_]+)|(\([a-z\d_]+(,[a-z\d_]+)+\))))*$'::text));


--
-- Name: DOMAIN d_prop_code; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON DOMAIN d_prop_code IS 'Код свойства';


SET search_path = job, pg_catalog;

--
-- Name: t_attr; Type: TYPE; Schema: job; Owner: -
--

CREATE TYPE t_attr AS (
	handler_id integer,
	status_id integer,
	arg_id integer,
	arg_date date,
	arg_num numeric,
	arg_more text,
	arg_id2 integer,
	arg_date2 date,
	arg_id3 integer
);


--
-- Name: TYPE t_attr; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON TYPE t_attr IS 'Атрибуты задачи';


--
-- Name: COLUMN t_attr.handler_id; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN t_attr.handler_id IS 'класс задачи (обработчика)';


--
-- Name: COLUMN t_attr.status_id; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN t_attr.status_id IS 'текущий статус';


--
-- Name: COLUMN t_attr.arg_id; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN t_attr.arg_id IS 'аргумент id';


--
-- Name: COLUMN t_attr.arg_date; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN t_attr.arg_date IS 'аргумент date';


--
-- Name: COLUMN t_attr.arg_num; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN t_attr.arg_num IS 'аргумент num';


--
-- Name: COLUMN t_attr.arg_more; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN t_attr.arg_more IS 'аргумент more';


--
-- Name: COLUMN t_attr.arg_id2; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN t_attr.arg_id2 IS 'аргумент id2';


--
-- Name: COLUMN t_attr.arg_date2; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN t_attr.arg_date2 IS 'аргумент, 2я дата для периодов';


--
-- Name: COLUMN t_attr.arg_id3; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN t_attr.arg_id3 IS 'аргумент id3';


SET search_path = wiki, pg_catalog;

--
-- Name: d_links; Type: DOMAIN; Schema: wiki; Owner: -
--

CREATE DOMAIN d_links AS text[];


SET search_path = ws, pg_catalog;

--
-- Name: d_id32; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_id32 AS integer
	CONSTRAINT d_id32_check CHECK (((VALUE > (-32768)) AND (VALUE < 32767)));


--
-- Name: DOMAIN d_id32; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_id32 IS 'Идентификатор справочника';


--
-- Name: d_acl; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_acl AS d_id32;


--
-- Name: DOMAIN d_acl; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_acl IS 'Уровень доступа';


--
-- Name: d_acls; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_acls AS integer[];


--
-- Name: DOMAIN d_acls; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_acls IS 'Массив уровней доступа';


--
-- Name: d_amount; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_amount AS numeric(11,3)
	CONSTRAINT d_amount_check CHECK ((VALUE > (0)::numeric));


--
-- Name: DOMAIN d_amount; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_amount IS 'Количество товара';


--
-- Name: d_bitmask; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_bitmask AS d_id32;


--
-- Name: DOMAIN d_bitmask; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_bitmask IS 'Битовая маска';


--
-- Name: d_booleana; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_booleana AS boolean[];


--
-- Name: DOMAIN d_booleana; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_booleana IS 'Массив boolean';


--
-- Name: d_class; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_class AS d_id32;


--
-- Name: DOMAIN d_class; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_class IS 'ID класса';


--
-- Name: d_classcode; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_classcode AS character(2);


--
-- Name: d_cnt; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_cnt AS integer
	CONSTRAINT d_cnt_check CHECK ((VALUE >= 0));


--
-- Name: DOMAIN d_cnt; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_cnt IS 'Количество элементов';


--
-- Name: d_code; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_code AS text
	CONSTRAINT d_code_check CHECK ((VALUE ~ '^[a-z\d][a-z\d\.\-_]*$'::text));


--
-- Name: DOMAIN d_code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_code IS 'Имя переменной';


--
-- Name: d_code_arg; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_code_arg AS text
	CONSTRAINT d_code_arg_check CHECK ((VALUE ~ '^[a-z\d_][a-z\d\.\-_]*$'::text));


--
-- Name: DOMAIN d_code_arg; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_code_arg IS 'Имя аргумента';


--
-- Name: d_code_like; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_code_like AS text
	CONSTRAINT d_code_like_check CHECK ((VALUE ~ '^[a-z\d\.\-_\%]+$'::text));


--
-- Name: DOMAIN d_code_like; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_code_like IS 'Шаблон имени переменной';


--
-- Name: d_codea; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_codea AS text[]
	CONSTRAINT d_codea_check CHECK ((array_to_string(VALUE, ';'::text) ~ '^([a-z\d][a-z\d\.\-_]*)(;[a-z\d][a-z\d\.\-_]*)*$'::text));


--
-- Name: DOMAIN d_codea; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_codea IS 'Массив d_code';


--
-- Name: d_codei; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_codei AS text
	CONSTRAINT d_codei_check CHECK ((VALUE ~ '^[a-z\d][a-z\d\.\-_A-Z]*$'::text));


--
-- Name: DOMAIN d_codei; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_codei IS 'Имя переменной в любом регистре';


--
-- Name: d_decimal_non_neg; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_decimal_non_neg AS numeric
	CONSTRAINT d_decimal_non_neg_check CHECK ((VALUE >= (0)::numeric));


--
-- Name: DOMAIN d_decimal_non_neg; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_decimal_non_neg IS 'Вещественное >= 0';


--
-- Name: d_decimal_positive; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_decimal_positive AS numeric
	CONSTRAINT d_decimal_positive_check CHECK ((VALUE > (0)::numeric));


--
-- Name: DOMAIN d_decimal_positive; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_decimal_positive IS 'Вещественное > 0';


--
-- Name: d_email; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_email AS text
	CONSTRAINT d_email_check CHECK (((VALUE = ''::text) OR (VALUE ~ '^[^ ]+@[^ ]+\.[^ ]{2,6}'::text)));


--
-- Name: DOMAIN d_email; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_email IS 'Адрес email';


--
-- Name: d_emails; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_emails AS text[];


--
-- Name: DOMAIN d_emails; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_emails IS 'Список адресов email';


--
-- Name: d_errcode; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_errcode AS character(5)
	CONSTRAINT d_errcode_check CHECK ((VALUE ~ '^Y\d{4}$'::text));


--
-- Name: DOMAIN d_errcode; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_errcode IS 'Код ошибки';


--
-- Name: d_format; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_format AS text;


--
-- Name: DOMAIN d_format; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_format IS 'Формат для printf';


--
-- Name: d_id; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_id AS integer;


--
-- Name: DOMAIN d_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_id IS 'Идентификатор';


--
-- Name: d_id32a; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_id32a AS integer[]
	CONSTRAINT d_id32a_check CHECK ((((-32768) < ALL (VALUE)) AND (32767 > ALL (VALUE))));


--
-- Name: DOMAIN d_id32a; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_id32a IS 'Массив d_id32';


--
-- Name: d_id_positive; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_id_positive AS integer
	CONSTRAINT d_id_positive_check CHECK ((VALUE > 0));


--
-- Name: DOMAIN d_id_positive; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_id_positive IS 'Целое > 0';


--
-- Name: d_ida; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_ida AS integer[];


--
-- Name: DOMAIN d_ida; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_ida IS 'Массив d_id';


--
-- Name: d_lang; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_lang AS text
	CONSTRAINT d_lang_check CHECK ((VALUE ~ '^(?:ru|en)$'::text));


--
-- Name: DOMAIN d_lang; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_lang IS 'Идентификатор языка';


--
-- Name: d_login; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_login AS text
	CONSTRAINT d_login_check CHECK ((VALUE ~ '^[a-zA-Z0-9\.+_@\-]{5,}$'::text));


--
-- Name: DOMAIN d_login; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_login IS 'Логин';


--
-- Name: d_money; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_money AS numeric(16,2);


--
-- Name: DOMAIN d_money; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_money IS 'Деньги';


--
-- Name: d_moneya; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_moneya AS numeric(16,2)[];


--
-- Name: DOMAIN d_moneya; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_moneya IS 'Массив d_money';


--
-- Name: d_path; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_path AS text
	CONSTRAINT d_path_check CHECK ((VALUE ~ '^(|[a-z\d_][a-z\d\.\-_/]+)$'::text));


--
-- Name: DOMAIN d_path; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_path IS 'Относительный путь';


--
-- Name: d_pg_argnames; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_pg_argnames AS text[];


--
-- Name: d_pg_argtypes; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_pg_argtypes AS oidvector;


--
-- Name: d_rating; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_rating AS numeric(4,3)
	CONSTRAINT d_rating_check CHECK (((VALUE >= ((-2))::numeric) AND (VALUE <= (2)::numeric)));


--
-- Name: DOMAIN d_rating; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_rating IS 'Рейтинг компании';


--
-- Name: d_regexp; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_regexp AS text;


--
-- Name: DOMAIN d_regexp; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_regexp IS 'Регулярное выражение';


--
-- Name: d_sid; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_sid AS text;


--
-- Name: DOMAIN d_sid; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_sid IS 'Идентификатор сессии';


--
-- Name: d_sort; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_sort AS integer
	CONSTRAINT d_sort_check CHECK (((VALUE > (-32768)) AND (VALUE < 32767)));


--
-- Name: DOMAIN d_sort; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_sort IS 'Порядок сортировки';


--
-- Name: d_stamp; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_stamp AS timestamp(0) without time zone;


--
-- Name: DOMAIN d_stamp; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_stamp IS 'Момент времени с точностью до секунды';


--
-- Name: d_string; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_string AS text
	CONSTRAINT d_string_check CHECK ((VALUE !~ '\n'::text));


--
-- Name: DOMAIN d_string; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_string IS 'Текстовая строка';


--
-- Name: d_sub; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_sub AS text
	CONSTRAINT d_sub_check CHECK ((VALUE ~ '^([a-z\d][a-z\d\.\-_]+)|([A-Z\d][a-z\d\.\-_:A-Z]+)$'::text));


--
-- Name: DOMAIN d_sub; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_sub IS 'Имя внешнего метода';


--
-- Name: d_text; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_text AS text;


--
-- Name: DOMAIN d_text; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_text IS 'Текст';


--
-- Name: d_texta; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_texta AS text[];


--
-- Name: DOMAIN d_texta; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_texta IS 'Массив text';


--
-- Name: d_zip; Type: DOMAIN; Schema: ws; Owner: -
--

CREATE DOMAIN d_zip AS text
	CONSTRAINT d_zip_check CHECK ((VALUE ~ '^[a-zA-Zа-яА-я0-9][a-zA-Zа-яА-я0-9 -]{2,11}'::text));


--
-- Name: DOMAIN d_zip; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON DOMAIN d_zip IS 'Почтовый индекс';


--
-- Name: t_acl_check; Type: TYPE; Schema: ws; Owner: -
--

CREATE TYPE t_acl_check AS (
	value integer,
	id integer,
	code text,
	name text
);


--
-- Name: TYPE t_acl_check; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TYPE t_acl_check IS 'Результат проверки ACL';


--
-- Name: t_date_info; Type: TYPE; Schema: ws; Owner: -
--

CREATE TYPE t_date_info AS (
	date date,
	day d_id32,
	month d_id32,
	year d_id32,
	date_month date,
	date_year date,
	date_name text,
	month_name text,
	date_name_doc text,
	fmt_calend text,
	fmt_example text
);


--
-- Name: TYPE t_date_info; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TYPE t_date_info IS 'Атрибуты даты';


--
-- Name: COLUMN t_date_info.date_name; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN t_date_info.date_name IS 'ДД месяц ГГГГ';


--
-- Name: COLUMN t_date_info.month_name; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN t_date_info.month_name IS 'месяц ГГГГ';


--
-- Name: COLUMN t_date_info.date_name_doc; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN t_date_info.date_name_doc IS '(ДД|0Д) месяц ГГГГ';


--
-- Name: t_hashtable; Type: TYPE; Schema: ws; Owner: -
--

CREATE TYPE t_hashtable AS (
	id text,
	name text
);


--
-- Name: TYPE t_hashtable; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TYPE t_hashtable IS 'Хэштаблица';


--
-- Name: COLUMN t_hashtable.id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN t_hashtable.id IS 'ID';


--
-- Name: COLUMN t_hashtable.name; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN t_hashtable.name IS 'Название';


--
-- Name: t_month_info; Type: TYPE; Schema: ws; Owner: -
--

CREATE TYPE t_month_info AS (
	id date,
	date_month_last date,
	date_month_prev date,
	date_month_next date,
	date_year date,
	month d_id32,
	year d_id32,
	key text,
	month_name text,
	month_name_ic text
);


--
-- Name: TYPE t_month_info; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TYPE t_month_info IS 'Атрибуты месяца';


--
-- Name: COLUMN t_month_info.id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN t_month_info.id IS 'Дата - первое число месяца';


--
-- Name: COLUMN t_month_info.date_month_last; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN t_month_info.date_month_last IS 'Дата - последнее число месяца';


--
-- Name: COLUMN t_month_info.date_month_prev; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN t_month_info.date_month_prev IS 'Дата - первое число предыдущего месяца';


--
-- Name: COLUMN t_month_info.date_month_next; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN t_month_info.date_month_next IS 'Дата - первое число следующего месяца';


--
-- Name: COLUMN t_month_info.date_year; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN t_month_info.date_year IS 'Дата - первое число года';


--
-- Name: COLUMN t_month_info.month; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN t_month_info.month IS 'Номер месяца';


--
-- Name: COLUMN t_month_info.year; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN t_month_info.year IS 'Год';


--
-- Name: COLUMN t_month_info.key; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN t_month_info.key IS 'ГГГГММ';


--
-- Name: COLUMN t_month_info.month_name; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN t_month_info.month_name IS 'месяц ГГГГ';


--
-- Name: COLUMN t_month_info.month_name_ic; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN t_month_info.month_name_ic IS 'Месяц ГГГГ';


--
-- Name: t_page_info; Type: TYPE; Schema: ws; Owner: -
--

CREATE TYPE t_page_info AS (
	code d_code,
	up_code d_code,
	class_id d_class,
	action_id d_id32,
	group_id d_id32,
	sort d_sort,
	uri d_regexp,
	tmpl d_path,
	id_fixed d_id,
	id_session d_code,
	is_hidden boolean,
	target text,
	uri_re text,
	uri_fmt text,
	pkg text,
	name text,
	req text,
	args text[],
	group_name text
);


--
-- Name: TYPE t_page_info; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TYPE t_page_info IS 'Параметры страницы';


--
-- Name: t_pg_object; Type: TYPE; Schema: ws; Owner: -
--

CREATE TYPE t_pg_object AS ENUM (
    'h',
    'r',
    'v',
    'c',
    't',
    'd',
    'f',
    'a',
    's'
);


--
-- Name: t_pg_proc_info; Type: TYPE; Schema: ws; Owner: -
--

CREATE TYPE t_pg_proc_info AS (
	schema text,
	name text,
	anno text,
	rt_oid oid,
	rt_name text,
	is_set boolean,
	args text,
	args_pub text
);


--
-- Name: TYPE t_pg_proc_info; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TYPE t_pg_proc_info IS 'Параметры хранимой процедуры';


--
-- Name: t_pg_view_info; Type: TYPE; Schema: ws; Owner: -
--

CREATE TYPE t_pg_view_info AS (
	rel text,
	code text,
	rel_src text,
	rel_src_col text,
	status_id integer,
	anno text
);


SET search_path = acc, pg_catalog;

--
-- Name: account_acl(ws.d_id, ws.d_sid); Type: FUNCTION; Schema: acc; Owner: -
--

CREATE FUNCTION account_acl(a_id ws.d_id, a__sid ws.d_sid DEFAULT NULL::text) RETURNS SETOF ws.d_acl
    LANGUAGE plpgsql STABLE
    AS $$ /* acc:acc:51_account.sql / 55 */ 
  /*
    Получить уровень доступа пользователя сессии a_sid на экземпляр a_id класса "user"
    Например: администратор отдела, в котором состоит заданный пользователь a_id
      или для ws.part_topic_message - пользователь является автором поста
  */
  DECLARE
    v_acl ws.d_acl;
  BEGIN
    -- получить роль пользователя и ее описание
    -- получить информацию про экземпляр
    -- определить acl
    RETURN NEXT 1::ws.d_acl;
    RETURN;
  END
$$;


--
-- Name: FUNCTION account_acl(a_id ws.d_id, a__sid ws.d_sid); Type: COMMENT; Schema: acc; Owner: -
--

COMMENT ON FUNCTION account_acl(a_id ws.d_id, a__sid ws.d_sid) IS 'ACL к учетной записи пользователя';


SET search_path = ws, pg_catalog;

SET default_with_oids = false;

--
-- Name: server; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE server (
    id d_id32 NOT NULL,
    uri text NOT NULL,
    name text NOT NULL
);


--
-- Name: TABLE server; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE server IS 'Сервер горизонтального масштабирования (reserved)';


--
-- Name: COLUMN server.id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN server.id IS 'ID сервера';


--
-- Name: COLUMN server.uri; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN server.uri IS 'Адрес сервера';


--
-- Name: COLUMN server.name; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN server.name IS 'Название сервера';


SET search_path = acc, pg_catalog;

--
-- Name: account_server(ws.d_id); Type: FUNCTION; Schema: acc; Owner: -
--

CREATE FUNCTION account_server(a_id ws.d_id) RETURNS SETOF ws.server
    LANGUAGE plpgsql STABLE
    AS $$ /* acc:acc:51_account.sql / 76 */ 
  DECLARE
    v_id  ws.d_id32;
    r_srv ws.server;
  BEGIN
    v_id := 1; -- расчет id ответственного сервера по id компании
    RETURN QUERY
      SELECT *
        FROM ws.server
        WHERE id = v_id
    ;
    RETURN;
  END
$$;


--
-- Name: FUNCTION account_server(a_id ws.d_id); Type: COMMENT; Schema: acc; Owner: -
--

COMMENT ON FUNCTION account_server(a_id ws.d_id) IS 'Сервер учетной записи пользователя';


--
-- Name: account_status(ws.d_id); Type: FUNCTION; Schema: acc; Owner: -
--

CREATE FUNCTION account_status(a_id ws.d_id) RETURNS ws.d_id32
    LANGUAGE sql STABLE
    AS $_$ /* acc:acc:51_account.sql / 48 */ 
  SELECT status_id::ws.d_id32 FROM wsd.account WHERE id = $1
$_$;


--
-- Name: FUNCTION account_status(a_id ws.d_id); Type: COMMENT; Schema: acc; Owner: -
--

COMMENT ON FUNCTION account_status(a_id ws.d_id) IS 'Статус учетной записи пользователя';


--
-- Name: const_admin_psw_default(); Type: FUNCTION; Schema: acc; Owner: -
--

CREATE FUNCTION const_admin_psw_default() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ /* acc:acc:19_const.sql / 41 */ 
  SELECT 'pgws'::TEXT
$$;


--
-- Name: FUNCTION const_admin_psw_default(); Type: COMMENT; Schema: acc; Owner: -
--

COMMENT ON FUNCTION const_admin_psw_default() IS 'Константа: Первичный пароль администратора';


--
-- Name: const_error_login(); Type: FUNCTION; Schema: acc; Owner: -
--

CREATE FUNCTION const_error_login() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ /* acc:acc:19_const.sql / 55 */ 
  SELECT 'Y0302'::TEXT
$$;


--
-- Name: FUNCTION const_error_login(); Type: COMMENT; Schema: acc; Owner: -
--

COMMENT ON FUNCTION const_error_login() IS 'Константа: Код ошибки авторизации с неизвестным логином';


--
-- Name: const_error_password(); Type: FUNCTION; Schema: acc; Owner: -
--

CREATE FUNCTION const_error_password() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ /* acc:acc:19_const.sql / 48 */ 
  SELECT 'Y0301'::TEXT
$$;


--
-- Name: FUNCTION const_error_password(); Type: COMMENT; Schema: acc; Owner: -
--

COMMENT ON FUNCTION const_error_password() IS 'Константа: Код ошибки авторизации с неправильным паролем';


--
-- Name: const_error_status(); Type: FUNCTION; Schema: acc; Owner: -
--

CREATE FUNCTION const_error_status() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ /* acc:acc:19_const.sql / 62 */ 
  SELECT 'Y0303'::TEXT
$$;


--
-- Name: FUNCTION const_error_status(); Type: COMMENT; Schema: acc; Owner: -
--

COMMENT ON FUNCTION const_error_status() IS 'Константа: Код ошибки авторизации с недопустимым статусом';


--
-- Name: const_role_id_guest(); Type: FUNCTION; Schema: acc; Owner: -
--

CREATE FUNCTION const_role_id_guest() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ /* acc:acc:19_const.sql / 27 */ 
  SELECT 1
$$;


--
-- Name: FUNCTION const_role_id_guest(); Type: COMMENT; Schema: acc; Owner: -
--

COMMENT ON FUNCTION const_role_id_guest() IS 'Константа: ID роли неавторизованного пользователя';


--
-- Name: const_role_id_user(); Type: FUNCTION; Schema: acc; Owner: -
--

CREATE FUNCTION const_role_id_user() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ /* acc:acc:19_const.sql / 34 */ 
  SELECT 2
$$;


--
-- Name: FUNCTION const_role_id_user(); Type: COMMENT; Schema: acc; Owner: -
--

COMMENT ON FUNCTION const_role_id_user() IS 'Константа: ID роли авторизованного пользователя';


--
-- Name: const_status_id_active(); Type: FUNCTION; Schema: acc; Owner: -
--

CREATE FUNCTION const_status_id_active() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ /* acc:acc:19_const.sql / 13 */ 
  SELECT 4
$$;


--
-- Name: FUNCTION const_status_id_active(); Type: COMMENT; Schema: acc; Owner: -
--

COMMENT ON FUNCTION const_status_id_active() IS 'Константа: ID статуса активного аккаунта';


--
-- Name: const_status_id_active_locked(); Type: FUNCTION; Schema: acc; Owner: -
--

CREATE FUNCTION const_status_id_active_locked() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ /* acc:acc:19_const.sql / 20 */ 
  SELECT 5
$$;


SET search_path = wsd, pg_catalog;

--
-- Name: account_id_seq; Type: SEQUENCE; Schema: wsd; Owner: -
--

CREATE SEQUENCE account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE account (
    id integer DEFAULT nextval('account_id_seq'::regclass) NOT NULL,
    status_id integer DEFAULT 1 NOT NULL,
    def_role_id integer NOT NULL,
    login text NOT NULL,
    psw text NOT NULL,
    name text NOT NULL,
    is_psw_plain boolean DEFAULT true NOT NULL,
    is_ip_checked boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone DEFAULT now() NOT NULL,
    updated_at timestamp(0) without time zone DEFAULT now() NOT NULL,
    psw_updated_at timestamp(0) without time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE account; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE account IS 'Учетные записи пользователей';


--
-- Name: COLUMN account.def_role_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN account.def_role_id IS 'ID роли по умолчанию';


--
-- Name: COLUMN account.is_psw_plain; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN account.is_psw_plain IS 'Пароль хранить незашифрованным';


--
-- Name: COLUMN account.is_ip_checked; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN account.is_ip_checked IS 'IP проверять при валидации сессии';


--
-- Name: COLUMN account.psw_updated_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN account.psw_updated_at IS 'Момент изменения пароля';


--
-- Name: role_id_seq; Type: SEQUENCE; Schema: wsd; Owner: -
--

CREATE SEQUENCE role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: role; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE role (
    id integer DEFAULT nextval('role_id_seq'::regclass) NOT NULL,
    level_id integer NOT NULL,
    has_team boolean DEFAULT true NOT NULL,
    name text NOT NULL,
    anno text NOT NULL
);


--
-- Name: TABLE role; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE role IS 'Глобальная роль';


--
-- Name: COLUMN role.id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN role.id IS 'ID роли';


--
-- Name: session_id_seq; Type: SEQUENCE; Schema: wsd; Owner: -
--

CREATE SEQUENCE session_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: session; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE session (
    id integer DEFAULT nextval('session_id_seq'::regclass) NOT NULL,
    account_id integer NOT NULL,
    role_id integer NOT NULL,
    sid text,
    ip text NOT NULL,
    is_ip_checked boolean NOT NULL,
    created_at timestamp(0) without time zone DEFAULT now() NOT NULL,
    updated_at timestamp(0) without time zone DEFAULT now() NOT NULL,
    deleted_at timestamp(0) without time zone
);


--
-- Name: TABLE session; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE session IS 'Сессия авторизованного пользователя';


--
-- Name: COLUMN session.deleted_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN session.deleted_at IS 'Признак и время завершения сессии';


SET search_path = acc, pg_catalog;

--
-- Name: session_info; Type: VIEW; Schema: acc; Owner: -
--

CREATE VIEW session_info AS
    SELECT s.id, s.account_id, s.role_id, s.sid, s.ip, s.is_ip_checked, s.created_at, s.updated_at, s.deleted_at, a.status_id, a.name AS account_name, r.name AS role_name FROM ((wsd.session s JOIN wsd.account a ON ((a.id = s.account_id))) JOIN wsd.role r ON ((r.id = s.role_id)));


--
-- Name: login(text, text, text, text); Type: FUNCTION; Schema: acc; Owner: -
--

CREATE FUNCTION login(a__ip text, a_login text, a_psw text, a__cook text DEFAULT NULL::text) RETURNS SETOF session_info
    LANGUAGE plpgsql
    AS $$ /* acc:acc:51_account.sql / 117 */ 
  -- a__cook: ID cookie
  -- a__ip: IP-адреса сессии
  -- a_login: пароль
  -- a_psw: пароль
  DECLARE
    r     acc.account_attr;
    v_key TEXT;
    v_id  INTEGER;
  BEGIN
    SELECT INTO r
      *
      FROM wsd.account
      WHERE login = a_login
    ;
    IF FOUND THEN
      RAISE DEBUG 'Account % found', a_login;

      IF r.status_id NOT IN (acc.const_status_id_active(), acc.const_status_id_active_locked()) THEN
        RAISE EXCEPTION '%', ws.error_str(acc.const_error_status(), r_account_attr.status_id::text);
      END IF;

      -- TODO: контроль IP
      IF r.is_psw_plain AND r.psw = a_psw
        OR NOT r.is_psw_plain AND r.psw = md5(a_psw) THEN
        RAISE DEBUG 'Password matched for %', a_login;

        v_id := NEXTVAL('wsd.session_id_seq');
        -- определяем ключ авторизации
        IF a__cook IS NOT NULL THEN
          v_key = a__cook;
          -- закрываем все сессии для этого v_key
          PERFORM acc.logout(v_key);
        ELSE
          v_key = (random() * 10 ^ 8)::INTEGER::TEXT || v_id;
        END IF;

        -- создаем сессию
        INSERT INTO wsd.session (id, account_id, role_id, sid, ip, is_ip_checked)
          VALUES (v_id, r.id, r.def_role_id, v_key, a__ip, r.is_ip_checked)
        ;
        RETURN QUERY SELECT
          *
          FROM acc.session_info
          WHERE id = v_id
        ;
      ELSE
        -- TODO: журналировать потенциальный подбор пароля через cache
        RAISE EXCEPTION '%', ws.error_str(acc.const_error_password(), a_login::text);
      END IF;
    ELSE
      RAISE EXCEPTION '%', ws.error_str(acc.const_error_login(), a_login::text);
    END IF;
    RETURN;
  END;
$$;


--
-- Name: FUNCTION login(a__ip text, a_login text, a_psw text, a__cook text); Type: COMMENT; Schema: acc; Owner: -
--

COMMENT ON FUNCTION login(a__ip text, a_login text, a_psw text, a__cook text) IS 'Авторизация пользователя';


--
-- Name: logout(ws.d_sid); Type: FUNCTION; Schema: acc; Owner: -
--

CREATE FUNCTION logout(a__sid ws.d_sid DEFAULT NULL::text) RETURNS integer
    LANGUAGE plpgsql
    AS $$ /* acc:acc:51_account.sql / 94 */ 
  -- a__sid: ID сессии
  DECLARE
    v_cnt INTEGER;
  BEGIN
    UPDATE wsd.session SET
      deleted_at = now()
      WHERE sid = a__sid
        AND deleted_at IS NULL
    ;
    GET DIAGNOSTICS v_cnt = ROW_COUNT;
    RETURN v_cnt;
  END;
$$;


--
-- Name: FUNCTION logout(a__sid ws.d_sid); Type: COMMENT; Schema: acc; Owner: -
--

COMMENT ON FUNCTION logout(a__sid ws.d_sid) IS 'Завершить авторизации пользователя и вернуть количество завершенных';


--
-- Name: object_acl(ws.d_id, ws.d_id, ws.d_sid); Type: FUNCTION; Schema: acc; Owner: -
--

CREATE FUNCTION object_acl(a_class_id ws.d_id, a_id ws.d_id, a__sid ws.d_sid DEFAULT NULL::text) RETURNS SETOF ws.d_acl
    LANGUAGE plpgsql STABLE
    AS $$ /* acc:acc:50_object.sql / 25 */ 
  DECLARE
    v_role_id INTEGER;
    v_acl_id ws.d_acl;
  BEGIN
    -- текущая роль пользователя
    SELECT INTO v_role_id
      role_id
      FROM wsd.session
      WHERE sid = a__sid
        AND deleted_at IS NULL
    ;
    IF NOT FOUND THEN
      RETURN QUERY
        SELECT acl_id::ws.d_acl
          FROM wsd.role_acl
          WHERE role_id = acc.const_role_id_guest()
            AND class_id = a_class_id
            AND object_id = a_id
      ;
    ELSE
      RETURN QUERY
        SELECT acl_id::ws.d_acl
          FROM wsd.role_acl
          WHERE role_id IN (v_role_id, acc.const_role_id_user())
            AND class_id = a_class_id
            AND object_id = a_id
      ;
      -- TODO: поддержка отношений объекта и группы пользователя
    END IF;
    RETURN;
  END;
$$;


--
-- Name: FUNCTION object_acl(a_class_id ws.d_id, a_id ws.d_id, a__sid ws.d_sid); Type: COMMENT; Schema: acc; Owner: -
--

COMMENT ON FUNCTION object_acl(a_class_id ws.d_id, a_id ws.d_id, a__sid ws.d_sid) IS 'Получить уровень доступа пользователя сессии a_sid на экземпляр a_id класса a_class_id';


SET search_path = ws, pg_catalog;

--
-- Name: class_status_name(d_code, d_id32); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION class_status_name(a_class_code d_code, a_id d_id32) RETURNS text
    LANGUAGE sql STABLE STRICT
    AS $_$ /* ws:ws:52_class.sql / 85 */ 
  SELECT name FROM ws.class_status WHERE class_id = ws.class_id($1) AND $2 = id;
$_$;


SET search_path = acc, pg_catalog;

--
-- Name: account_attr; Type: VIEW; Schema: acc; Owner: -
--

CREATE VIEW account_attr AS
    SELECT a.id, a.status_id, a.def_role_id, a.login, a.psw, a.name, a.is_psw_plain, a.is_ip_checked, a.created_at, a.updated_at, a.psw_updated_at, ws.class_status_name(('account'::text)::ws.d_code, (a.status_id)::ws.d_id32) AS status_name FROM wsd.account a;


--
-- Name: profile(text); Type: FUNCTION; Schema: acc; Owner: -
--

CREATE FUNCTION profile(a__sid text) RETURNS SETOF account_attr
    LANGUAGE plpgsql
    AS $$ /* acc:acc:51_account.sql / 178 */ 
  -- a__sid: ID сессии
  DECLARE
    v_account_id ws.d_id;
    r_account_attr acc.account_attr;
  BEGIN
    -- TODO: контроль IP?

    SELECT INTO v_account_id
      account_id
      FROM wsd.session
      WHERE sid = a__sid
        AND deleted_at IS NULL
    ;
    IF FOUND THEN
      SELECT INTO r_account_attr
        *
        FROM acc.account_attr
        WHERE id = v_account_id
      ;
      -- прячем пароль
      r_account_attr.psw := '***';
      RETURN NEXT r_account_attr;
    END IF;

    RETURN;
  END;
$$;


--
-- Name: FUNCTION profile(a__sid text); Type: COMMENT; Schema: acc; Owner: -
--

COMMENT ON FUNCTION profile(a__sid text) IS 'Профиль текущего пользователя';


--
-- Name: sid_info(ws.d_sid, text); Type: FUNCTION; Schema: acc; Owner: -
--

CREATE FUNCTION sid_info(a__sid ws.d_sid DEFAULT NULL::text, a__ip text DEFAULT NULL::text) RETURNS SETOF wsd.session
    LANGUAGE plpgsql
    AS $$ /* acc:acc:51_account.sql / 25 */ 
  BEGIN
    RETURN QUERY SELECT
      *
      FROM wsd.session
      WHERE deleted_at IS NULL
        AND sid = a__sid
        AND (NOT is_ip_checked OR a__ip IS NULL OR ip = a__ip)
      LIMIT 1
    ;
    IF FOUND THEN
      UPDATE wsd.session SET
        updated_at = CURRENT_TIMESTAMP
        WHERE sid = a__sid
      ;
    END IF;
    RETURN;
  END;
$$;


--
-- Name: FUNCTION sid_info(a__sid ws.d_sid, a__ip text); Type: COMMENT; Schema: acc; Owner: -
--

COMMENT ON FUNCTION sid_info(a__sid ws.d_sid, a__ip text) IS 'Атрибуты своей сессии';


SET search_path = app, pg_catalog;

--
-- Name: add(integer, integer); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION add(a integer, b integer DEFAULT 0) RETURNS integer
    LANGUAGE plpgsql STABLE
    AS $$   /* app:app:52_add.sql / 25 */ -- FD: app:app:50_add.sql / 13 --
  -- a: Слагаемое 1
  -- b: Слагаемое 2
BEGIN
  IF a = -1 THEN
    -- unhandled exception
    RAISE EXCEPTION 'Unhandled catched';
  ELSIF a = -2 THEN
    -- no access (system error)
    RAISE EXCEPTION '%', ws.e_noaccess();
  ELSIF a = -3 THEN
    -- app form error
    RAISE EXCEPTION '%', ws.error_str(app.const_error_forbidden(), a::text);
  ELSIF a = -4 THEN
    -- app form field error
    RAISE EXCEPTION '%', ws.perror_str(app.const_error_notfound(), 'a', a::text);
  END IF;

  RETURN a + b;
END;
$$;


--
-- Name: FUNCTION add(a integer, b integer); Type: COMMENT; Schema: app; Owner: -
--

COMMENT ON FUNCTION add(a integer, b integer) IS 'Сумма 2х целых';


--
-- Name: const_error_forbidden(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION const_error_forbidden() RETURNS ws.d_errcode
    LANGUAGE sql IMMUTABLE
    AS $$ /* app:app:19_const.sql / 28 */ 
  SELECT 'Y0021'::ws.d_errcode
$$;


--
-- Name: FUNCTION const_error_forbidden(); Type: COMMENT; Schema: app; Owner: -
--

COMMENT ON FUNCTION const_error_forbidden() IS 'Константа: ошибка доступа уровня приложения';


--
-- Name: const_error_notfound(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION const_error_notfound() RETURNS ws.d_errcode
    LANGUAGE sql IMMUTABLE
    AS $$ /* app:app:19_const.sql / 35 */ 
  SELECT 'Y0021'::ws.d_errcode
$$;


--
-- Name: FUNCTION const_error_notfound(); Type: COMMENT; Schema: app; Owner: -
--

COMMENT ON FUNCTION const_error_notfound() IS 'Константа: ошибка поиска уровня приложения';


SET search_path = cfg, pg_catalog;

--
-- Name: cache(ws.d_id32); Type: FUNCTION; Schema: cfg; Owner: -
--

CREATE FUNCTION cache(a_id ws.d_id32 DEFAULT 0) RETURNS SETOF ws.t_hashtable
    LANGUAGE sql STABLE STRICT
    AS $_$ /* ws:cfg:51_cache.sql / 25 */ 
  SELECT poid::text, name FROM wsd.prop_owner WHERE pogc = 'cache' AND $1 IN (poid, 0) ORDER BY name;
$_$;


--
-- Name: FUNCTION cache(a_id ws.d_id32); Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON FUNCTION cache(a_id ws.d_id32) IS 'Атрибуты кэша по id';


SET search_path = ws, pg_catalog;

--
-- Name: mask2regexp(text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION mask2regexp(a_mask text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$ /* ws:ws:19_utils.sql / 114 */ 
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
$$;


--
-- Name: FUNCTION mask2regexp(a_mask text); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION mask2regexp(a_mask text) IS 'Сформировать строку поиска по шаблону';


--
-- Name: pg_cs(text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pg_cs(text DEFAULT ''::text) RETURNS name
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:18_pg.sql / 54 */ 
 SELECT (current_schema() || CASE WHEN COALESCE($1, '') = '' THEN '' ELSE '.' || $1 END)::name
$_$;


--
-- Name: FUNCTION pg_cs(text); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION pg_cs(text) IS 'Текущая (первая) схема БД в пути поиска';


SET search_path = cfg, pg_catalog;

--
-- Name: prop; Type: TABLE; Schema: cfg; Owner: -
--

CREATE TABLE prop (
    code d_prop_code NOT NULL,
    pkg text DEFAULT ws.pg_cs() NOT NULL,
    pogc_list ws.d_texta NOT NULL,
    is_mask boolean NOT NULL,
    def_value text,
    name text NOT NULL,
    value_fmt text,
    anno text
);


--
-- Name: TABLE prop; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON TABLE prop IS 'Справочник свойств';


--
-- Name: COLUMN prop.code; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop.code IS 'Код свойства';


--
-- Name: COLUMN prop.pkg; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop.pkg IS 'Пакет, в котором добавлено свойство';


--
-- Name: COLUMN prop.pogc_list; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop.pogc_list IS 'Массив кодов разрешенных групп (prop_group)';


--
-- Name: COLUMN prop.is_mask; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop.is_mask IS 'Свойство не атомарно';


--
-- Name: COLUMN prop.def_value; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop.def_value IS 'Значение по умолчанию';


--
-- Name: COLUMN prop.name; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop.name IS 'Название';


--
-- Name: COLUMN prop.value_fmt; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop.value_fmt IS 'Строка формата для вывода значения';


--
-- Name: COLUMN prop.anno; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop.anno IS 'Аннотация';


SET search_path = wsd, pg_catalog;

--
-- Name: prop_owner; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE prop_owner (
    pogc text NOT NULL,
    poid integer NOT NULL,
    pkg text DEFAULT ws.pg_cs() NOT NULL,
    sort integer NOT NULL,
    name text NOT NULL,
    anno text
);


--
-- Name: TABLE prop_owner; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE prop_owner IS 'Владельцы свойств (Property Owner)';


--
-- Name: COLUMN prop_owner.pogc; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN prop_owner.pogc IS 'Код группы (Property Owner Group Code)';


--
-- Name: COLUMN prop_owner.poid; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN prop_owner.poid IS 'ID владельца (Property Owner ID)';


--
-- Name: COLUMN prop_owner.pkg; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN prop_owner.pkg IS 'Пакет, в котором добавлена группа';


--
-- Name: COLUMN prop_owner.sort; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN prop_owner.sort IS 'Порядок сортировки';


--
-- Name: COLUMN prop_owner.name; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN prop_owner.name IS 'Название';


--
-- Name: COLUMN prop_owner.anno; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN prop_owner.anno IS 'Аннотация';


--
-- Name: prop_value; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE prop_value (
    pogc text NOT NULL,
    poid integer NOT NULL,
    code text NOT NULL,
    valid_from date DEFAULT '2000-01-01'::date NOT NULL,
    pkg text DEFAULT ws.pg_cs() NOT NULL,
    value text
);


--
-- Name: TABLE prop_value; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE prop_value IS 'Значения свойств объектов';


--
-- Name: COLUMN prop_value.pogc; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN prop_value.pogc IS 'Код группы (Property Owner Group Code)';


--
-- Name: COLUMN prop_value.poid; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN prop_value.poid IS 'ID владельца (Property Owner ID)';


--
-- Name: COLUMN prop_value.code; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN prop_value.code IS 'Код свойства';


--
-- Name: COLUMN prop_value.valid_from; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN prop_value.valid_from IS 'Дата начала действия';


--
-- Name: COLUMN prop_value.pkg; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN prop_value.pkg IS 'Пакет, в котором задано значение';


--
-- Name: COLUMN prop_value.value; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN prop_value.value IS 'Значение свойства';


SET search_path = cfg, pg_catalog;

--
-- Name: prop_attr; Type: VIEW; Schema: cfg; Owner: -
--

CREATE VIEW prop_attr AS
    SELECT pv.code, p.pkg, p.pogc_list, p.is_mask, p.def_value, p.name, p.value_fmt, p.anno, pv.pogc, pv.poid, pv.valid_from, pv.pkg AS value_pkg, pv.value FROM prop p, wsd.prop_value pv WHERE (((pv.pogc = ANY ((p.pogc_list)::text[])) AND p.is_mask) AND (pv.code ~ ws.mask2regexp((p.code)::text))) UNION SELECT p.code, p.pkg, p.pogc_list, p.is_mask, p.def_value, p.name, p.value_fmt, p.anno, po.pogc, po.poid, '2000-01-02'::date AS valid_from, po.pkg AS value_pkg, (SELECT prop_value.value FROM wsd.prop_value WHERE (((prop_value.pogc = po.pogc) AND (prop_value.poid = po.poid)) AND (prop_value.code = (p.code)::text))) AS value FROM prop p, wsd.prop_owner po WHERE ((po.pogc = ANY ((p.pogc_list)::text[])) AND (NOT p.is_mask)) ORDER BY 9, 10, 1, 11;


--
-- Name: VIEW prop_attr; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON VIEW prop_attr IS 'Атрибуты свойств';


--
-- Name: COLUMN prop_attr.code; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop_attr.code IS 'Код свойства';


--
-- Name: COLUMN prop_attr.pogc; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop_attr.pogc IS 'Код группы (Property Owner Group Code)';


--
-- Name: COLUMN prop_attr.poid; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop_attr.poid IS 'ID владельца (Property Owner ID)';


--
-- Name: COLUMN prop_attr.valid_from; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop_attr.valid_from IS 'Дата начала действия';


--
-- Name: COLUMN prop_attr.value_pkg; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop_attr.value_pkg IS 'Пакет, в котором задано значение';


--
-- Name: COLUMN prop_attr.value; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop_attr.value IS 'Значение свойства';


--
-- Name: prop_attr(text, integer, text); Type: FUNCTION; Schema: cfg; Owner: -
--

CREATE FUNCTION prop_attr(a_pogc text DEFAULT NULL::text, a_poid integer DEFAULT 0, a_code text DEFAULT NULL::text) RETURNS SETOF prop_attr
    LANGUAGE sql STABLE
    AS $_$ /* ws:cfg:50_main.sql / 36 */ 
-- a_pogc: код группы владельцев
-- a_poid: код владельца свойств
-- a_code: код свойства
  SELECT * FROM cfg.prop_attr
  WHERE COALESCE($1, pogc) = pogc
    AND $2 IN (0, poid)
    AND COALESCE($3, code) = code
$_$;


--
-- Name: FUNCTION prop_attr(a_pogc text, a_poid integer, a_code text); Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON FUNCTION prop_attr(a_pogc text, a_poid integer, a_code text) IS 'Атрибуты Свойства';


--
-- Name: prop_calc_is_mask(); Type: FUNCTION; Schema: cfg; Owner: -
--

CREATE FUNCTION prop_calc_is_mask() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ /* ws:cfg:60_main.sql / 25 */ 
  BEGIN
    NEW.is_mask := ws.mask_is_multi(NEW.code);
    RETURN NEW;
  END;
$$;


--
-- Name: FUNCTION prop_calc_is_mask(); Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON FUNCTION prop_calc_is_mask() IS 'Расчет значения поля is_mask';


--
-- Name: prop_clean_pkg(text, boolean); Type: FUNCTION; Schema: cfg; Owner: -
--

CREATE FUNCTION prop_clean_pkg(a_pkg text, a_wsd_clean boolean) RETURNS void
    LANGUAGE plpgsql
    AS $_$ /* ws:cfg:52_misc.sql / 25 */ 
-- a_pkg: пакет для которого производится чистка
-- a_wsd_clean: признак удаления атрибутов свойств в схеме wsd
  BEGIN

    -- удаление списка свойств для пакета a_pkg
    DELETE FROM cfg.prop WHERE pkg = $1;
    UPDATE cfg.prop SET pogc_list = ws.array_remove(pogc_list::text[], $1) WHERE $1 = ANY(pogc_list);

    -- удаление значений свойств и владельцев из схемы wsd
    IF $2 THEN
      DELETE FROM wsd.prop_value WHERE pkg = $1;
      DELETE FROM wsd.prop_owner WHERE pkg = $1;
      DELETE FROM wsd.prop_group WHERE pkg = $1;
    END IF;

  END
$_$;


--
-- Name: FUNCTION prop_clean_pkg(a_pkg text, a_wsd_clean boolean); Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON FUNCTION prop_clean_pkg(a_pkg text, a_wsd_clean boolean) IS 'Удаление свойств для отдельного пакета';


--
-- Name: prop_clean_value(text); Type: FUNCTION; Schema: cfg; Owner: -
--

CREATE FUNCTION prop_clean_value(a_prop_value text) RETURNS void
    LANGUAGE plpgsql
    AS $_$ /* ws:cfg:52_misc.sql / 47 */ 
-- a_prop_value: значение свойства
  BEGIN

    DELETE FROM wsd.prop_value WHERE code = $1;

  END
$_$;


--
-- Name: FUNCTION prop_clean_value(a_prop_value text); Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON FUNCTION prop_clean_value(a_prop_value text) IS 'Удаление значения свойства';


--
-- Name: prop_group_value_list(text, ws.d_id, text, boolean, date, text, text); Type: FUNCTION; Schema: cfg; Owner: -
--

CREATE FUNCTION prop_group_value_list(a_pogc text, a_poid ws.d_id DEFAULT 0, a_prefix text DEFAULT ''::text, a_prefix_keep boolean DEFAULT true, a_date date DEFAULT ('now'::text)::date, a_prefix_new text DEFAULT ''::text, a_mark_default text DEFAULT '%s'::text) RETURNS SETOF ws.t_hashtable
    LANGUAGE plpgsql STABLE
    AS $$ /* ws:cfg:30_main.sql / 125 */ 
-- a_pogc: код группы владельцев
-- a_poid: код владельца
-- a_prefix: часть кода свойства до '.'
-- a_prefix_keep:признак замены в результате a_prefix на a_prefix_new
-- a_date: дата получения значения свойства
-- a_prefix_new: добавочный префикс
-- a_mark_default: метка для не атомарного свойства
DECLARE
  r wsd.prop_owner;
  v_prefix_add TEXT;
BEGIN
  FOR r IN SELECT * FROM wsd.prop_owner WHERE pogc = a_pogc AND a_poid IN (poid, 0) ORDER BY sort
  LOOP
    v_prefix_add := CASE
      WHEN a_poid = 0 THEN r.poid || '.'
      ELSE ''
    END;
    RETURN QUERY SELECT * FROM cfg.prop_value_list(r.pogc, r.poid, a_prefix, a_prefix_keep, a_date, a_prefix_new || v_prefix_add, a_mark_default);
  END LOOP;
  RETURN;
END;
$$;


--
-- Name: FUNCTION prop_group_value_list(a_pogc text, a_poid ws.d_id, a_prefix text, a_prefix_keep boolean, a_date date, a_prefix_new text, a_mark_default text); Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON FUNCTION prop_group_value_list(a_pogc text, a_poid ws.d_id, a_prefix text, a_prefix_keep boolean, a_date date, a_prefix_new text, a_mark_default text) IS 'Значения свойств по части кода (до .), в разрезе владельцев свойств';


--
-- Name: prop_info(d_prop_code, boolean); Type: FUNCTION; Schema: cfg; Owner: -
--

CREATE FUNCTION prop_info(a_code d_prop_code DEFAULT NULL::text, a_is_mask boolean DEFAULT false) RETURNS SETOF prop
    LANGUAGE plpgsql STABLE
    AS $$ /* ws:cfg:30_main.sql / 25 */ 
-- a_code: код свойства
-- a_is_mask: признак атомарности свойства
  DECLARE
    v_code TEXT;
  BEGIN
    IF a_is_mask THEN
      v_code := COALESCE(a_code, ''); -- аргумент не может быть "''", только d_prop_code или NULL
      v_code := v_code || '%';
      RETURN QUERY SELECT * FROM cfg.prop WHERE lower(code) LIKE lower(v_code);
    ELSE
      -- TODO: RAISE IF a_code IS NULL
      RETURN QUERY SELECT * FROM cfg.prop WHERE lower(code) = lower(a_code);
    END IF;
    RETURN;
  END;
$$;


--
-- Name: FUNCTION prop_info(a_code d_prop_code, a_is_mask boolean); Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON FUNCTION prop_info(a_code d_prop_code, a_is_mask boolean) IS 'Описание свойства или списка свойств';


SET search_path = wsd, pg_catalog;

--
-- Name: prop_group; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE prop_group (
    pogc text NOT NULL,
    pkg text DEFAULT ws.pg_cs() NOT NULL,
    sort integer NOT NULL,
    is_id_required boolean DEFAULT true NOT NULL,
    name text NOT NULL,
    anno text
);


--
-- Name: TABLE prop_group; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE prop_group IS 'Группа владельцев свойств';


--
-- Name: COLUMN prop_group.pogc; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN prop_group.pogc IS 'Код группы (Property Owner Group Code)';


--
-- Name: COLUMN prop_group.pkg; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN prop_group.pkg IS 'Пакет, в котором добавлена группа';


--
-- Name: COLUMN prop_group.sort; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN prop_group.sort IS 'Порядок сортировки';


--
-- Name: COLUMN prop_group.is_id_required; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN prop_group.is_id_required IS 'Загрузка без указания poid не используется';


--
-- Name: COLUMN prop_group.name; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN prop_group.name IS 'Название';


--
-- Name: COLUMN prop_group.anno; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN prop_group.anno IS 'Аннотация';


SET search_path = cfg, pg_catalog;

--
-- Name: prop_owner_attr; Type: VIEW; Schema: cfg; Owner: -
--

CREATE VIEW prop_owner_attr AS
    SELECT po.pogc, po.poid, po.pkg, po.sort, po.name, po.anno, pog.is_id_required, pog.sort AS pog_sort, pog.name AS pog_name FROM (wsd.prop_owner po JOIN wsd.prop_group pog USING (pogc)) ORDER BY pog.sort, po.sort;


--
-- Name: VIEW prop_owner_attr; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON VIEW prop_owner_attr IS 'Владельцы свойств';


--
-- Name: COLUMN prop_owner_attr.pogc; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop_owner_attr.pogc IS 'Код группы (Property Owner Group Code)';


--
-- Name: COLUMN prop_owner_attr.poid; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop_owner_attr.poid IS 'ID владельца (Property Owner ID)';


--
-- Name: COLUMN prop_owner_attr.pkg; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop_owner_attr.pkg IS 'Пакет, в котором добавлена группа';


--
-- Name: COLUMN prop_owner_attr.sort; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop_owner_attr.sort IS 'Порядок сортировки';


--
-- Name: COLUMN prop_owner_attr.name; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop_owner_attr.name IS 'Название';


--
-- Name: COLUMN prop_owner_attr.anno; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop_owner_attr.anno IS 'Аннотация';


--
-- Name: COLUMN prop_owner_attr.is_id_required; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop_owner_attr.is_id_required IS 'Загрузка без указания poid не используется';


--
-- Name: COLUMN prop_owner_attr.pog_sort; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop_owner_attr.pog_sort IS 'Порядок сортировки';


--
-- Name: COLUMN prop_owner_attr.pog_name; Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON COLUMN prop_owner_attr.pog_name IS 'Название';


--
-- Name: prop_owner_attr(text, integer); Type: FUNCTION; Schema: cfg; Owner: -
--

CREATE FUNCTION prop_owner_attr(a_pogc text DEFAULT NULL::text, a_poid integer DEFAULT 0) RETURNS SETOF prop_owner_attr
    LANGUAGE sql STABLE
    AS $_$ /* ws:cfg:50_main.sql / 25 */ 
-- a_pogc: код группы владельцев
-- a_poid: код владельца свойства
  SELECT * FROM cfg.prop_owner_attr
  WHERE COALESCE($1, pogc) = pogc
    AND $2 IN (0, poid)
$_$;


--
-- Name: FUNCTION prop_owner_attr(a_pogc text, a_poid integer); Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON FUNCTION prop_owner_attr(a_pogc text, a_poid integer) IS 'Атрибуты POID';


--
-- Name: prop_value(text, ws.d_id, d_prop_code, date); Type: FUNCTION; Schema: cfg; Owner: -
--

CREATE FUNCTION prop_value(a_pogc text, a_poid ws.d_id, a_code d_prop_code, a_date date DEFAULT ('now'::text)::date) RETURNS text
    LANGUAGE sql STABLE
    AS $_$ /* ws:cfg:30_main.sql / 51 */ 
-- a_pogc: код группы владельцев
-- a_poid: код владельца
-- a_code: код свойства
-- a_date: дата получения значения свойства
  SELECT value
    FROM wsd.prop_value
    WHERE pogc = $1 /* a_pogc */
      AND poid = $2 /* a_poid */
      AND code = $3 /* a_code */
      AND valid_from <= COALESCE($4, CURRENT_DATE) /* a_date */
      ORDER BY valid_from DESC
      LIMIT 1
$_$;


--
-- Name: FUNCTION prop_value(a_pogc text, a_poid ws.d_id, a_code d_prop_code, a_date date); Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON FUNCTION prop_value(a_pogc text, a_poid ws.d_id, a_code d_prop_code, a_date date) IS 'Значение свойства';


--
-- Name: prop_value_insupd_trigger(); Type: FUNCTION; Schema: cfg; Owner: -
--

CREATE FUNCTION prop_value_insupd_trigger() RETURNS trigger
    LANGUAGE plpgsql IMMUTABLE
    AS $$ /* ws:cfg:60_main.sql / 35 */ 
  DECLARE
    v_rows INTEGER;
  BEGIN
    SELECT INTO v_rows
      count(1)
      FROM cfg.prop
      WHERE NEW.pogc = ANY(pogc_list)
        AND NEW.code ~ ws.mask2regexp(code)
    ;
    IF v_rows = 0 THEN
      RAISE EXCEPTION 'Unknown code % in group %', NEW.code, NEW.pogc;
    ELSIF v_rows > 1 THEN
      RAISE EXCEPTION 'code % related to % props, but need only 1', NEW.code, v_rows;
    END IF;
    RETURN NEW;
  END;
$$;


--
-- Name: FUNCTION prop_value_insupd_trigger(); Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON FUNCTION prop_value_insupd_trigger() IS 'Проверка наличия свойства в таблице prop';


--
-- Name: prop_value_list(text, ws.d_id, text, boolean, date, text, text); Type: FUNCTION; Schema: cfg; Owner: -
--

CREATE FUNCTION prop_value_list(a_pogc text, a_poid ws.d_id, a_prefix text DEFAULT ''::text, a_prefix_keep boolean DEFAULT true, a_date date DEFAULT ('now'::text)::date, a_prefix_new text DEFAULT ''::text, a_mark_default text DEFAULT '%s'::text) RETURNS SETOF ws.t_hashtable
    LANGUAGE sql STABLE
    AS $_$ /* ws:cfg:30_main.sql / 77 */ 
-- a_pogc: код группы владельцев
-- a_poid: код владельца
-- a_prefix: часть кода свойства до '.'
-- a_prefix_keep:признак замены в результате a_prefix на a_prefix_new
-- a_date: дата получения значения свойства
-- a_prefix_new: добавочный префикс
-- a_mark_default: метка для не атомарного свойства
  SELECT
    $6 || CASE WHEN $3 /* a_prefix */ = '' OR $4 /* a_prefix_keep */
      THEN code
      ELSE regexp_replace (code, '^' || $3 || E'\\.', '')
    END as code
  , COALESCE(cfg.prop_value($1, $2, code, $5), ws.sprintf($7 /* a_mark_default */, def_value))
    FROM cfg.prop
    WHERE $1 = ANY(pogc_list)
      AND NOT is_mask
      AND ($3 = '' OR code LIKE $3 || '.%')
  UNION SELECT
    $6 || CASE WHEN $3 /* a_prefix */ = '' OR $4 /* a_prefix_keep */
      THEN tmp.code
      ELSE regexp_replace (tmp.code, '^' || $3 || E'\\.', '')
    END as code
  , COALESCE(tmp.value, ws.sprintf($7 /* a_mark_default */, p.def_value))
    FROM (
      SELECT code, value, row_number() over (partition by pogc, poid, code order by valid_from desc)
        FROM wsd.prop_value v
        WHERE pogc = $1 AND poid = $2 AND valid_from <= COALESCE($5, CURRENT_DATE)
      ) tmp
      , cfg.prop p
      WHERE tmp.row_number = 1 /* самая свежая по началу действия строка */
        AND ($3 = '' OR tmp.code ~ ws.mask2regexp(p.code))
        AND p.is_mask
        AND $1 = ANY(p.pogc_list)
  ORDER BY code
$_$;


--
-- Name: FUNCTION prop_value_list(a_pogc text, a_poid ws.d_id, a_prefix text, a_prefix_keep boolean, a_date date, a_prefix_new text, a_mark_default text); Type: COMMENT; Schema: cfg; Owner: -
--

COMMENT ON FUNCTION prop_value_list(a_pogc text, a_poid ws.d_id, a_prefix text, a_prefix_keep boolean, a_date date, a_prefix_new text, a_mark_default text) IS 'Значения свойств по части кода (до .)';


SET search_path = ev, pg_catalog;

--
-- Name: const_pkg(); Type: FUNCTION; Schema: ev; Owner: -
--

CREATE FUNCTION const_pkg() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ /* ev:ev:19_const.sql / 28 */ 
  SELECT 'ev'::text
$$;


--
-- Name: FUNCTION const_pkg(); Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON FUNCTION const_pkg() IS 'Кодовое имя пакета "ev"';


--
-- Name: const_status_id_archive(); Type: FUNCTION; Schema: ev; Owner: -
--

CREATE FUNCTION const_status_id_archive() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ /* ev:ev:19_const.sql / 63 */ 
  SELECT 7
$$;


--
-- Name: FUNCTION const_status_id_archive(); Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON FUNCTION const_status_id_archive() IS 'ID статуса события, не имеющего списка адресатов';


--
-- Name: const_status_id_done(); Type: FUNCTION; Schema: ev; Owner: -
--

CREATE FUNCTION const_status_id_done() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ /* ev:ev:19_const.sql / 56 */ 
  SELECT 4
$$;


--
-- Name: FUNCTION const_status_id_done(); Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON FUNCTION const_status_id_done() IS 'ID статуса события после завершения всех действий';


--
-- Name: const_status_id_draft(); Type: FUNCTION; Schema: ev; Owner: -
--

CREATE FUNCTION const_status_id_draft() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ /* ev:ev:19_const.sql / 35 */ 
  SELECT 1
$$;


--
-- Name: FUNCTION const_status_id_draft(); Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON FUNCTION const_status_id_draft() IS 'ID статуса события до готовности спецификации';


--
-- Name: const_status_id_notify(); Type: FUNCTION; Schema: ev; Owner: -
--

CREATE FUNCTION const_status_id_notify() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ /* ev:ev:19_const.sql / 49 */ 
  SELECT 3
$$;


--
-- Name: FUNCTION const_status_id_notify(); Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON FUNCTION const_status_id_notify() IS 'ID статуса события в процессе формирования уведомлений';


--
-- Name: const_status_id_rcpt(); Type: FUNCTION; Schema: ev; Owner: -
--

CREATE FUNCTION const_status_id_rcpt() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ /* ev:ev:19_const.sql / 42 */ 
  SELECT 2
$$;


--
-- Name: FUNCTION const_status_id_rcpt(); Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON FUNCTION const_status_id_rcpt() IS 'ID статуса события в процессе формирования списка адресатов';


--
-- Name: create(ws.d_id, ws.d_id32, ws.d_id, ws.d_id, ws.d_id, text, text); Type: FUNCTION; Schema: ev; Owner: -
--

CREATE FUNCTION "create"(a_kind_id ws.d_id, a_status_id ws.d_id32, a_created_by ws.d_id, a_arg_id ws.d_id DEFAULT NULL::integer, a_arg_id2 ws.d_id DEFAULT NULL::integer, a_arg_name text DEFAULT NULL::text, a_arg_name2 text DEFAULT NULL::text) RETURNS ws.d_id
    LANGUAGE plpgsql
    AS $_$ /* ev:ev:51_main.sql / 47 */ 
  DECLARE
    r ev.kind;
    v_id INTEGER;
  BEGIN
    r := ev.kind(a_kind_id);
    INSERT INTO wsd.event (
      kind_id
    , status_id
    , created_by
    , arg_id
    , arg_id2
    , arg_name
    , arg_name2
    , class_id
    ) VALUES (
      r.id
    , COALESCE($2, ev.const_status_id_draft())
    , $3
    , $4
    , $5
    , $6
    , $7
    , r.class_id
    )
    RETURNING id INTO v_id
    ;
    RETURN v_id;
  END;
$_$;


--
-- Name: FUNCTION "create"(a_kind_id ws.d_id, a_status_id ws.d_id32, a_created_by ws.d_id, a_arg_id ws.d_id, a_arg_id2 ws.d_id, a_arg_name text, a_arg_name2 text); Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON FUNCTION "create"(a_kind_id ws.d_id, a_status_id ws.d_id32, a_created_by ws.d_id, a_arg_id ws.d_id, a_arg_id2 ws.d_id, a_arg_name text, a_arg_name2 text) IS 'Создать событие';


--
-- Name: kind; Type: TABLE; Schema: ev; Owner: -
--

CREATE TABLE kind (
    id ws.d_id32 NOT NULL,
    group_id ws.d_id32 NOT NULL,
    class_id ws.d_id32 NOT NULL,
    def_prio ws.d_id32 NOT NULL,
    keep_days ws.d_id32 DEFAULT 0 NOT NULL,
    has_spec boolean DEFAULT false NOT NULL,
    pkg text DEFAULT ws.pg_cs() NOT NULL,
    signature_id ws.d_id32,
    tmpl ws.d_path NOT NULL,
    form_codes ws.d_codea NOT NULL,
    name ws.d_string NOT NULL,
    name_fmt ws.d_string,
    name_count ws.d_cnt DEFAULT 0 NOT NULL,
    spec_name ws.d_string,
    anno ws.d_text NOT NULL
);


--
-- Name: TABLE kind; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON TABLE kind IS 'Вид события';


--
-- Name: COLUMN kind.id; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN kind.id IS 'ID вида';


--
-- Name: COLUMN kind.group_id; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN kind.group_id IS 'ID группы вида';


--
-- Name: COLUMN kind.class_id; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN kind.class_id IS 'ID класса';


--
-- Name: COLUMN kind.def_prio; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN kind.def_prio IS 'Приоритет по умолчанию';


--
-- Name: COLUMN kind.keep_days; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN kind.keep_days IS 'Кол-во дней хранения уведомления о событии';


--
-- Name: COLUMN kind.has_spec; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN kind.has_spec IS 'Есть спецификация';


--
-- Name: COLUMN kind.pkg; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN kind.pkg IS 'Пакет';


--
-- Name: COLUMN kind.signature_id; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN kind.signature_id IS 'ID подписи';


--
-- Name: COLUMN kind.tmpl; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN kind.tmpl IS 'Файл шаблона';


--
-- Name: COLUMN kind.form_codes; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN kind.form_codes IS 'Массив кодов допустимых форматов';


--
-- Name: COLUMN kind.name; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN kind.name IS 'Название';


--
-- Name: COLUMN kind.name_fmt; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN kind.name_fmt IS 'Строка формата названия';


--
-- Name: COLUMN kind.name_count; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN kind.name_count IS 'Кол-во аргументов строки формата';


--
-- Name: COLUMN kind.spec_name; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN kind.spec_name IS 'Название спецификации (если она есть)';


--
-- Name: COLUMN kind.anno; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN kind.anno IS 'Аннотация';


--
-- Name: kind(ws.d_id32); Type: FUNCTION; Schema: ev; Owner: -
--

CREATE FUNCTION kind(a_id ws.d_id32) RETURNS SETOF kind
    LANGUAGE sql
    AS $_$ /* ev:ev:51_main.sql / 32 */ 
  SELECT * FROM ev.kind WHERE $1 IN (id,0);
$_$;


--
-- Name: FUNCTION kind(a_id ws.d_id32); Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON FUNCTION kind(a_id ws.d_id32) IS 'Вид события по ID';


--
-- Name: kind_class_id(ws.d_id32); Type: FUNCTION; Schema: ev; Owner: -
--

CREATE FUNCTION kind_class_id(a_id ws.d_id32) RETURNS integer
    LANGUAGE sql
    AS $_$ /* ev:ev:51_main.sql / 26 */ 
  SELECT class_id FROM ev.kind WHERE id = $1;
$_$;


--
-- Name: FUNCTION kind_class_id(a_id ws.d_id32); Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON FUNCTION kind_class_id(a_id ws.d_id32) IS 'ID класса по ID вида события';


SET search_path = fs, pg_catalog;

--
-- Name: const_file_format_any(); Type: FUNCTION; Schema: fs; Owner: -
--

CREATE FUNCTION const_file_format_any() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ /* fs:ws:19_const.sql / 12 */ 
  SELECT '*'::TEXT
$$;


--
-- Name: FUNCTION const_file_format_any(); Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON FUNCTION const_file_format_any() IS 'Файл любого формата';


--
-- Name: file_add(integer, text, integer, text, integer, text, text, integer, text, text, text); Type: FUNCTION; Schema: fs; Owner: -
--

CREATE FUNCTION file_add(a_account_id integer, a_folder_code text, a_obj_id integer, a__path text, a__size integer, a__csum text, a_name text, a_id integer DEFAULT NULL::integer, a_ctype text DEFAULT NULL::text, a_file_code text DEFAULT NULL::text, a_anno text DEFAULT NULL::text) RETURNS integer
    LANGUAGE plpgsql
    AS $$ /* fs:ws:51_main.sql / 68 */ 
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
$$;


SET search_path = wsd, pg_catalog;

--
-- Name: file_folder; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE file_folder (
    code text NOT NULL,
    class_id integer NOT NULL,
    sort integer DEFAULT 1 NOT NULL,
    has_version boolean DEFAULT false NOT NULL,
    has_file_code boolean DEFAULT false NOT NULL,
    file_code_unpack text,
    file_code_mask text,
    page_code text,
    name text NOT NULL,
    anno text,
    pkg text DEFAULT ws.pg_cs() NOT NULL
);


--
-- Name: TABLE file_folder; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE file_folder IS 'Допустимые в папке форматов файлов';


--
-- Name: COLUMN file_folder.code; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_folder.code IS 'Код папки';


--
-- Name: COLUMN file_folder.class_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_folder.class_id IS 'Класс объектов, которым принадлежат файлы';


--
-- Name: COLUMN file_folder.sort; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_folder.sort IS 'Сортировка внутри класса';


--
-- Name: COLUMN file_folder.has_version; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_folder.has_version IS 'Файлы в папке имеют версии';


--
-- Name: COLUMN file_folder.has_file_code; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_folder.has_file_code IS 'Файлы в папке различаются кодом файла';


--
-- Name: COLUMN file_folder.file_code_unpack; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_folder.file_code_unpack IS 'Функция декодирования кода файла';


--
-- Name: COLUMN file_folder.file_code_mask; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_folder.file_code_mask IS 'Маска кода файла';


--
-- Name: COLUMN file_folder.page_code; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_folder.page_code IS 'Код страницы - ссылки на файл';


--
-- Name: COLUMN file_folder.name; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_folder.name IS 'Название папки';


--
-- Name: COLUMN file_folder.anno; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_folder.anno IS 'Аннотация';


--
-- Name: COLUMN file_folder.pkg; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_folder.pkg IS 'Папкет, в котором используется папка';


SET search_path = fs, pg_catalog;

--
-- Name: file_folder(text); Type: FUNCTION; Schema: fs; Owner: -
--

CREATE FUNCTION file_folder(a_code text) RETURNS SETOF wsd.file_folder
    LANGUAGE sql STABLE
    AS $_$ /* fs:ws:51_main.sql / 32 */ 
  SELECT * FROM wsd.file_folder WHERE code = $1;
$_$;


--
-- Name: FUNCTION file_folder(a_code text); Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON FUNCTION file_folder(a_code text) IS 'Атрибуты файловой папки';


--
-- Name: file_format; Type: TABLE; Schema: fs; Owner: -
--

CREATE TABLE file_format (
    code text NOT NULL,
    sort integer DEFAULT 1 NOT NULL,
    ctype text NOT NULL,
    ext_mask text NOT NULL,
    name text NOT NULL
);


--
-- Name: TABLE file_format; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON TABLE file_format IS 'допустимые форматы файлов';


--
-- Name: COLUMN file_format.code; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_format.code IS 'Код формата';


--
-- Name: COLUMN file_format.sort; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_format.sort IS 'Сортировка при выводе нескольких форматов одного файла';


--
-- Name: COLUMN file_format.ctype; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_format.ctype IS 'Content type';


--
-- Name: COLUMN file_format.ext_mask; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_format.ext_mask IS 'Маска допустимых расширений файла';


--
-- Name: COLUMN file_format.name; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_format.name IS 'Название формата';


--
-- Name: file_format(text); Type: FUNCTION; Schema: fs; Owner: -
--

CREATE FUNCTION file_format(a_name text) RETURNS SETOF file_format
    LANGUAGE sql STABLE
    AS $_$ /* fs:ws:51_main.sql / 39 */ 
  SELECT * FROM fs.file_format
    WHERE $1 ~* (E'\\.' || ext_mask || '$')
      OR code = fs.const_file_format_any()
    ORDER BY sort LIMIT 1;
$_$;


--
-- Name: FUNCTION file_format(a_name text); Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON FUNCTION file_format(a_name text) IS 'Атрибуты формата по имени файла';


--
-- Name: file_format_code(text); Type: FUNCTION; Schema: fs; Owner: -
--

CREATE FUNCTION file_format_code(a_name text) RETURNS text
    LANGUAGE sql STABLE STRICT
    AS $_$ /* fs:ws:51_main.sql / 49 */ 
  SELECT code FROM fs.file_format WHERE $1 ~* (E'\\.' || ext_mask || '$') ORDER BY sort LIMIT 1;
$_$;


--
-- Name: FUNCTION file_format_code(a_name text); Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON FUNCTION file_format_code(a_name text) IS 'Код формата по имени файла';


--
-- Name: file_new_path_mk(text, integer, text, text); Type: FUNCTION; Schema: fs; Owner: -
--

CREATE FUNCTION file_new_path_mk(a_folder_code text, a_obj_id integer, a_name text, a_code text DEFAULT NULL::text) RETURNS ws.t_hashtable
    LANGUAGE plpgsql
    AS $$ /* fs:ws:51_main.sql / 234 */ 
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
$$;


--
-- Name: FUNCTION file_new_path_mk(a_folder_code text, a_obj_id integer, a_name text, a_code text); Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON FUNCTION file_new_path_mk(a_folder_code text, a_obj_id integer, a_name text, a_code text) IS 'ID и путь хранения для формируемого файла';


SET search_path = wsd, pg_catalog;

--
-- Name: file_id_seq; Type: SEQUENCE; Schema: wsd; Owner: -
--

CREATE SEQUENCE file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE file (
    id integer DEFAULT nextval('file_id_seq'::regclass) NOT NULL,
    path text NOT NULL,
    name text NOT NULL,
    size integer NOT NULL,
    csum text NOT NULL,
    format_code text NOT NULL,
    ctype text DEFAULT 'application/unknown'::text NOT NULL,
    link_cnt integer DEFAULT 1 NOT NULL,
    created_by integer NOT NULL,
    created_at timestamp(0) without time zone DEFAULT now() NOT NULL,
    anno text
);


--
-- Name: TABLE file; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE file IS 'Внешний файл';


--
-- Name: COLUMN file.id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file.id IS 'ID файла';


--
-- Name: COLUMN file.path; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file.path IS 'Ключ файл-сервера';


--
-- Name: COLUMN file.name; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file.name IS 'Внешнее имя файла';


--
-- Name: COLUMN file.size; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file.size IS 'Размер (байт)';


--
-- Name: COLUMN file.csum; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file.csum IS 'Контрольная сумма (sha1)';


--
-- Name: COLUMN file.format_code; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file.format_code IS 'Код формата файла';


--
-- Name: COLUMN file.ctype; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file.ctype IS 'Content type (для формата *)';


--
-- Name: COLUMN file.link_cnt; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file.link_cnt IS 'Количество связанных объектов';


--
-- Name: COLUMN file.created_by; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file.created_by IS 'Автор загрузки/генерации';


--
-- Name: COLUMN file.created_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file.created_at IS 'Момент загрузки/генерации';


--
-- Name: COLUMN file.anno; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file.anno IS 'Комментарий';


SET search_path = fs, pg_catalog;

--
-- Name: file_store; Type: VIEW; Schema: fs; Owner: -
--

CREATE VIEW file_store AS
    SELECT f.id, f.path, f.size, f.csum, f.name, f.created_at, f.ctype FROM wsd.file f;


--
-- Name: file_store(integer); Type: FUNCTION; Schema: fs; Owner: -
--

CREATE FUNCTION file_store(a_id integer) RETURNS SETOF file_store
    LANGUAGE sql STABLE
    AS $_$ /* fs:ws:51_main.sql / 25 */ 
  SELECT * FROM fs.file_store WHERE id = $1;
$_$;


--
-- Name: FUNCTION file_store(a_id integer); Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON FUNCTION file_store(a_id integer) IS 'Атрибуты хранения файла';


SET search_path = i18n_def, pg_catalog;

--
-- Name: amount2words(numeric, integer); Type: FUNCTION; Schema: i18n_def; Owner: -
--

CREATE FUNCTION amount2words(source numeric, up_mode integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$ /* ws:ws:51_i18n.sql / 74 */ 
/*
  Сумма прописью в рублях и копейках
  up_mode = 0 - все символы строчные
          = 1 - Первый символ строки - прописной

  Оригинальное название: number2word
  Источник: http://oraclub.trecom.tomsk.su/db/web.page?pid=461
  В конференцию relcom.comp.dbms.oracle поместил "Igor Volkov" (volkov@rdtex.msk.ru)
*/
DECLARE
  result TEXT;
BEGIN
  -- k - копейки
  result := ltrim(to_char( source,
    '9,9,,9,,,,,,9,9,,9,,,,,9,9,,9,,,,9,9,,9,,,.99')) || 'k';
  -- t - тысячи; m - милионы; M - миллиарды;
  result := replace( result, ',,,,,,', 'eM');
  result := replace( result, ',,,,,', 'em');
  result := replace( result, ',,,,', 'et');
  -- e - единицы; d - десятки; c - сотни;
  result := replace( result, ',,,', 'e');
  result := replace( result, ',,', 'd');
  result := replace( result, ',', 'c');
  --
  result := replace( result, '0c0d0et', '');
  result := replace( result, '0c0d0em', '');
  result := replace( result, '0c0d0eM', '');
  --
  result := replace( result, '0c', '');
  result := replace( result, '1c', 'сто' || ' ');
  result := replace( result, '2c', 'двести' || '  ');
  result := replace( result, '3c', 'триста' || '  ');
  result := replace( result, '4c', 'четыреста' || '  ');
  result := replace( result, '5c', 'пятьсот' || '  ');
  result := replace( result, '6c', 'шестьсот' || '  ');
  result := replace( result, '7c', 'семьсот' || '  ');
  result := replace( result, '8c', 'восемьсот' || '  ');
  result := replace( result, '9c', 'девятьсот' || '  ');
  --
  result := replace( result, '1d0e', 'десять' || '  ');
  result := replace( result, '1d1e', 'одиннадцать' || '  ');
  result := replace( result, '1d2e', 'двенадцать' || '  ');
  result := replace( result, '1d3e', 'тринадцать' || '  ');
  result := replace( result, '1d4e', 'четырнадцать' || '  ');
  result := replace( result, '1d5e', 'пятнадцать' || '  ');
  result := replace( result, '1d6e', 'шестнадцать' || '  ');
  result := replace( result, '1d7e', 'семнадцать' || '  ');
  result := replace( result, '1d8e', 'восемнадцать' || '  ');
  result := replace( result, '1d9e', 'девятнадцать' || '  ');
  --
  result := replace( result, '0d', '');
  result := replace( result, '2d', 'двадцать' || '  ');
  result := replace( result, '3d', 'тридцать' || '  ');
  result := replace( result, '4d', 'сорок' || '  ');
  result := replace( result, '5d', 'пятьдесят' || '  ');
  result := replace( result, '6d', 'шестьдесят' || '  ');
  result := replace( result, '7d', 'семьдесят' || '  ');
  result := replace( result, '8d', 'восемьдесят' || '  ');
  result := replace( result, '9d', 'девяносто' || '  ');
  --
  result := replace( result, '0e', '');
  result := replace( result, '5e', 'пять' || '  ');
  result := replace( result, '6e', 'шесть' || '  ');
  result := replace( result, '7e', 'семь' || '  ');
  result := replace( result, '8e', 'восемь' || '  ');
  result := replace( result, '9e', 'девять' || '  ');
  --
  result := replace( result, '1e.', 'один рубль' || '  ');
  result := replace( result, '2e.', 'два рубля' || '  ');
  result := replace( result, '3e.', 'три рубля' || '  ');
  result := replace( result, '4e.', 'четыре рубля' || '  ');
  result := replace( result, '1et', 'одна тысяча' || '  ');
  result := replace( result, '2et', 'две тысячи' || '  ');
  result := replace( result, '3et', 'три тысячи' || '  ');
  result := replace( result, '4et', 'четыре тысячи' || '  ');
  result := replace( result, '1em', 'один миллион' || '  ');
  result := replace( result, '2em', 'два миллиона' || '  ');
  result := replace( result, '3em', 'три миллиона' || '  ');
  result := replace( result, '4em', 'четыре миллиона' || '  ');
  result := replace( result, '1eM', 'один миллиард' || '  ');
  result := replace( result, '2eM', 'два миллиарда' || '  ');
  result := replace( result, '3eM', 'три миллиарда' || '  ');
  result := replace( result, '4eM', 'четыре миллиарда' || '  ');
  --

  --  блок для написания копеек без сокращения 'коп'
  result := replace( result, '11k', '11 копеек');
  result := replace( result, '12k', '12 копеек');
  result := replace( result, '13k', '13 копеек');
  result := replace( result, '14k', '14 копеек');
  result := replace( result, '1k', '1 копейка');
  result := replace( result, '2k', '2 копейки');
  result := replace( result, '3k', '3 копейки');
  result := replace( result, '4k', '4 копейки');
  result := replace( result, 'k', ' ' || 'копеек');
  --
  result := replace( result, '.', 'рублей' || '  ');
  result := replace( result, 't', 'тысяч' || '  ');
  result := replace( result, 'm', 'миллионов' || '  ');
  result := replace( result, 'M', 'миллиардов' || '  ');

  -- сокращенные коп
  -- result := replace( result, 'k', ' ' || 'коп');
  --
  IF up_mode = 1 THEN
    result := upper(substr(result, 1, 1)) || substr(result, 2);
  END IF;
  RETURN result;
END
$$;


--
-- Name: FUNCTION amount2words(source numeric, up_mode integer); Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON FUNCTION amount2words(source numeric, up_mode integer) IS 'Сумма прописью в рублях и копейках';


--
-- Name: date_name(date); Type: FUNCTION; Schema: i18n_def; Owner: -
--

CREATE FUNCTION date_name(a_date date) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$ /* ws:ws:51_i18n.sql / 25 */ 
  DECLARE
    m_names TEXT := 'января февраля марта апреля мая июня июля августа сентября октября ноября декабря';
  BEGIN
    RETURN date_part('day', a_date)
          ||' '||split_part(m_names, ' '::text, date_part('month', a_date)::int)
          ||' '||date_part('year', a_date)
    ;
  END
$$;


--
-- Name: FUNCTION date_name(a_date date); Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON FUNCTION date_name(a_date date) IS 'Название даты вида "1 января 2007"';


--
-- Name: date_name_doc(date); Type: FUNCTION; Schema: i18n_def; Owner: -
--

CREATE FUNCTION date_name_doc(a_date date) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$ /* ws:ws:51_i18n.sql / 39 */ 
  SELECT CASE WHEN date_part('day', $1) < 10 THEN '0' ELSE '' END || date_name($1)
$_$;


--
-- Name: FUNCTION date_name_doc(a_date date); Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON FUNCTION date_name_doc(a_date date) IS 'Название даты вида "01 января 2007"';


--
-- Name: month_amount_name(integer); Type: FUNCTION; Schema: i18n_def; Owner: -
--

CREATE FUNCTION month_amount_name(a_id integer) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$ /* ws:ws:51_i18n.sql / 59 */ 
  SELECT CASE
    WHEN $1 % 10 = 1 AND $1 <> 11 THEN $1::text || ' ' || 'месяц'
    WHEN $1 IN (24,36,48) THEN $1/12 || ' ' || 'года'
    WHEN $1 = 12     THEN '1 год'
    WHEN $1 % 12 = 0 THEN $1/12 || ' ' || 'лет'
    WHEN $1 % 10 BETWEEN 1 AND 4 AND $1 NOT BETWEEN 11 AND 14 THEN $1::text || ' ' || 'месяца'
    ELSE $1::text || ' ' || 'месяцев'
  END
;
$_$;


--
-- Name: FUNCTION month_amount_name(a_id integer); Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON FUNCTION month_amount_name(a_id integer) IS 'Название периода из заданного числа месяцев (252 max)';


--
-- Name: month_name(date); Type: FUNCTION; Schema: i18n_def; Owner: -
--

CREATE FUNCTION month_name(a_date date) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$ /* ws:ws:51_i18n.sql / 46 */ 
  DECLARE
    m_names TEXT := 'январь февраль март апрель май июнь июль август сентябрь октябрь ноябрь декабрь';
  BEGIN
    RETURN split_part(m_names, ' '::text, date_part('month', a_date)::int)
          ||' '||date_part('year', a_date)
    ;
  END
$$;


--
-- Name: FUNCTION month_name(a_date date); Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON FUNCTION month_name(a_date date) IS 'Название месяца вида "январь 2007"';


SET search_path = i18n_en, pg_catalog;

--
-- Name: amount2words(numeric, integer); Type: FUNCTION; Schema: i18n_en; Owner: -
--

CREATE FUNCTION amount2words(source numeric, up_mode integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$ /* ws:ws:51_i18n.sql / 60 */ 
/*
  Сумма прописью в рублях и копейках
  up_mode = 0 - все символы строчные
          = 1 - Первый символ строки - прописной

  Оригинальное название: number2word
  Источник: http://oraclub.trecom.tomsk.su/db/web.page?pid=461
  В конференцию relcom.comp.dbms.oracle поместил "Igor Volkov" (volkov@rdtex.msk.ru)
*/
DECLARE
  result TEXT;
BEGIN
  -- k - копейки
  result := ltrim(to_char( source,
    '9,9,,9,,,,,,9,9,,9,,,,,9,9,,9,,,,9,9,,9,,,.99')) || 'k';
  -- t - тысячи; m - милионы; M - миллиарды;
  result := replace( result, ',,,,,,', 'eM');
  result := replace( result, ',,,,,', 'em');
  result := replace( result, ',,,,', 'et');
  -- e - единицы; d - десятки; c - сотни;
  result := replace( result, ',,,', 'e');
  result := replace( result, ',,', 'd');
  result := replace( result, ',', 'c');
  --
  result := replace( result, '0c0d0et', '');
  result := replace( result, '0c0d0em', '');
  result := replace( result, '0c0d0eM', '');
  --
  result := replace( result, '0c', '');
  result := replace( result, '1c', 'сто' || ' ');
  result := replace( result, '2c', 'двести' || '  ');
  result := replace( result, '3c', 'триста' || '  ');
  result := replace( result, '4c', 'четыреста' || '  ');
  result := replace( result, '5c', 'пятьсот' || '  ');
  result := replace( result, '6c', 'шестьсот' || '  ');
  result := replace( result, '7c', 'семьсот' || '  ');
  result := replace( result, '8c', 'восемьсот' || '  ');
  result := replace( result, '9c', 'девятьсот' || '  ');
  --
  result := replace( result, '1d0e', 'десять' || '  ');
  result := replace( result, '1d1e', 'одиннадцать' || '  ');
  result := replace( result, '1d2e', 'двенадцать' || '  ');
  result := replace( result, '1d3e', 'тринадцать' || '  ');
  result := replace( result, '1d4e', 'четырнадцать' || '  ');
  result := replace( result, '1d5e', 'пятнадцать' || '  ');
  result := replace( result, '1d6e', 'шестнадцать' || '  ');
  result := replace( result, '1d7e', 'семнадцать' || '  ');
  result := replace( result, '1d8e', 'восемнадцать' || '  ');
  result := replace( result, '1d9e', 'девятнадцать' || '  ');
  --
  result := replace( result, '0d', '');
  result := replace( result, '2d', 'двадцать' || '  ');
  result := replace( result, '3d', 'тридцать' || '  ');
  result := replace( result, '4d', 'сорок' || '  ');
  result := replace( result, '5d', 'пятьдесят' || '  ');
  result := replace( result, '6d', 'шестьдесят' || '  ');
  result := replace( result, '7d', 'семьдесят' || '  ');
  result := replace( result, '8d', 'восемьдесят' || '  ');
  result := replace( result, '9d', 'девяносто' || '  ');
  --
  result := replace( result, '0e', '');
  result := replace( result, '5e', 'пять' || '  ');
  result := replace( result, '6e', 'шесть' || '  ');
  result := replace( result, '7e', 'семь' || '  ');
  result := replace( result, '8e', 'восемь' || '  ');
  result := replace( result, '9e', 'девять' || '  ');
  --
  result := replace( result, '1e.', 'один рубль' || '  ');
  result := replace( result, '2e.', 'два рубля' || '  ');
  result := replace( result, '3e.', 'три рубля' || '  ');
  result := replace( result, '4e.', 'четыре рубля' || '  ');
  result := replace( result, '1et', 'одна тысяча' || '  ');
  result := replace( result, '2et', 'две тысячи' || '  ');
  result := replace( result, '3et', 'три тысячи' || '  ');
  result := replace( result, '4et', 'четыре тысячи' || '  ');
  result := replace( result, '1em', 'один миллион' || '  ');
  result := replace( result, '2em', 'два миллиона' || '  ');
  result := replace( result, '3em', 'три миллиона' || '  ');
  result := replace( result, '4em', 'четыре миллиона' || '  ');
  result := replace( result, '1eM', 'один миллиард' || '  ');
  result := replace( result, '2eM', 'два миллиарда' || '  ');
  result := replace( result, '3eM', 'три миллиарда' || '  ');
  result := replace( result, '4eM', 'четыре миллиарда' || '  ');
  --

  --  блок для написания копеек без сокращения 'коп'
  result := replace( result, '11k', '11 копеек');
  result := replace( result, '12k', '12 копеек');
  result := replace( result, '13k', '13 копеек');
  result := replace( result, '14k', '14 копеек');
  result := replace( result, '1k', '1 копейка');
  result := replace( result, '2k', '2 копейки');
  result := replace( result, '3k', '3 копейки');
  result := replace( result, '4k', '4 копейки');
  result := replace( result, 'k', ' ' || 'копеек');
  --
  result := replace( result, '.', 'рублей' || '  ');
  result := replace( result, 't', 'тысяч' || '  ');
  result := replace( result, 'm', 'миллионов' || '  ');
  result := replace( result, 'M', 'миллиардов' || '  ');

  -- сокращенные коп
  -- result := replace( result, 'k', ' ' || 'коп');
  --
  IF up_mode = 1 THEN
    result := upper(substr(result, 1, 1)) || substr(result, 2);
  END IF;
  RETURN result;
END
$$;


--
-- Name: FUNCTION amount2words(source numeric, up_mode integer); Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON FUNCTION amount2words(source numeric, up_mode integer) IS 'Сумма прописью в рублях и копейках';


--
-- Name: date_name(date); Type: FUNCTION; Schema: i18n_en; Owner: -
--

CREATE FUNCTION date_name(a_date date) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$ /* ws:ws:51_i18n.sql / 11 */ 
  DECLARE
    m_names TEXT := 'january february march april may june july august september october november december';
  BEGIN
    RETURN date_part('day', a_date)
          ||' '||split_part(m_names, ' '::text, date_part('month', a_date)::int)
          ||' '||date_part('year', a_date)
    ;
  END
$$;


--
-- Name: FUNCTION date_name(a_date date); Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON FUNCTION date_name(a_date date) IS 'Название даты вида "1 января 2007"';


--
-- Name: date_name_doc(date); Type: FUNCTION; Schema: i18n_en; Owner: -
--

CREATE FUNCTION date_name_doc(a_date date) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$  /* i18n:i18n_en:20_dump.sql / 205 */ /* ws:ws:51_i18n.sql / 25 */ 
  SELECT CASE WHEN date_part('day', $1) < 10 THEN '0' ELSE '' END || date_name($1)
$_$;


--
-- Name: FUNCTION date_name_doc(a_date date); Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON FUNCTION date_name_doc(a_date date) IS 'Название даты вида "01 января 2007"';


--
-- Name: month_amount_name(integer); Type: FUNCTION; Schema: i18n_en; Owner: -
--

CREATE FUNCTION month_amount_name(a_id integer) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$  /* i18n:i18n_en:20_dump.sql / 223 */ /* ws:ws:51_i18n.sql / 45 */ 
  SELECT CASE
    WHEN $1 % 10 = 1 AND $1 <> 11 THEN $1::text || ' ' || 'месяц'
    WHEN $1 IN (24,36,48) THEN $1/12 || ' ' || 'года'
    WHEN $1 = 12     THEN '1 год'
    WHEN $1 % 12 = 0 THEN $1/12 || ' ' || 'лет'
    WHEN $1 % 10 BETWEEN 1 AND 4 AND $1 NOT BETWEEN 11 AND 14 THEN $1::text || ' ' || 'месяца'
    ELSE $1::text || ' ' || 'месяцев'
  END
;
$_$;


--
-- Name: FUNCTION month_amount_name(a_id integer); Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON FUNCTION month_amount_name(a_id integer) IS 'Название периода из заданного числа месяцев (252 max)';


--
-- Name: month_name(date); Type: FUNCTION; Schema: i18n_en; Owner: -
--

CREATE FUNCTION month_name(a_date date) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$ /* ws:ws:51_i18n.sql / 32 */ 
  DECLARE
    m_names TEXT := 'january february march april may june july august september october november december';
  BEGIN
    RETURN split_part(m_names, ' '::text, date_part('month', a_date)::int)
          ||' '||date_part('year', a_date)
    ;
  END
$$;


--
-- Name: FUNCTION month_name(a_date date); Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON FUNCTION month_name(a_date date) IS 'Название месяца вида "январь 2007"';


SET search_path = job, pg_catalog;

--
-- Name: clean(integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION clean(a_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$ /* job:job:52_handlers.sql / 55 */ 
  -- handler_core_clean - Очистка wsd.job от выполненных задач
  -- a_id: ID задачи
  DECLARE
    r           wsd.job%ROWTYPE;
  BEGIN
    r := job.current(a_id);
    -- В журнал если выполнено и handler.dust_days = 0
    INSERT INTO wsd.job_past SELECT * FROM job.current2past(r.arg_date);

    -- Оседание пыли (Удаляем устаревшее)
    DELETE FROM wsd.job_dust WHERE r.arg_date - validfrom::date > job.handler_dust_days(handler_id);

    -- В архив если выполнено
    INSERT INTO wsd.job_dust SELECT * FROM job.current2dust(r.arg_date);

    RETURN job.const_status_id_success();
  END
$$;


--
-- Name: const_arg_type_none(); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION const_arg_type_none() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ /* job:job:19_const.sql / 105 */ 
  SELECT 1
$$;


--
-- Name: FUNCTION const_arg_type_none(); Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON FUNCTION const_arg_type_none() IS 'ID типа неиспользуемого аргумента';


--
-- Name: const_pkg(); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION const_pkg() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ /* job:job:19_const.sql / 28 */ 
  SELECT 'job'::text
$$;


--
-- Name: FUNCTION const_pkg(); Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON FUNCTION const_pkg() IS 'Кодовое имя пакета "job"';


--
-- Name: const_status_id_again(); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION const_status_id_again() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ /* job:job:19_const.sql / 42 */ 
  SELECT 3
$$;


--
-- Name: FUNCTION const_status_id_again(); Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON FUNCTION const_status_id_again() IS 'ID статуса задач, готовой к выполнению после ожидания';


--
-- Name: const_status_id_error(); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION const_status_id_error() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ /* job:job:19_const.sql / 84 */ 
  SELECT 12
$$;


--
-- Name: FUNCTION const_status_id_error(); Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON FUNCTION const_status_id_error() IS 'ID статуса задач, выполнение которых вызвало ошибку';


--
-- Name: const_status_id_forced(); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION const_status_id_forced() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ /* job:job:19_const.sql / 63 */ 
  SELECT 7
$$;


--
-- Name: FUNCTION const_status_id_forced(); Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON FUNCTION const_status_id_forced() IS 'ID статуса задач, выполняемой индивидуальным сервером';


--
-- Name: const_status_id_idle(); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION const_status_id_idle() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ /* job:job:19_const.sql / 98 */ 
  SELECT 13
$$;


--
-- Name: FUNCTION const_status_id_idle(); Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON FUNCTION const_status_id_idle() IS 'ID статуса задач, выполненных вхолостую';


--
-- Name: const_status_id_locked(); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION const_status_id_locked() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ /* job:job:19_const.sql / 70 */ 
  SELECT 8
$$;


--
-- Name: FUNCTION const_status_id_locked(); Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON FUNCTION const_status_id_locked() IS 'ID статуса задач, выполнение которых заблокировано';


--
-- Name: const_status_id_process(); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION const_status_id_process() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ /* job:job:19_const.sql / 49 */ 
  SELECT 4
$$;


--
-- Name: FUNCTION const_status_id_process(); Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON FUNCTION const_status_id_process() IS 'ID статуса задач в процессе выполнения';


--
-- Name: const_status_id_ready(); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION const_status_id_ready() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ /* job:job:19_const.sql / 35 */ 
  SELECT 2
$$;


--
-- Name: FUNCTION const_status_id_ready(); Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON FUNCTION const_status_id_ready() IS 'ID статуса задач, готовой к выполнению';


--
-- Name: const_status_id_success(); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION const_status_id_success() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ /* job:job:19_const.sql / 91 */ 
  SELECT 10
$$;


--
-- Name: FUNCTION const_status_id_success(); Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON FUNCTION const_status_id_success() IS 'ID статуса задач, выполненных успешно';


--
-- Name: const_status_id_urgent(); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION const_status_id_urgent() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ /* job:job:19_const.sql / 77 */ 
  SELECT 9
$$;


--
-- Name: FUNCTION const_status_id_urgent(); Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON FUNCTION const_status_id_urgent() IS 'ID статуса задач, выполняемой вне очереди';


--
-- Name: const_status_id_waiting(); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION const_status_id_waiting() RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ /* job:job:19_const.sql / 56 */ 
  SELECT 5
$$;


--
-- Name: FUNCTION const_status_id_waiting(); Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON FUNCTION const_status_id_waiting() IS 'ID статуса задач, ожидающих завершения приоритетных';


--
-- Name: create(integer, integer, integer, date, integer, numeric, text, date, integer, integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION "create"(a_handler_id integer, a_status_id integer, a_parent integer, a_date date, a_id integer DEFAULT NULL::integer, a_num numeric DEFAULT NULL::numeric, a_more text DEFAULT NULL::text, a_date2 date DEFAULT NULL::date, a_id2 integer DEFAULT NULL::integer, a_id3 integer DEFAULT NULL::integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$ /* job:job:51_main.sql / 153 */ 
  DECLARE
    v_date   DATE;
    r_handler job.handler%ROWTYPE;
  BEGIN
    v_date := COALESCE(a_date, CURRENT_DATE); -- если дата не указана - текущая
    r_handler := job.handler(a_handler_id);
    RETURN job.create_at(
      v_date + (r_handler.def_prio::TEXT || ' sec')::INTERVAL
    , a_handler_id
    , a_status_id
    , a_parent
    , v_date
    , a_id
    , a_num
    , a_more
    , a_date2
    , a_id2
    , a_id3
    );
  END
$$;


--
-- Name: create_at(timestamp without time zone, integer, integer, integer, date, integer, numeric, text, date, integer, integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION create_at(a_validfrom timestamp without time zone, a_handler_id integer, a_status_id integer, a_parent integer, a_date date, a_id integer DEFAULT NULL::integer, a_num numeric DEFAULT NULL::numeric, a_more text DEFAULT NULL::text, a_date2 date DEFAULT NULL::date, a_id2 integer DEFAULT NULL::integer, a_id3 integer DEFAULT NULL::integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$ /* job:job:51_main.sql / 69 */ 
/*
  Создать задачу
  Вызов:
    job_id := job.create_at(handler_id, a_status, a_parent, a_date)
  Возвращаемое значение:
    id новой задачи, если у класса нет требования уникальности или задача с такими аргументами еще не зарегистрирована.
    Иначе - id зарегистрированной ранее задачи (с минусом, если она уже выполнена)
  TODO: проконтролировать соответствие аргументов описанию класса
  TODO: для status=11 exit_at=created_at=run_at
*/
  DECLARE
    v_status_id INTEGER;
    v_id        INTEGER;
    r_handler     job.handler%ROWTYPE;
    r           job.stored%ROWTYPE;
  BEGIN
    r_handler := job.handler(a_handler_id);
    IF r_handler IS NULL THEN
      RAISE EXCEPTION 'Unknown handler_id (%)',a_handler_id;
    END IF;
    IF r_handler.is_run_allowed THEN
      v_status_id := COALESCE(a_status_id, r_handler.def_status_id);
      IF NOT job.status_can_create(v_status_id) THEN
        RAISE EXCEPTION 'Incorrect initial status (%) for pkg.handler (%.%)', v_status_id, r_handler.pkg, r_handler.code;
      END IF;
    ELSE
      v_status_id := job.const_status_id_locked();
    END IF;

    IF r_handler.uk_bits > 0 THEN
      SELECT INTO r
        *
        FROM job.stored
        WHERE handler_id = a_handler_id
          AND status_id <> job.const_status_id_error()
          AND (r_handler.uk_bits &  1 = 0 OR arg_date   IS NOT DISTINCT FROM a_date)
          AND (r_handler.uk_bits &  2 = 0 OR arg_id     IS NOT DISTINCT FROM a_id)
          AND (r_handler.uk_bits &  4 = 0 OR arg_num    IS NOT DISTINCT FROM a_num)
          AND (r_handler.uk_bits &  8 = 0 OR arg_more   IS NOT DISTINCT FROM a_more)
          AND (r_handler.uk_bits & 16 = 0 OR arg_date2  IS NOT DISTINCT FROM a_date2)
          AND (r_handler.uk_bits & 32 = 0 OR arg_id2    IS NOT DISTINCT FROM a_id2)
          AND (r_handler.uk_bits & 64 = 0 OR arg_id3    IS NOT DISTINCT FROM a_id3)
      ;
      IF FOUND THEN
        -- оставляем как есть
        RETURN -r.id;
      END IF;
    END IF;
    -- TODO: проверка наличия всех ненулевых arg_*_type

    v_id := NEXTVAL('wsd.job_seq');

    IF a_validfrom::date > CURRENT_DATE AND r_handler.is_todo_allowed THEN
      INSERT INTO wsd.job_todo
        (id, status_id, prio, handler_id, created_by, validfrom, arg_date, arg_id, arg_num, arg_more, arg_date2, arg_id2, arg_id3)
        VALUES
        (v_id, v_status_id, r_handler.def_prio, a_handler_id, a_parent, a_validfrom, a_date, a_id, a_num, a_more, a_date2, a_id2, a_id3)
      ;
    ELSE
      INSERT INTO wsd.job
        (id, status_id, prio, handler_id, created_by, validfrom, arg_date, arg_id, arg_num, arg_more, arg_date2, arg_id2, arg_id3)
        VALUES
        (v_id, v_status_id, r_handler.def_prio, a_handler_id, a_parent, a_validfrom, a_date, a_id, a_num, a_more, a_date2, a_id2, a_id3)
      ;
    END IF;
    RETURN v_id;
  END
$$;


--
-- Name: create_now(integer, integer, integer, date, integer, numeric, text, date, integer, integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION create_now(a_handler_id integer, a_status_id integer, a_parent integer, a_date date DEFAULT NULL::date, a_id integer DEFAULT NULL::integer, a_num numeric DEFAULT NULL::numeric, a_more text DEFAULT NULL::text, a_date2 date DEFAULT NULL::date, a_id2 integer DEFAULT NULL::integer, a_id3 integer DEFAULT NULL::integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$ /* job:job:51_main.sql / 190 */ 
  DECLARE
    v_date   DATE;
 BEGIN
    v_date := COALESCE(a_date, CURRENT_DATE); -- если дата не указана или NULL - используем текущую дату
    RETURN job.create_at(now()::timestamp - '1 sec'::interval, a_handler_id, a_status_id, a_parent, v_date, a_id, a_num, a_more, a_date2, a_id2, a_id3);
  END
$$;


--
-- Name: cron(); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION cron() RETURNS void
    LANGUAGE sql
    AS $$ /* job:job:51_main.sql / 453 */ 
  UPDATE wsd.job_cron SET
    prev_at = run_at
  , run_at = CURRENT_TIMESTAMP
    WHERE is_active
  ;
$$;


SET search_path = wsd, pg_catalog;

--
-- Name: job_seq; Type: SEQUENCE; Schema: wsd; Owner: -
--

CREATE SEQUENCE job_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE job (
    id integer DEFAULT nextval('job_seq'::regclass) NOT NULL,
    validfrom timestamp(0) without time zone NOT NULL,
    prio integer NOT NULL,
    handler_id integer NOT NULL,
    status_id integer NOT NULL,
    created_by integer,
    waiting_for integer,
    arg_id integer,
    arg_date date,
    arg_num numeric,
    arg_more text,
    arg_id2 integer,
    arg_date2 date,
    arg_id3 integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    run_pid integer,
    run_ip inet,
    run_at timestamp without time zone,
    exit_at timestamp without time zone
);


--
-- Name: TABLE job; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE job IS 'Задачи текущего дня';


--
-- Name: COLUMN job.id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job.id IS 'ID задачи';


--
-- Name: COLUMN job.validfrom; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job.validfrom IS 'дата активации';


--
-- Name: COLUMN job.prio; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job.prio IS 'фактический приоритет';


--
-- Name: COLUMN job.handler_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job.handler_id IS 'ID обработчика';


--
-- Name: COLUMN job.status_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job.status_id IS 'текущий статус';


--
-- Name: COLUMN job.created_by; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job.created_by IS 'id задачи/сессии, создавшей';


--
-- Name: COLUMN job.waiting_for; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job.waiting_for IS 'id задачи, которую ждем';


--
-- Name: COLUMN job.arg_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job.arg_id IS 'аргумент id';


--
-- Name: COLUMN job.arg_date; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job.arg_date IS 'аргумент date';


--
-- Name: COLUMN job.arg_num; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job.arg_num IS 'аргумент num';


--
-- Name: COLUMN job.arg_more; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job.arg_more IS 'аргумент more';


--
-- Name: COLUMN job.arg_id2; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job.arg_id2 IS 'аргумент id2';


--
-- Name: COLUMN job.arg_date2; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job.arg_date2 IS 'аргумент date2';


--
-- Name: COLUMN job.arg_id3; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job.arg_id3 IS 'аргумент id3';


--
-- Name: COLUMN job.created_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job.created_at IS 'время создания';


--
-- Name: COLUMN job.run_pid; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job.run_pid IS 'pid выполняющего процесса';


--
-- Name: COLUMN job.run_ip; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job.run_ip IS 'ip хоста выполняющего процесса';


--
-- Name: COLUMN job.run_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job.run_at IS 'время начала выполнения';


--
-- Name: COLUMN job.exit_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job.exit_at IS 'время завершения выполнения';


SET search_path = job, pg_catalog;

--
-- Name: current(integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION current(a_id integer) RETURNS wsd.job
    LANGUAGE sql STABLE
    AS $_$ /* job:job:30_misc.sql / 110 */ 
  SELECT * FROM wsd.job WHERE id = $1;
$_$;


--
-- Name: current2dust(date); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION current2dust(date) RETURNS SETOF wsd.job
    LANGUAGE sql
    AS $_$  /* job:job:51_main.sql / 37 */ -- current2dust - Удаление и возврат из wsd.job завершенных задач для помещения в wsd.job_dust, валидных до наступления заданной даты
-- вызывается после current2past, поэтому строк с arc_days = 0 уже нет
  DELETE FROM wsd.job USING job.status s -- , job.handler c
    WHERE status_id = s.id AND s.can_arc
      -- AND handler_id = c.id AND c.arc_days > 0
      AND validfrom < ($1 + 1)::timestamp
  RETURNING wsd.job.*
$_$;


--
-- Name: current2past(date); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION current2past(date) RETURNS SETOF wsd.job
    LANGUAGE sql
    AS $_$  /* job:job:51_main.sql / 25 */ -- current2past - Удаление и возврат из wsd.job завершенных задач для помещения в wsd.job_past, валидных до наступления заданной даты
-- Вызов:
--   INSERT INTO wsd.job_past SELECT * FROM job.current2past(r_t.arg_date);
  DELETE FROM wsd.job USING job.status s, job.handler c
    WHERE status_id = s.id AND s.can_arc
      AND handler_id = c.id AND c.dust_days = 0
      AND validfrom < ($1 + 1)::timestamp
  RETURNING wsd.job.*
$_$;


--
-- Name: finish(integer, integer, text); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION finish(a_id integer, a_status_id integer, a_exit_text text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$ /* job:job:51_main.sql / 337 */ 
/*
  Регистрация завершения выполнения задачи с указанным кодом. Если задача была активна - меняется статус ожидающих задач.
  Если задана текстовая информация - она сохраняется в отдельной таблице job.error
  Вызов:
    SELECT job.task_end(a_id, status_id, error_text)
  Возвращаемое значение:
    true, если указанная задача была активна

  TODO: реализовать вариант "отказ выполнения", который будет возвращать server() для не-sql задач
   (или сделать фильтрацию по классу задач)
*/
  DECLARE
    v_found BOOL;
    r           wsd.job%ROWTYPE;
  BEGIN

    IF a_status_id = job.const_status_id_waiting() THEN
      -- задача уже переведена в режим ожидания
      -- проверить, что та, которую ждем, еще не выполнилась
      SELECT INTO r * FROM wsd.job
        WHERE status_id = job.const_status_id_waiting()
          AND id = a_id
        FOR UPDATE
      ;
      IF FOUND THEN
        r := job.current(r.waiting_for);
        IF NOT job.status_can_run(r.status_id) THEN
          UPDATE wsd.job SET
            status_id = job.const_status_id_again()
            WHERE id = a_id
          ;
        END IF;
      END IF;
      RETURN FALSE;
    END IF;

    -- Сохраним новый статус
    UPDATE wsd.job SET
      status_id = a_status_id,
      exit_at = clock_timestamp()
      WHERE id = a_id
        AND status_id = job.const_status_id_process() -- статус меняем только у выполняющихся задач
    ;
    v_found := FOUND;
    -- Сохраним описание ошибки отдельно
    IF a_exit_text IS NOT NULL THEN
      INSERT INTO job.srv_error (job_id, status_id, exit_text)
        VALUES (a_id, a_status_id, a_exit_text)
      ;
    END IF;
    RETURN v_found;
  END
$$;


--
-- Name: finished(integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION finished(a_id integer) RETURNS void
    LANGUAGE sql
    AS $_$ /* job:job:51_main.sql / 394 */ 
  -- finished - Изменить статус ожидающим задачам
  UPDATE wsd.job SET
    status_id = job.const_status_id_again()
    WHERE waiting_for = $1 /* a_id */
      AND status_id = job.const_status_id_waiting()
  ;
$_$;


--
-- Name: handler; Type: TABLE; Schema: job; Owner: -
--

CREATE TABLE handler (
    id ws.d_id32 NOT NULL,
    pkg ws.d_string DEFAULT ws.pg_cs() NOT NULL,
    code ws.d_code NOT NULL,
    def_prio ws.d_id NOT NULL,
    def_status_id ws.d_id32 DEFAULT const_status_id_ready() NOT NULL,
    uk_bits ws.d_bitmask DEFAULT 0 NOT NULL,
    is_sql boolean DEFAULT true NOT NULL,
    next_handler_id ws.d_id32,
    arg_date_type ws.d_id32 DEFAULT const_arg_type_none() NOT NULL,
    arg_id_type ws.d_id32 DEFAULT const_arg_type_none() NOT NULL,
    arg_num_type ws.d_id32 DEFAULT const_arg_type_none() NOT NULL,
    arg_more_type ws.d_id32 DEFAULT const_arg_type_none() NOT NULL,
    arg_date2_type ws.d_id32 DEFAULT const_arg_type_none() NOT NULL,
    arg_id2_type ws.d_id32 DEFAULT const_arg_type_none() NOT NULL,
    arg_id3_type ws.d_id32 DEFAULT const_arg_type_none() NOT NULL,
    dust_days ws.d_id32 DEFAULT 0 NOT NULL,
    is_run_allowed boolean DEFAULT true NOT NULL,
    is_todo_allowed boolean DEFAULT true NOT NULL,
    name ws.d_string NOT NULL
);


--
-- Name: TABLE handler; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON TABLE handler IS 'Обработчик задач Job';


--
-- Name: COLUMN handler.id; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN handler.id IS 'ID обработчика';


--
-- Name: COLUMN handler.pkg; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN handler.pkg IS 'Код пакета';


--
-- Name: COLUMN handler.code; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN handler.code IS 'символьный код обработчика';


--
-- Name: COLUMN handler.def_prio; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN handler.def_prio IS 'приоритет по умолчанию';


--
-- Name: COLUMN handler.def_status_id; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN handler.def_status_id IS 'статус по умолчанию';


--
-- Name: COLUMN handler.uk_bits; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN handler.uk_bits IS 'маска аргументов, которые должны быть уникальны';


--
-- Name: COLUMN handler.is_sql; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN handler.is_sql IS 'обработчик - метод БД (иначе - метод API)';


--
-- Name: COLUMN handler.next_handler_id; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN handler.next_handler_id IS 'ID обработчика задачи, создаваемой при успехе выполнения текущей';


--
-- Name: COLUMN handler.arg_date_type; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN handler.arg_date_type IS 'домен значений аргумента arg_date';


--
-- Name: COLUMN handler.arg_id_type; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN handler.arg_id_type IS 'домен значений аргумента arg_id';


--
-- Name: COLUMN handler.arg_num_type; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN handler.arg_num_type IS 'домен значений аргумента arg_num';


--
-- Name: COLUMN handler.arg_more_type; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN handler.arg_more_type IS 'домен значений аргумента arg_more';


--
-- Name: COLUMN handler.arg_date2_type; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN handler.arg_date2_type IS 'домен значений аргумента arg_date2';


--
-- Name: COLUMN handler.arg_id2_type; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN handler.arg_id2_type IS 'домен значений аргумента arg_id2';


--
-- Name: COLUMN handler.arg_id3_type; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN handler.arg_id3_type IS 'домен значений аргумента arg_id3';


--
-- Name: COLUMN handler.dust_days; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN handler.dust_days IS 'через сколько дней удалять из dust (0 - перемещать в past)';


--
-- Name: COLUMN handler.is_run_allowed; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN handler.is_run_allowed IS 'выполнение обработчика разрешено';


--
-- Name: COLUMN handler.is_todo_allowed; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN handler.is_todo_allowed IS 'создание задач в wsd.job_todo разрешено';


--
-- Name: COLUMN handler.name; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN handler.name IS 'название обработчика';


--
-- Name: handler(integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION handler(integer) RETURNS handler
    LANGUAGE sql STABLE
    AS $_$ /* job:job:30_misc.sql / 103 */ 
/* Вызов: job.handler_info(handler_id) */
  SELECT * FROM job.handler WHERE id = $1
$_$;


--
-- Name: handler_dust_days(integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION handler_dust_days(a_id integer) RETURNS integer
    LANGUAGE sql STABLE
    AS $_$ /* job:job:30_misc.sql / 97 */ 
  SELECT dust_days FROM job.handler WHERE id = $1;
$_$;


--
-- Name: handler_id(text); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION handler_id(a_type_handler_code text) RETURNS integer
    LANGUAGE sql STABLE
    AS $_$ /* job:job:30_misc.sql / 73 */ 
  -- handler_id - Номер договора компании на заданную дату
  -- a_type_handler_code:   "Код типа"."Код класса"
  SELECT job.handler_id(split_part($1, '.', 1), split_part($1, '.', 2));
$_$;


--
-- Name: handler_id(text, text); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION handler_id(a_pkg text, a_code text) RETURNS integer
    LANGUAGE plpgsql STABLE
    AS $$ /* job:job:30_misc.sql / 52 */ 
  -- handler_id - Номер договора компании на заданную дату
  -- a_pkg:   Код пакета
  -- a_code:  Код класса
  DECLARE
    v_handler_id job.handler.id%TYPE;
  BEGIN
    SELECT INTO v_handler_id
      id
      FROM job.handler
      WHERE pkg = a_pkg AND code = a_code
    ;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Unknown handler code %:%', a_pkg, a_code;
    END IF;
    RETURN v_handler_id;
  END
$$;


--
-- Name: handler_name(integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION handler_name(a_id integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$ /* job:job:30_misc.sql / 81 */ 
  -- handler_name - Имя класса по id
  -- a_id: ID класса
  SELECT name FROM job.handler WHERE id = $1;
$_$;


--
-- Name: handler_pkg_code(integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION handler_pkg_code(a_id integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$ /* job:job:30_misc.sql / 89 */ 
  -- handler_name - Имя класса по id
  -- a_id: ID класса
  SELECT pkg||'.'||code FROM job.handler WHERE id = $1;
$_$;


--
-- Name: mgr_error_load(integer, integer, integer, integer, text); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION mgr_error_load(a_pid integer, a_error_count integer, a_first_at integer, a_last_at integer, a_anno text) RETURNS integer
    LANGUAGE plpgsql
    AS $$ /* job:job:50_mgr.sql / 85 */ 
BEGIN
  UPDATE job.mgr_error SET
    updated_at    = CURRENT_TIMESTAMP
    , first_at    = ws.min(first_at, ws.epoch2timestamp(a_first_at))
    , last_at     = ws.max(last_at, ws.epoch2timestamp(a_last_at))
    , error_count = error_count + a_error_count
   WHERE pid = a_pid
    AND anno = a_anno
  ;
  IF NOT FOUND THEN
    INSERT INTO job.mgr_error(pid, error_count, anno, first_at, last_at)
      VALUES (a_pid, a_error_count, a_anno
        , ws.epoch2timestamp(a_first_at)
        , ws.epoch2timestamp(a_last_at)
      )
    ;
  END IF;
  PERFORM pg_notify('job_error_loaded', a_pid::text); -- To whom it may concern
  RETURN 1;
END;
$$;


--
-- Name: mgr_stat_load(integer, integer, integer, integer, integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION mgr_stat_load(a_pid integer, a_loop_count integer, a_event_count integer, a_error_count integer, a_run_at integer, a_loop_at integer, a_event_at integer, a_error_at integer, a_cron_at integer, a_shadow_at integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$ /* job:job:50_mgr.sql / 45 */ 
BEGIN
  UPDATE job.mgr_stat SET
    updated_at    = CURRENT_TIMESTAMP
    , loop_count  = a_loop_count
    , event_count = a_event_count
    , error_count = a_error_count
    , run_at      = ws.epoch2timestamp(a_run_at)
    , loop_at     = ws.epoch2timestamp(a_loop_at)
    , event_at    = ws.epoch2timestamp(a_event_at)
    , error_at    = ws.epoch2timestamp(a_error_at)
    , cron_at     = ws.epoch2timestamp(a_cron_at)
    , shadow_at   = ws.epoch2timestamp(a_shadow_at)
   WHERE pid = a_pid
  ;
  IF NOT FOUND THEN
    INSERT INTO job.mgr_stat(pid, loop_count, event_count, error_count, run_at, loop_at, event_at, error_at, cron_at, shadow_at)
      VALUES (a_pid, a_loop_count, a_event_count, a_error_count
        , ws.epoch2timestamp(a_run_at)
        , ws.epoch2timestamp(a_loop_at)
        , ws.epoch2timestamp(a_event_at)
        , ws.epoch2timestamp(a_error_at)
        , ws.epoch2timestamp(a_cron_at)
        , ws.epoch2timestamp(a_shadow_at)
      )
    ;
  END IF;
  PERFORM pg_notify('job_stat_loaded', a_pid::text); -- To whom it may concern
  RETURN 1;
END;
$$;


--
-- Name: mgr_stat_reload(); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION mgr_stat_reload() RETURNS void
    LANGUAGE sql
    AS $$ /* job:job:50_mgr.sql / 25 */ 
DELETE FROM job.mgr_stat;
DELETE FROM job.mgr_error;
SELECT pg_notify ('job_stat', '');
$$;


--
-- Name: FUNCTION mgr_stat_reload(); Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON FUNCTION mgr_stat_reload() IS 'Обновить статистику JobManager';


--
-- Name: mgr_test_event(integer, integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION mgr_test_event(a_id_first integer DEFAULT 0, a_id_last integer DEFAULT 10) RETURNS integer
    LANGUAGE plpgsql
    AS $$ /* job:job:50_mgr.sql / 110 */ 
DECLARE
BEGIN
  FOR v_i IN a_id_first..a_id_last LOOP
    PERFORM pg_notify('job_event', v_i::text);
  END LOOP;
  PERFORM job.mgr_stat_reload();
  RETURN a_id_last - a_id_first + 1;
END;
$$;


--
-- Name: next(integer, integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION next(a_pid integer, a_id integer DEFAULT 0) RETURNS SETOF wsd.job
    LANGUAGE plpgsql
    AS $_$ /* job:job:51_main.sql / 201 */ 
/*
  Выбрать следующую задачу для выполнения из числа имеющих статус 1 или 2 и validfrom меньше текущего момента.
  Если a_id<>0 - задачу с заданным task_id и статусом 6
  При успехе - зарегистрировать ее за процессом pid (если pid IS NOT NULL)
  Для задач со статусом 1, 2 и 8 производится контроль test.billing_stop

  Список задач сортируется по validfrom, prio, id
    Возвращаемое значение:
      описание задачи
  Вызов:
    SELECT * FROM job.task_next($$)
*/
  DECLARE
    v_stamp TIMESTAMP := CURRENT_TIMESTAMP;
    r  wsd.job%ROWTYPE;
  BEGIN
    IF a_id <> 0 THEN
      SELECT INTO r * FROM wsd.job
      WHERE id = a_id
        AND status_id IN (job.const_status_id_ready(), job.const_status_id_again(), job.const_status_id_forced())
      FOR UPDATE
      ;
    ELSE
      SELECT INTO r * FROM wsd.job
        WHERE status_id = job.const_status_id_urgent()
          AND validfrom <= v_stamp
        ORDER BY validfrom, prio, id
        LIMIT 1
        FOR UPDATE
      ;
      IF NOT FOUND THEN
        SELECT INTO r * FROM wsd.job
          WHERE status_id = job.const_status_id_again()
            AND validfrom <= v_stamp
          ORDER BY validfrom, prio, id
          LIMIT 1
          FOR UPDATE
        ;
        IF NOT FOUND THEN
          SELECT INTO r * FROM wsd.job
            WHERE status_id = job.const_status_id_ready()
              AND validfrom <= v_stamp
            ORDER BY validfrom, prio, id
            LIMIT 1
            FOR UPDATE
          ;
        END IF;
      END IF;
    END IF;

    IF NOT FOUND THEN
      RETURN;
    END IF;

    RETURN NEXT r;
    IF a_pid IS NULL THEN
      RETURN;
    END IF;
    UPDATE wsd.job SET
      run_pid = a_pid,
      run_ip = inet_client_addr(),
      run_at = clock_timestamp(), --CURRENT_TIMESTAMP,
      status_id = job.const_status_id_process()
      WHERE
        id = r.id
        AND status_id = r.status_id -- TODO: Удалить после проверки блокировки строки в FOR UPDATE
    ;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'ID %: cannot set process status', r.id;
    END IF;
    RETURN;
  END
$_$;


--
-- Name: server(integer, integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION server(a_pid integer, a_id integer DEFAULT 0) RETURNS integer
    LANGUAGE plpgsql
    AS $_$ /* job:job:51_main.sql / 405 */ 
/*
  Тестовая версия сервера обработки задач
  Вызов:
    SELECT job.server($$, $task_id)
    Если $task_id<>0 - выполняется задача с заданным id
*/
  DECLARE
    v_job_count INTEGER :=0;
    r_job  wsd.job%ROWTYPE;
    r_handler job.handler%ROWTYPE;
    v_cmd  TEXT;
    v_err  TEXT;
    v_ret  INTEGER;
    v1 INTEGER;
    v2 INTEGER;
  BEGIN
    LOOP
      SELECT INTO r_job * FROM job.next(a_pid, a_id);
      IF NOT FOUND THEN --OR r_task.handler_id = 7 THEN
        EXIT;
      END IF;
      r_handler := job.handler(r_job.handler_id);
      RAISE DEBUG 'job.server C: % D: % ID: % NUM: % MORE: % D2: % (%) *************', r_job.handler_id, r_job.arg_date, r_job.arg_id, r_job.arg_num, r_job.arg_more, r_job.arg_date2, r_handler.name;
      v_err := NULL;
      IF r_handler.is_sql THEN
        v_cmd := ws.sprintf('SELECT %s.%s(%s)', r_handler.pkg, r_handler.code, r_job.id::text);
        BEGIN
          EXECUTE v_cmd INTO v_ret;
        EXCEPTION WHEN OTHERS THEN
          v_ret := job.const_status_id_error();
          v_err := SQLERRM;
        END;
      ELSE
        v_ret := job.const_status_id_idle();
      END IF;
      PERFORM job.finish(r_job.id, v_ret, v_err);
      PERFORM job.finished(r_job.id);
      IF v_err IS NULL THEN
        v_job_count := v_job_count + 1;
      END IF;
    END LOOP;
    RETURN v_job_count;
  END
$_$;


--
-- Name: status_can_arc(integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION status_can_arc(a_id integer) RETURNS boolean
    LANGUAGE sql STABLE
    AS $_$ /* job:job:30_misc.sql / 42 */ 
  SELECT can_arc FROM job.status WHERE id = $1;
$_$;


--
-- Name: status_can_create(integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION status_can_create(a_id integer) RETURNS boolean
    LANGUAGE sql STABLE
    AS $_$ /* job:job:30_misc.sql / 30 */ 
  SELECT can_create FROM job.status WHERE id = $1;
$_$;


--
-- Name: status_can_run(integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION status_can_run(a_id integer) RETURNS boolean
    LANGUAGE sql STABLE
    AS $_$ /* job:job:30_misc.sql / 36 */ 
  SELECT can_run FROM job.status WHERE id = $1;
$_$;


--
-- Name: status_name(integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION status_name(a_id integer) RETURNS text
    LANGUAGE sql STABLE
    AS $_$ /* job:job:30_misc.sql / 24 */ 
  SELECT name FROM job.status WHERE id = $1;
$_$;


--
-- Name: stop(integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION stop(a_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$ /* job:job:52_handlers.sql / 77 */ 
  -- handler_core_stop - Запрет выполнения всех классов задач.
  -- Применяется в тестах внутри транзакций, завершающихся ROLLBACK
  -- После остановки будут выполнены только ранее созданные задачи
  -- Новые задачи будут при создании получать статус 8
  -- Отмена действий обработчика производится вручную командой
  -- UPDATE job.handler SET is_run_allowed = TRUE WHERE NOT is_run_allowed;
  -- ВАЖНО: поле is_run_allowed предназначено только для обработчика job.stop
  -- перед созданием задачи надо убедиться, что оно везде = FALSE
  -- a_id: ID задачи
  DECLARE
    r           wsd.job%ROWTYPE;
    v_cnt INTEGER;
  BEGIN
    r := job.current(a_id);
    -- если есть задача с меньшим приоритетом - ждем ее
    IF job.wait_prio(a_id, r.handler_id, r.prio, r.arg_date) IS NOT NULL THEN
      RETURN job.const_status_id_waiting();
    END IF;

    UPDATE job.handler SET is_run_allowed = FALSE WHERE is_run_allowed;
    GET DIAGNOSTICS v_cnt = ROW_COUNT;
    IF v_cnt > 0 THEN
      RETURN job.const_status_id_success();
    ELSE
      RETURN job.const_status_id_idle();
    END IF;
  END
$$;


--
-- Name: test_mgr(integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION test_mgr(a_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$ /* job:job:52_handlers_hl_test.sql / 55 */ 
  -- test_mgr - генератор тестовых задач
  -- Применяется в нагрузочных тестах
  -- a_id: ID задачи

  -- Аргументы:
  -- arg_id --  значение arg_id создаваемых задач
  -- arg_id2 -- кол-во создаваемых задач 
  -- arg_id3 -- (если > 0) - значение pg_sleep после выполнения задачи

  DECLARE
    r           wsd.job%ROWTYPE;
    v_cnt INTEGER;
  BEGIN
    r := job.current(a_id);

    IF job.wait_prio(a_id, r.handler_id, r.prio, r.arg_date) IS NOT NULL THEN
      RETURN job.const_status_id_waiting();
    END IF;

    -- создать подзадачи количеством arg_id2
    -- передав каждой в arg_id значение arg_id3 (сколько раз выполниться)
    PERFORM job.create(job.handler_id('job.test_run'), null, a_id, r.arg_date, r.arg_id) FROM generate_series(1, r.arg_id2); 

    -- создать свою задачу следующей датой
    PERFORM job.create(r.handler_id, null, a_id, r.arg_date + 1, a_id := r.arg_id, a_id2 := r.arg_id2, a_id3 := r.arg_id3); 

    IF COALESCE(r.arg_id3, 0) > 0 THEN
      -- дадим диспетчеру время разгрузить очередь
      PERFORM pg_sleep(r.arg_id3);
    END IF;

    RETURN job.const_status_id_success();
  END
$$;


--
-- Name: test_run(integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION test_run(a_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$ /* job:job:52_handlers_hl_test.sql / 93 */ 
  -- test_run - обработчик тестовой задачи
  -- Применяется в нагрузочных тестах
  -- a_id: ID задачи

  -- Аргументы:
  -- arg_id --  кол-во итераций "выполнился - создал новую"
  DECLARE
    r           wsd.job%ROWTYPE;
  BEGIN
    r := job.current(a_id);

    -- некоторая операция по изменению БД
    UPDATE wsd.job SET arg_num = COALESCE (arg_num, 0) + 1 WHERE id = r.created_by;

    IF r.arg_id > 1 THEN
      -- повторяем выполнение в новой задаче
      PERFORM job.create(r.handler_id, null, a_id, r.arg_date, r.arg_id - 1); 
    END IF;

    RETURN job.const_status_id_success();
  END
$$;


--
-- Name: today(integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION today(a_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$ /* job:job:52_handlers.sql / 25 */ 
  -- today - Задача завершения дня. Arg_date этой задачи - текущая дата диспетчера
  -- a_id: ID задачи
  DECLARE
    r           wsd.job%ROWTYPE;
  BEGIN
    r := job.current(a_id);
    -- если есть задача с меньшим приоритетом - ждем ее
    IF job.wait_prio(a_id, r.handler_id, r.prio, r.arg_date) IS NOT NULL THEN
      RETURN job.const_status_id_waiting();
    END IF;

    -- создать задачу на очистку
    PERFORM job.create(job.handler_id('job.clean'), null, a_id, r.arg_date);

    -- создать задачу "сегодня" для следующего дня
    PERFORM job.create(r.handler_id, null, a_id, r.arg_date + 1);

    -- Перенести из wsd.job_todo задачи завтрашнего дня
    INSERT INTO wsd.job SELECT * FROM job.todo2current(r.arg_date + 1);

    -- TODO: для массовых расчетов может портебоваться ассинхронно получать статус
    -- PERFORM pg_notify('job_new_day', (r.arg_date + 1)::TEXT);

    RETURN job.const_status_id_success();
  END
$$;


--
-- Name: todo2current(date); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION todo2current(date) RETURNS SETOF wsd.job
    LANGUAGE sql
    AS $_$  /* job:job:51_main.sql / 49 */ -- Удаление и возврат из job.todo задач, валидных до завершения заданной даты
  DELETE FROM wsd.job_todo WHERE validfrom < ($1 + 1)::timestamp
  RETURNING *
$_$;


--
-- Name: wait_prio(integer, integer, integer, date, integer, numeric, text, date, integer, integer); Type: FUNCTION; Schema: job; Owner: -
--

CREATE FUNCTION wait_prio(a_job_id integer, a_handler_id integer, a_prio integer, a_date date DEFAULT NULL::date, a_id integer DEFAULT NULL::integer, a_num numeric DEFAULT NULL::numeric, a_more text DEFAULT NULL::text, a_date2 date DEFAULT NULL::date, a_id2 integer DEFAULT NULL::integer, a_id3 integer DEFAULT NULL::integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$ /* job:job:51_main.sql / 290 */ 
/*
  Найти последнюю задачу того же типа, но с меньшим приоритетом,
  у которой статус <> 0 или 10
  и совпадают с указанными те аргументы, которые заданы (not null) при вызове функции
  При успехе - перевести текущую в режим ожидания найденной

    Вызов:
      IF job.wait_prio(a_id, r_t.handler_id, r_t.prio, r_t.arg_date, r_t.arg_id, r_t.arg_num, r_t.arg_more, r_t.arg_date2) IS NOT NULL THEN
        RETURN 1; -- задача отложена
      END IF;
    Возвращаемое значение:
      id найденной задачи или NULL
*/
  DECLARE
    v_id  INTEGER;
  BEGIN
    SELECT INTO v_id
      id
      FROM wsd.job
        WHERE job.status_can_run(status_id)
          AND prio < a_prio
          AND (a_date   IS NULL OR arg_date <= a_date)
          AND (a_id     IS NULL OR arg_id = a_id)
          AND (a_num    IS NULL OR arg_num = a_num)
          AND (a_more   IS NULL OR arg_more = a_more)
          AND (a_date2  IS NULL OR arg_date2 = a_date2)
          AND (a_id2    IS NULL OR arg_id2 = a_id2)
          AND (a_id3    IS NULL OR arg_id3 = a_id3)
        ORDER BY validfrom DESC, prio DESC, id DESC
        LIMIT 1
    ;
    IF FOUND THEN
      UPDATE wsd.job SET
        status_id = job.const_status_id_waiting()
      , waiting_for = v_id
        WHERE id = a_job_id
      ;
      RAISE DEBUG 'job.wait_prio: delay % for %', a_job_id, v_id;
      RETURN v_id;
    END IF;
    RETURN NULL;
  END
$$;


SET search_path = wiki, pg_catalog;

--
-- Name: acl(ws.d_id, ws.d_sid); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION acl(a_id ws.d_id, a__sid ws.d_sid DEFAULT NULL::text) RETURNS SETOF ws.d_acl
    LANGUAGE sql STABLE
    AS $_$ /* wiki:wiki:53_wiki.sql / 32 */ 
  SELECT * FROM acc.object_acl(wiki.const_class_id(), $1, $2)
$_$;


--
-- Name: FUNCTION acl(a_id ws.d_id, a__sid ws.d_sid); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION acl(a_id ws.d_id, a__sid ws.d_sid) IS 'ACL вики';


--
-- Name: const_class_id(); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION const_class_id() RETURNS ws.d_class
    LANGUAGE sql IMMUTABLE
    AS $$ /* wiki:wiki:19_const.sql / 28 */ 
  SELECT 10::ws.d_class
$$;


--
-- Name: FUNCTION const_class_id(); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION const_class_id() IS 'ID класса wiki';


--
-- Name: const_doc_class_id(); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION const_doc_class_id() RETURNS ws.d_class
    LANGUAGE sql IMMUTABLE
    AS $$ /* wiki:wiki:19_const.sql / 35 */ 
  SELECT 11::ws.d_class
$$;


--
-- Name: FUNCTION const_doc_class_id(); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION const_doc_class_id() IS 'ID класса статьи wiki';


--
-- Name: const_doc_status_id_draft(); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION const_doc_status_id_draft() RETURNS ws.d_id32
    LANGUAGE sql IMMUTABLE
    AS $$ /* wiki:wiki:19_const.sql / 49 */ 
  SELECT 3::ws.d_id32
$$;


--
-- Name: FUNCTION const_doc_status_id_draft(); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION const_doc_status_id_draft() IS 'ID начального статуcа статьи wiki';


--
-- Name: const_error_codeexists(); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION const_error_codeexists() RETURNS ws.d_errcode
    LANGUAGE sql IMMUTABLE
    AS $$ /* wiki:wiki:19_const.sql / 70 */ 
  SELECT 'Y9903'::ws.d_errcode
$$;


--
-- Name: FUNCTION const_error_codeexists(); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION const_error_codeexists() IS 'Код ошибки повторного создания кода документа';


--
-- Name: const_error_nochgtosave(); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION const_error_nochgtosave() RETURNS ws.d_errcode
    LANGUAGE sql IMMUTABLE
    AS $$ /* wiki:wiki:19_const.sql / 77 */ 
  SELECT 'Y9904'::ws.d_errcode
$$;


--
-- Name: FUNCTION const_error_nochgtosave(); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION const_error_nochgtosave() IS 'Код ошибки сохранения версии, не содержащей изменений';


--
-- Name: const_error_nodoc(); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION const_error_nodoc() RETURNS ws.d_errcode
    LANGUAGE sql IMMUTABLE
    AS $$ /* wiki:wiki:19_const.sql / 84 */ 
  SELECT 'Y9905'::ws.d_errcode
$$;


--
-- Name: FUNCTION const_error_nodoc(); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION const_error_nodoc() IS 'Код ошибки поиска статьи';


--
-- Name: const_error_nogroupcode(); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION const_error_nogroupcode() RETURNS ws.d_errcode
    LANGUAGE sql IMMUTABLE
    AS $$ /* wiki:wiki:19_const.sql / 56 */ 
  SELECT 'Y9901'::ws.d_errcode
$$;


--
-- Name: FUNCTION const_error_nogroupcode(); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION const_error_nogroupcode() IS 'Код ошибки поиска группы по коду';


--
-- Name: const_error_norevision(); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION const_error_norevision() RETURNS ws.d_errcode
    LANGUAGE sql IMMUTABLE
    AS $$ /* wiki:wiki:19_const.sql / 63 */ 
  SELECT 'Y9902'::ws.d_errcode
$$;


--
-- Name: FUNCTION const_error_norevision(); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION const_error_norevision() IS 'Код ошибки соответствия версии документа';


--
-- Name: const_status_id_online(); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION const_status_id_online() RETURNS ws.d_id32
    LANGUAGE sql IMMUTABLE
    AS $$ /* wiki:wiki:19_const.sql / 42 */ 
  SELECT 1::ws.d_id32
$$;


--
-- Name: FUNCTION const_status_id_online(); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION const_status_id_online() IS 'ID статуcа wiki, при котором статьи имеют свой статус';


--
-- Name: doc_acl(ws.d_id, ws.d_sid); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION doc_acl(a_id ws.d_id, a__sid ws.d_sid DEFAULT NULL::text) RETURNS SETOF ws.d_acl
    LANGUAGE sql STABLE
    AS $_$ /* wiki:wiki:54_doc.sql / 47 */ 
  SELECT * FROM acc.object_acl(wiki.const_class_id(), wiki.doc_group_id($1), $2)
  -- TODO: добавить acl автора
$_$;


--
-- Name: FUNCTION doc_acl(a_id ws.d_id, a__sid ws.d_sid); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION doc_acl(a_id ws.d_id, a__sid ws.d_sid) IS 'ACL вики';


--
-- Name: doc_by_name(ws.d_id32, text, ws.d_cnt); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION doc_by_name(a_id ws.d_id32, a_string text, a_max_rows ws.d_cnt DEFAULT 15) RETURNS SETOF ws.t_hashtable
    LANGUAGE sql STABLE
    AS $_$ /* wiki:wiki:53_wiki.sql / 85 */ 
  -- a_id: ID wiki
  SELECT id::TEXT, name FROM wiki.doc_info WHERE group_id = $1 AND name ~* $2 ORDER BY name LIMIT $3;
$_$;


--
-- Name: FUNCTION doc_by_name(a_id ws.d_id32, a_string text, a_max_rows ws.d_cnt); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION doc_by_name(a_id ws.d_id32, a_string text, a_max_rows ws.d_cnt) IS 'список статей, название которых содержит string';


--
-- Name: doc_create(text, ws.d_id, ws.d_path, text, text, d_links, text, text); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION doc_create(a__sid text, a_id ws.d_id, a_code ws.d_path DEFAULT ''::text, a_src text DEFAULT ''::text, a_name text DEFAULT ''::text, a_links d_links DEFAULT NULL::text[], a_anno text DEFAULT ''::text, a_toc text DEFAULT ''::text) RETURNS ws.d_id
    LANGUAGE plpgsql
    AS $$ /* wiki:wiki:53_wiki.sql / 110 */ 
  -- a__sid:      ID сессии
  -- a_id:        ID wiki
  -- a_code:      Код статьи
  -- a_src:       Текст в разметке wiki
  -- a_name:      Название
  -- a links:     Список внешних ссылок
  -- a_anno:      Аннотация
  -- a toc:       Содержание
  DECLARE
    v_account_id ws.d_id;
    v_doc_id ws.d_id;
  BEGIN
    v_account_id := (acc.profile(a__sid)).id;
    IF v_account_id IS NULL THEN
      RAISE EXCEPTION 'unknown account'; -- TODO: ERRORCODE from acc.
    END IF;

    SELECT INTO v_doc_id
      id
      FROM wsd.doc
      WHERE group_id = a_id
        AND code = a_code
    ;
    IF FOUND THEN
      RAISE EXCEPTION '%', ws.error_str(wiki.const_error_codeexists(), v_doc_id::text);
    END IF;

    INSERT INTO wsd.doc (group_id, status_id, code, created_by, updated_by, name, src)
      VALUES (a_id, wiki.const_doc_status_id_draft(), a_code, v_account_id, v_account_id, a_name, a_src)
      RETURNING id INTO v_doc_id
    ;

    PERFORM wiki.doc_update_extra(a__sid, v_doc_id, a_links, a_anno, a_toc);

    RETURN v_doc_id;
  END;
$$;


--
-- Name: FUNCTION doc_create(a__sid text, a_id ws.d_id, a_code ws.d_path, a_src text, a_name text, a_links d_links, a_anno text, a_toc text); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION doc_create(a__sid text, a_id ws.d_id, a_code ws.d_path, a_src text, a_name text, a_links d_links, a_anno text, a_toc text) IS 'Создание документа';


SET search_path = wsd, pg_catalog;

--
-- Name: doc_diff; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE doc_diff (
    id integer NOT NULL,
    revision integer NOT NULL,
    updated_by integer NOT NULL,
    updated_at timestamp(0) without time zone DEFAULT now() NOT NULL,
    diff_src text
);


--
-- Name: TABLE doc_diff; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE doc_diff IS 'Изменения между ревизиями статьи wiki';


--
-- Name: COLUMN doc_diff.id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN doc_diff.id IS 'ID статьи';


SET search_path = wiki, pg_catalog;

--
-- Name: doc_diff(ws.d_id, ws.d_cnt); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION doc_diff(a_id ws.d_id, a_revision ws.d_cnt) RETURNS SETOF wsd.doc_diff
    LANGUAGE sql STABLE STRICT
    AS $_$ /* wiki:wiki:54_doc.sql / 106 */ 
  -- a_id: ID статьи
  SELECT * FROM wsd.doc_diff WHERE id = $1 /* a_id */ AND revision = $2 /* a_revision */;
$_$;


--
-- Name: FUNCTION doc_diff(a_id ws.d_id, a_revision ws.d_cnt); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION doc_diff(a_id ws.d_id, a_revision ws.d_cnt) IS 'Изменения заданной ревизии';


--
-- Name: doc_extra; Type: TABLE; Schema: wiki; Owner: -
--

CREATE TABLE doc_extra (
    id ws.d_id32 NOT NULL,
    is_toc_preferred boolean DEFAULT false NOT NULL,
    toc text,
    anno text
);


--
-- Name: TABLE doc_extra; Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON TABLE doc_extra IS 'Дополнительные данные статьи wiki';


--
-- Name: COLUMN doc_extra.id; Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON COLUMN doc_extra.id IS 'ID статьи';


--
-- Name: COLUMN doc_extra.is_toc_preferred; Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON COLUMN doc_extra.is_toc_preferred IS 'В кратком списке выводить не аннотацию а содержание';


--
-- Name: doc_extra(ws.d_id); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION doc_extra(a_id ws.d_id) RETURNS doc_extra
    LANGUAGE sql STABLE STRICT
    AS $_$ /* wiki:wiki:54_doc.sql / 90 */ 
  -- a_id: ID статьи
  SELECT * FROM wiki.doc_extra WHERE id = $1; /* a_id */
$_$;


--
-- Name: FUNCTION doc_extra(a_id ws.d_id); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION doc_extra(a_id ws.d_id) IS 'Дополнительные данные';


SET search_path = wsd, pg_catalog;

--
-- Name: file_link; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE file_link (
    class_id integer NOT NULL,
    obj_id integer NOT NULL,
    folder_code text NOT NULL,
    format_code text NOT NULL,
    file_code text DEFAULT ''::text NOT NULL,
    ver integer DEFAULT 1 NOT NULL,
    id integer,
    up_id integer,
    is_ver_last boolean DEFAULT true NOT NULL,
    created_by integer NOT NULL,
    created_at timestamp(0) without time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE file_link; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE file_link IS 'Связи внешнего файла';


--
-- Name: COLUMN file_link.class_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_link.class_id IS 'ID класса';


--
-- Name: COLUMN file_link.obj_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_link.obj_id IS 'ID объекта';


--
-- Name: COLUMN file_link.folder_code; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_link.folder_code IS 'Код папки';


--
-- Name: COLUMN file_link.format_code; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_link.format_code IS 'Код формата';


--
-- Name: COLUMN file_link.file_code; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_link.file_code IS 'Код файла';


--
-- Name: COLUMN file_link.ver; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_link.ver IS 'Версия файла';


--
-- Name: COLUMN file_link.id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_link.id IS 'ID файла';


--
-- Name: COLUMN file_link.up_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_link.up_id IS 'ID файла, по которому сформирован текущий (TODO)';


--
-- Name: COLUMN file_link.is_ver_last; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_link.is_ver_last IS 'Версия файла является последней';


--
-- Name: COLUMN file_link.created_by; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_link.created_by IS 'Автор привязки';


--
-- Name: COLUMN file_link.created_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN file_link.created_at IS 'Момент привязки';


SET search_path = fs, pg_catalog;

--
-- Name: file_info; Type: VIEW; Schema: fs; Owner: -
--

CREATE VIEW file_info AS
    SELECT f.name, f.size, f.csum, f.format_code, f.created_by, f.created_at, f.anno, fl.class_id, fl.obj_id, fl.folder_code, fl.file_code, fl.ver, fl.id, fl.is_ver_last, fl.created_by AS link_created_by, fl.created_at AS link_created_at FROM (wsd.file f JOIN wsd.file_link fl USING (id));


--
-- Name: VIEW file_info; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON VIEW file_info IS 'Атрибуты внешнего файла объекта';


--
-- Name: COLUMN file_info.name; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_info.name IS 'Внешнее имя файла';


--
-- Name: COLUMN file_info.size; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_info.size IS 'Размер (байт)';


--
-- Name: COLUMN file_info.csum; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_info.csum IS 'Контрольная сумма (sha1)';


--
-- Name: COLUMN file_info.format_code; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_info.format_code IS 'Код формата файла';


--
-- Name: COLUMN file_info.created_by; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_info.created_by IS 'Автор загрузки/генерации';


--
-- Name: COLUMN file_info.created_at; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_info.created_at IS 'Момент загрузки/генерации';


--
-- Name: COLUMN file_info.anno; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_info.anno IS 'Комментарий';


--
-- Name: COLUMN file_info.class_id; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_info.class_id IS 'ID класса';


--
-- Name: COLUMN file_info.obj_id; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_info.obj_id IS 'ID объекта';


--
-- Name: COLUMN file_info.folder_code; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_info.folder_code IS 'Код связи';


--
-- Name: COLUMN file_info.file_code; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_info.file_code IS 'Код файла';


--
-- Name: COLUMN file_info.ver; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_info.ver IS 'Версия внутри кода связи';


--
-- Name: COLUMN file_info.id; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_info.id IS 'ID файла';


--
-- Name: COLUMN file_info.is_ver_last; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_info.is_ver_last IS 'Версия является последней';


--
-- Name: COLUMN file_info.link_created_by; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_info.link_created_by IS 'Автор привязки';


--
-- Name: COLUMN file_info.link_created_at; Type: COMMENT; Schema: fs; Owner: -
--

COMMENT ON COLUMN file_info.link_created_at IS 'Момент привязки';


SET search_path = wiki, pg_catalog;

--
-- Name: doc_file(ws.d_id, ws.d_id); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION doc_file(a_id ws.d_id, a_file_id ws.d_id DEFAULT 0) RETURNS SETOF fs.file_info
    LANGUAGE sql
    AS $_$ /* wiki:wiki:51_file.sql / 28 */ 
  SELECT * FROM fs.file_info WHERE class_id = wiki.const_doc_class_id() AND obj_id = $1 AND $2 IN (id, 0) ORDER BY created_at;
$_$;


--
-- Name: FUNCTION doc_file(a_id ws.d_id, a_file_id ws.d_id); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION doc_file(a_id ws.d_id, a_file_id ws.d_id) IS 'Атрибуты файлов статьи';


--
-- Name: doc_file_add(text, ws.d_id, text, integer, text, text, text, text); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION doc_file_add(a__sid text, a_id ws.d_id, a__path text, a__size integer, a__csum text, a_name text, a_ctype text, a_anno text DEFAULT NULL::text) RETURNS SETOF fs.file_info
    LANGUAGE plpgsql
    AS $$ /* wiki:wiki:51_file.sql / 44 */ 
  -- a__sid:  ID сессии
  -- a_id:    ID статьи
  -- a__path: Путь к файлу в хранилище nginx
  -- a__size: Размер (байт)
  -- a__csum: Контрольная сумма (sha1)
  -- a_name:  Внешнее имя файла
  -- a_ctype: Content type
  -- a_anno:  Комментарий
  DECLARE
    v_account_id INTEGER;
    v_code TEXT;
    v_file_id INTEGER;
  BEGIN
    -- TODO: content-type & extention control
    v_account_id := (acc.profile(a__sid)).id;
    v_file_id := fs.file_add(v_account_id, 'wiki', a_id, a__path, a__size, a__csum, a_name, NULL, a_ctype, NULL, a_anno);
    RETURN QUERY SELECT * FROM wiki.doc_file(a_id, v_file_id);
    RETURN;
  END;
$$;


--
-- Name: FUNCTION doc_file_add(a__sid text, a_id ws.d_id, a__path text, a__size integer, a__csum text, a_name text, a_ctype text, a_anno text); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION doc_file_add(a__sid text, a_id ws.d_id, a__path text, a__size integer, a__csum text, a_name text, a_ctype text, a_anno text) IS 'Добавление в статью загруженного файла';


--
-- Name: doc_file_del(ws.d_id, ws.d_id); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION doc_file_del(a_id ws.d_id, a_file_id ws.d_id) RETURNS boolean
    LANGUAGE plpgsql
    AS $$ /* wiki:wiki:51_file.sql / 72 */ 
  BEGIN
    DELETE FROM wsd.file_link WHERE class_id = wiki.const_doc_class_id() AND obj_id = a_id AND id = a_file_id;
    -- TODO: если файл уже нигде не используется - удалить его?
    RETURN TRUE;
  END;
$$;


--
-- Name: FUNCTION doc_file_del(a_id ws.d_id, a_file_id ws.d_id); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION doc_file_del(a_id ws.d_id, a_file_id ws.d_id) IS 'Удаление файла из статьи';


--
-- Name: doc_group_id(ws.d_id); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION doc_group_id(a_id ws.d_id) RETURNS integer
    LANGUAGE sql STABLE
    AS $_$ /* wiki:wiki:52_doc.sql / 80 */ 
  -- a_id: ID статьи
  SELECT group_id FROM wsd.doc WHERE id = $1;
$_$;


--
-- Name: FUNCTION doc_group_id(a_id ws.d_id); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION doc_group_id(a_id ws.d_id) IS 'ID вики по ID статьи';


--
-- Name: doc_id_by_code(ws.d_id, ws.d_path); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION doc_id_by_code(a_id ws.d_id, a_code ws.d_path DEFAULT ''::text) RETURNS ws.d_id
    LANGUAGE sql STABLE
    AS $_$ /* wiki:wiki:53_wiki.sql / 72 */ 
  -- a_id: ID вики
  -- a_code: Код документа
  SELECT id::ws.d_id
      FROM wsd.doc
      WHERE group_id = $1
        AND code = $2
    ;
$_$;


--
-- Name: FUNCTION doc_id_by_code(a_id ws.d_id, a_code ws.d_path); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION doc_id_by_code(a_id ws.d_id, a_code ws.d_path) IS 'ID документа по коду';


SET search_path = wsd, pg_catalog;

--
-- Name: doc_id_seq; Type: SEQUENCE; Schema: wsd; Owner: -
--

CREATE SEQUENCE doc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: doc; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE doc (
    id integer DEFAULT nextval('doc_id_seq'::regclass) NOT NULL,
    status_id integer DEFAULT 1 NOT NULL,
    group_id integer NOT NULL,
    up_id integer,
    code text DEFAULT ''::text NOT NULL,
    revision integer DEFAULT 1 NOT NULL,
    pub_date date,
    created_by integer NOT NULL,
    created_at timestamp(0) without time zone DEFAULT now() NOT NULL,
    updated_by integer NOT NULL,
    updated_at timestamp(0) without time zone DEFAULT now() NOT NULL,
    cached_at timestamp(0) without time zone,
    status_next_id integer,
    status_next_at timestamp(0) without time zone,
    src text NOT NULL,
    name text
);


--
-- Name: TABLE doc; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE doc IS 'Статья wiki';


--
-- Name: COLUMN doc.code; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN doc.code IS 'Код статьи (URI)';


--
-- Name: COLUMN doc.updated_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN doc.updated_at IS 'Момент последнего редактирования';


--
-- Name: COLUMN doc.cached_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN doc.cached_at IS 'Момент актуализации кэша';


--
-- Name: doc_group; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE doc_group (
    id integer NOT NULL,
    status_id integer DEFAULT 1 NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    anno text NOT NULL
);


SET search_path = wiki, pg_catalog;

--
-- Name: doc_info; Type: VIEW; Schema: wiki; Owner: -
--

CREATE VIEW doc_info AS
    SELECT d.id, d.status_id, d.group_id, d.up_id, d.code, d.revision, d.pub_date, d.created_by, d.created_at, d.updated_by, d.updated_at, d.status_next_id, d.status_next_at, d.name, dg.status_id AS group_status_id, dg.name AS group_name, a.name AS updated_by_name FROM ((wsd.doc d JOIN wsd.doc_group dg ON ((d.group_id = dg.id))) JOIN wsd.account a ON ((d.created_by = a.id)));


--
-- Name: doc_info(ws.d_id); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION doc_info(a_id ws.d_id) RETURNS SETOF doc_info
    LANGUAGE plpgsql STABLE
    AS $$ /* wiki:wiki:54_doc.sql / 63 */ 
  -- a_id: ID статьи
  BEGIN
    RETURN QUERY SELECT * FROM wiki.doc_info WHERE id = a_id;
  END;
$$;


--
-- Name: FUNCTION doc_info(a_id ws.d_id); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION doc_info(a_id ws.d_id) IS 'Атрибуты документа';


--
-- Name: doc_keyword(ws.d_id); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION doc_keyword(a_id ws.d_id) RETURNS SETOF text
    LANGUAGE sql STABLE
    AS $_$ /* wiki:wiki:54_doc.sql / 74 */ 
  -- a_id: ID статьи
  SELECT name FROM wsd.doc_keyword WHERE id = $1 ORDER BY name;
$_$;


--
-- Name: FUNCTION doc_keyword(a_id ws.d_id); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION doc_keyword(a_id ws.d_id) IS 'список ключевых слов статьи';


--
-- Name: doc_link; Type: TABLE; Schema: wiki; Owner: -
--

CREATE TABLE doc_link (
    id ws.d_id32 NOT NULL,
    path text NOT NULL,
    is_wiki boolean DEFAULT true NOT NULL,
    link_id ws.d_id
);


--
-- Name: TABLE doc_link; Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON TABLE doc_link IS 'Ссылка на внутренние документы статьи wiki';


--
-- Name: COLUMN doc_link.id; Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON COLUMN doc_link.id IS 'ID статьи';


--
-- Name: doc_link(ws.d_id); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION doc_link(a_id ws.d_id) RETURNS SETOF doc_link
    LANGUAGE sql STABLE STRICT
    AS $_$ /* wiki:wiki:54_doc.sql / 98 */ 
  -- a_id: ID статьи
  SELECT * FROM wiki.doc_link WHERE id = $1; /* a_id */
$_$;


--
-- Name: FUNCTION doc_link(a_id ws.d_id); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION doc_link(a_id ws.d_id) IS 'Ссылки ни внутренние документы';


--
-- Name: doc_server(ws.d_id); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION doc_server(a_id ws.d_id) RETURNS SETOF ws.server
    LANGUAGE sql STABLE
    AS $_$ /* wiki:wiki:54_doc.sql / 56 */ 
  SELECT wiki.server(wiki.doc_group_id($1))
$_$;


--
-- Name: doc_src(ws.d_id); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION doc_src(a_id ws.d_id) RETURNS text
    LANGUAGE sql STABLE STRICT
    AS $_$ /* wiki:wiki:54_doc.sql / 82 */ 
  -- a_id: ID статьи
  SELECT src FROM wsd.doc WHERE id = $1; /* a_id */
$_$;


--
-- Name: FUNCTION doc_src(a_id ws.d_id); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION doc_src(a_id ws.d_id) IS 'Текст документа';


--
-- Name: doc_status(ws.d_id); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION doc_status(a_id ws.d_id) RETURNS ws.d_id32
    LANGUAGE plpgsql STABLE
    AS $$ /* wiki:wiki:54_doc.sql / 25 */ 
  DECLARE
    v_status_id ws.d_id32;
  BEGIN
    SELECT INTO v_status_id
      status_id::ws.d_id32
      FROM wsd.doc_group WHERE id = wiki.doc_group_id(a_id)
    ;
    IF v_status_id = wiki.const_status_id_online() THEN
      -- wiki online, используем статус статьи
      SELECT INTO v_status_id
        status_id::ws.d_id32
        FROM wsd.doc WHERE id = a_id
      ;
    END IF;
    RETURN v_status_id;
  END;
$$;


--
-- Name: FUNCTION doc_status(a_id ws.d_id); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION doc_status(a_id ws.d_id) IS 'Статус статьи вики';


--
-- Name: doc_update_attr(text, ws.d_id, ws.d_id32, ws.d_id, ws.d_id, ws.d_stamp, ws.d_texta); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION doc_update_attr(a__sid text, a_id ws.d_id, a_status_id ws.d_id32, a_up_id ws.d_id DEFAULT NULL::integer, a_status_next_id ws.d_id DEFAULT NULL::integer, a_status_next_at ws.d_stamp DEFAULT NULL::timestamp without time zone, a_keywords ws.d_texta DEFAULT NULL::text[]) RETURNS ws.d_id
    LANGUAGE plpgsql
    AS $$ /* wiki:wiki:54_doc.sql / 180 */ 
  -- a__sid:      ID сессии
  -- a_id:        ID статьи
  -- a_status_id: ID статуса
  -- a_up_id:     ID статьи-предка
  -- a_status_next_id  ID отложенного статуса
  -- a_status_next_at  Время активации отложенного статуса
  -- a_keywords        Ключевые слова
  DECLARE
    v_account_id ws.d_id;
    v_revision ws.d_id;
  BEGIN
    v_account_id := (acc.profile(a__sid)).id;
    IF v_account_id IS NULL THEN
      RAISE EXCEPTION 'unknown account'; -- TODO: ERRORCODE
    END IF;
    -- TODO: валидировать значения status_id, up_id, status_next_id
    -- TODO: заполнить pub_date по факту публикации
    UPDATE wsd.doc SET
      status_id        = a_status_id
      , up_id          = a_up_id
      , status_next_id = a_status_next_id
      , status_next_at = a_status_next_at
      WHERE id = a_id
    ;
    IF NOT FOUND THEN
      RAISE EXCEPTION '%', ws.e_nodata();
    END IF;

    DELETE FROM wsd.doc_keyword  WHERE id = a_id;

    INSERT INTO wsd.doc_keyword (id, name)
      SELECT DISTINCT a_id, name FROM unnest(a_keywords) name
    ;
    RETURN a_id;
  END;
$$;


--
-- Name: FUNCTION doc_update_attr(a__sid text, a_id ws.d_id, a_status_id ws.d_id32, a_up_id ws.d_id, a_status_next_id ws.d_id, a_status_next_at ws.d_stamp, a_keywords ws.d_texta); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION doc_update_attr(a__sid text, a_id ws.d_id, a_status_id ws.d_id32, a_up_id ws.d_id, a_status_next_id ws.d_id, a_status_next_at ws.d_stamp, a_keywords ws.d_texta) IS 'Изменение атрибутов документа';


--
-- Name: doc_update_extra(text, ws.d_id, d_links, text, text); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION doc_update_extra(a__sid text, a_id ws.d_id, a_links d_links DEFAULT NULL::text[], a_anno text DEFAULT ''::text, a_toc text DEFAULT ''::text) RETURNS ws.d_id
    LANGUAGE plpgsql
    AS $$ /* wiki:wiki:52_doc.sql / 31 */ 
  -- a__sid:      ID сессии
  -- a_id:        ID статьи
  -- a links:     Список внешних ссылок
  -- a_anno:      Аннотация
  -- a toc:       Содержание
  DECLARE
    v_account_id ws.d_id;
    v_revision ws.d_id;
  BEGIN
    v_account_id := (acc.profile(a__sid)).id;
    IF v_account_id IS NULL THEN
      RAISE EXCEPTION 'unknown account'; -- TODO: ERRORCODE
    END IF;
    -- TODO: save diff and v_account_id
    UPDATE wsd.doc SET
        cached_at = CURRENT_TIMESTAMP
      WHERE id = a_id
    ;
    IF NOT FOUND THEN
      RAISE EXCEPTION '%', ws.e_nodata();
    END IF;

    UPDATE wiki.doc_extra SET
      anno = a_anno
      , toc = a_toc
      WHERE id = a_id
    ;
    IF NOT FOUND THEN
      INSERT INTO wiki.doc_extra (id, anno, toc)
        VALUES (a_id, a_anno, a_toc)
      ;
    END IF;
    DELETE FROM wiki.doc_link WHERE id = a_id;
    IF a_links IS NOT NULL THEN
      INSERT INTO wiki.doc_link (id, path)
        SELECT a_id, link FROM unnest(a_links) link
      ;
    END IF;
    RETURN a_id;
  END;
$$;


--
-- Name: FUNCTION doc_update_extra(a__sid text, a_id ws.d_id, a_links d_links, a_anno text, a_toc text); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION doc_update_extra(a__sid text, a_id ws.d_id, a_links d_links, a_anno text, a_toc text) IS 'Обновление вторичных данных';


--
-- Name: doc_update_src(text, ws.d_id, ws.d_cnt, text, text, d_links, text, text, text); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION doc_update_src(a__sid text, a_id ws.d_id, a_revision ws.d_cnt, a_src text DEFAULT ''::text, a_name text DEFAULT ''::text, a_links d_links DEFAULT NULL::text[], a_anno text DEFAULT ''::text, a_toc text DEFAULT ''::text, a_diff text DEFAULT ''::text) RETURNS ws.d_id
    LANGUAGE plpgsql
    AS $$ /* wiki:wiki:54_doc.sql / 125 */ 
  -- a__sid:      ID сессии
  -- a_id:        ID статьи
  -- a_revision:  Номер текущей ревизии
  -- a_src:       Текст в разметке wiki
  -- a_name:      Название
  -- a links:     Список внешних ссылок
  -- a_anno:      Аннотация
  -- a toc:       Содержание
  -- a_diff:      Изменения от предыдущей версии
  DECLARE
    v_account_id ws.d_id;
    v_revision ws.d_id;
  BEGIN
    v_account_id := (acc.profile(a__sid)).id;
    IF v_account_id IS NULL THEN
      RAISE EXCEPTION 'unknown account'; -- TODO: ERRORCODE
    END IF;
    -- TODO: save diff and v_account_id
    UPDATE wsd.doc SET
      revision = revision + 1
      , updated_by = v_account_id
      , updated_at = CURRENT_TIMESTAMP
      , cached_at = CURRENT_TIMESTAMP
      , name = a_name
      , src = a_src
      WHERE id = a_id
        AND revision = a_revision
      RETURNING revision
        INTO v_revision
    ;
    IF NOT FOUND THEN
      RAISE EXCEPTION '%', ws.error_str(wiki.const_error_norevision(), a_revision::text);
    END IF;

    INSERT INTO wsd.doc_diff (id, revision, updated_at, updated_by, diff_src)
      VALUES (a_id, v_revision, CURRENT_TIMESTAMP, v_account_id, a_diff)
    ;

    PERFORM wiki.doc_update_extra(a__sid, a_id, a_links, a_anno, a_toc);
    RETURN a_id;
  END;
$$;


--
-- Name: FUNCTION doc_update_src(a__sid text, a_id ws.d_id, a_revision ws.d_cnt, a_src text, a_name text, a_links d_links, a_anno text, a_toc text, a_diff text); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION doc_update_src(a__sid text, a_id ws.d_id, a_revision ws.d_cnt, a_src text, a_name text, a_links d_links, a_anno text, a_toc text, a_diff text) IS 'Изменение пользователем текста документа';


--
-- Name: id_by_code(ws.d_code); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION id_by_code(a_code ws.d_code) RETURNS ws.d_id32
    LANGUAGE sql STABLE
    AS $_$ /* wiki:wiki:53_wiki.sql / 57 */ 
  -- a_group_code: Код группы документов
-- TODO: не возвращать ID если нет доступа на чтение к группе
  SELECT id::ws.d_id32
    FROM wsd.doc_group
    WHERE code = $1 /* a_group_code */
  ;
$_$;


--
-- Name: FUNCTION id_by_code(a_code ws.d_code); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION id_by_code(a_code ws.d_code) IS 'ID wiki по ее коду';


--
-- Name: keyword_by_name(ws.d_id32, text, ws.d_cnt); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION keyword_by_name(a_id ws.d_id32, a_string text, a_max_rows ws.d_cnt DEFAULT 15) RETURNS SETOF text
    LANGUAGE sql STABLE
    AS $_$ /* wiki:wiki:53_wiki.sql / 93 */ 
  -- a_id: ID wiki
  SELECT DISTINCT name FROM wiki.doc_keyword_info WHERE group_id = $1 AND name ~* $2 ORDER BY name LIMIT $3;
$_$;


--
-- Name: FUNCTION keyword_by_name(a_id ws.d_id32, a_string text, a_max_rows ws.d_cnt); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION keyword_by_name(a_id ws.d_id32, a_string text, a_max_rows ws.d_cnt) IS 'список ключевых слов wiki, содержащих строку string';


--
-- Name: server(ws.d_id); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION server(a_id ws.d_id) RETURNS SETOF ws.server
    LANGUAGE plpgsql STABLE
    AS $$ /* wiki:wiki:53_wiki.sql / 40 */ 
  DECLARE
    v_id  ws.d_id32;
  BEGIN
    v_id := 1; -- расчет id ответственного сервера по id конкурса
    RETURN QUERY
      SELECT *
      FROM ws.server
      WHERE id = v_id
    ;
    RETURN;
  END
$$;


--
-- Name: FUNCTION server(a_id ws.d_id); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION server(a_id ws.d_id) IS 'Сервер вики';


--
-- Name: status(ws.d_id); Type: FUNCTION; Schema: wiki; Owner: -
--

CREATE FUNCTION status(a_id ws.d_id) RETURNS ws.d_id32
    LANGUAGE sql STABLE
    AS $_$ /* wiki:wiki:53_wiki.sql / 25 */ 
  SELECT status_id::ws.d_id32 FROM wsd.doc_group WHERE id = $1;
$_$;


--
-- Name: FUNCTION status(a_id ws.d_id); Type: COMMENT; Schema: wiki; Owner: -
--

COMMENT ON FUNCTION status(a_id ws.d_id) IS 'Статус вики';


SET search_path = ws, pg_catalog;

--
-- Name: acls_eff(d_class, d_id32, d_id32, d_acls); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION acls_eff(class_id d_class, status_id d_id32, action_id d_id32, acl_ids d_acls) RETURNS SETOF t_hashtable
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_class.sql / 61 */ 
SELECT ca.id::text, ca.name FROM ws.class_status_action_acl csaa
  JOIN ws.class_acl ca
  ON (ca.class_id = csaa.class_id AND ca.id = csaa.acl_id)
  WHERE csaa.class_id = $1 AND status_id = $2 AND action_id = $3 AND acl_id = ANY ($4::ws.d_acls)
$_$;


--
-- Name: FUNCTION acls_eff(class_id d_class, status_id d_id32, action_id d_id32, acl_ids d_acls); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION acls_eff(class_id d_class, status_id d_id32, action_id d_id32, acl_ids d_acls) IS 'Список эффективных ACL';


--
-- Name: acls_eff_ids(d_class, d_id32, d_id32, d_acls); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION acls_eff_ids(class_id d_class, status_id d_id32, action_id d_id32, acl_ids d_acls) RETURNS SETOF d_acl
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_class.sql / 53 */ 
SELECT acl_id FROM ws.class_status_action_acl
  WHERE class_id = $1 AND status_id = $2 AND action_id = $3 AND acl_id = ANY ($4::ws.d_acls)
$_$;


--
-- Name: FUNCTION acls_eff_ids(class_id d_class, status_id d_id32, action_id d_id32, acl_ids d_acls); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION acls_eff_ids(class_id d_class, status_id d_id32, action_id d_id32, acl_ids d_acls) IS 'Список id эффективных ACL';


--
-- Name: array_remove(anyarray, anyelement); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION array_remove(a anyarray, b anyelement) RETURNS anyarray
    LANGUAGE sql IMMUTABLE
    AS $_$ /* ws:ws:19_utils.sql / 96 */ 
SELECT array_agg(x) FROM unnest($1) x WHERE x <> $2;
$_$;


--
-- Name: class; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE class (
    id d_class NOT NULL,
    up_id d_class,
    id_count d_cnt DEFAULT 0 NOT NULL,
    is_ext boolean NOT NULL,
    sort d_sort,
    code d_code NOT NULL,
    name text NOT NULL
);


--
-- Name: TABLE class; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE class IS 'Класс объекта';


--
-- Name: COLUMN class.id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class.id IS 'ID класса';


--
-- Name: COLUMN class.up_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class.up_id IS 'ID класса-предка';


--
-- Name: COLUMN class.id_count; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class.id_count IS 'Количество идентификаторов экземпляра класса';


--
-- Name: COLUMN class.is_ext; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class.is_ext IS 'ID экземпляра предка входит в ID экземпляра';


--
-- Name: COLUMN class.sort; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class.sort IS 'Сортировка в списке классов';


--
-- Name: COLUMN class.code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class.code IS 'Код класса';


--
-- Name: COLUMN class.name; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class.name IS 'Название класса';


--
-- Name: class(d_class); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION class(a_id d_class DEFAULT 0) RETURNS SETOF class
    LANGUAGE sql STABLE STRICT
    AS $_$ /* ws:ws:52_class.sql / 39 */ 
  SELECT * FROM ws.class WHERE $1 IN (id, 0) ORDER BY id;
$_$;


--
-- Name: FUNCTION class(a_id d_class); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION class(a_id d_class) IS 'Атрибуты классов по ID';


--
-- Name: class_acl; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE class_acl (
    class_id d_class NOT NULL,
    id d_acl NOT NULL,
    is_sys boolean NOT NULL,
    sort d_sort,
    name text NOT NULL
);


--
-- Name: TABLE class_acl; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE class_acl IS 'Уровень доступа к объекту';


--
-- Name: COLUMN class_acl.class_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_acl.class_id IS 'ID класса';


--
-- Name: COLUMN class_acl.id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_acl.id IS 'ID уровня доступа';


--
-- Name: COLUMN class_acl.is_sys; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_acl.is_sys IS 'Не воказывать в интерфейсе';


--
-- Name: COLUMN class_acl.sort; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_acl.sort IS 'Сортировка в списке уровней доступа';


--
-- Name: COLUMN class_acl.name; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_acl.name IS 'Название уровня доступа';


--
-- Name: class_acl(d_class, d_id32); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION class_acl(a_class_id d_class DEFAULT 0, a_id d_id32 DEFAULT 0) RETURNS SETOF class_acl
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_class.sql / 92 */ 
  SELECT * FROM ws.class_acl WHERE $1 IN (class_id, 0) AND $2 IN (id, 0) ORDER BY 1,2;
$_$;


--
-- Name: FUNCTION class_acl(a_class_id d_class, a_id d_id32); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION class_acl(a_class_id d_class, a_id d_id32) IS 'Описание уровней доступа класса';


--
-- Name: class_action; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE class_action (
    class_id d_class NOT NULL,
    id d_id32 NOT NULL,
    sort d_sort,
    name text NOT NULL
);


--
-- Name: TABLE class_action; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE class_action IS 'Акция объекта';


--
-- Name: COLUMN class_action.class_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_action.class_id IS 'ID класса';


--
-- Name: COLUMN class_action.id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_action.id IS 'ID акции';


--
-- Name: COLUMN class_action.sort; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_action.sort IS 'Сортировка в списке акций';


--
-- Name: COLUMN class_action.name; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_action.name IS 'Название акции';


--
-- Name: class_action(d_class, d_id32); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION class_action(a_class_id d_class DEFAULT 0, a_id d_id32 DEFAULT 0) RETURNS SETOF class_action
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_class.sql / 71 */ 
  SELECT * FROM ws.class_action WHERE $1 IN (class_id, 0) AND $2 IN (id, 0) ORDER BY 1,2;
$_$;


--
-- Name: FUNCTION class_action(a_class_id d_class, a_id d_id32); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION class_action(a_class_id d_class, a_id d_id32) IS 'Описание акции класса';


--
-- Name: class_by_code(d_code); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION class_by_code(a_code d_code) RETURNS SETOF class
    LANGUAGE sql STABLE STRICT
    AS $_$ /* ws:ws:52_class.sql / 46 */ 
  SELECT * FROM ws.class WHERE code = $1 ORDER BY name;
$_$;


--
-- Name: FUNCTION class_by_code(a_code d_code); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION class_by_code(a_code d_code) IS 'Атрибуты классов по коду';


--
-- Name: class_code(d_class); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION class_code(a_id d_class) RETURNS d_code
    LANGUAGE sql STABLE STRICT
    AS $_$ /* ws:ws:52_class.sql / 32 */ 
  SELECT code FROM ws.class WHERE id = $1;
$_$;


--
-- Name: FUNCTION class_code(a_id d_class); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION class_code(a_id d_class) IS 'Код класса по ID';


--
-- Name: class_id(d_code); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION class_id(a_code d_code) RETURNS d_class
    LANGUAGE sql STABLE STRICT
    AS $_$ /* ws:ws:52_class.sql / 25 */ 
  SELECT id FROM ws.class WHERE code = $1;
$_$;


--
-- Name: FUNCTION class_id(a_code d_code); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION class_id(a_code d_code) IS 'ID класса по коду';


--
-- Name: class_status; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE class_status (
    class_id d_class NOT NULL,
    id d_id32 NOT NULL,
    sort d_sort,
    name text NOT NULL
);


--
-- Name: TABLE class_status; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE class_status IS 'Статус объекта';


--
-- Name: COLUMN class_status.class_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status.class_id IS 'ID класса';


--
-- Name: COLUMN class_status.id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status.id IS 'ID статуса';


--
-- Name: COLUMN class_status.sort; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status.sort IS 'Сортировка в списке статусов';


--
-- Name: COLUMN class_status.name; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status.name IS 'Название статуса';


--
-- Name: class_status(d_class, d_id32); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION class_status(a_class_id d_class DEFAULT 0, a_id d_id32 DEFAULT 0) RETURNS SETOF class_status
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_class.sql / 78 */ 
  SELECT * FROM ws.class_status WHERE $1 IN (class_id, 0) AND $2 IN (id, 0) ORDER BY 1,2;
$_$;


--
-- Name: FUNCTION class_status(a_class_id d_class, a_id d_id32); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION class_status(a_class_id d_class, a_id d_id32) IS 'Название статуса по ID и коду класса';


--
-- Name: class_action_acl; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE class_action_acl (
    class_id d_class NOT NULL,
    action_id d_id32 NOT NULL,
    acl_id d_acl NOT NULL
);


--
-- Name: TABLE class_action_acl; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE class_action_acl IS 'Уровень доступа для акции объекта';


--
-- Name: COLUMN class_action_acl.class_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_action_acl.class_id IS 'ID класса';


--
-- Name: COLUMN class_action_acl.action_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_action_acl.action_id IS 'ID акции';


--
-- Name: COLUMN class_action_acl.acl_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_action_acl.acl_id IS 'ID уровня доступа';


--
-- Name: class_status_action; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE class_status_action (
    class_id d_class NOT NULL,
    status_id d_id32 NOT NULL,
    action_id d_id32 NOT NULL
);


--
-- Name: TABLE class_status_action; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE class_status_action IS 'Акция по статусу объекта';


--
-- Name: COLUMN class_status_action.class_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action.class_id IS 'ID класса';


--
-- Name: COLUMN class_status_action.status_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action.status_id IS 'ID статуса';


--
-- Name: COLUMN class_status_action.action_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action.action_id IS 'ID акции';


--
-- Name: class_status_action_acl_addon; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE class_status_action_acl_addon (
    class_id d_class NOT NULL,
    status_id d_id32 NOT NULL,
    action_id d_id32 NOT NULL,
    acl_id d_acl NOT NULL,
    is_addon boolean DEFAULT false NOT NULL
);


--
-- Name: TABLE class_status_action_acl_addon; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE class_status_action_acl_addon IS 'Дополнения (+/-) к итоговым разрешениям';


--
-- Name: COLUMN class_status_action_acl_addon.class_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_acl_addon.class_id IS 'ID класса';


--
-- Name: COLUMN class_status_action_acl_addon.status_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_acl_addon.status_id IS 'ID статуса';


--
-- Name: COLUMN class_status_action_acl_addon.action_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_acl_addon.action_id IS 'ID акции';


--
-- Name: COLUMN class_status_action_acl_addon.acl_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_acl_addon.acl_id IS 'ID уровня доступа';


--
-- Name: COLUMN class_status_action_acl_addon.is_addon; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_acl_addon.is_addon IS 'Строка является добавлением разрешения';


--
-- Name: class_status_action_acl; Type: VIEW; Schema: ws; Owner: -
--

CREATE VIEW class_status_action_acl AS
    (SELECT sa.class_id, sa.status_id, sa.action_id, aa.acl_id, NULL::boolean AS is_addon FROM (class_status_action sa JOIN class_action_acl aa USING (class_id, action_id)) UNION SELECT class_status_action_acl_addon.class_id, class_status_action_acl_addon.status_id, class_status_action_acl_addon.action_id, class_status_action_acl_addon.acl_id, class_status_action_acl_addon.is_addon FROM class_status_action_acl_addon WHERE class_status_action_acl_addon.is_addon) EXCEPT SELECT class_status_action_acl_addon.class_id, class_status_action_acl_addon.status_id, class_status_action_acl_addon.action_id, class_status_action_acl_addon.acl_id, NULL::boolean AS is_addon FROM class_status_action_acl_addon WHERE (NOT class_status_action_acl_addon.is_addon);


--
-- Name: VIEW class_status_action_acl; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON VIEW class_status_action_acl IS 'class_status_action_acl';


--
-- Name: COLUMN class_status_action_acl.class_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_acl.class_id IS 'ID класса';


--
-- Name: COLUMN class_status_action_acl.status_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_acl.status_id IS 'ID статуса';


--
-- Name: COLUMN class_status_action_acl.action_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_acl.action_id IS 'ID акции';


--
-- Name: COLUMN class_status_action_acl.acl_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_acl.acl_id IS 'ID уровня доступа';


--
-- Name: COLUMN class_status_action_acl.is_addon; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_acl.is_addon IS 'Строка является добавлением разрешения';


--
-- Name: class_status_action_acl_ext; Type: VIEW; Schema: ws; Owner: -
--

CREATE VIEW class_status_action_acl_ext AS
    SELECT csaa.class_id, csaa.status_id, csaa.action_id, csaa.acl_id, csaa.is_addon, cl.name AS class, s.name AS status, a1.name AS action, a2.name AS acl FROM ((((class_status_action_acl csaa JOIN class cl ON (((csaa.class_id)::integer = (cl.id)::integer))) JOIN class_status s ON ((((csaa.status_id)::integer = (s.id)::integer) AND ((csaa.class_id)::integer = (s.class_id)::integer)))) JOIN class_action a1 ON ((((csaa.action_id)::integer = (a1.id)::integer) AND ((csaa.class_id)::integer = (a1.class_id)::integer)))) JOIN class_acl a2 ON ((((csaa.acl_id)::integer = (a2.id)::integer) AND ((csaa.class_id)::integer = (a2.class_id)::integer))));


--
-- Name: VIEW class_status_action_acl_ext; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON VIEW class_status_action_acl_ext IS 'class_status_action_acl с именами class, status, action, acl';


--
-- Name: COLUMN class_status_action_acl_ext.class_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_acl_ext.class_id IS 'ID класса';


--
-- Name: COLUMN class_status_action_acl_ext.status_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_acl_ext.status_id IS 'ID статуса';


--
-- Name: COLUMN class_status_action_acl_ext.action_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_acl_ext.action_id IS 'ID акции';


--
-- Name: COLUMN class_status_action_acl_ext.acl_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_acl_ext.acl_id IS 'ID уровня доступа';


--
-- Name: COLUMN class_status_action_acl_ext.is_addon; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_acl_ext.is_addon IS 'Строка является добавлением разрешения';


--
-- Name: COLUMN class_status_action_acl_ext.class; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_acl_ext.class IS 'Название класса';


--
-- Name: COLUMN class_status_action_acl_ext.status; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_acl_ext.status IS 'Название статуса';


--
-- Name: COLUMN class_status_action_acl_ext.action; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_acl_ext.action IS 'Название акции';


--
-- Name: COLUMN class_status_action_acl_ext.acl; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_acl_ext.acl IS 'Название уровня доступа';


--
-- Name: csaa; Type: VIEW; Schema: ws; Owner: -
--

CREATE VIEW csaa AS
    SELECT class_status_action_acl_ext.class_id, class_status_action_acl_ext.status_id, class_status_action_acl_ext.action_id, class_status_action_acl_ext.acl_id, class_status_action_acl_ext.is_addon, class_status_action_acl_ext.class, class_status_action_acl_ext.status, class_status_action_acl_ext.action, class_status_action_acl_ext.acl FROM class_status_action_acl_ext;


--
-- Name: VIEW csaa; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON VIEW csaa IS 'Синоним class_status_action_acl_ext';


--
-- Name: COLUMN csaa.class_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN csaa.class_id IS 'ID класса';


--
-- Name: COLUMN csaa.status_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN csaa.status_id IS 'ID статуса';


--
-- Name: COLUMN csaa.action_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN csaa.action_id IS 'ID акции';


--
-- Name: COLUMN csaa.acl_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN csaa.acl_id IS 'ID уровня доступа';


--
-- Name: COLUMN csaa.is_addon; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN csaa.is_addon IS 'Строка является добавлением разрешения';


--
-- Name: COLUMN csaa.class; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN csaa.class IS 'Название класса';


--
-- Name: COLUMN csaa.status; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN csaa.status IS 'Название статуса';


--
-- Name: COLUMN csaa.action; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN csaa.action IS 'Название акции';


--
-- Name: COLUMN csaa.acl; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN csaa.acl IS 'Название уровня доступа';


--
-- Name: class_status_action_acl(d_class, d_id32, d_id32, d_id32); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION class_status_action_acl(a_class_id d_class DEFAULT 0, a_status_id d_id32 DEFAULT 0, a_action_id d_id32 DEFAULT 0, a_acl_id d_id32 DEFAULT 0) RETURNS SETOF csaa
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_class.sql / 99 */ 
  SELECT * FROM ws.csaa WHERE $1 IN (class_id, 0) AND $2 IN (status_id, 0) AND $3 IN (action_id, 0) AND $4 IN (acl_id, 0) ORDER BY 1, 2, 3, 4;
$_$;


--
-- Name: FUNCTION class_status_action_acl(a_class_id d_class, a_status_id d_id32, a_action_id d_id32, a_acl_id d_id32); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION class_status_action_acl(a_class_id d_class, a_status_id d_id32, a_action_id d_id32, a_acl_id d_id32) IS 'Статусы и ACL для заданной акции';


--
-- Name: compile_errors_chk(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION compile_errors_chk() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$ /* ws:ws:50_pkg.sql / 25 */ 
  DECLARE
    v_t TIMESTAMP := CURRENT_TIMESTAMP;
  BEGIN
    SELECT INTO v_t stamp FROM ws.compile_errors WHERE stamp = v_t LIMIT 1;
      IF FOUND THEN
        RAISE EXCEPTION '***************** Errors found *****************';
      END IF;
    RETURN 'Ok';
  END;
$$;


--
-- Name: const_error_core_no_data(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION const_error_core_no_data() RETURNS d_errcode
    LANGUAGE sql IMMUTABLE
    AS $$ /* ws:ws:19_const.sql / 60 */ 
  SELECT 'Y0010'::ws.d_errcode
$$;


--
-- Name: FUNCTION const_error_core_no_data(); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION const_error_core_no_data() IS 'нет данных';


--
-- Name: const_error_core_no_required_value(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION const_error_core_no_required_value() RETURNS d_errcode
    LANGUAGE sql IMMUTABLE
    AS $$ /* ws:ws:19_const.sql / 42 */ 
  SELECT 'Y0001'::ws.d_errcode
$$;


--
-- Name: FUNCTION const_error_core_no_required_value(); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION const_error_core_no_required_value() IS 'не задано обязательное значение';


--
-- Name: const_error_core_value_not_match_format(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION const_error_core_value_not_match_format() RETURNS d_errcode
    LANGUAGE sql IMMUTABLE
    AS $$ /* ws:ws:19_const.sql / 54 */ 
  SELECT 'Y0003'::ws.d_errcode
$$;


--
-- Name: FUNCTION const_error_core_value_not_match_format(); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION const_error_core_value_not_match_format() IS 'значение не соответствует шаблону';


--
-- Name: const_error_core_value_not_match_rule(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION const_error_core_value_not_match_rule() RETURNS d_errcode
    LANGUAGE sql IMMUTABLE
    AS $$ /* ws:ws:19_const.sql / 48 */ 
  SELECT 'Y0002'::ws.d_errcode
$$;


--
-- Name: FUNCTION const_error_core_value_not_match_rule(); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION const_error_core_value_not_match_rule() IS 'значение не соответствует условию';


--
-- Name: const_error_system_acl_check_not_found(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION const_error_system_acl_check_not_found() RETURNS d_errcode
    LANGUAGE sql IMMUTABLE
    AS $$ /* ws:ws:19_const.sql / 90 */ 
  SELECT 'Y0105'::ws.d_errcode
$$;


--
-- Name: FUNCTION const_error_system_acl_check_not_found(); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION const_error_system_acl_check_not_found() IS 'не найдена проверка для acl';


--
-- Name: const_error_system_auth_required(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION const_error_system_auth_required() RETURNS d_errcode
    LANGUAGE sql IMMUTABLE
    AS $$ /* ws:ws:19_const.sql / 78 */ 
  SELECT 'Y0103'::ws.d_errcode
$$;


--
-- Name: FUNCTION const_error_system_auth_required(); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION const_error_system_auth_required() IS 'необходима авторизация (не задан идентификатор сессии)';


--
-- Name: const_error_system_external_access_forbidden(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION const_error_system_external_access_forbidden() RETURNS d_errcode
    LANGUAGE sql IMMUTABLE
    AS $$ /* ws:ws:19_const.sql / 72 */ 
  SELECT 'Y0102'::ws.d_errcode
$$;


--
-- Name: FUNCTION const_error_system_external_access_forbidden(); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION const_error_system_external_access_forbidden() IS 'внешний доступ к методу запрещен';


--
-- Name: const_error_system_incorrect_acl_code(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION const_error_system_incorrect_acl_code() RETURNS d_errcode
    LANGUAGE sql IMMUTABLE
    AS $$ /* ws:ws:19_const.sql / 66 */ 
  SELECT 'Y0101'::ws.d_errcode
$$;


--
-- Name: FUNCTION const_error_system_incorrect_acl_code(); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION const_error_system_incorrect_acl_code() IS 'недопустимый код acl';


--
-- Name: const_error_system_incorrect_session_id(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION const_error_system_incorrect_session_id() RETURNS d_errcode
    LANGUAGE sql IMMUTABLE
    AS $$ /* ws:ws:19_const.sql / 84 */ 
  SELECT 'Y0104'::ws.d_errcode
$$;


--
-- Name: FUNCTION const_error_system_incorrect_session_id(); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION const_error_system_incorrect_session_id() IS 'некорректный идентификатор сессии';


--
-- Name: const_error_system_incorrect_status_id(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION const_error_system_incorrect_status_id() RETURNS d_errcode
    LANGUAGE sql IMMUTABLE
    AS $$ /* ws:ws:19_const.sql / 96 */ 
  SELECT 'Y0106'::ws.d_errcode
$$;


--
-- Name: FUNCTION const_error_system_incorrect_status_id(); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION const_error_system_incorrect_status_id() IS 'некорректный идентификатор статуса';


--
-- Name: const_realm_upload(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION const_realm_upload() RETURNS d_code
    LANGUAGE sql IMMUTABLE
    AS $$ /* ws:ws:19_const.sql / 103 */ 
  SELECT 'upload'::ws.d_code
$$;


--
-- Name: FUNCTION const_realm_upload(); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION const_realm_upload() IS 'область вызова методов загрузки файлов';


--
-- Name: const_rpc_err_noaccess(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION const_rpc_err_noaccess() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ /* ws:ws:19_const.sql / 35 */ 
  SELECT '42501'::TEXT
$$;


--
-- Name: FUNCTION const_rpc_err_noaccess(); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION const_rpc_err_noaccess() IS 'Константа: RPC код ошибки отсутствия доступа';


--
-- Name: const_rpc_err_nodata(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION const_rpc_err_nodata() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ /* ws:ws:19_const.sql / 28 */ 
  SELECT '02000'::TEXT
$$;


--
-- Name: FUNCTION const_rpc_err_nodata(); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION const_rpc_err_nodata() IS 'Константа: RPC код ошибки отсутствия данных';


--
-- Name: date2xml(date); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION date2xml(a date) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$ /* ws:ws:19_utils.sql / 108 */ 
SELECT to_char($1, E'YYYY-MM-DD');
$_$;


--
-- Name: date_info(date, integer); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION date_info(a_date date DEFAULT ('now'::text)::date, a_offset integer DEFAULT 0) RETURNS t_date_info
    LANGUAGE plpgsql IMMUTABLE
    AS $$ /* ws:ws:52_i18n_dep.sql / 25 */ 
  DECLARE
    r       ws.t_date_info;
  BEGIN
    r.date          := COALESCE(a_date, CURRENT_DATE) + a_offset;
    r.day           := date_part('day', r.date);
    r.month         := date_part('month', r.date);
    r.year          := date_part('year', r.date);
    r.date_month    := date_trunc('month', r.date);
    r.date_year     := date_trunc('year', r.date);
    r.date_name     := date_name(r.date);
    r.month_name    := month_name(r.date);
    r.date_name_doc := date_name_doc(r.date);
    r.fmt_calend    := '%d.%m.%Y';
    r.fmt_example   := 'ДД.ММ.ГГГГ';

    RETURN r;
  END;
$$;


--
-- Name: FUNCTION date_info(a_date date, a_offset integer); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION date_info(a_date date, a_offset integer) IS 'Атрибуты заданной даты';


--
-- Name: dt; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE dt (
    code d_code NOT NULL,
    parent_code d_code,
    base_code d_code,
    allow_null boolean DEFAULT true NOT NULL,
    def_val text,
    anno text NOT NULL,
    is_list boolean DEFAULT false NOT NULL,
    is_complex boolean DEFAULT false NOT NULL,
    is_sql boolean DEFAULT false NOT NULL
);


--
-- Name: TABLE dt; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE dt IS 'Описание типа';


--
-- Name: COLUMN dt.code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt.code IS 'Код типа';


--
-- Name: COLUMN dt.parent_code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt.parent_code IS 'Код родительского типа';


--
-- Name: COLUMN dt.base_code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt.base_code IS 'Код базового типа';


--
-- Name: COLUMN dt.allow_null; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt.allow_null IS 'Разрешен NULL';


--
-- Name: COLUMN dt.def_val; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt.def_val IS 'Значение по умолчанию';


--
-- Name: COLUMN dt.anno; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt.anno IS 'Аннотация';


--
-- Name: COLUMN dt.is_list; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt.is_list IS 'Конструктор типа - массив';


--
-- Name: COLUMN dt.is_complex; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt.is_complex IS 'Конструктор типа - структура';


--
-- Name: COLUMN dt.is_sql; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt.is_sql IS 'Тип создан в БД';


--
-- Name: dt(d_code); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION dt(a_code d_code DEFAULT NULL::text) RETURNS SETOF dt
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_dt.sql / 63 */ 
  SELECT * FROM ws.dt WHERE code LIKE COALESCE($1, '%') ORDER BY 1;
$_$;


--
-- Name: FUNCTION dt(a_code d_code); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION dt(a_code d_code) IS 'Атрибуты типа по маске кода';


--
-- Name: dt_code(d_code); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION dt_code(a_code d_code) RETURNS d_code
    LANGUAGE plpgsql
    AS $$ /* ws:ws:52_dt.sql / 48 */ 
  DECLARE
    v_code TEXT;
  BEGIN
    SELECT code INTO v_code FROM ws.dt WHERE code IN (a_code, ws.pg_cs(a_code), 'ws.'||a_code) ORDER BY 1;
    IF v_code IS NULL and a_code ~ '^d_' THEN
      v_code := current_schema() || '.' || a_code;
    END IF;
    RETURN v_code;
  END;
$$;


--
-- Name: dt_facet; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE dt_facet (
    code d_code NOT NULL,
    facet_id d_id32 NOT NULL,
    value text NOT NULL,
    base_code d_code NOT NULL,
    anno text
);


--
-- Name: TABLE dt_facet; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE dt_facet IS 'Значение ограничения типа';


--
-- Name: COLUMN dt_facet.code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt_facet.code IS 'Код типа';


--
-- Name: COLUMN dt_facet.facet_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt_facet.facet_id IS 'ID ограничения';


--
-- Name: COLUMN dt_facet.value; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt_facet.value IS 'Значение ограничения';


--
-- Name: COLUMN dt_facet.base_code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt_facet.base_code IS 'Код базового типа';


--
-- Name: COLUMN dt_facet.anno; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt_facet.anno IS 'Аннотация ограничения';


--
-- Name: dt_facet(d_code); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION dt_facet(a_code d_code) RETURNS SETOF dt_facet
    LANGUAGE sql STABLE STRICT
    AS $_$ /* ws:ws:52_dt.sql / 91 */ 
  SELECT * FROM ws.dt_facet WHERE code = $1 ORDER BY 2;
$_$;


--
-- Name: FUNCTION dt_facet(a_code d_code); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION dt_facet(a_code d_code) IS 'Атрибуты ограничения типа по коду типа';


--
-- Name: dt_facet_insupd_trigger(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION dt_facet_insupd_trigger() RETURNS trigger
    LANGUAGE plpgsql STABLE
    AS $$ /* ws:ws:60_trig.sql / 79 */ 
  DECLARE
    v_code ws.d_code;
  BEGIN
    v_code := ws.dt_parent_base_code(NEW.code);
    IF v_code IS NULL THEN
      RAISE EXCEPTION 'Incorrect dt id: %', NEW.code;
    END IF;
    NEW.base_code := v_code;
    RETURN NEW;
  END;
$$;


--
-- Name: dt_insupd_trigger(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION dt_insupd_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ /* ws:ws:60_trig.sql / 25 */ 
  DECLARE
    v_code ws.d_code;
  BEGIN
    IF NEW.code = NEW.parent_code AND (NEW.is_complex OR NEW.is_list) THEN
      -- базовый тип - только скаляр
      RAISE EXCEPTION 'Unsupported value set: % % % %', NEW.code, NEW.parent_code, NEW.is_complex, NEW.is_list;
    END IF;
    IF NEW.parent_code IS NOT NULL THEN
      -- определить base_id если задан parent_code
      IF NEW.code = NEW.parent_code THEN
        NEW.base_code := NEW.code;
      ELSE
        v_code := ws.dt_parent_base_code(NEW.parent_code);
        IF v_code IS NULL then
           v_code := ws.pg_register_type(split_part(NEW.parent_code, '.', 2));
           v_code := ws.dt_parent_base_code(NEW.parent_code);
        END IF;
        IF v_code IS NULL THEN
          RAISE EXCEPTION 'Incorrect parent_code: %', NEW.parent_code;
        END IF;
        NEW.base_code := v_code;
      END IF;
    END IF;
    -- TODO: запретить изменение is_list и is_complex для parent
    -- NEW.anno := COALESCE(NEW.anno, NEW.code);
    RETURN NEW;
  END;
$$;


--
-- Name: dt_is_complex(d_code); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION dt_is_complex(a_code d_code) RETURNS boolean
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_dt.sql / 41 */ 
  SELECT is_complex FROM ws.dt WHERE code = $1;
$_$;


--
-- Name: FUNCTION dt_is_complex(a_code d_code); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION dt_is_complex(a_code d_code) IS 'Значение is_complex для заданного типа';


--
-- Name: dt_parent_base_code(d_code); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION dt_parent_base_code(a_code d_code) RETURNS d_code
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_dt.sql / 25 */ 
  SELECT base_code FROM ws.dt WHERE code = $1 AND NOT is_complex;
  -- у элементов массива может быть check
  -- SELECT base_id FROM ws.dt WHERE id = $1 AND NOT is_list AND NOT is_complex;
$_$;


--
-- Name: FUNCTION dt_parent_base_code(a_code d_code); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION dt_parent_base_code(a_code d_code) IS 'Базовый тип для заданного родительского типа';


--
-- Name: dt_part; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE dt_part (
    dt_code d_code NOT NULL,
    part_id d_cnt DEFAULT 0 NOT NULL,
    code d_code_arg NOT NULL,
    parent_code d_code NOT NULL,
    base_code d_code NOT NULL,
    allow_null boolean DEFAULT true NOT NULL,
    def_val text,
    anno text NOT NULL,
    is_list boolean DEFAULT false NOT NULL
);


--
-- Name: TABLE dt_part; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE dt_part IS 'Поля композитного типа';


--
-- Name: COLUMN dt_part.dt_code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt_part.dt_code IS 'Код комплексного типа';


--
-- Name: COLUMN dt_part.part_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt_part.part_id IS 'ID поля';


--
-- Name: COLUMN dt_part.code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt_part.code IS 'Код поля';


--
-- Name: COLUMN dt_part.parent_code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt_part.parent_code IS 'Код родительского типа';


--
-- Name: COLUMN dt_part.base_code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt_part.base_code IS 'Код базового типа';


--
-- Name: COLUMN dt_part.allow_null; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt_part.allow_null IS 'Разрешен NULL';


--
-- Name: COLUMN dt_part.def_val; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt_part.def_val IS 'Значение по умолчанию';


--
-- Name: COLUMN dt_part.anno; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt_part.anno IS 'Аннотация';


--
-- Name: COLUMN dt_part.is_list; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN dt_part.is_list IS 'Конструктор поля - массив';


--
-- Name: dt_part(d_code, d_id32); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION dt_part(a_code d_code, a_part_id d_id32 DEFAULT 0) RETURNS SETOF dt_part
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_dt.sql / 70 */ 
  SELECT * FROM ws.dt_part WHERE dt_code = $1 AND $2 IN (part_id, 0) ORDER BY 2;
$_$;


--
-- Name: FUNCTION dt_part(a_code d_code, a_part_id d_id32); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION dt_part(a_code d_code, a_part_id d_id32) IS 'Атрибуты полей комплексного типа';


--
-- Name: dt_part_insupd_trigger(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION dt_part_insupd_trigger() RETURNS trigger
    LANGUAGE plpgsql STABLE
    AS $$ /* ws:ws:60_trig.sql / 57 */ 
  DECLARE
    v_code ws.d_code;
  BEGIN
      -- проверить что в описании parent типа стоит is_complex

    IF NEW.parent_code IS NOT NULL THEN
      -- определить base_id если задан parent_code
      v_code := ws.dt_part_parent_base_code(NEW.parent_code);
      IF v_code IS NULL THEN
        RAISE EXCEPTION 'Incorrect part parent_code: %', NEW.parent_code;
      END IF;
      NEW.base_code := v_code;
    END IF;
    -- NEW.anno := COALESCE(NEW.anno, NEW.code);

    RETURN NEW;
  END;
$$;


--
-- Name: dt_part_parent_base_code(d_code); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION dt_part_parent_base_code(a_code d_code) RETURNS d_code
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_dt.sql / 34 */ 
  SELECT base_code FROM ws.dt WHERE code = $1 AND NOT is_complex;
$_$;


--
-- Name: FUNCTION dt_part_parent_base_code(a_code d_code); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION dt_part_parent_base_code(a_code d_code) IS 'Базовый тип для заданной части комплексного типа';


--
-- Name: dt_parts(d_code); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION dt_parts(a_code d_code) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$ /* ws:ws:52_dt.sql / 98 */ 
  DECLARE
    v_names TEXT[];
    r ws.dt_part;
    r_dt ws.dt;
  BEGIN
    FOR r IN
      SELECT *
      FROM ws.dt_part
      WHERE dt_code = a_code
      ORDER BY 2
    LOOP
      r_dt := ws.dt(r.parent_code);
      v_names := array_append(v_names, r.code || ' ' || r_dt.code);
    END LOOP;
    RETURN array_to_string(v_names, ', ');
  END;
$$;


--
-- Name: FUNCTION dt_parts(a_code d_code); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION dt_parts(a_code d_code) IS 'Список полей комплексного типа по коду как строка';


--
-- Name: dt_tree(d_code); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION dt_tree(a_code d_code) RETURNS SETOF d_code
    LANGUAGE sql STABLE
    AS $$ /* ws:ws:52_dt.sql / 120 */ 
  WITH RECURSIVE dtree AS (
    SELECT d.*, ARRAY[code::text] as branches
      FROM ws.dt d
      WHERE code = 'ws.d_code'
    UNION
    SELECT d.*, dtree.branches || d.code::text
      FROM ws.dt d
        JOIN dtree ON d.code = dtree.parent_code 
      WHERE NOT d.code = ANY(dtree.branches)
  )
  SELECT code 
    FROM dtree
    ORDER BY array_length(branches, 1);
$$;


--
-- Name: e_code(d_errcode); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION e_code(code d_errcode) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$ /* ws:ws:19_utils.sql / 25 */ 
  SELECT ws.sprintf('[{"code": "%s"}]', $1);
$_$;


--
-- Name: e_noaccess(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION e_noaccess() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ /* ws:ws:19_utils.sql / 31 */ 
  SELECT ws.sprintf('[{"code": "%s"}]', ws.const_rpc_err_noaccess());
$$;


--
-- Name: e_nodata(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION e_nodata() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ /* ws:ws:19_utils.sql / 37 */ 
  SELECT ws.sprintf('[{"code": "%s"}]', ws.const_rpc_err_nodata());
-- P0002  no_data_found
$$;


--
-- Name: epoch2timestamp(integer); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION epoch2timestamp(a_epoch integer DEFAULT 0) RETURNS timestamp without time zone
    LANGUAGE sql IMMUTABLE
    AS $_$ /* ws:ws:19_utils.sql / 72 */ 
SELECT CASE
  WHEN $1 = 0 THEN NULL
  ELSE timezone(
    (SELECT setting FROM pg_settings WHERE name = 'TimeZone')
    , (TIMESTAMPTZ 'epoch' + $1 * INTERVAL '1 second')::timestamptz
    )
END;
$_$;


--
-- Name: epoch2timestamptz(integer); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION epoch2timestamptz(a_epoch integer DEFAULT 0) RETURNS timestamp with time zone
    LANGUAGE sql IMMUTABLE
    AS $_$ /* ws:ws:19_utils.sql / 66 */ 
SELECT CASE WHEN $1 = 0 THEN NULL ELSE TIMESTAMPTZ 'epoch' + $1 * INTERVAL '1 second' END;
$_$;


SET search_path = i18n_def, pg_catalog;

--
-- Name: error_message; Type: TABLE; Schema: i18n_def; Owner: -
--

CREATE TABLE error_message (
    code ws.d_errcode NOT NULL,
    id_count ws.d_cnt DEFAULT 0 NOT NULL,
    message ws.d_format NOT NULL
);


--
-- Name: TABLE error_message; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON TABLE error_message IS 'Сообщение об ошибке в локали схемы БД';


--
-- Name: COLUMN error_message.code; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN error_message.code IS 'Код ошибки';


--
-- Name: COLUMN error_message.id_count; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN error_message.id_count IS 'Количество аргументов в строке сообщения';


--
-- Name: COLUMN error_message.message; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN error_message.message IS 'Форматированная строка сообщения об ошибке';


--
-- Name: error; Type: VIEW; Schema: i18n_def; Owner: -
--

CREATE VIEW error AS
    SELECT error_message.code, error_message.id_count, error_message.message FROM error_message;


--
-- Name: VIEW error; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON VIEW error IS 'Описание ошибки';


--
-- Name: COLUMN error.code; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN error.code IS 'Код ошибки';


--
-- Name: COLUMN error.id_count; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN error.id_count IS 'Количество аргументов в строке сообщения';


--
-- Name: COLUMN error.message; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN error.message IS 'Форматированная строка сообщения об ошибке';


SET search_path = ws, pg_catalog;

--
-- Name: error_info(d_errcode); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION error_info(a_code d_errcode) RETURNS i18n_def.error
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_main.sql / 180 */ 
  SELECT * FROM error WHERE code = $1;
$_$;


--
-- Name: FUNCTION error_info(a_code d_errcode); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION error_info(a_code d_errcode) IS 'Описание ошибки';


--
-- Name: error_str(d_errcode, text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION error_str(code d_errcode, arg text DEFAULT ''::text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$ /* ws:ws:19_utils.sql / 44 */ 
  SELECT ws.sprintf('[{"code": "%s", "id":"%s", "arg": "%s"}]', $1::TEXT, '_', $2);
$_$;


--
-- Name: facet; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE facet (
    id d_id32 NOT NULL,
    code d_codei NOT NULL,
    anno text NOT NULL
);


--
-- Name: TABLE facet; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE facet IS 'Вид ограничений типов';


--
-- Name: COLUMN facet.id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN facet.id IS 'ID ограничения';


--
-- Name: COLUMN facet.code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN facet.code IS 'Код ограничения';


--
-- Name: COLUMN facet.anno; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN facet.anno IS 'Аннотация';


--
-- Name: facet(d_id32); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION facet(a_id d_id32) RETURNS SETOF facet
    LANGUAGE sql STABLE STRICT
    AS $_$ /* ws:ws:52_dt.sql / 84 */ 
  SELECT * FROM ws.facet WHERE $1 IN (0, id) ORDER BY 2;
$_$;


--
-- Name: FUNCTION facet(a_id d_id32); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION facet(a_id d_id32) IS 'Атрибуты ограничения по id';


--
-- Name: facet_id(d_codei); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION facet_id(a_code d_codei) RETURNS d_id32
    LANGUAGE sql STABLE STRICT
    AS $_$ /* ws:ws:52_dt.sql / 77 */ 
  SELECT id FROM ws.facet WHERE code = $1;
$_$;


--
-- Name: FUNCTION facet_id(a_code d_codei); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION facet_id(a_code d_codei) IS 'ID ограничения типа по коду';


--
-- Name: info_acl(d_sid); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION info_acl(a__sid d_sid) RETURNS SETOF d_acl
    LANGUAGE sql IMMUTABLE
    AS $$ /* ws:ws:52_info.sql / 32 */ 
  SELECT 1::ws.d_acl;
$$;


--
-- Name: FUNCTION info_acl(a__sid d_sid); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION info_acl(a__sid d_sid) IS 'ACL sid для инфо';


--
-- Name: info_server(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION info_server() RETURNS SETOF server
    LANGUAGE sql STABLE
    AS $$ /* ws:ws:52_info.sql / 40 */ 
  SELECT * FROM ws.server WHERE id = 1
$$;


--
-- Name: info_status(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION info_status() RETURNS d_id32
    LANGUAGE sql IMMUTABLE
    AS $$ /* ws:ws:52_info.sql / 25 */ 
  SELECT 1::ws.d_id32
$$;


--
-- Name: FUNCTION info_status(); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION info_status() IS 'Статус инфо';


--
-- Name: is_ids_enough(d_class, text, text, text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION is_ids_enough(a_class_id d_class, a_id text DEFAULT NULL::text, a_id1 text DEFAULT NULL::text, a_id2 text DEFAULT NULL::text) RETURNS boolean
    LANGUAGE plpgsql STABLE
    AS $$ /* ws:ws:52_main.sql / 89 */ 
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
$$;


--
-- Name: FUNCTION is_ids_enough(a_class_id d_class, a_id text, a_id1 text, a_id2 text); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION is_ids_enough(a_class_id d_class, a_id text, a_id1 text, a_id2 text) IS 'Достаточно ли заданных ID для идентификации экземпляра класса';


--
-- Name: mask2format(text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION mask2format(a_mask text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $_$ /* ws:ws:19_utils.sql / 140 */ 
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


--
-- Name: FUNCTION mask2format(a_mask text); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION mask2format(a_mask text) IS 'Сформировать строку формата по шаблону';


--
-- Name: mask_is_multi(text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION mask_is_multi(a_mask text) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$ /* ws:ws:19_utils.sql / 132 */ 
  SELECT $1 ~ E'(\\?|,|:)'
$_$;


--
-- Name: FUNCTION mask_is_multi(a_mask text); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION mask_is_multi(a_mask text) IS 'Шаблон соответствует нескольким значениям';


--
-- Name: max(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION max(a timestamp without time zone, b timestamp without time zone) RETURNS timestamp without time zone
    LANGUAGE sql IMMUTABLE
    AS $_$ /* ws:ws:19_utils.sql / 90 */ 
SELECT CASE WHEN $1 < $2 THEN $2 ELSE $1 END;
$_$;


--
-- Name: method; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE method (
    code d_code NOT NULL,
    class_id d_class NOT NULL,
    action_id d_id32 NOT NULL,
    cache_id d_id32 NOT NULL,
    rvf_id d_id32 NOT NULL,
    is_write boolean DEFAULT false NOT NULL,
    is_i18n boolean DEFAULT false NOT NULL,
    is_sql boolean DEFAULT true NOT NULL,
    is_strict boolean DEFAULT false,
    code_real d_sub NOT NULL,
    arg_dt_code d_code,
    rv_dt_code d_code,
    name text NOT NULL,
    args_exam text,
    args text NOT NULL,
    pkg text DEFAULT pg_cs() NOT NULL,
    realm_code d_code
);


--
-- Name: TABLE method; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE method IS 'Метод API';


--
-- Name: COLUMN method.code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN method.code IS 'внешнее имя метода';


--
-- Name: COLUMN method.class_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN method.class_id IS 'ID класса, к которому относится метод';


--
-- Name: COLUMN method.action_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN method.action_id IS 'ID акции, которой соответствует метод';


--
-- Name: COLUMN method.cache_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN method.cache_id IS 'ID кэша, в котором размещается результат вызова метода';


--
-- Name: COLUMN method.rvf_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN method.rvf_id IS 'ID формата результата (для SQL-методов)';


--
-- Name: COLUMN method.is_write; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN method.is_write IS 'метод меняет БД';


--
-- Name: COLUMN method.is_i18n; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN method.is_i18n IS 'метод поддерживает интернационализацию';


--
-- Name: COLUMN method.is_sql; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN method.is_sql IS 'метод реализован как sql function';


--
-- Name: COLUMN method.is_strict; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN method.is_strict IS 'отсутствие результата порождает ошибку';


--
-- Name: COLUMN method.code_real; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN method.code_real IS 'имя вызываемого метода (для не-sql - включая package)';


--
-- Name: COLUMN method.arg_dt_code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN method.arg_dt_code IS 'Код типа, описывающего аргументы';


--
-- Name: COLUMN method.rv_dt_code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN method.rv_dt_code IS 'Код типа результата';


--
-- Name: COLUMN method.name; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN method.name IS 'внешнее описание метода';


--
-- Name: COLUMN method.args_exam; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN method.args_exam IS 'пример вызова функции';


--
-- Name: COLUMN method.args; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN method.args IS 'строка списка аргументов';


--
-- Name: COLUMN method.pkg; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN method.pkg IS 'пакет, в котором метод зарегистрирован';


--
-- Name: COLUMN method.realm_code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN method.realm_code IS 'код области вызова метода';


--
-- Name: method_by_action(d_class, d_id32); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION method_by_action(a_class_id d_class DEFAULT 0, a_action_id d_id32 DEFAULT 0) RETURNS SETOF method
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_main.sql / 146 */ 
  SELECT *
    FROM ws.method WHERE $1 IN (class_id, 0) AND $2 IN (action_id, 0) ORDER BY 2,3,1;
$_$;


--
-- Name: FUNCTION method_by_action(a_class_id d_class, a_action_id d_id32); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION method_by_action(a_class_id d_class, a_action_id d_id32) IS 'Атрибуты страницы  по акции и идентификаторам';


--
-- Name: method_by_code(d_code); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION method_by_code(a_code d_code) RETURNS SETOF method
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_main.sql / 138 */ 
  SELECT * FROM ws.method WHERE code = $1 ORDER BY 2,3,1;
--  SELECT * FROM ws.method WHERE code LIKE $1 ORDER BY 2,3,1;
$_$;


--
-- Name: FUNCTION method_by_code(a_code d_code); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION method_by_code(a_code d_code) IS 'Атрибуты метода по коду';


--
-- Name: method_insupd_trigger(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION method_insupd_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ /* ws:ws:60_trig.sql / 109 */ 
  DECLARE
    r_proc ws.t_pg_proc_info;
    v_code text;
    v_dt_code ws.d_code;
  BEGIN
    IF NEW.code_real ~ ':' THEN
      NEW.is_sql := FALSE;
      NEW.args := COALESCE(ws.dt_parts(NEW.arg_dt_code), '');
      -- TODO: check cache
      -- TODO: check plugin config
    ELSE
      -- проверим наличие функции
      NEW.code_real  := COALESCE(NEW.code_real, NEW.code);

      r_proc := ws.pg_proc_info(split_part(NEW.code_real, '.', 1), split_part(NEW.code_real, '.', 2));
      IF r_proc IS NULL THEN
        RAISE EXCEPTION 'Unknown internal func (%)', NEW.code_real;
        RETURN NULL;
      END IF;

      v_code := r_proc.rt_name;
  /*    IF r_proc.schema = ws.pg_cs('') THEN
         -- в этом случае схемы в имени не будет
         v_code := r_proc.schema || '.'|| v_code;
      END IF;
    */  
      IF dt_code(v_code) IS NOT NULL THEN
        NEW.rv_dt_code := dt_code(v_code);
      ELSE
        -- если это - таблицы, можем сделать авторегистрацию
        RAISE NOTICE 'Unknown rv_type: %', v_code;
        NEW.rv_dt_code := ws.pg_register_class(r_proc.rt_oid);
      END IF;

      IF NEW.arg_dt_code IS NULL THEN
        v_dt_code := ws.dt_code(split_part(NEW.code_real, '.', 1) ||'.z_'|| split_part(NEW.code_real, '.', 2)); -- NEW.code_real);
        IF v_dt_code IS NULL THEN
          -- авторегистрация типа аргументов
          v_dt_code := ws.pg_register_proarg(NEW.code_real);
        END IF;
        NEW.arg_dt_code    := v_dt_code;
      END IF;

      NEW.name := COALESCE(NEW.name, r_proc.anno);
      NEW.args := COALESCE(ws.dt_parts(v_dt_code), '');
      -- TODO: сравнить args с r_proc.args
    END IF;

    IF NEW.arg_dt_code IS NOT NULL AND NOT COALESCE(ws.dt_is_complex(NEW.arg_dt_code), false) THEN
        RAISE EXCEPTION 'Method arg type (%) must be complex', NEW.arg_dt_code;
    END IF;
    
    RAISE NOTICE 'New method: %(%) -> %.', NEW.code_real, NEW.arg_dt_code, NEW.rv_dt_code;
    RETURN NEW;
  END;
$$;


--
-- Name: method_lookup(d_code_like, d_cnt, d_cnt); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION method_lookup(a_code d_code_like DEFAULT '%'::text, a_page d_cnt DEFAULT 0, a_by d_cnt DEFAULT 0) RETURNS SETOF method
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_main.sql / 159 */ 
  SELECT *
    FROM ws.method
    WHERE code ilike '%'||$1 -- ищем по всему имени
--    WHERE lower(code) LIKE lower($1 ||'%') -- демоверсия поиска по началу с индексом
  ORDER BY 2,3,1 -- code
  OFFSET $2 * $3
  LIMIT NULLIF($3, 0);
$_$;


--
-- Name: FUNCTION method_lookup(a_code d_code_like, a_page d_cnt, a_by d_cnt); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION method_lookup(a_code d_code_like, a_page d_cnt, a_by d_cnt) IS 'Поиск метода по code';


--
-- Name: method_rv_format; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE method_rv_format (
    id d_id32 NOT NULL,
    name text NOT NULL
);


--
-- Name: TABLE method_rv_format; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE method_rv_format IS 'Формат результатов метода';


--
-- Name: COLUMN method_rv_format.id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN method_rv_format.id IS 'ID формата';


--
-- Name: COLUMN method_rv_format.name; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN method_rv_format.name IS 'Название формата';


--
-- Name: method_rvf(d_id32); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION method_rvf(a_id d_id32 DEFAULT 0) RETURNS SETOF method_rv_format
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_main.sql / 172 */ 
  SELECT * FROM ws.method_rv_format WHERE $1 IN (id, 0) ORDER BY 1;
$_$;


--
-- Name: FUNCTION method_rvf(a_id d_id32); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION method_rvf(a_id d_id32) IS 'Список форматов результата метода';


--
-- Name: min(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION min(a timestamp without time zone, b timestamp without time zone) RETURNS timestamp without time zone
    LANGUAGE sql IMMUTABLE
    AS $_$ /* ws:ws:19_utils.sql / 84 */ 
SELECT CASE WHEN $1 < $2 THEN $1 ELSE $2 END;
$_$;


--
-- Name: month_info(date); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION month_info(a_date date DEFAULT ('now'::text)::date) RETURNS t_month_info
    LANGUAGE sql IMMUTABLE
    AS $_$ /* ws:ws:52_i18n_dep.sql / 48 */ 
  SELECT
    date_trunc('month', $1)::date
    , date_trunc('month', $1 + '1 month'::interval)::date - 1
    , date_trunc('month', $1 - '1 month'::interval)::date
    , date_trunc('month', $1 + '1 month'::interval)::date
    , date_trunc('year', $1)::date
    , date_part('month', $1)::ws.d_id32
    , date_part('year', $1)::ws.d_id32
    , to_char($1, 'YYYYMM')
    , month_name($1)
    , initcap(month_name($1))
  ;
$_$;


--
-- Name: FUNCTION month_info(a_date date); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION month_info(a_date date) IS 'Атрибуты месяца заданной даты';


--
-- Name: notice(text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION notice(a_text text) RETURNS void
    LANGUAGE plpgsql
    AS $$ /* ws:ws:18_pg.sql / 473 */ 
  -- вызов RAISE NOTICE из скриптов и sql
  BEGIN
    RAISE NOTICE '%', a_text;
  END
$$;


--
-- Name: FUNCTION notice(a_text text); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION notice(a_text text) IS 'Вывод предупреждения посредством RAISE NOTICE';


--
-- Name: page_by_action(d_class, d_id32, text, text, text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION page_by_action(a_class_id d_class DEFAULT 0, a_action_id d_id32 DEFAULT 0, a_id text DEFAULT NULL::text, a_id1 text DEFAULT NULL::text, a_id2 text DEFAULT NULL::text) RETURNS SETOF t_page_info
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_main.sql / 54 */ 
  SELECT *
    , ws.sprintf(uri_fmt, $3, $4, $5)
    , ws.uri_args(ws.sprintf(uri_fmt, $3, $4, $5), uri_re)
    , ws.page_group_name(group_id)
    FROM page WHERE $1 IN (class_id, 0) AND $2 IN (action_id, 0) ORDER BY code;
$_$;


--
-- Name: FUNCTION page_by_action(a_class_id d_class, a_action_id d_id32, a_id text, a_id1 text, a_id2 text); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION page_by_action(a_class_id d_class, a_action_id d_id32, a_id text, a_id1 text, a_id2 text) IS 'Атрибуты страницы  по акции и идентификаторам';


--
-- Name: page_by_code(text, text, text, text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION page_by_code(a_code text, a_id text DEFAULT NULL::text, a_id1 text DEFAULT NULL::text, a_id2 text DEFAULT NULL::text) RETURNS SETOF t_page_info
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_main.sql / 43 */ 
  SELECT *
    , ws.sprintf(uri_fmt, $2, $3, $4)
    , ws.uri_args(ws.sprintf(uri_fmt, $2, $3, $4), uri_re)
    , ws.page_group_name(group_id)
    FROM page WHERE code LIKE $1 ORDER BY code;
$_$;


--
-- Name: FUNCTION page_by_code(a_code text, a_id text, a_id1 text, a_id2 text); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION page_by_code(a_code text, a_id text, a_id1 text, a_id2 text) IS 'Атрибуты страницы  по коду и идентификаторам';


--
-- Name: page_by_uri(text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION page_by_uri(a_uri text DEFAULT ''::text) RETURNS SETOF t_page_info
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_main.sql / 32 */ 
  SELECT *
    , $1
    , ws.uri_args($1, uri_re)
    , ws.page_group_name(group_id)
    FROM page WHERE $1 ~* ('^' || uri_re) ORDER BY uri_re DESC LIMIT 1;
$_$;


--
-- Name: FUNCTION page_by_uri(a_uri text); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION page_by_uri(a_uri text) IS 'Атрибуты страницы по uri';


--
-- Name: page_childs(text, text, text, text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION page_childs(a_code text DEFAULT NULL::text, a_id text DEFAULT NULL::text, a_id1 text DEFAULT NULL::text, a_id2 text DEFAULT NULL::text) RETURNS SETOF t_page_info
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_main.sql / 106 */ 
  SELECT *
    , ws.sprintf(uri_fmt, $2, $3, $4)
    , ws.uri_args(ws.sprintf(uri_fmt, $2, $3, $4), uri_re)
    , ws.page_group_name(group_id)
    FROM page WHERE sort IS NOT NULL AND up_code IS NOT DISTINCT FROM $1 AND ws.is_ids_enough(class_id, $2, $3, $4) ORDER BY group_id, sort, 1;
$_$;


--
-- Name: FUNCTION page_childs(a_code text, a_id text, a_id1 text, a_id2 text); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION page_childs(a_code text, a_id text, a_id1 text, a_id2 text) IS 'Атрибуты страниц, имеющих предком заданную';


--
-- Name: page_group_name(d_id32); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION page_group_name(a_id d_id32) RETURNS text
    LANGUAGE sql STABLE STRICT
    AS $_$ /* ws:ws:52_main.sql / 25 */ 
  SELECT name FROM page_group WHERE id = $1;
$_$;


--
-- Name: FUNCTION page_group_name(a_id d_id32); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION page_group_name(a_id d_id32) IS 'Название группы страниц';


--
-- Name: page_insupd_trigger(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION page_insupd_trigger() RETURNS trigger
    LANGUAGE plpgsql IMMUTABLE
    AS $$ /* ws:ws:60_trig.sql / 94 */ 
  BEGIN
    IF NEW.uri_re IS NULL THEN
      NEW.uri_re := ws.mask2regexp(NEW.uri);
    END IF;
    IF NEW.uri_fmt IS NULL THEN
      NEW.uri_fmt := ws.mask2format(NEW.uri);
    END IF;
    RAISE NOTICE 'New page: %', NEW.uri_re;
    RETURN NEW;
  END;
$$;


--
-- Name: page_path(text, text, text, text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION page_path(a_code text DEFAULT NULL::text, a_id text DEFAULT NULL::text, a_id1 text DEFAULT NULL::text, a_id2 text DEFAULT NULL::text) RETURNS SETOF t_page_info
    LANGUAGE plpgsql STABLE
    AS $_$ /* ws:ws:52_main.sql / 65 */ 
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


--
-- Name: FUNCTION page_path(a_code text, a_id text, a_id1 text, a_id2 text); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION page_path(a_code text, a_id text, a_id1 text, a_id2 text) IS 'Атрибуты страниц пути от заданной до корневой';


--
-- Name: page_tree(text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION page_tree(a_code text DEFAULT NULL::text) RETURNS SETOF t_hashtable
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_main.sql / 117 */ 
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


--
-- Name: FUNCTION page_tree(a_code text); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION page_tree(a_code text) IS 'Иерархия страниц, имеющих предком заданную или main';


--
-- Name: perror_str(d_errcode, text, text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION perror_str(code d_errcode, param_name text, arg text DEFAULT ''::text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$ /* ws:ws:19_utils.sql / 54 */ 
  SELECT ws.sprintf('[{"code": "%s", "id":"%s", "arg": "%s"}]', $1::TEXT, $2, $3);
$_$;


--
-- Name: pg_c(t_pg_object, name, text, text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pg_c(a_type t_pg_object, a_code name, a_text text, a_anno text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql
    AS $$ /* ws:ws:18_pg.sql / 407 */ 
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
RAISE NOTICE 'COMMENT FOR % %: % (%)', v_name, v_code, a_text, a_anno;
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
        RAISE NOTICE '%', v_name;
      END LOOP;
    ELSE
      EXECUTE ws.sprintf(E'COMMENT ON %s %s IS \'%s\'', v_name, v_code, a_text);
    END IF;
  END;
$$;


--
-- Name: FUNCTION pg_c(a_type t_pg_object, a_code name, a_text text, a_anno text); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION pg_c(a_type t_pg_object, a_code name, a_text text, a_anno text) IS 'Создать комментарий к объекту БД';


--
-- Name: pg_exec_func(text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pg_exec_func(a_name text) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$ /* ws:ws:18_pg.sql / 72 */ 
  DECLARE
    v TEXT;
  BEGIN
    EXECUTE 'SELECT * FROM ' || a_name || '()' INTO v;
    RETURN v;
  END;
$$;


--
-- Name: pg_exec_func(text, text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pg_exec_func(a_schema text, a_name text) RETURNS text
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:18_pg.sql / 83 */ 
  SELECT ws.pg_exec_func($1 || '.' || $2)
$_$;


--
-- Name: pg_proarg_arg_anno(text, text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pg_proarg_arg_anno(a_src text, a_argname text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$ /* ws:ws:50_pg.sql / 107 */ 
  SELECT (regexp_matches($1, E'--\\s+' || $2 || E':\\s+(.*)$', 'gm'))[1];
$_$;


--
-- Name: pg_proargs2str(d_pg_argnames, d_pg_argtypes, boolean); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pg_proargs2str(a_names d_pg_argnames, a_types d_pg_argtypes, a_pub boolean) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$ /* ws:ws:18_pg.sql / 110 */ 
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
$$;


--
-- Name: pg_proc_info(text, text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pg_proc_info(a_ns text, a_name text) RETURNS SETOF t_pg_proc_info
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:18_pg.sql / 139 */ 
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


--
-- Name: pg_register_class(oid); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pg_register_class(a_oid oid) RETURNS d_code
    LANGUAGE plpgsql
    AS $_$ /* ws:ws:50_pg.sql / 191 */ 
  DECLARE
    r_pg_type pg_catalog.pg_type;
    v_code TEXT;
    v_type TEXT;
    v_tpnm TEXT;
    v_islist boolean;
    rec RECORD;
  BEGIN
    SELECT INTO r_pg_type * FROM pg_catalog.pg_type WHERE oid = a_oid;
    v_code := ws.pg_type_name(a_oid);
    IF r_pg_type.typtype in ('c','b','d') THEN
      v_tpnm := CASE
        WHEN r_pg_type.typtype = 'c' THEN
          'Composite'
        WHEN r_pg_type.typtype = 'b' THEN
          'Base'
        WHEN r_pg_type.typtype = 'd' THEN
          'Domain'
        END;
      RAISE NOTICE 'Registering "%" type: % (%)', v_tpnm, v_code, a_oid;      
      v_islist := FALSE;
      IF r_pg_type.typtype = 'd' THEN
        v_type := 
         (SELECT pg_catalog.format_type(oid, typtypmod)
          FROM pg_type
          WHERE oid = r_pg_type.typbasetype);
        v_type := split_part(v_type, ' ', 1);
        v_islist := CASE WHEN v_type ~ '\[\]$' THEN TRUE ELSE FALSE END;
        v_type := split_part(btrim(v_type, '[]'),' ', 1);
        IF NOT EXISTS(SELECT 1 FROM ws.dt WHERE code = dt_code(v_type)) THEN
          v_type := ws.pg_register_type(split_part(btrim(v_type, '[]'),' ', 1));
        END IF;
        IF ws.dt_parent_base_code(v_type) is null THEN
          v_type := (select code from ws.dt where code = current_schema() || '.' || v_type);
        END IF;
        IF v_type IS NULL THEN
          RAISE EXCEPTION 'Parent type for domain % is unknown', v_code;
        END IF;
      END IF;
      INSERT INTO ws.dt (code, anno, is_complex, parent_code, is_list)
        VALUES (v_code, COALESCE(obj_description(r_pg_type.typrelid, 'pg_class'), obj_description(a_oid, 'pg_type'), v_code), 
          CASE WHEN r_pg_type.typtype = 'd' then false else true end
        , v_type, v_islist)
      ;
      FOR rec IN
        SELECT a.attname
          , pg_catalog.format_type(a.atttypid, a.atttypmod)
          , (SELECT substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid) for 128)
            FROM pg_catalog.pg_attrdef d
            WHERE d.adrelid = a.attrelid AND d.adnum = a.attnum AND a.atthasdef) as def_val
          , a.attnotnull
          , a.attnum
          , pg_catalog.col_description(a.attrelid, a.attnum) as anno
        FROM pg_catalog.pg_attribute a
        WHERE a.attrelid = r_pg_type.typrelid AND a.attnum > 0 AND NOT a.attisdropped
        ORDER BY a.attnum
      LOOP
        v_islist := case when rec.format_type ~ '\[\]$' then true else false end;
        v_type := btrim(rec.format_type, '[]');
        IF v_type ~ E'^timestamp[\\( ]' THEN
          v_type := 'timestamp'; -- clean "timestamp(0) without time zone"
        ELSIF v_type ~ E'^time[\\( ]' THEN
          v_type := 'time'; -- clean "time without time zone"
        ELSIF v_type ~ E'^numeric\\(' THEN
          v_type := 'numeric'; -- clean "numeric(14,4)"
        ELSIF v_type ~ E'^double' THEN
          v_type := 'double'; -- clean "double precision"
        ELSIF v_type ~ E'^character varying' THEN
          v_type := 'text'; -- TODO: allow length
        END IF;
        RAISE NOTICE '   column % %', rec.attname, v_type;
        IF NOT EXISTS(SELECT 1 FROM ws.dt WHERE code IN ('ws.' || v_type, v_type)) THEN
          v_type := ws.pg_register_type(v_type);
          IF ws.dt_code(v_type) IS NULL THEN
            RAISE EXCEPTION 'Unknown type (%)', v_type;
          END IF;
        END IF;
        BEGIN
          INSERT INTO ws.dt_part (dt_code, part_id, code, parent_code, anno, def_val, allow_null, is_list)
            VALUES (v_code, rec.attnum, rec.attname, ws.dt_code(v_type), COALESCE(rec.anno, rec.attname), rec.def_val, NOT rec.attnotnull,v_islist)
          ;
          EXCEPTION
            WHEN CHECK_VIOLATION THEN
              RAISE EXCEPTION 'Unregistered % part type (%)', v_code, v_type
            ;
        END;
      END LOOP;
    ELSE
      RAISE EXCEPTION 'ERROR: OID = % неподдерживаемого типа "%"', a_oid, r_pg_type.typtype;
    END IF;
    RETURN v_code;
  END;
$_$;


--
-- Name: pg_register_proarg(d_code); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pg_register_proarg(a_code d_code) RETURNS d_code
    LANGUAGE plpgsql
    AS $_$ /* ws:ws:50_pg.sql / 112 */ 
  DECLARE
    v_i INTEGER;
    v_code d_code;

    v_args TEXT;
    v_src  TEXT;
    v_arg_anno TEXT;
    v_defs TEXT[];
    v_def TEXT;
    v_name TEXT;
    v_type TEXT;
    v_default TEXT;
    v_allow_null BOOL;
  BEGIN
    SELECT INTO v_args, v_src
      pg_get_function_arguments(oid), prosrc
      FROM pg_catalog.pg_proc p
        WHERE p.pronamespace = ws.pg_schema_oid(split_part(a_code, '.', 1))
        AND p.proname = split_part(a_code, '.', 2)
    ;
    IF v_args = '' THEN
      -- ф-я не имеет аргументов
      RETURN NULL;
    END IF;

    RAISE NOTICE 'New datatype: %', a_code;
    RAISE DEBUG 'args: %',v_args;

    v_code := split_part(a_code, '.', 1) || '.z_' || split_part(a_code, '.', 2);

    INSERT INTO ws.dt (code, anno, is_complex)
      VALUES (v_code, 'Aргументы метода ' || a_code, true)
    ;

    v_defs := regexp_split_to_array(v_args, E',\\s+');
    FOR v_i IN 1 .. pg_catalog.array_upper(v_defs, 1) LOOP
      v_def := v_defs[v_i];
      IF v_def !~ E'^(IN)?OUT ' THEN
        v_def := 'IN ' || v_def;
      END IF;
      IF split_part(v_def, ' ', 1) = 'OUT' THEN
        CONTINUE;
      END IF;
      IF split_part(v_def, ' ', 3) IN ('', 'DEFAULT') THEN
        -- аргумент без имени - автогенерация невозможна
        RAISE EXCEPTION 'No required arg name for % arg id %',a_code, v_i;
      END IF;

      v_allow_null := FALSE;
      IF split_part(v_def, ' ', 4) = 'DEFAULT' THEN
        v_default := substr(v_def, strpos(v_def, ' DEFAULT ') + 9);
        v_default := regexp_replace(v_default, '::[^:]+$', '');
        IF v_default = 'NULL' THEN
          v_default := NULL;
          v_allow_null := TRUE;
        ELSE
          v_default := btrim(v_default, chr(39)); -- '
        END IF;
      ELSE
        v_default := NULL;
      END IF;
      v_name := regexp_replace(split_part(v_def, ' ', 2), '^a_', '');
      v_type := split_part(v_def, ' ', 3);
      IF NOT EXISTS(SELECT 1 FROM ws.dt WHERE code = dt_code(v_type)) THEN
        PERFORM ws.pg_register_type(v_type);
      END IF;     
      v_arg_anno := COALESCE(ws.pg_proarg_arg_anno(v_src, split_part(v_def, ' ', 2)), '');
      RAISE NOTICE '   column name=%, type=%, def=%, null=%, anno=%', v_name, v_type, v_default, v_allow_null, v_arg_anno;
      INSERT INTO ws.dt_part (dt_code, part_id, code, parent_code, anno, def_val, allow_null)
        VALUES (v_code, v_i, v_name, dt_code(v_type), v_arg_anno, v_default, v_allow_null)
      ;
    END LOOP;
    RETURN v_code;
  END;
$_$;


--
-- Name: pg_register_proarg_old(d_code); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pg_register_proarg_old(a_code d_code) RETURNS d_code
    LANGUAGE plpgsql
    AS $$ /* ws:ws:50_pg.sql / 57 */ 
  DECLARE
    v_names text[];
    v_types oidvector;
    v_i INTEGER;
    v_name TEXT;
    v_type TEXT;
    v_code d_code;
  BEGIN
    SELECT INTO v_names, v_types, v_i
      p.proargnames, p.proargtypes, p.pronargs
      FROM pg_catalog.pg_proc p
        WHERE p.pronamespace = ws.pg_schema_oid(split_part(a_code, '.', 1))
        AND p.proname = split_part(a_code, '.', 2)
    ;

    IF v_i = 0 THEN
      -- ф-я не имеет аргументов
      RETURN NULL;
    END IF;

    RAISE NOTICE 'New datatype: %', a_code;
    IF v_names IS NULL THEN
      RAISE EXCEPTION 'No required arg names for %', a_code;
    END IF;

    v_code := split_part(a_code, '.', 1) || '.z_' || split_part(a_code, '.', 2);

    INSERT INTO ws.dt (code, anno, is_complex)
      VALUES (v_code, 'Aргументы метода ' || a_code, true)
    ;

    FOR v_i IN 0 .. pg_catalog.array_upper(v_types, 1) LOOP
      v_type := pg_catalog.format_type(v_types[v_i], NULL);
      IF COALESCE(v_names[v_i + 1], '') = '' THEN
        -- аргумент без имени - автогенерация невозможна
        RAISE EXCEPTION 'No required arg name for % arg id %',a_code, v_i;
      END IF;
      v_name := regexp_replace(v_names[v_i + 1], '^a_', '');
      RAISE NOTICE '   column % %', v_name, v_type;
      INSERT INTO ws.dt_part (dt_code, part_id, code, parent_code, anno, def_val, allow_null)
        VALUES (v_code, v_i + 1, v_name, v_type, v_name, null, false)
      ;
    END LOOP;
    RETURN v_code;
  END;
$$;


--
-- Name: pg_register_type(d_code); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pg_register_type(a_type d_code) RETURNS d_code
    LANGUAGE sql
    AS $_$ /* ws:ws:50_pg.sql / 288 */ 
  SELECT ws.pg_register_class(oid) FROM pg_type WHERE typname = $1 /* a_type */;
$_$;


--
-- Name: pg_schema_by_oid(oid); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pg_schema_by_oid(a_oid oid) RETURNS text
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:18_pg.sql / 89 */ 
  SELECT nspname::TEXT FROM pg_namespace WHERE oid = $1
$_$;


--
-- Name: pg_schema_oid(text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pg_schema_oid(a_name text) RETURNS oid
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:18_pg.sql / 66 */ 
  SELECT oid FROM pg_namespace WHERE nspname = $1
$_$;


--
-- Name: pg_type_name(oid); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pg_type_name(a_oid oid) RETURNS text
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:18_pg.sql / 95 */ 
  SELECT CASE WHEN nspname = 'pg_catalog' THEN pg_catalog.format_type($1, NULL) ELSE  nspname || '.' || typname END
    FROM (
      SELECT (SELECT nspname FROM pg_namespace WHERE oid = typnamespace) as nspname, typname FROM pg_type WHERE oid = $1
    ) AS pg_type_name_temp
$_$;


--
-- Name: pg_view_comments(text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pg_view_comments(a_code text) RETURNS SETOF t_pg_view_info
    LANGUAGE plpgsql
    AS $$ /* ws:ws:18_pg.sql / 194 */ 
  DECLARE
    v_code text[];
    v_def text;
    v_def_arr text[];
    r_ record;
    v_i int;
    v_j int;
    v_k int;
    v_viewname text;    
    v_ret_1 text[];
    v_ret_2 text[];
    v_ret_3 text[];
    v_ret_4 text[];
    v_ret_5 int[];
    v_ret_6 text[];
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
    IF v_def is null THEN
      RAISE WARNING 'ERROR: Представление не найдено %', a_code;
      RETURN;
    END IF;
    v_def_arr := string_to_array(v_def, ' union ');
    FOR v_j in array_lower(v_def_arr, 1)..array_upper(v_def_arr, 1) LOOP
      DECLARE
         v_list text;
         v_list_check text;
         v_field text;
         v_brac int;  -- индекс подсчета скобок
         v_temp text[];
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
            v_const_1 text := ' as ';         
            v_const_2 text := '.';
            v_fld text; -- поле "A.B" или "A.B as C"
            v_exp text; -- A.B A.B
            v_tbl text; -- A   A
            v_col text; -- B   B
            v_als text; -- B   C
            v_res_1 text;
            v_res_2 text;
            v_res_3 text;
            v_res_4 text;
            v_res_5 int;
            v_res_6 text;
            v__debug text;
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
                v_src text; -- таб. источник
              BEGIN
                -- v_pos: позиция v_tbl в строке выборки v_def в порядке определенном v_const_3
                DECLARE
                  v_const_3 text[][] = ARRAY[[' ',' '],[' ',','],['.',''],['','']];
                  v_srh text;
                  v_x int;
                  v_pos int;
                  v_l text;
                  v_r text;
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
                  v__debug = v_l || '~' || v_r || '~' || v_tbl || '~' || v_pos::text;
                END;
                v_res_3 := v_src;
                v_res_4 := v_col;
                IF v_src is not null and length(v_src) - length(replace(v_src, v_const_2, '')) = length(v_const_2) THEN
                  -- дополнительная проверка: если v_src определена неправильно не будет ошибки выполнения запроса (превентивная, частных случаев нет)
                  PERFORM 1 FROM information_schema.tables WHERE table_schema = split_part(v_src, '.', 1) AND table_name = split_part(v_src, '.', 2);
                  IF FOUND THEN
                    v_res_6 := 
                      (SELECT col_description
                      ((SELECT (v_src)::regclass::oid)::int,
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
$$;


--
-- Name: FUNCTION pg_view_comments(a_code text); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION pg_view_comments(a_code text) IS 'получить комментарии полей view из таблиц запроса';


--
-- Name: pg_view_comments_get_tbl(text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pg_view_comments_get_tbl(a_code text) RETURNS text
    LANGUAGE plpgsql
    AS $$ /* ws:ws:18_pg.sql / 157 */ 
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
$$;


--
-- Name: pkg; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE pkg (
    id integer NOT NULL,
    code text NOT NULL,
    ver text,
    op character(1) DEFAULT '+'::bpchar,
    log_name text,
    user_name text,
    ssh_client text,
    usr text DEFAULT "current_user"(),
    ip inet DEFAULT inet_client_addr(),
    stamp timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE pkg; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE pkg IS 'Актуальные (последние) изменения пакетов PGWS';


--
-- Name: COLUMN pkg.id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN pkg.id IS 'ID изменения';


--
-- Name: COLUMN pkg.code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN pkg.code IS 'Код пакета';


--
-- Name: COLUMN pkg.ver; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN pkg.ver IS 'Версия пакета (reserved)';


--
-- Name: COLUMN pkg.op; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN pkg.op IS 'Код операции (+ init, - drop, = make)';


--
-- Name: COLUMN pkg.log_name; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN pkg.log_name IS '$LOGNAME из сессии пользователя в ОС';


--
-- Name: COLUMN pkg.user_name; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN pkg.user_name IS '$USERNAME из сессии пользователя в ОС';


--
-- Name: COLUMN pkg.ssh_client; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN pkg.ssh_client IS '$SSH_CLIENT из сессии пользователя в ОС';


--
-- Name: COLUMN pkg.usr; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN pkg.usr IS 'Имя пользователя соединения с БД';


--
-- Name: COLUMN pkg.ip; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN pkg.ip IS 'IP пользователя соединения с БД';


--
-- Name: COLUMN pkg.stamp; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN pkg.stamp IS 'Момент выполнения изменения';


--
-- Name: pkg(text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pkg(a_code text) RETURNS pkg
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:50_pkg.sql / 54 */ 
  SELECT * FROM ws.pkg WHERE code = $1;
$_$;


--
-- Name: pkg_add(text, text, text, text, text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pkg_add(a_code text, a_ver text, a_log_name text, a_user_name text, a_ssh_client text) RETURNS text
    LANGUAGE plpgsql
    AS $$ /* ws:ws:50_pkg.sql / 78 */ 
  DECLARE
    r_pkg ws.pkg%ROWTYPE;
  BEGIN
    r_pkg := ws.pkg(a_code);
    IF r_pkg IS NULL THEN
      INSERT INTO ws.pkg (id, code, ver, log_name, user_name, ssh_client)
        VALUES (NEXTVAL('ws.pkg_id_seq'), a_code, a_ver, a_log_name, a_user_name, a_ssh_client)
        RETURNING * INTO r_pkg;
        INSERT INTO ws.pkg_log VALUES (r_pkg.*);
      RETURN 'Ok';
    END IF;
    RAISE EXCEPTION '***************** Package % (%) installed already at % (%) *****************'
      , a_code, a_ver, r_pkg.stamp, r_pkg.id;
  END;
$$;


--
-- Name: pkg_del(text, text, text, text, text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pkg_del(a_code text, a_ver text, a_log_name text, a_user_name text, a_ssh_client text) RETURNS text
    LANGUAGE plpgsql
    AS $$ /* ws:ws:50_pkg.sql / 124 */ 
  DECLARE
    r_pkg ws.pkg%ROWTYPE;
    v_id  INTEGER;
  BEGIN
    r_pkg := ws.pkg(a_code);
    IF a_ver = r_pkg.ver THEN
      INSERT INTO ws.pkg_log (id, code, ver, log_name, user_name, ssh_client, op)
        VALUES (NEXTVAL('ws.pkg_id_seq'), a_code, a_ver, a_log_name, a_user_name, a_ssh_client, '-')
      ;
      DELETE FROM ws.pkg
        WHERE code = a_code
      ;
      RETURN 'Ok';
    END IF;

    RAISE EXCEPTION '***************** Package % (%) is not actial (%) *****************'
      , a_code, a_ver, r_pkg.ver
    ;
  END
$$;


--
-- Name: pkg_erase(text, text, text, text, text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pkg_erase(a_code text, a_ver text, a_log_name text, a_user_name text, a_ssh_client text) RETURNS text
    LANGUAGE plpgsql
    AS $$ /* ws:ws:50_pkg.sql / 148 */ 
  DECLARE
    r_pkg ws.pkg%ROWTYPE;
    v_id  INTEGER;
  BEGIN
    r_pkg := ws.pkg(a_code);
    IF a_ver = r_pkg.ver THEN
      INSERT INTO ws.pkg_log (id, code, ver, log_name, user_name, ssh_client, op)
        VALUES (NEXTVAL('ws.pkg_id_seq'), a_code, a_ver, a_log_name, a_user_name, a_ssh_client, '0')
      ;
      DELETE FROM ws.pkg
        WHERE code = a_code
      ;
      RETURN 'Ok';
    END IF;

    RAISE EXCEPTION '***************** Package % (%) is not actial (%) *****************'
      , a_code, a_ver, r_pkg.ver
    ;
  END
$$;


--
-- Name: pkg_is_core_only(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pkg_is_core_only() RETURNS boolean
    LANGUAGE plpgsql STABLE
    AS $$ /* ws:ws:50_pkg.sql / 60 */ 
  DECLARE
    v_pkgs TEXT;
  BEGIN
    SELECT INTO v_pkgs
      array_to_string(array_agg(code),', ')
      FROM ws.pkg
      WHERE code <> 'ws'
    ;
    IF v_pkgs IS NOT NULL THEN
      RAISE EXCEPTION '***************** There are app packages installed (%) *****************', v_pkgs;
    END IF;
    RETURN TRUE;
  END;
$$;


--
-- Name: pkg_make(text, text, text, text, text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pkg_make(a_code text, a_ver text, a_log_name text, a_user_name text, a_ssh_client text) RETURNS text
    LANGUAGE plpgsql
    AS $$ /* ws:ws:50_pkg.sql / 97 */ 
  DECLARE
    r_pkg ws.pkg%ROWTYPE;
  BEGIN
    UPDATE ws.pkg SET
      id            = NEXTVAL('ws.pkg_id_seq') -- runs after rule
      , log_name    = a_log_name
      , user_name   = a_user_name
      , ssh_client  = a_ssh_client
      , stamp       = now()
      , op          = '.'
      WHERE code = a_code
        AND ver  = a_ver
        RETURNING * INTO r_pkg
    ;
    IF NOT FOUND THEN
      RAISE EXCEPTION '***************** Package % ver % does not found *****************'
        , a_code, a_ver
      ;
    END IF;
    INSERT INTO ws.pkg_log VALUES (r_pkg.*);
    RETURN 'Ok';
  END;
$$;


--
-- Name: pkg_require(text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION pkg_require(a_code text) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$ /* ws:ws:50_pkg.sql / 171 */ 
  BEGIN
    RAISE NOTICE 'TODO: function needs code';
    RETURN NULL;
  END
$$;


--
-- Name: ref_item; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE ref_item (
    ref_id d_id32 NOT NULL,
    id d_id32 NOT NULL,
    sort d_sort,
    name text NOT NULL,
    group_id d_id32 DEFAULT 1 NOT NULL,
    deleted_at d_stamp
);


--
-- Name: TABLE ref_item; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE ref_item IS 'Позиция справочника';


--
-- Name: COLUMN ref_item.ref_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN ref_item.ref_id IS 'ID справочника';


--
-- Name: COLUMN ref_item.id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN ref_item.id IS 'ID позиции';


--
-- Name: COLUMN ref_item.sort; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN ref_item.sort IS 'Порядок сортировки';


--
-- Name: COLUMN ref_item.name; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN ref_item.name IS 'Название';


--
-- Name: COLUMN ref_item.group_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN ref_item.group_id IS 'Внутренний ID группы';


--
-- Name: COLUMN ref_item.deleted_at; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN ref_item.deleted_at IS 'Момент удаления';


--
-- Name: ref(d_id32, d_id32, d_id32, boolean); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION ref(a_id d_id32, a_item_id d_id32 DEFAULT 0, a_group_id d_id32 DEFAULT 0, a_active_only boolean DEFAULT true) RETURNS SETOF ref_item
    LANGUAGE plpgsql STABLE
    AS $_$ /* ws:ws:52_main.sql / 188 */ 
  DECLARE
    v_code TEXT;
  BEGIN
  RETURN QUERY
    SELECT *
    FROM ws.ref_item
    WHERE ref_id = a_id
      AND a_item_id IN (id, 0)
      AND a_group_id IN (group_id, 0)
      AND (NOT a_active_only OR deleted_at IS NULL)
      ORDER BY sort
  ;
  IF NOT FOUND THEN
    SELECT INTO v_code code FROM ws.ref WHERE id = a_id;
    IF NOT FOUND THEN
      RAISE EXCEPTION '%', ws.e_nodata();
    END IF;
    RETURN QUERY EXECUTE 'SELECT * FROM ' || v_code || '($1, $2, $3)' USING a_id, a_item_id, a_group_id;
  END IF;
  RETURN;
  END;
$_$;


--
-- Name: FUNCTION ref(a_id d_id32, a_item_id d_id32, a_group_id d_id32, a_active_only boolean); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION ref(a_id d_id32, a_item_id d_id32, a_group_id d_id32, a_active_only boolean) IS 'Значение из справочника ws.ref';


--
-- Name: ref; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE ref (
    id d_id32 NOT NULL,
    class_id d_class NOT NULL,
    name text NOT NULL,
    code d_code,
    updated_at d_stamp DEFAULT '2010-01-01 00:00:00'::timestamp without time zone NOT NULL
);


--
-- Name: TABLE ref; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE ref IS 'Справочник';


--
-- Name: COLUMN ref.id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN ref.id IS 'ID';


--
-- Name: COLUMN ref.name; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN ref.name IS 'Название';


--
-- Name: COLUMN ref.code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN ref.code IS 'Метод доступа';


--
-- Name: COLUMN ref.updated_at; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN ref.updated_at IS 'Момент последнего изменения';


--
-- Name: ref_info(d_id32); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION ref_info(a_id d_id32) RETURNS SETOF ref
    LANGUAGE sql STABLE
    AS $_$ /* ws:ws:52_main.sql / 214 */ 
  SELECT * FROM ws.ref WHERE id = $1;
$_$;


--
-- Name: FUNCTION ref_info(a_id d_id32); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION ref_info(a_id d_id32) IS 'Атрибуты справочника';


--
-- Name: reserved_args(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION reserved_args() RETURNS text[]
    LANGUAGE sql IMMUTABLE
    AS $$ /* ws:ws:18_pg.sql / 104 */ 
  SELECT ARRAY['a__acl', 'a__sid', 'a__ip', 'a__cook', 'a__lang'];
$$;


--
-- Name: FUNCTION reserved_args(); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION reserved_args() IS 'Зарезервированные имена аргументов методов';


--
-- Name: set_lang(text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION set_lang(a_lang text DEFAULT NULL::text) RETURNS text
    LANGUAGE plpgsql
    AS $$ /* ws:ws:50_pg.sql / 36 */ 
  DECLARE
    v_lang TEXT;
    v_path_old TEXT;
    v_path_new TEXT;
  BEGIN
    v_lang := COALESCE(NULLIF(a_lang, 'ru'), 'def');
    EXECUTE 'SHOW search_path' INTO v_path_old;
    IF v_path_old ~ E'i18n_\w+' THEN
      v_path_new := regexp_replace(v_path_old, E'i18n_\\w+', 'i18n_' || v_lang);
    ELSE
      v_path_new := 'i18n_' || v_lang || ', '|| v_path_old;
    END IF;
    PERFORM ws.set_search_path(v_path_new);
    RETURN v_path_old;
  END;
$$;


--
-- Name: set_search_path(text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION set_search_path(a_path text) RETURNS void
    LANGUAGE plpgsql
    AS $$ /* ws:ws:50_pg.sql / 25 */ 
  DECLARE
    v_sql TEXT;
  BEGIN
    v_sql := 'SET LOCAL search_path = ' || a_path;
    EXECUTE v_sql;
  END;
$$;


--
-- Name: sprintf(text, text, text, text, text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION sprintf(text, text DEFAULT ''::text, text DEFAULT ''::text, text DEFAULT ''::text, text DEFAULT ''::text) RETURNS text
    LANGUAGE plperl IMMUTABLE
    AS $_$ # /* ws:ws:18_pg.sql / 60 */ 
    my ($fmt, @args) = @_; my $str = sprintf($fmt, @args); return $str;
$_$;


--
-- Name: FUNCTION sprintf(text, text, text, text, text); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION sprintf(text, text, text, text, text) IS 'Порт функции sprintf';


--
-- Name: stamp2xml(timestamp without time zone); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION stamp2xml(a timestamp without time zone) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$ /* ws:ws:19_utils.sql / 102 */ 
SELECT to_char($1, E'YYYY-MM-DD"T"HH24:MI:SS+04:00');
$_$;


--
-- Name: system_acl(d_sid); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION system_acl(a__sid d_sid DEFAULT NULL::text) RETURNS SETOF d_acl
    LANGUAGE plpgsql STABLE
    AS $$ /* ws:ws:52_system.sql / 32 */ 
  DECLARE
  BEGIN
    -- проверки прав сессии на объект
    IF COALESCE(a__sid, '') = '' THEN
      RETURN NEXT 1::ws.d_acl;
      RETURN;
    END IF;

    RETURN NEXT 2::ws.d_acl; --TODO: Сервис, Админ, клиент?

    RETURN;
  END
$$;


--
-- Name: FUNCTION system_acl(a__sid d_sid); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION system_acl(a__sid d_sid) IS 'ACL sid для системы';


--
-- Name: system_server(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION system_server() RETURNS SETOF server
    LANGUAGE sql STABLE
    AS $$ /* ws:ws:52_system.sql / 51 */ 
  SELECT * FROM ws.server WHERE id = 1
$$;


--
-- Name: system_status(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION system_status() RETURNS d_id32
    LANGUAGE sql STABLE
    AS $$ /* ws:ws:52_system.sql / 25 */ 
  SELECT 1::ws.d_id32 -- TODO: брать актуальный статус из таблицы (после готовности поддержки статуса "Обслуживание")
$$;


--
-- Name: FUNCTION system_status(); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION system_status() IS 'Статус системы';


--
-- Name: test(d_code); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION test(a_code d_code) RETURNS text
    LANGUAGE plpgsql
    AS $$ /* ws:ws:50_pkg.sql / 39 */ 
  BEGIN
    --t/test1_global_config.t .. ok
    --t/test2_run_config.t ..... ok
    IF a_code IS NULL THEN
      RAISE WARNING '::';
    ELSE
      RAISE WARNING '::%', rpad('t/'||a_code||' ', 20, '.');
    END IF;
    RETURN ' ***** ' || a_code || ' *****';
  END;
$$;


--
-- Name: tr_exception(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION tr_exception() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ /* ws:ws:50_pg.sql / 310 */ 
  DECLARE
    v_text TEXT;
  BEGIN
    v_text := TG_ARGV[0];
    RAISE EXCEPTION '%', v_text;
    RETURN NEW;
  END;
$$;


--
-- Name: tr_notify(); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION tr_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ /* ws:ws:50_pg.sql / 296 */ 
  DECLARE
    v_channel TEXT;
  BEGIN
    v_channel := TG_ARGV[0];
    PERFORM pg_notify(v_channel, NEW.id::TEXT);
    RETURN NEW;
  END;
$$;


--
-- Name: uri_args(text, text); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION uri_args(a_uri text, a_mask text) RETURNS text[]
    LANGUAGE plperl IMMUTABLE
    AS $_$  # /* ws:ws:19_utils.sql / 60 */ 
    my ($uri, $mask) = @_; if ($uri =~ /$mask/) { return [$1, $2, $3, $4, $5]; } return undef;
$_$;


--
-- Name: year_months(date, date, date); Type: FUNCTION; Schema: ws; Owner: -
--

CREATE FUNCTION year_months(a_date date DEFAULT ('now'::text)::date, a_date_min date DEFAULT NULL::date, a_date_max date DEFAULT NULL::date) RETURNS SETOF t_month_info
    LANGUAGE plpgsql IMMUTABLE
    AS $$ /* ws:ws:52_i18n_dep.sql / 66 */ 
  -- Список атрибутов месяцев года заданной даты
  -- a_date:      Дата
  -- a_date_min:  Дата, месяцы раньше которой не включать
  -- a_date_max:  Дата, месяцы позднее которой не включать
  DECLARE
    v_i INTEGER;
    v_date DATE;
    v_date_curr DATE;
    r ws.t_month_info;
  BEGIN
    v_date := COALESCE(a_date, CURRENT_DATE);
    FOR v_i IN 0..11 LOOP
      v_date_curr := date_trunc('year', v_date)::date + (v_i || ' months')::interval;
      CONTINUE WHEN v_date_curr < date_trunc('month', a_date_min);
      CONTINUE WHEN v_date_curr >= date_trunc('month', a_date_max) + '1 month'::interval;
      r := ws.month_info(v_date_curr);
      RETURN NEXT r;
    END LOOP;
    RETURN;
  END;
$$;


--
-- Name: FUNCTION year_months(a_date date, a_date_min date, a_date_max date); Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON FUNCTION year_months(a_date date, a_date_min date, a_date_max date) IS 'Список атрибутов месяцев года заданной даты';


SET search_path = acc, pg_catalog;

--
-- Name: account_attr_pub; Type: VIEW; Schema: acc; Owner: -
--

CREATE VIEW account_attr_pub AS
    SELECT account_attr.id, account_attr.status_id, account_attr.name, account_attr.created_at, account_attr.status_name FROM account_attr;


SET search_path = wsd, pg_catalog;

--
-- Name: event_seq; Type: SEQUENCE; Schema: wsd; Owner: -
--

CREATE SEQUENCE event_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE event (
    id integer DEFAULT nextval('event_seq'::regclass) NOT NULL,
    status_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    kind_id integer NOT NULL,
    created_by integer,
    class_id integer NOT NULL,
    arg_id integer,
    arg_id2 integer,
    arg_name text,
    arg_name2 text
);


--
-- Name: TABLE event; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE event IS 'Событие';


--
-- Name: COLUMN event.id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event.id IS 'ID события';


--
-- Name: COLUMN event.status_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event.status_id IS 'ID статуса';


--
-- Name: COLUMN event.created_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event.created_at IS 'отметка времени возникновения';


--
-- Name: COLUMN event.kind_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event.kind_id IS 'ID категории';


--
-- Name: COLUMN event.created_by; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event.created_by IS 'Идентификатор автора';


--
-- Name: COLUMN event.class_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event.class_id IS 'ID класса объектов';


--
-- Name: COLUMN event.arg_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event.arg_id IS 'ID объекта';


--
-- Name: COLUMN event.arg_id2; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event.arg_id2 IS 'ID объекта2';


--
-- Name: COLUMN event.arg_name; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event.arg_name IS 'Параметр названия события';


--
-- Name: COLUMN event.arg_name2; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event.arg_name2 IS 'Параметр2 названия события';


SET search_path = ev, pg_catalog;

--
-- Name: event_info; Type: VIEW; Schema: ev; Owner: -
--

CREATE VIEW event_info AS
    SELECT e.id, e.status_id, e.created_at, e.kind_id, e.created_by, e.class_id, e.arg_id, e.arg_id2, e.arg_name, e.arg_name2, ek.name_count, ek.name_fmt, ek.name FROM (wsd.event e JOIN kind ek ON ((e.kind_id = (ek.id)::integer))) ORDER BY e.id;


--
-- Name: form; Type: TABLE; Schema: ev; Owner: -
--

CREATE TABLE form (
    code ws.d_code NOT NULL,
    sort ws.d_sort NOT NULL,
    is_email boolean DEFAULT true NOT NULL,
    name ws.d_string NOT NULL
);


--
-- Name: TABLE form; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON TABLE form IS 'Формат уведомления';


--
-- Name: COLUMN form.code; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN form.code IS 'Код формата';


--
-- Name: COLUMN form.sort; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN form.sort IS 'Сортировка';


--
-- Name: COLUMN form.is_email; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN form.is_email IS 'Отправляется по электронной почте';


--
-- Name: COLUMN form.name; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN form.name IS 'Название';


--
-- Name: kind_group; Type: TABLE; Schema: ev; Owner: -
--

CREATE TABLE kind_group (
    id ws.d_id32 NOT NULL,
    sort ws.d_sort NOT NULL,
    name ws.d_string NOT NULL,
    anno ws.d_text NOT NULL
);


--
-- Name: TABLE kind_group; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON TABLE kind_group IS 'Группа вида события';


--
-- Name: COLUMN kind_group.id; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN kind_group.id IS 'ID группы';


--
-- Name: COLUMN kind_group.sort; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN kind_group.sort IS 'Сортировка';


--
-- Name: COLUMN kind_group.name; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN kind_group.name IS 'Название';


--
-- Name: COLUMN kind_group.anno; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN kind_group.anno IS 'Аннотация';


--
-- Name: signature; Type: TABLE; Schema: ev; Owner: -
--

CREATE TABLE signature (
    id ws.d_id32 NOT NULL,
    name ws.d_string NOT NULL,
    email ws.d_string NOT NULL,
    tmpl ws.d_path NOT NULL
);


--
-- Name: TABLE signature; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON TABLE signature IS 'Подпись уведомлений';


--
-- Name: COLUMN signature.id; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN signature.id IS 'ID подписи';


--
-- Name: COLUMN signature.name; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN signature.name IS 'Имя отправителя';


--
-- Name: COLUMN signature.email; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN signature.email IS 'Email отправителя';


--
-- Name: COLUMN signature.tmpl; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN signature.tmpl IS 'Файл шаблона';


--
-- Name: status; Type: TABLE; Schema: ev; Owner: -
--

CREATE TABLE status (
    id ws.d_id32 NOT NULL,
    name ws.d_string NOT NULL
);


--
-- Name: TABLE status; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON TABLE status IS 'Статус события';


--
-- Name: COLUMN status.id; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN status.id IS 'ID группы';


--
-- Name: COLUMN status.name; Type: COMMENT; Schema: ev; Owner: -
--

COMMENT ON COLUMN status.name IS 'Название';


SET search_path = i18n_def, pg_catalog;

--
-- Name: page_name; Type: TABLE; Schema: i18n_def; Owner: -
--

CREATE TABLE page_name (
    code ws.d_code NOT NULL,
    name text NOT NULL
);


--
-- Name: TABLE page_name; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON TABLE page_name IS 'Заголовок страницы сайта в локали схемы БД';


--
-- Name: COLUMN page_name.code; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN page_name.code IS 'Код страницы';


--
-- Name: COLUMN page_name.name; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN page_name.name IS 'Заголовок страницы в карте сайта';


SET search_path = ws, pg_catalog;

--
-- Name: page_data; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE page_data (
    code d_code NOT NULL,
    up_code d_code,
    class_id d_class NOT NULL,
    action_id d_id32 NOT NULL,
    group_id d_id32,
    sort d_sort,
    uri d_regexp,
    tmpl d_path,
    id_fixed d_id,
    id_session d_code,
    is_hidden boolean DEFAULT true NOT NULL,
    target text DEFAULT ''::text NOT NULL,
    uri_re text,
    uri_fmt text NOT NULL,
    pkg text NOT NULL
);


--
-- Name: TABLE page_data; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE page_data IS 'Атрибуты страниц для page_data';


--
-- Name: COLUMN page_data.code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN page_data.code IS 'Идентификатор страницы';


--
-- Name: COLUMN page_data.up_code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN page_data.up_code IS 'идентификатор страницы верхнего уровня';


--
-- Name: COLUMN page_data.class_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN page_data.class_id IS 'ID класса, к которому относится страница';


--
-- Name: COLUMN page_data.action_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN page_data.action_id IS 'ID акции, к которой относится страница';


--
-- Name: COLUMN page_data.group_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN page_data.group_id IS 'ID группы страниц для меню';


--
-- Name: COLUMN page_data.sort; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN page_data.sort IS 'порядок сортировки в меню страниц одного уровня (NULL - нет в меню)';


--
-- Name: COLUMN page_data.uri; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN page_data.uri IS 'мета-маска с именами переменных, которой должен соответствовать URI запроса';


--
-- Name: COLUMN page_data.tmpl; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN page_data.tmpl IS 'файл шаблона (NULL для внешних адресов)';


--
-- Name: COLUMN page_data.id_fixed; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN page_data.id_fixed IS 'ID объекта взять из этого поля';


--
-- Name: COLUMN page_data.id_session; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN page_data.id_session IS 'ID объекта взять из этого поля сессии';


--
-- Name: COLUMN page_data.is_hidden; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN page_data.is_hidden IS 'Запрет включения внешних блоков в разметку страницы';


--
-- Name: COLUMN page_data.target; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN page_data.target IS 'значение атрибута target в формируемых ссылках';


--
-- Name: COLUMN page_data.uri_re; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN page_data.uri_re IS 'regexp URI, вычисляется триггером при insert/update';


--
-- Name: COLUMN page_data.uri_fmt; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN page_data.uri_fmt IS 'строка формата для генерации URI, вычисляется триггером при insert/update';


--
-- Name: COLUMN page_data.pkg; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN page_data.pkg IS 'пакет, в котором зарегистрирована страница';


SET search_path = i18n_def, pg_catalog;

--
-- Name: page; Type: VIEW; Schema: i18n_def; Owner: -
--

CREATE VIEW page AS
    SELECT d.code, d.up_code, d.class_id, d.action_id, d.group_id, d.sort, d.uri, d.tmpl, d.id_fixed, d.id_session, d.is_hidden, d.target, d.uri_re, d.uri_fmt, d.pkg, n.name FROM (ws.page_data d JOIN page_name n USING (code));


--
-- Name: VIEW page; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON VIEW page IS 'Страница сайта';


--
-- Name: COLUMN page.code; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN page.code IS 'Идентификатор страницы';


--
-- Name: COLUMN page.up_code; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN page.up_code IS 'идентификатор страницы верхнего уровня';


--
-- Name: COLUMN page.class_id; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN page.class_id IS 'ID класса, к которому относится страница';


--
-- Name: COLUMN page.action_id; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN page.action_id IS 'ID акции, к которой относится страница';


--
-- Name: COLUMN page.group_id; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN page.group_id IS 'ID группы страниц для меню';


--
-- Name: COLUMN page.sort; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN page.sort IS 'порядок сортировки в меню страниц одного уровня (NULL - нет в меню)';


--
-- Name: COLUMN page.uri; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN page.uri IS 'мета-маска с именами переменных, которой должен соответствовать URI запроса';


--
-- Name: COLUMN page.tmpl; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN page.tmpl IS 'файл шаблона (NULL для внешних адресов)';


--
-- Name: COLUMN page.id_fixed; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN page.id_fixed IS 'ID объекта взять из этого поля';


--
-- Name: COLUMN page.id_session; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN page.id_session IS 'ID объекта взять из этого поля сессии';


--
-- Name: COLUMN page.is_hidden; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN page.is_hidden IS 'Запрет включения внешних блоков в разметку страницы';


--
-- Name: COLUMN page.target; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN page.target IS 'значение атрибута target в формируемых ссылках';


--
-- Name: COLUMN page.uri_re; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN page.uri_re IS 'regexp URI, вычисляется триггером при insert/update';


--
-- Name: COLUMN page.uri_fmt; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN page.uri_fmt IS 'строка формата для генерации URI, вычисляется триггером при insert/update';


--
-- Name: COLUMN page.pkg; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN page.pkg IS 'пакет, в котором зарегистрирована страница';


--
-- Name: COLUMN page.name; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN page.name IS 'Заголовок страницы в карте сайта';


--
-- Name: page_group; Type: TABLE; Schema: i18n_def; Owner: -
--

CREATE TABLE page_group (
    id ws.d_id32 NOT NULL,
    name text NOT NULL
);


--
-- Name: TABLE page_group; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON TABLE page_group IS 'Группа страниц для меню';


--
-- Name: COLUMN page_group.id; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN page_group.id IS 'ID группы';


--
-- Name: COLUMN page_group.name; Type: COMMENT; Schema: i18n_def; Owner: -
--

COMMENT ON COLUMN page_group.name IS 'Название';


SET search_path = i18n_en, pg_catalog;

--
-- Name: error_message; Type: TABLE; Schema: i18n_en; Owner: -
--

CREATE TABLE error_message (
    code ws.d_errcode NOT NULL,
    id_count ws.d_cnt DEFAULT 0 NOT NULL,
    message ws.d_format NOT NULL
);


--
-- Name: error; Type: VIEW; Schema: i18n_en; Owner: -
--

CREATE VIEW error AS
    SELECT error_message.code, error_message.id_count, error_message.message FROM error_message;


--
-- Name: VIEW error; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON VIEW error IS 'Error description';


--
-- Name: page_name; Type: TABLE; Schema: i18n_en; Owner: -
--

CREATE TABLE page_name (
    code ws.d_code NOT NULL,
    name text NOT NULL
);


--
-- Name: page; Type: VIEW; Schema: i18n_en; Owner: -
--

CREATE VIEW page AS
    SELECT d.code, d.up_code, d.class_id, d.action_id, d.group_id, d.sort, d.uri, d.tmpl, d.id_fixed, d.id_session, d.is_hidden, d.target, d.uri_re, d.uri_fmt, d.pkg, n.name FROM (ws.page_data d JOIN page_name n USING (code));


--
-- Name: VIEW page; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON VIEW page IS 'Site page';


--
-- Name: COLUMN page.code; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON COLUMN page.code IS 'Page ID';


--
-- Name: COLUMN page.up_code; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON COLUMN page.up_code IS 'id of parent level page';


--
-- Name: COLUMN page.class_id; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON COLUMN page.class_id IS 'Class ID page corresponds with';


--
-- Name: COLUMN page.action_id; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON COLUMN page.action_id IS 'Action ID page corresponds with';


--
-- Name: COLUMN page.group_id; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON COLUMN page.group_id IS 'Manu page group ID';


--
-- Name: COLUMN page.sort; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON COLUMN page.sort IS 'page order in one level menu';


--
-- Name: COLUMN page.uri; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON COLUMN page.uri IS 'metamask with variable names for request uri lookup';


--
-- Name: COLUMN page.tmpl; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON COLUMN page.tmpl IS 'template file (NULL for external URL)';


--
-- Name: COLUMN page.id_fixed; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON COLUMN page.id_fixed IS 'ID объекта взять из этого поля';


--
-- Name: COLUMN page.id_session; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON COLUMN page.id_session IS 'Session field to get object ID from';


--
-- Name: COLUMN page.is_hidden; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON COLUMN page.is_hidden IS 'Запрет включения внешних блоков в разметку страницы';


--
-- Name: COLUMN page.target; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON COLUMN page.target IS 'value of target attribute in generated links';


--
-- Name: COLUMN page.uri_re; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON COLUMN page.uri_re IS 'regexp for URI, calculated by insert/update trigger';


--
-- Name: COLUMN page.uri_fmt; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON COLUMN page.uri_fmt IS 'format string for URI generation, filled by insert/update trigger';


--
-- Name: COLUMN page.pkg; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON COLUMN page.pkg IS 'пакет, в котором зарегистрирована страница';


--
-- Name: COLUMN page.name; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON COLUMN page.name IS 'Sitemap page title';


--
-- Name: page_group; Type: TABLE; Schema: i18n_en; Owner: -
--

CREATE TABLE page_group (
    id ws.d_id32 NOT NULL,
    name text NOT NULL
);


--
-- Name: TABLE page_group; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON TABLE page_group IS 'Menu page group';


--
-- Name: COLUMN page_group.id; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON COLUMN page_group.id IS 'Group ID';


--
-- Name: COLUMN page_group.name; Type: COMMENT; Schema: i18n_en; Owner: -
--

COMMENT ON COLUMN page_group.name IS 'Название';


SET search_path = job, pg_catalog;

--
-- Name: arg_attr; Type: VIEW; Schema: job; Owner: -
--

CREATE VIEW arg_attr AS
    SELECT job.id, job.validfrom, job.handler_id, job.status_id, job.arg_id, job.arg_date, job.arg_num, job.arg_more, job.arg_id2, job.arg_date2, job.arg_id3 FROM wsd.job ORDER BY job.id;


--
-- Name: arg_type; Type: TABLE; Schema: job; Owner: -
--

CREATE TABLE arg_type (
    id ws.d_id32 NOT NULL,
    name ws.d_string NOT NULL
);


--
-- Name: TABLE arg_type; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON TABLE arg_type IS 'Тип аргумента';


--
-- Name: COLUMN arg_type.id; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN arg_type.id IS 'ID типа';


--
-- Name: COLUMN arg_type.name; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN arg_type.name IS 'Название типа';


--
-- Name: mgr_error; Type: TABLE; Schema: job; Owner: -
--

CREATE TABLE mgr_error (
    pid integer NOT NULL,
    error_count integer,
    anno text NOT NULL,
    first_at timestamp(0) without time zone,
    last_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone DEFAULT now()
);


--
-- Name: TABLE mgr_error; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON TABLE mgr_error IS 'Ошибки процессов JobManager';


--
-- Name: COLUMN mgr_error.pid; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN mgr_error.pid IS 'PID процесса';


--
-- Name: mgr_stat; Type: TABLE; Schema: job; Owner: -
--

CREATE TABLE mgr_stat (
    pid integer NOT NULL,
    loop_count integer,
    event_count integer,
    error_count integer,
    run_at timestamp(0) without time zone,
    loop_at timestamp(0) without time zone,
    event_at timestamp(0) without time zone,
    error_at timestamp(0) without time zone,
    cron_at timestamp(0) without time zone,
    shadow_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone DEFAULT now()
);


--
-- Name: TABLE mgr_stat; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON TABLE mgr_stat IS 'Статистика процессов JobManager';


--
-- Name: COLUMN mgr_stat.pid; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN mgr_stat.pid IS 'PID процесса';


--
-- Name: srv_attr; Type: VIEW; Schema: job; Owner: -
--

CREATE VIEW srv_attr AS
    SELECT job.id, job.validfrom, job.prio, job.handler_id AS h_id, handler_pkg_code(job.handler_id) AS code, job.status_id AS s_id, status_name(job.status_id) AS status_name, job.created_by, job.waiting_for AS wait4, (job.created_at)::timestamp(0) without time zone AS created_at, (job.run_at)::timestamp(0) without time zone AS run_at, (job.exit_at)::timestamp(0) without time zone AS exit_at FROM wsd.job ORDER BY job.id;


--
-- Name: srv_error; Type: TABLE; Schema: job; Owner: -
--

CREATE TABLE srv_error (
    created_at timestamp(0) without time zone DEFAULT now() NOT NULL,
    job_id integer NOT NULL,
    status_id integer NOT NULL,
    exit_text text NOT NULL
);


--
-- Name: TABLE srv_error; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON TABLE srv_error IS 'Ошибки выполнения job.srv';


--
-- Name: COLUMN srv_error.created_at; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN srv_error.created_at IS 'Момент возникновения';


--
-- Name: COLUMN srv_error.job_id; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN srv_error.job_id IS 'ID задачи';


--
-- Name: COLUMN srv_error.status_id; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN srv_error.status_id IS 'ID статуса завершения';


--
-- Name: COLUMN srv_error.exit_text; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN srv_error.exit_text IS 'Текст ошибки';


--
-- Name: status; Type: TABLE; Schema: job; Owner: -
--

CREATE TABLE status (
    id ws.d_id32 NOT NULL,
    can_create boolean NOT NULL,
    can_run boolean NOT NULL,
    can_arc boolean NOT NULL,
    name ws.d_string NOT NULL,
    anno ws.d_text NOT NULL
);


--
-- Name: TABLE status; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON TABLE status IS 'Статус';


--
-- Name: COLUMN status.id; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN status.id IS 'ID статуса';


--
-- Name: COLUMN status.can_create; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN status.can_create IS 'Допустим при создании';


--
-- Name: COLUMN status.can_run; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN status.can_run IS 'Допустимо выполнение';


--
-- Name: COLUMN status.can_arc; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN status.can_arc IS 'Допустима архивация';


--
-- Name: COLUMN status.name; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN status.name IS 'Название';


--
-- Name: COLUMN status.anno; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN status.anno IS 'Аннотация';


SET search_path = wsd, pg_catalog;

--
-- Name: job_past; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE job_past (
    id integer NOT NULL,
    validfrom timestamp(0) without time zone NOT NULL,
    prio integer NOT NULL,
    handler_id integer NOT NULL,
    status_id integer NOT NULL,
    created_by integer,
    waiting_for integer,
    arg_id integer,
    arg_date date,
    arg_num numeric,
    arg_more text,
    arg_id2 integer,
    arg_date2 date,
    arg_id3 integer,
    created_at timestamp without time zone NOT NULL,
    run_pid integer,
    run_ip inet,
    run_at timestamp without time zone,
    exit_at timestamp without time zone
);


--
-- Name: TABLE job_past; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE job_past IS 'Архив выполненных задач';


--
-- Name: COLUMN job_past.id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_past.id IS 'ID задачи';


--
-- Name: COLUMN job_past.validfrom; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_past.validfrom IS 'дата активации';


--
-- Name: COLUMN job_past.prio; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_past.prio IS 'фактический приоритет';


--
-- Name: COLUMN job_past.handler_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_past.handler_id IS 'ID обработчика';


--
-- Name: COLUMN job_past.status_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_past.status_id IS 'текущий статус';


--
-- Name: COLUMN job_past.created_by; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_past.created_by IS 'id задачи/сессии, создавшей';


--
-- Name: COLUMN job_past.waiting_for; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_past.waiting_for IS 'id задачи, которую ждем';


--
-- Name: COLUMN job_past.arg_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_past.arg_id IS 'аргумент id';


--
-- Name: COLUMN job_past.arg_date; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_past.arg_date IS 'аргумент date';


--
-- Name: COLUMN job_past.arg_num; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_past.arg_num IS 'аргумент num';


--
-- Name: COLUMN job_past.arg_more; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_past.arg_more IS 'аргумент more';


--
-- Name: COLUMN job_past.arg_id2; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_past.arg_id2 IS 'аргумент id2';


--
-- Name: COLUMN job_past.arg_date2; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_past.arg_date2 IS 'аргумент date2';


--
-- Name: COLUMN job_past.arg_id3; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_past.arg_id3 IS 'аргумент id3';


--
-- Name: COLUMN job_past.created_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_past.created_at IS 'время создания';


--
-- Name: COLUMN job_past.run_pid; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_past.run_pid IS 'pid выполняющего процесса';


--
-- Name: COLUMN job_past.run_ip; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_past.run_ip IS 'ip хоста выполняющего процесса';


--
-- Name: COLUMN job_past.run_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_past.run_at IS 'время начала выполнения';


--
-- Name: COLUMN job_past.exit_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_past.exit_at IS 'время завершения выполнения';


--
-- Name: job_todo; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE job_todo (
    id integer DEFAULT nextval('job_seq'::regclass) NOT NULL,
    validfrom timestamp(0) without time zone NOT NULL,
    prio integer NOT NULL,
    handler_id integer NOT NULL,
    status_id integer NOT NULL,
    created_by integer,
    waiting_for integer,
    arg_id integer,
    arg_date date,
    arg_num numeric,
    arg_more text,
    arg_id2 integer,
    arg_date2 date,
    arg_id3 integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    run_pid integer,
    run_ip inet,
    run_at timestamp without time zone,
    exit_at timestamp without time zone
);


--
-- Name: TABLE job_todo; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE job_todo IS 'Задачи будущих дней';


--
-- Name: COLUMN job_todo.id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_todo.id IS 'ID задачи';


--
-- Name: COLUMN job_todo.validfrom; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_todo.validfrom IS 'дата активации';


--
-- Name: COLUMN job_todo.prio; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_todo.prio IS 'фактический приоритет';


--
-- Name: COLUMN job_todo.handler_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_todo.handler_id IS 'ID обработчика';


--
-- Name: COLUMN job_todo.status_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_todo.status_id IS 'текущий статус';


--
-- Name: COLUMN job_todo.created_by; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_todo.created_by IS 'id задачи/сессии, создавшей';


--
-- Name: COLUMN job_todo.waiting_for; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_todo.waiting_for IS 'id задачи, которую ждем';


--
-- Name: COLUMN job_todo.arg_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_todo.arg_id IS 'аргумент id';


--
-- Name: COLUMN job_todo.arg_date; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_todo.arg_date IS 'аргумент date';


--
-- Name: COLUMN job_todo.arg_num; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_todo.arg_num IS 'аргумент num';


--
-- Name: COLUMN job_todo.arg_more; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_todo.arg_more IS 'аргумент more';


--
-- Name: COLUMN job_todo.arg_id2; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_todo.arg_id2 IS 'аргумент id2';


--
-- Name: COLUMN job_todo.arg_date2; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_todo.arg_date2 IS 'аргумент date2';


--
-- Name: COLUMN job_todo.arg_id3; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_todo.arg_id3 IS 'аргумент id3';


--
-- Name: COLUMN job_todo.created_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_todo.created_at IS 'время создания';


--
-- Name: COLUMN job_todo.run_pid; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_todo.run_pid IS 'pid выполняющего процесса';


--
-- Name: COLUMN job_todo.run_ip; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_todo.run_ip IS 'ip хоста выполняющего процесса';


--
-- Name: COLUMN job_todo.run_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_todo.run_at IS 'время начала выполнения';


--
-- Name: COLUMN job_todo.exit_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_todo.exit_at IS 'время завершения выполнения';


SET search_path = job, pg_catalog;

--
-- Name: stored; Type: VIEW; Schema: job; Owner: -
--

CREATE VIEW stored AS
    (SELECT 'current'::text AS storage_code, job.id, job.validfrom, job.prio, job.handler_id, job.status_id, job.created_by, job.waiting_for, job.arg_id, job.arg_date, job.arg_num, job.arg_more, job.arg_id2, job.arg_date2, job.arg_id3, job.created_at, job.run_pid, job.run_ip, job.run_at, job.exit_at FROM wsd.job UNION SELECT 'todo'::text AS storage_code, job_todo.id, job_todo.validfrom, job_todo.prio, job_todo.handler_id, job_todo.status_id, job_todo.created_by, job_todo.waiting_for, job_todo.arg_id, job_todo.arg_date, job_todo.arg_num, job_todo.arg_more, job_todo.arg_id2, job_todo.arg_date2, job_todo.arg_id3, job_todo.created_at, job_todo.run_pid, job_todo.run_ip, job_todo.run_at, job_todo.exit_at FROM wsd.job_todo) UNION SELECT 'past'::text AS storage_code, job_past.id, job_past.validfrom, job_past.prio, job_past.handler_id, job_past.status_id, job_past.created_by, job_past.waiting_for, job_past.arg_id, job_past.arg_date, job_past.arg_num, job_past.arg_more, job_past.arg_id2, job_past.arg_date2, job_past.arg_id3, job_past.created_at, job_past.run_pid, job_past.run_ip, job_past.run_at, job_past.exit_at FROM wsd.job_past;


--
-- Name: VIEW stored; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON VIEW stored IS 'Все хранилища job';


--
-- Name: COLUMN stored.storage_code; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN stored.storage_code IS 'Код хранилища';


--
-- Name: COLUMN stored.id; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN stored.id IS 'ID задачи';


--
-- Name: COLUMN stored.validfrom; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN stored.validfrom IS 'дата активации';


--
-- Name: COLUMN stored.prio; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN stored.prio IS 'фактический приоритет';


--
-- Name: COLUMN stored.handler_id; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN stored.handler_id IS 'ID обработчика';


--
-- Name: COLUMN stored.status_id; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN stored.status_id IS 'текущий статус';


--
-- Name: COLUMN stored.created_by; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN stored.created_by IS 'id задачи/сессии, создавшей';


--
-- Name: COLUMN stored.waiting_for; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN stored.waiting_for IS 'id задачи, которую ждем';


--
-- Name: COLUMN stored.arg_id; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN stored.arg_id IS 'аргумент id';


--
-- Name: COLUMN stored.arg_date; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN stored.arg_date IS 'аргумент date';


--
-- Name: COLUMN stored.arg_num; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN stored.arg_num IS 'аргумент num';


--
-- Name: COLUMN stored.arg_more; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN stored.arg_more IS 'аргумент more';


--
-- Name: COLUMN stored.arg_id2; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN stored.arg_id2 IS 'аргумент id2';


--
-- Name: COLUMN stored.arg_date2; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN stored.arg_date2 IS 'аргумент date2';


--
-- Name: COLUMN stored.arg_id3; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN stored.arg_id3 IS 'аргумент id3';


--
-- Name: COLUMN stored.created_at; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN stored.created_at IS 'время создания';


--
-- Name: COLUMN stored.run_pid; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN stored.run_pid IS 'pid выполняющего процесса';


--
-- Name: COLUMN stored.run_ip; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN stored.run_ip IS 'ip хоста выполняющего процесса';


--
-- Name: COLUMN stored.run_at; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN stored.run_at IS 'время начала выполнения';


--
-- Name: COLUMN stored.exit_at; Type: COMMENT; Schema: job; Owner: -
--

COMMENT ON COLUMN stored.exit_at IS 'время завершения выполнения';


SET search_path = wsd, pg_catalog;

--
-- Name: doc_keyword; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE doc_keyword (
    id integer NOT NULL,
    name text NOT NULL
);


--
-- Name: TABLE doc_keyword; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE doc_keyword IS 'Ключевые слова';


--
-- Name: COLUMN doc_keyword.id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN doc_keyword.id IS 'ID статьи';


--
-- Name: COLUMN doc_keyword.name; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN doc_keyword.name IS 'Слово';


SET search_path = wiki, pg_catalog;

--
-- Name: doc_keyword_info; Type: VIEW; Schema: wiki; Owner: -
--

CREATE VIEW doc_keyword_info AS
    SELECT d.id, d.group_id, dk.name FROM (wsd.doc d JOIN wsd.doc_keyword dk USING (id));


SET search_path = ws, pg_catalog;

--
-- Name: class_action_acl_ext; Type: VIEW; Schema: ws; Owner: -
--

CREATE VIEW class_action_acl_ext AS
    SELECT aa.class_id, aa.action_id, aa.acl_id, cl.name AS class, a1.name AS action, a2.name AS acl FROM (((class_action_acl aa JOIN class cl ON (((aa.class_id)::integer = (cl.id)::integer))) JOIN class_action a1 ON ((((aa.class_id)::integer = (a1.class_id)::integer) AND ((aa.action_id)::integer = (a1.id)::integer)))) JOIN class_acl a2 ON ((((aa.class_id)::integer = (a2.class_id)::integer) AND ((aa.acl_id)::integer = (a2.id)::integer))));


--
-- Name: VIEW class_action_acl_ext; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON VIEW class_action_acl_ext IS 'class_action_acl с именами class, action, acl';


--
-- Name: COLUMN class_action_acl_ext.class_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_action_acl_ext.class_id IS 'ID класса';


--
-- Name: COLUMN class_action_acl_ext.action_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_action_acl_ext.action_id IS 'ID акции';


--
-- Name: COLUMN class_action_acl_ext.acl_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_action_acl_ext.acl_id IS 'ID уровня доступа';


--
-- Name: COLUMN class_action_acl_ext.class; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_action_acl_ext.class IS 'Название класса';


--
-- Name: COLUMN class_action_acl_ext.action; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_action_acl_ext.action IS 'Название акции';


--
-- Name: COLUMN class_action_acl_ext.acl; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_action_acl_ext.acl IS 'Название уровня доступа';


--
-- Name: caa; Type: VIEW; Schema: ws; Owner: -
--

CREATE VIEW caa AS
    SELECT class_action_acl_ext.class_id, class_action_acl_ext.action_id, class_action_acl_ext.acl_id, class_action_acl_ext.class, class_action_acl_ext.action, class_action_acl_ext.acl FROM class_action_acl_ext;


--
-- Name: VIEW caa; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON VIEW caa IS 'Синоним class_action_acl_ext';


--
-- Name: COLUMN caa.class_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN caa.class_id IS 'ID класса';


--
-- Name: COLUMN caa.action_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN caa.action_id IS 'ID акции';


--
-- Name: COLUMN caa.acl_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN caa.acl_id IS 'ID уровня доступа';


--
-- Name: COLUMN caa.class; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN caa.class IS 'Название класса';


--
-- Name: COLUMN caa.action; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN caa.action IS 'Название акции';


--
-- Name: COLUMN caa.acl; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN caa.acl IS 'Название уровня доступа';


--
-- Name: class_status_action_ext; Type: VIEW; Schema: ws; Owner: -
--

CREATE VIEW class_status_action_ext AS
    SELECT sa.class_id, sa.status_id, sa.action_id, cl.name AS class, s.name AS status, a.name AS action FROM (((class_status_action sa JOIN class cl ON (((sa.class_id)::integer = (cl.id)::integer))) JOIN class_status s ON ((((sa.class_id)::integer = (s.class_id)::integer) AND ((sa.status_id)::integer = (s.id)::integer)))) JOIN class_action a ON ((((sa.class_id)::integer = (a.class_id)::integer) AND ((sa.action_id)::integer = (a.id)::integer))));


--
-- Name: VIEW class_status_action_ext; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON VIEW class_status_action_ext IS 'class_status_action с именами class, status, action';


--
-- Name: COLUMN class_status_action_ext.class_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_ext.class_id IS 'ID класса';


--
-- Name: COLUMN class_status_action_ext.status_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_ext.status_id IS 'ID статуса';


--
-- Name: COLUMN class_status_action_ext.action_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_ext.action_id IS 'ID акции';


--
-- Name: COLUMN class_status_action_ext.class; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_ext.class IS 'Название класса';


--
-- Name: COLUMN class_status_action_ext.status; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_ext.status IS 'Название статуса';


--
-- Name: COLUMN class_status_action_ext.action; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN class_status_action_ext.action IS 'Название акции';


--
-- Name: compile_errors; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE compile_errors (
    data text,
    stamp timestamp without time zone DEFAULT now(),
    usr text DEFAULT "current_user"(),
    ip inet DEFAULT inet_client_addr()
);


--
-- Name: TABLE compile_errors; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE compile_errors IS 'Буфер хранения ошибок на этапе компиляции';


--
-- Name: COLUMN compile_errors.data; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN compile_errors.data IS 'текст';


--
-- Name: COLUMN compile_errors.stamp; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN compile_errors.stamp IS 'Момент компиляции';


--
-- Name: COLUMN compile_errors.usr; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN compile_errors.usr IS 'Имя пользователя соединения с БД';


--
-- Name: COLUMN compile_errors.ip; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN compile_errors.ip IS 'IP пользователя соединения с БД';


--
-- Name: csa; Type: VIEW; Schema: ws; Owner: -
--

CREATE VIEW csa AS
    SELECT class_status_action_ext.class_id, class_status_action_ext.status_id, class_status_action_ext.action_id, class_status_action_ext.class, class_status_action_ext.status, class_status_action_ext.action FROM class_status_action_ext;


--
-- Name: VIEW csa; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON VIEW csa IS 'Синоним class_status_action_ext';


--
-- Name: COLUMN csa.class_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN csa.class_id IS 'ID класса';


--
-- Name: COLUMN csa.status_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN csa.status_id IS 'ID статуса';


--
-- Name: COLUMN csa.action_id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN csa.action_id IS 'ID акции';


--
-- Name: COLUMN csa.class; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN csa.class IS 'Название класса';


--
-- Name: COLUMN csa.status; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN csa.status IS 'Название статуса';


--
-- Name: COLUMN csa.action; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN csa.action IS 'Название акции';


--
-- Name: error_data; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE error_data (
    code d_errcode NOT NULL
);


--
-- Name: TABLE error_data; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE error_data IS 'Коды ошибок (без строк локализации)';


--
-- Name: COLUMN error_data.code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN error_data.code IS 'Код ошибки';


--
-- Name: facet_dt_base; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE facet_dt_base (
    id d_id32 NOT NULL,
    base_code d_code NOT NULL
);


--
-- Name: TABLE facet_dt_base; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE facet_dt_base IS 'Для какого базового типа применимо ограничение';


--
-- Name: COLUMN facet_dt_base.id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN facet_dt_base.id IS 'ID ограничения';


--
-- Name: COLUMN facet_dt_base.base_code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN facet_dt_base.base_code IS 'Код базового типа';


--
-- Name: pg_const; Type: VIEW; Schema: ws; Owner: -
--

CREATE VIEW pg_const AS
    SELECT pg_schema_by_oid(p.pronamespace) AS schema, p.proname AS code, format_type(p.prorettype, NULL::integer) AS type, pg_exec_func(pg_schema_by_oid(p.pronamespace), (p.proname)::text) AS value, obj_description(p.oid, 'pg_proc'::name) AS anno FROM pg_proc p WHERE (p.proname ~~ 'const_%'::text) ORDER BY pg_schema_by_oid(p.pronamespace), p.proname;


--
-- Name: VIEW pg_const; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON VIEW pg_const IS 'Справочник внутренних констант пакетов';


--
-- Name: pg_sql; Type: VIEW; Schema: ws; Owner: -
--

CREATE VIEW pg_sql AS
    SELECT pg_stat_activity.datname, (now() - pg_stat_activity.query_start) AS duration, pg_stat_activity.application_name, pg_stat_activity.procpid, pg_stat_activity.current_query FROM pg_stat_activity WHERE (pg_stat_activity.current_query <> '<IDLE>'::text) ORDER BY (now() - pg_stat_activity.query_start) DESC;


--
-- Name: VIEW pg_sql; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON VIEW pg_sql IS 'Текущие запросы к БД';


--
-- Name: pkg_id_seq; Type: SEQUENCE; Schema: ws; Owner: -
--

CREATE SEQUENCE pkg_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pkg_log; Type: TABLE; Schema: ws; Owner: -
--

CREATE TABLE pkg_log (
    id integer DEFAULT nextval('pkg_id_seq'::regclass) NOT NULL,
    code text DEFAULT 'ws'::text NOT NULL,
    ver text DEFAULT '000'::text NOT NULL,
    op character(1) DEFAULT '+'::bpchar,
    log_name text,
    user_name text,
    ssh_client text,
    usr text DEFAULT "current_user"(),
    ip inet DEFAULT inet_client_addr(),
    stamp timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE pkg_log; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON TABLE pkg_log IS 'Журнал изменений пакетов PGWS';


--
-- Name: COLUMN pkg_log.id; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN pkg_log.id IS 'ID изменения';


--
-- Name: COLUMN pkg_log.code; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN pkg_log.code IS 'Код пакета';


--
-- Name: COLUMN pkg_log.ver; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN pkg_log.ver IS 'Версия пакета (reserved)';


--
-- Name: COLUMN pkg_log.op; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN pkg_log.op IS 'Код операции (+ init, - drop, = make)';


--
-- Name: COLUMN pkg_log.log_name; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN pkg_log.log_name IS '$LOGNAME из сессии пользователя в ОС';


--
-- Name: COLUMN pkg_log.user_name; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN pkg_log.user_name IS '$USERNAME из сессии пользователя в ОС';


--
-- Name: COLUMN pkg_log.ssh_client; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN pkg_log.ssh_client IS '$SSH_CLIENT из сессии пользователя в ОС';


--
-- Name: COLUMN pkg_log.usr; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN pkg_log.usr IS 'Имя пользователя соединения с БД';


--
-- Name: COLUMN pkg_log.ip; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN pkg_log.ip IS 'IP пользователя соединения с БД';


--
-- Name: COLUMN pkg_log.stamp; Type: COMMENT; Schema: ws; Owner: -
--

COMMENT ON COLUMN pkg_log.stamp IS 'Момент выполнения изменения';


SET search_path = wsd, pg_catalog;

--
-- Name: account_contact; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE account_contact (
    account_id integer NOT NULL,
    contact_type_id integer NOT NULL,
    value text NOT NULL,
    varified_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: TABLE account_contact; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE account_contact IS 'Контакты учетной записи';


--
-- Name: COLUMN account_contact.account_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN account_contact.account_id IS 'ID учетной записи';


--
-- Name: COLUMN account_contact.contact_type_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN account_contact.contact_type_id IS 'ID типа контакта';


--
-- Name: account_role; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE account_role (
    account_id integer NOT NULL,
    role_id integer NOT NULL
);


--
-- Name: TABLE account_role; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE account_role IS 'Роли учетной записи';


--
-- Name: COLUMN account_role.account_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN account_role.account_id IS 'ID учетной записи';


--
-- Name: COLUMN account_role.role_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN account_role.role_id IS 'ID роли';


--
-- Name: event_notify; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE event_notify (
    event_id integer NOT NULL,
    account_id integer NOT NULL,
    role_id integer NOT NULL,
    is_new boolean DEFAULT true NOT NULL,
    cause_id integer NOT NULL,
    read_at timestamp(0) without time zone,
    read_by integer,
    deleted_at timestamp(0) without time zone,
    deleted_by integer,
    notify_at timestamp(0) without time zone,
    notify_data text,
    confirm_at timestamp(0) without time zone,
    confirm_data text
);


--
-- Name: TABLE event_notify; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE event_notify IS 'Уведомление';


--
-- Name: COLUMN event_notify.event_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_notify.event_id IS 'ID события';


--
-- Name: COLUMN event_notify.account_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_notify.account_id IS 'ID пользователя';


--
-- Name: COLUMN event_notify.role_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_notify.role_id IS 'ID роли пользователя';


--
-- Name: COLUMN event_notify.cause_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_notify.cause_id IS 'ID причины связывания';


--
-- Name: COLUMN event_notify.read_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_notify.read_at IS 'время прочтения';


--
-- Name: COLUMN event_notify.read_by; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_notify.read_by IS 'SID пользователя';


--
-- Name: COLUMN event_notify.deleted_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_notify.deleted_at IS 'время удаления';


--
-- Name: COLUMN event_notify.deleted_by; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_notify.deleted_by IS 'SID пользователя';


--
-- Name: COLUMN event_notify.notify_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_notify.notify_at IS 'время отправки дополнительного уведомления (согласно профайлу)';


--
-- Name: COLUMN event_notify.notify_data; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_notify.notify_data IS 'ID доп. уведомления (message ID письма и т.п.)';


--
-- Name: COLUMN event_notify.confirm_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_notify.confirm_at IS 'время получения уведомления о доставке';


--
-- Name: COLUMN event_notify.confirm_data; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_notify.confirm_data IS 'результат отправки доп. уведомления';


--
-- Name: event_notify_spec; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE event_notify_spec (
    event_id integer NOT NULL,
    account_id integer NOT NULL,
    role_id integer NOT NULL,
    spec_id integer NOT NULL
);


--
-- Name: TABLE event_notify_spec; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE event_notify_spec IS 'Спецификация уведомления';


--
-- Name: COLUMN event_notify_spec.event_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_notify_spec.event_id IS 'ID события';


--
-- Name: COLUMN event_notify_spec.account_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_notify_spec.account_id IS 'ID пользователя';


--
-- Name: COLUMN event_notify_spec.role_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_notify_spec.role_id IS 'ID пользователя';


--
-- Name: COLUMN event_notify_spec.spec_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_notify_spec.spec_id IS 'ID спецификации';


--
-- Name: event_role_signup; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE event_role_signup (
    role_id integer NOT NULL,
    kind_id integer NOT NULL,
    spec_id integer NOT NULL,
    is_on boolean DEFAULT true NOT NULL,
    prio integer NOT NULL
);


--
-- Name: TABLE event_role_signup; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE event_role_signup IS 'Подписка роли';


--
-- Name: COLUMN event_role_signup.role_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_role_signup.role_id IS 'ID роли';


--
-- Name: COLUMN event_role_signup.kind_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_role_signup.kind_id IS 'ID вида события';


--
-- Name: COLUMN event_role_signup.spec_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_role_signup.spec_id IS 'ID спецификации';


--
-- Name: COLUMN event_role_signup.is_on; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_role_signup.is_on IS 'Подписка активна';


--
-- Name: COLUMN event_role_signup.prio; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_role_signup.prio IS 'Приоритет';


--
-- Name: event_signup; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE event_signup (
    account_id integer NOT NULL,
    role_id integer NOT NULL,
    kind_id integer NOT NULL,
    spec_id integer NOT NULL,
    is_on boolean DEFAULT true NOT NULL,
    prio integer NOT NULL,
    profile_id integer
);


--
-- Name: TABLE event_signup; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE event_signup IS 'Подписка роли';


--
-- Name: COLUMN event_signup.account_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_signup.account_id IS 'ID пользователя';


--
-- Name: COLUMN event_signup.kind_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_signup.kind_id IS 'ID вида события';


--
-- Name: COLUMN event_signup.spec_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_signup.spec_id IS 'ID спецификации';


--
-- Name: COLUMN event_signup.is_on; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_signup.is_on IS 'Подписка активна';


--
-- Name: COLUMN event_signup.prio; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_signup.prio IS 'Приоритет';


--
-- Name: COLUMN event_signup.profile_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_signup.profile_id IS 'ID профайла подписки';


--
-- Name: event_signup_profile; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE event_signup_profile (
    account_id integer NOT NULL,
    profile_id integer NOT NULL,
    format_code text,
    delay_hours integer DEFAULT 0 NOT NULL
);


--
-- Name: TABLE event_signup_profile; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE event_signup_profile IS 'Профайл подписок пользователя';


--
-- Name: COLUMN event_signup_profile.account_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_signup_profile.account_id IS 'ID пользователя';


--
-- Name: COLUMN event_signup_profile.profile_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_signup_profile.profile_id IS 'ID профайла';


--
-- Name: COLUMN event_signup_profile.format_code; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_signup_profile.format_code IS 'Код формата';


--
-- Name: COLUMN event_signup_profile.delay_hours; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_signup_profile.delay_hours IS 'Частота уведомления';


--
-- Name: event_spec; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE event_spec (
    event_id integer NOT NULL,
    spec_id integer NOT NULL
);


--
-- Name: TABLE event_spec; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE event_spec IS 'Спецификация события';


--
-- Name: COLUMN event_spec.event_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_spec.event_id IS 'ID события';


--
-- Name: COLUMN event_spec.spec_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN event_spec.spec_id IS 'ID спецификации';


--
-- Name: file_folder_format; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE file_folder_format (
    folder_code text NOT NULL,
    format_code text NOT NULL,
    is_internal boolean DEFAULT false NOT NULL
);


--
-- Name: job_cron; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE job_cron (
    is_active boolean DEFAULT true NOT NULL,
    run_at timestamp without time zone NOT NULL,
    prev_at timestamp without time zone
);


--
-- Name: TABLE job_cron; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE job_cron IS 'Время старта cron';


--
-- Name: COLUMN job_cron.is_active; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_cron.is_active IS 'Активный крон';


--
-- Name: COLUMN job_cron.run_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_cron.run_at IS 'Время последнего запуска';


--
-- Name: COLUMN job_cron.prev_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_cron.prev_at IS 'Время предыдущего запуска';


--
-- Name: job_dust; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE job_dust (
    id integer NOT NULL,
    validfrom timestamp(0) without time zone NOT NULL,
    prio integer NOT NULL,
    handler_id integer NOT NULL,
    status_id integer NOT NULL,
    created_by integer,
    waiting_for integer,
    arg_id integer,
    arg_date date,
    arg_num numeric,
    arg_more text,
    arg_id2 integer,
    arg_date2 date,
    arg_id3 integer,
    created_at timestamp without time zone NOT NULL,
    run_pid integer,
    run_ip inet,
    run_at timestamp without time zone,
    exit_at timestamp without time zone
);


--
-- Name: TABLE job_dust; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE job_dust IS 'Временное хранение выполненных задач до удаления';


--
-- Name: COLUMN job_dust.id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_dust.id IS 'ID задачи';


--
-- Name: COLUMN job_dust.validfrom; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_dust.validfrom IS 'дата активации';


--
-- Name: COLUMN job_dust.prio; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_dust.prio IS 'фактический приоритет';


--
-- Name: COLUMN job_dust.handler_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_dust.handler_id IS 'ID обработчика';


--
-- Name: COLUMN job_dust.status_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_dust.status_id IS 'текущий статус';


--
-- Name: COLUMN job_dust.created_by; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_dust.created_by IS 'id задачи/сессии, создавшей';


--
-- Name: COLUMN job_dust.waiting_for; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_dust.waiting_for IS 'id задачи, которую ждем';


--
-- Name: COLUMN job_dust.arg_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_dust.arg_id IS 'аргумент id';


--
-- Name: COLUMN job_dust.arg_date; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_dust.arg_date IS 'аргумент date';


--
-- Name: COLUMN job_dust.arg_num; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_dust.arg_num IS 'аргумент num';


--
-- Name: COLUMN job_dust.arg_more; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_dust.arg_more IS 'аргумент more';


--
-- Name: COLUMN job_dust.arg_id2; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_dust.arg_id2 IS 'аргумент id2';


--
-- Name: COLUMN job_dust.arg_date2; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_dust.arg_date2 IS 'аргумент date2';


--
-- Name: COLUMN job_dust.arg_id3; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_dust.arg_id3 IS 'аргумент id3';


--
-- Name: COLUMN job_dust.created_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_dust.created_at IS 'время создания';


--
-- Name: COLUMN job_dust.run_pid; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_dust.run_pid IS 'pid выполняющего процесса';


--
-- Name: COLUMN job_dust.run_ip; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_dust.run_ip IS 'ip хоста выполняющего процесса';


--
-- Name: COLUMN job_dust.run_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_dust.run_at IS 'время начала выполнения';


--
-- Name: COLUMN job_dust.exit_at; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN job_dust.exit_at IS 'время завершения выполнения';


--
-- Name: pkg_script_protected; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE pkg_script_protected (
    pkg text DEFAULT ws.pg_cs() NOT NULL,
    code text NOT NULL,
    ver text DEFAULT '000'::text NOT NULL,
    schema text DEFAULT ws.pg_cs(),
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE pkg_script_protected; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE pkg_script_protected IS 'Оперативные данные пакетов PGWS';


--
-- Name: role_acl; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE role_acl (
    role_id integer NOT NULL,
    class_id integer NOT NULL,
    object_id integer NOT NULL,
    acl_id integer
);


--
-- Name: TABLE role_acl; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE role_acl IS 'ACL глобальной роли';


--
-- Name: COLUMN role_acl.role_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN role_acl.role_id IS 'ID роли';


--
-- Name: role_team; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE role_team (
    role_id integer NOT NULL,
    team_id integer NOT NULL
);


--
-- Name: TABLE role_team; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE role_team IS 'Роль группы пользователей';


--
-- Name: COLUMN role_team.team_id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN role_team.team_id IS 'ID группы';


--
-- Name: team_id_seq; Type: SEQUENCE; Schema: wsd; Owner: -
--

CREATE SEQUENCE team_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team; Type: TABLE; Schema: wsd; Owner: -
--

CREATE TABLE team (
    id integer DEFAULT nextval('team_id_seq'::regclass) NOT NULL,
    name text NOT NULL,
    anno text NOT NULL
);


--
-- Name: TABLE team; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON TABLE team IS 'Группа пользователей';


--
-- Name: COLUMN team.id; Type: COMMENT; Schema: wsd; Owner: -
--

COMMENT ON COLUMN team.id IS 'ID группы';


SET search_path = i18n_def, pg_catalog;

--
-- Name: id_count; Type: DEFAULT; Schema: i18n_def; Owner: -
--

ALTER TABLE ONLY error ALTER COLUMN id_count SET DEFAULT 0;


--
-- Name: target; Type: DEFAULT; Schema: i18n_def; Owner: -
--

ALTER TABLE ONLY page ALTER COLUMN target SET DEFAULT ''::text;


SET search_path = i18n_en, pg_catalog;

--
-- Name: id_count; Type: DEFAULT; Schema: i18n_en; Owner: -
--

ALTER TABLE ONLY error ALTER COLUMN id_count SET DEFAULT 0;


--
-- Name: target; Type: DEFAULT; Schema: i18n_en; Owner: -
--

ALTER TABLE ONLY page ALTER COLUMN target SET DEFAULT ''::text;


SET search_path = cfg, pg_catalog;

--
-- Data for Name: prop; Type: TABLE DATA; Schema: cfg; Owner: -
--

INSERT INTO prop VALUES ('ws.daemon.db.sql.:i', 'cfg', '{db}', true, '', 'SQL настройки соединения с БД', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.startup.sock_wait', 'cfg', '{fcgi}', false, '10', 'Максимальная длина очереди ожидающих входящих запросов FCGI до обрыва новых соединений, шт', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.fcgi.frontend_poid', 'cfg', '{fcgi}', false, '1', 'POID настроек фронтенда', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.fcgi.core_poid', 'cfg', '{fcgi}', false, '1', 'POID настроек бэкенда', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.fe.tmpl.layout_default', 'cfg', '{fe}', false, 'style01', 'Название макета страниц', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.fe.tmpl.skin_default', 'cfg', '{fe}', false, 'default', 'Название скина страниц', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.lang.default', 'cfg', '{fe,be}', false, 'ru', 'Код язык сайта по умолчанию', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.lang.allowed.:i', 'cfg', '{fe,be}', true, '', 'Допустимые коды языка сайта', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.fe.tt2.:s', 'cfg', '{fe}', true, '', 'Параметр конфигурации TemplateToolkit', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.fe.sid_arg', 'cfg', '{fe}', false, '', 'Если задан - брать ID сессии из этого аргумента запроса, а не из cookie', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.fe.error_500', 'cfg', '{fe}', false, '/error/', 'Адрес внешнего редиректа при фатальной ошибке PGWS', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.fe.site_is_hidden', 'cfg', '{fe}', false, '1', 'Не выводить внешние счетчики на страницах', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.fe.post.:u', 'cfg', '{fe}', true, '', 'Адрес, на который будут отправляться POST-запросы к PGWS', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.fe.def.sid', 'cfg', '{fe}', false, 'acc.sid_info', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.fe.def.login', 'cfg', '{fe}', false, 'acc.login', 'Метод авторизации', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.fe.def.logout', 'cfg', '{fe}', false, 'acc.logout', 'Метод завершения сессии', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.fe.def.acl', 'cfg', '{fe}', false, 'info.acl_check', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.fe.def.uri', 'cfg', '{fe}', false, 'ws.page_by_uri', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.fe.def.code', 'cfg', '{fe}', false, 'ws.page_by_code', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.fe.tmpl.ext', 'cfg', '{fe}', false, '.tt2', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.fe.tmpl.error', 'cfg', '{fe}', false, 'app/error', 'Каталог шаблонов страниц описаний ошибок', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.fe.tmpl.pages', 'cfg', '{fe}', false, 'page/', 'Каталог шаблонов, вызываемых по GET-запросу', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.fe.tmpl.jobs', 'cfg', '{fe}', false, 'job/', 'Каталог шаблонов, вызываемых из Job', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.check_prefix', 'cfg', '{be}', false, 'check:', 'Префикс запроса на валидацию аргументов ACL', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.acl_prefix', 'cfg', '{be}', false, 'acl:', 'Префикс запроса на проверку ACL', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.nocache_prefix', 'cfg', '{be}', false, 'nc:', 'Префикс запроса без проверки кэша', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.db_noacc_code', 'cfg', '{be}', false, '42501', 'Код ошибки БД при запрете доступа', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.acl_trigger', 'cfg', '{be}', false, 'acc.log(in|out)', 'Regexp кодов методов меняющих ACL', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.lang.sql.default', 'cfg', '{be}', false, 'SET search_path TO i18n_def, public', 'Выбор языка по умолчанию', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.lang.sql.other', 'cfg', '{be}', false, 'SET search_path TO i18n_%s, i18n_def, public', 'Выбор языка', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.lang.sql.encoding', 'cfg', '{be}', false, 'SET client_encoding TO ''%s''', 'Выбор кодировки', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.def_method.code', 'cfg', '{be}', false, 'ws.method_by_code', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.def_method.code_real', 'cfg', '{be}', false, 'ws.method_by_code', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.def_method.is_sql', 'cfg', '{be}', false, '1', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.def_method.rvf_id', 'cfg', '{be}', false, '3', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.def.class', 'cfg', '{be}', false, 'ws.class', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.def.sid', 'cfg', '{be}', false, 'acc.sid_info', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.def.err', 'cfg', '{be}', false, 'ws.error_info', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.def.acl', 'cfg', '{be}', false, 'info.acl_check', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.def.acl_eff', 'cfg', '{be}', false, 'ws.acls_eff', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.def.dt', 'cfg', '{be}', false, 'ws.dt', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.def.dt_part', 'cfg', '{be}', false, 'ws.dt_part', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.def.dt_facet', 'cfg', '{be}', false, 'ws.dt_facet', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.def.facet', 'cfg', '{be}', false, 'ws.facet', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.def.uncache', 'cfg', '{be}', false, 'ws.uncache', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.def_suffix.status', 'cfg', '{be}', false, '.status', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.def_suffix.acl', 'cfg', '{be}', false, '.acl', '', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.plugin.:s.lib', 'cfg', '{be}', true, '', 'Пакет плагина', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.plugin.:s.pogc', 'cfg', '{be}', true, '', 'POGC настроек плагина (если используется)', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.plugin.:s.poid', 'cfg', '{be}', true, '', 'POID настроек плагина', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.plugin.:s.data_set', 'cfg', '{be}', true, '', 'Сохранять дамп настроек плагина', NULL, NULL);
INSERT INTO prop VALUES ('ws.plugin.cache.code', 'cfg', '{cache}', false, '', 'Код кэша', NULL, NULL);
INSERT INTO prop VALUES ('ws.plugin.cache.is_active', 'cfg', '{cache}', false, '1', 'Кэш включен', NULL, NULL);
INSERT INTO prop VALUES ('ws.plugin.cache.cache_size', 'cfg', '{cache}', false, '1024k', 'Размер кэша', NULL, NULL);
INSERT INTO prop VALUES ('ws.plugin.cache.page_size', 'cfg', '{cache}', false, '64k', 'Максимальный размер элемента хранения', NULL, NULL);
INSERT INTO prop VALUES ('ws.plugin.cache.expire_time', 'cfg', '{cache}', false, '10s', 'Максимальное время хранения элемента', NULL, NULL);
INSERT INTO prop VALUES ('ws.plugin.cache.enable_stats', 'cfg', '{cache}', false, '1', 'Собирать статистику работы с кэшем', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.error.:s.code', 'cfg', '{be}', true, '', 'Код ошибки JSON-RPC 2.0', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.error.:s.message', 'cfg', '{be}', true, '', 'Название ошибки JSON-RPC 2.0', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.be.error.:s.data', 'cfg', '{be}', true, '', 'Аннотация ошибки JSON-RPC 2.0', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.log.encoding', 'cfg', '{be,fe}', false, 'UTF-8', 'Кодировка по умолчанию', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.log.default_level', 'cfg', '{be,fe}', false, '3', 'Уровень отладки по умолчанию', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.log.syslog.default.(default,init,cache)', 'cfg', '{be}', true, '3', 'Уровень отладки запросов инициализации ядра', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.log.syslog.default.(default,call,sid,acl,cache,validate)', 'cfg', '{fe}', true, '3', 'Уровень отладки запросов POST', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.log.syslog.post.(default,call,sid,acl,cache,validate)', 'cfg', '{fe}', true, '3', 'Уровень отладки запросов POST', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.log.syslog.get.(default,call,sid,acl,cache,validate)', 'cfg', '{fe}', true, '3', 'Уровень отладки запросов GET', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.log.syslog.tmpl.(default,call,sid,acl,cache,validate)', 'cfg', '{fe}', true, '3', 'Уровень отладки запросов из шаблонов', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.log.debug.default.(default,call,sid,acl,cache,validate)', 'cfg', '{fe}', true, '3', 'Уровень отладки запросов POST', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.log.debug.post.(default,call,sid,acl,cache,validate)', 'cfg', '{fe}', true, '3', 'Уровень отладки запросов POST', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.log.debug.get.(default,call,sid,acl,cache,validate)', 'cfg', '{fe}', true, '3', 'Уровень отладки запросов GET', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.log.debug.tmpl.(default,call,sid,acl,cache,validate)', 'cfg', '{fe}', true, '3', 'Уровень отладки запросов из шаблонов', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.startup.pm.n_processes', 'cfg', '{fcgi,tm,job}', false, '10', 'Количество запускаемых процессов, шт', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.startup.pm.die_timeout', 'cfg', '{fcgi,tm,job}', false, '4', 'Время ожидания корректного завершения процесса, сек', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.mgr.listen_wait', 'cfg', '{tm,job}', false, '60', 'Время ожидания уведомления внутри итерации, сек', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.mgr.listen.job', 'cfg', '{tm,job}', false, '', 'Канал уведомлений (NOTIFY) о добавлении задания', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.mgr.cron_every', 'job', '{job}', false, '60', 'Запуск cron, если номер секунды в сутках кратен заданной', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.mgr.cron_predict', 'job', '{job}', false, '50', 'За сколько секунд до запуска cron резервировать процесс', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.mgr.mem_size', 'job', '{job}', false, '131072', 'Объем разделяемой памяти для очереди выполненных задач, байт', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.mgr.reload_key', 'job', '{job}', false, '', 'Пароль рестарта демона', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.mgr.listen.stat', 'job', '{job}', false, '', 'Канал команд (NOTIFY) об обновлении статистики процессов', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.mgr.listen.reload', 'job', '{job}', false, '', 'Канал команд (NOTIFY) о рестарте процессов', NULL, NULL);
INSERT INTO prop VALUES ('ws.daemon.log.syslog.job.(default,call,sid,acl,cache,validate)', 'job', '{fe}', true, '3', 'Уровень отладки запросов JOB', NULL, NULL);


SET search_path = ev, pg_catalog;

--
-- Data for Name: form; Type: TABLE DATA; Schema: ev; Owner: -
--



--
-- Data for Name: kind; Type: TABLE DATA; Schema: ev; Owner: -
--



--
-- Data for Name: kind_group; Type: TABLE DATA; Schema: ev; Owner: -
--



--
-- Data for Name: signature; Type: TABLE DATA; Schema: ev; Owner: -
--



--
-- Data for Name: status; Type: TABLE DATA; Schema: ev; Owner: -
--

INSERT INTO status VALUES (1, 'Ожидает спецификацию');
INSERT INTO status VALUES (2, 'Расчет адресатов');
INSERT INTO status VALUES (3, 'Подготовка уведомлений');
INSERT INTO status VALUES (4, 'Зарегистировано');
INSERT INTO status VALUES (7, 'Архив');


SET search_path = fs, pg_catalog;

--
-- Data for Name: file_format; Type: TABLE DATA; Schema: fs; Owner: -
--

INSERT INTO file_format VALUES ('*', 9, 'application/unknown', '.+', 'Файл');
INSERT INTO file_format VALUES ('jpg', 1, 'image/jpeg', 'jp(g|eg|e)', 'Файл jpg');
INSERT INTO file_format VALUES ('gif', 1, 'image/gif', 'gif', 'Файл gif');
INSERT INTO file_format VALUES ('png', 1, 'image/png', 'png', 'Файл png');
INSERT INTO file_format VALUES ('doc', 1, 'application/msword', 'doc', 'Файл doc');
INSERT INTO file_format VALUES ('rtf', 1, 'application/rtf', 'rtf', 'Файл rtf');
INSERT INTO file_format VALUES ('pdf', 1, 'application/pdf', 'pdf', 'Файл pdf');
INSERT INTO file_format VALUES ('zip', 1, 'application/x-gzip', 'zip', 'Файл zip');
INSERT INTO file_format VALUES ('arj', 1, 'application/octet-stream', 'arj', 'Файл arj');
INSERT INTO file_format VALUES ('rar', 1, 'application/x-rar-compressed', 'rar', 'Файл rar');
INSERT INTO file_format VALUES ('tar', 1, 'application/x-gtar', 'tar', 'Файл tar');
INSERT INTO file_format VALUES ('gz', 1, 'application/x-gzip', 'gz', 'Файл gz ');
INSERT INTO file_format VALUES ('tgz', 1, 'application/x-gzip', 'tgz', 'Файл tgz');
INSERT INTO file_format VALUES ('lha', 1, 'application/octet-stream', 'lha', 'Файл lha');
INSERT INTO file_format VALUES ('xls', 1, 'application/vnd.ms-excel', 'xls', 'Файл xls');
INSERT INTO file_format VALUES ('xml', 1, 'application/xml', 'xml', 'Файл xml');


SET search_path = i18n_def, pg_catalog;

--
-- Data for Name: error_message; Type: TABLE DATA; Schema: i18n_def; Owner: -
--

INSERT INTO error_message VALUES ('Y0001', 0, 'не задано обязательное значение');
INSERT INTO error_message VALUES ('Y0002', 2, 'значение не соответствует условию "%s %s"');
INSERT INTO error_message VALUES ('Y0003', 1, 'значение не соответствует шаблону "%s"');
INSERT INTO error_message VALUES ('Y0010', 0, 'нет данных');
INSERT INTO error_message VALUES ('Y0101', 1, 'недопустимый код acl "%s"');
INSERT INTO error_message VALUES ('Y0102', 1, 'внешний доступ к методу с "%s" запрещен');
INSERT INTO error_message VALUES ('Y0103', 0, 'необходима авторизация (не задан идентификатор сессии)');
INSERT INTO error_message VALUES ('Y0104', 1, 'некорректный идентификатор сессии "%s"');
INSERT INTO error_message VALUES ('Y0105', 1, 'не найдена проверка для acl "%s"');
INSERT INTO error_message VALUES ('Y0106', 1, 'некорректный идентификатор статуса "%s"');
INSERT INTO error_message VALUES ('Y0301', 0, 'неправильный пароль');
INSERT INTO error_message VALUES ('Y0302', 0, 'неизвестный логин');
INSERT INTO error_message VALUES ('Y0303', 1, 'статус пользователя (%s) не допускает авторизацию');
INSERT INTO error_message VALUES ('Y9901', 1, 'Не найдена группа "%s"');
INSERT INTO error_message VALUES ('Y9902', 1, 'Версия документа (%s) не актуальна и(или) устарела');
INSERT INTO error_message VALUES ('Y9903', 1, 'Документ с таким адресом уже создан (%s)');
INSERT INTO error_message VALUES ('Y9904', 0, 'Документ не содержит изменений');
INSERT INTO error_message VALUES ('Y9905', 0, 'Документ не найден');
INSERT INTO error_message VALUES ('Y0021', 1, 'нет доступа к результату суммы при а = %i');
INSERT INTO error_message VALUES ('Y0022', 1, 'нет данных по a = %i');


--
-- Data for Name: page_group; Type: TABLE DATA; Schema: i18n_def; Owner: -
--



--
-- Data for Name: page_name; Type: TABLE DATA; Schema: i18n_def; Owner: -
--

INSERT INTO page_name VALUES ('main', 'API');
INSERT INTO page_name VALUES ('api', 'Описание API');
INSERT INTO page_name VALUES ('api.smd', 'Описание методов');
INSERT INTO page_name VALUES ('api.map', 'Описание страниц');
INSERT INTO page_name VALUES ('api.xsd', 'Описание типов');
INSERT INTO page_name VALUES ('api.class', 'Описание классов');
INSERT INTO page_name VALUES ('api.smd1', 'Описание методов (JS)');
INSERT INTO page_name VALUES ('api.markup', 'Примеры разметки страниц');
INSERT INTO page_name VALUES ('api.class.single', 'Описание класса');
INSERT INTO page_name VALUES ('login', 'Вход');
INSERT INTO page_name VALUES ('logout', 'Выход');
INSERT INTO page_name VALUES ('wiki.wk', 'Вики');
INSERT INTO page_name VALUES ('wiki.wk.edit', 'Редактирование');
INSERT INTO page_name VALUES ('wiki.wk.history', 'История изменений');
INSERT INTO page_name VALUES ('wiki.wk.file', 'Файл');
INSERT INTO page_name VALUES ('api.test', 'Тестовая страница');


SET search_path = i18n_en, pg_catalog;

--
-- Data for Name: error_message; Type: TABLE DATA; Schema: i18n_en; Owner: -
--

INSERT INTO error_message VALUES ('Y0001', 0, 'required value does not given');
INSERT INTO error_message VALUES ('Y0002', 2, 'value does not conform to condition "%s %s"');
INSERT INTO error_message VALUES ('Y0003', 1, 'value does not conform to template "%s %s"');
INSERT INTO error_message VALUES ('Y0010', 0, 'no data');
INSERT INTO error_message VALUES ('Y0101', 1, 'incorrect acl code "%s"');
INSERT INTO error_message VALUES ('Y0102', 1, 'внешний доступ к методу с "%s" запрещен');
INSERT INTO error_message VALUES ('Y0103', 0, 'authorization required (no session id)');
INSERT INTO error_message VALUES ('Y0104', 1, 'incorrect session id "%s"');
INSERT INTO error_message VALUES ('Y0105', 1, 'no check for acl "%s"');
INSERT INTO error_message VALUES ('Y0106', 1, 'incorrect status id "%s"');
INSERT INTO error_message VALUES ('Y0301', 0, 'неправильный пароль');
INSERT INTO error_message VALUES ('Y0302', 0, 'неизвестный логин');
INSERT INTO error_message VALUES ('Y0303', 1, 'статус пользователя (%s) не допускает авторизацию');
INSERT INTO error_message VALUES ('Y0021', 1, 'no access to sum result when a = %i');
INSERT INTO error_message VALUES ('Y0022', 1, 'no data for a = %i');
INSERT INTO error_message VALUES ('Y9901', 1, 'Не найдена группа "%s"');
INSERT INTO error_message VALUES ('Y9902', 1, 'Версия документа (%s) не актуальна и(или) устарела');
INSERT INTO error_message VALUES ('Y9903', 1, 'Документ с таким адресом уже создан (%s)');
INSERT INTO error_message VALUES ('Y9904', 0, 'Документ не содержит изменений');
INSERT INTO error_message VALUES ('Y9905', 0, 'Документ не найден');


--
-- Data for Name: page_group; Type: TABLE DATA; Schema: i18n_en; Owner: -
--



--
-- Data for Name: page_name; Type: TABLE DATA; Schema: i18n_en; Owner: -
--

INSERT INTO page_name VALUES ('main', 'API');
INSERT INTO page_name VALUES ('api', 'API docs');
INSERT INTO page_name VALUES ('api.smd', 'Methods');
INSERT INTO page_name VALUES ('api.map', 'Pages');
INSERT INTO page_name VALUES ('api.xsd', 'Types');
INSERT INTO page_name VALUES ('api.class', 'Classes');
INSERT INTO page_name VALUES ('api.smd1', 'Methods via JS');
INSERT INTO page_name VALUES ('api.class.single', 'Class');
INSERT INTO page_name VALUES ('login', 'Вход');
INSERT INTO page_name VALUES ('logout', 'Выход');
INSERT INTO page_name VALUES ('api.test', 'Test page');
INSERT INTO page_name VALUES ('wiki.wk', 'Вики');
INSERT INTO page_name VALUES ('wiki.wk.edit', 'Редактирование');
INSERT INTO page_name VALUES ('wiki.wk.history', 'История изменений');


SET search_path = job, pg_catalog;

--
-- Data for Name: arg_type; Type: TABLE DATA; Schema: job; Owner: -
--

INSERT INTO arg_type VALUES (1, 'Нет');
INSERT INTO arg_type VALUES (2, 'Дата документа');
INSERT INTO arg_type VALUES (3, 'ID учетной записи');
INSERT INTO arg_type VALUES (4, 'ID группы');


--
-- Data for Name: handler; Type: TABLE DATA; Schema: job; Owner: -
--

INSERT INTO handler VALUES (1, 'job', 'stop', 86390, 2, 0, true, NULL, 1, 1, 1, 1, 1, 1, 1, 0, true, true, 'Остановка диспетчера');
INSERT INTO handler VALUES (2, 'job', 'clean', 1, 2, 0, true, NULL, 2, 1, 1, 1, 1, 1, 1, 7, true, true, 'Очистка списка текущих задач');
INSERT INTO handler VALUES (7, 'job', 'test_mgr', 3, 2, 0, true, NULL, 1, 1, 1, 1, 1, 1, 1, 100, true, true, 'Генерация тестовых задач');
INSERT INTO handler VALUES (8, 'job', 'test_run', 2, 2, 0, true, NULL, 1, 1, 1, 1, 1, 1, 1, 100, true, true, 'Обработка тестовой задачи');
INSERT INTO handler VALUES (9, 'job', 'today', 85800, 2, 0, true, NULL, 2, 1, 1, 1, 1, 1, 1, 7, true, true, 'Завершение дня');
INSERT INTO handler VALUES (4, 'acc', 'mailtest', 20, 2, 0, false, NULL, 2, 1, 1, 1, 1, 1, 1, 31, true, true, 'Тест API');


--
-- Data for Name: mgr_error; Type: TABLE DATA; Schema: job; Owner: -
--



--
-- Data for Name: mgr_stat; Type: TABLE DATA; Schema: job; Owner: -
--



--
-- Data for Name: srv_error; Type: TABLE DATA; Schema: job; Owner: -
--



--
-- Data for Name: status; Type: TABLE DATA; Schema: job; Owner: -
--

INSERT INTO status VALUES (1, true, false, false, 'Черновик', 'задача в стадии создания');
INSERT INTO status VALUES (2, true, true, false, 'К исполнению', 'задача готова к исполнению');
INSERT INTO status VALUES (3, false, true, false, 'После ожидания', 'ожидавшаяся задача завершена');
INSERT INTO status VALUES (4, false, true, false, 'Выполняется', 'происходит выполнение задачи');
INSERT INTO status VALUES (5, false, true, false, 'Ожидает', 'ожидает выполнения связанной задачи');
INSERT INTO status VALUES (6, true, false, true, 'Недоступна', 'выполнение недоступно (например - по недостатку баланса)');
INSERT INTO status VALUES (7, true, false, false, 'Вне очереди', 'задача уже выполняется отдельным процессом');
INSERT INTO status VALUES (8, true, false, true, 'Заблокирована', 'выполнение класса заблокировано админом');
INSERT INTO status VALUES (9, true, false, false, 'Срочная', 'выполнение точно в заданный срок');
INSERT INTO status VALUES (10, false, false, true, 'Завершена', 'выполнение завершено успешно');
INSERT INTO status VALUES (11, true, false, true, 'Протокол', 'задача не предназначена для выполнения');
INSERT INTO status VALUES (12, false, false, true, 'Ошибка', 'выполнение невозможно из-за ошибки');
INSERT INTO status VALUES (13, false, false, true, 'Нет изменений', 'задача завершена, но действий не производилось');


SET search_path = wiki, pg_catalog;

--
-- Data for Name: doc_extra; Type: TABLE DATA; Schema: wiki; Owner: -
--



--
-- Data for Name: doc_link; Type: TABLE DATA; Schema: wiki; Owner: -
--



SET search_path = ws, pg_catalog;

--
-- Data for Name: class; Type: TABLE DATA; Schema: ws; Owner: -
--

INSERT INTO class VALUES (1, NULL, 0, false, 1, 'system', 'Система');
INSERT INTO class VALUES (2, NULL, 0, false, 2, 'info', 'Информация');
INSERT INTO class VALUES (3, NULL, 1, false, 3, 'account', 'Учетная запись пользователя');
INSERT INTO class VALUES (4, NULL, 1, false, 4, 'team', 'Группа пользователей');
INSERT INTO class VALUES (10, NULL, 1, false, 10, 'wiki', 'Вики');
INSERT INTO class VALUES (11, NULL, 1, false, 11, 'doc', 'Статья Вики');


--
-- Data for Name: class_acl; Type: TABLE DATA; Schema: ws; Owner: -
--

INSERT INTO class_acl VALUES (1, 1, true, 11, 'Неавторизованный пользователь');
INSERT INTO class_acl VALUES (1, 2, true, 12, 'Авторизованный пользователь');
INSERT INTO class_acl VALUES (1, 3, true, 13, 'Сервис');
INSERT INTO class_acl VALUES (1, 4, true, 14, 'Администратор');
INSERT INTO class_acl VALUES (2, 1, true, 21, 'Любой пользователь');
INSERT INTO class_acl VALUES (10, 1, false, 101, 'Гость');
INSERT INTO class_acl VALUES (10, 2, false, 102, 'Читатель');
INSERT INTO class_acl VALUES (10, 3, false, 103, 'Комментатор');
INSERT INTO class_acl VALUES (10, 4, false, 104, 'Писатель');
INSERT INTO class_acl VALUES (10, 5, false, 105, 'Модератор');
INSERT INTO class_acl VALUES (11, 1, false, 101, 'Гость');
INSERT INTO class_acl VALUES (11, 2, false, 102, 'Читатель');
INSERT INTO class_acl VALUES (11, 3, false, 103, 'Комментатор');
INSERT INTO class_acl VALUES (11, 4, false, 104, 'Писатель');
INSERT INTO class_acl VALUES (11, 5, false, 105, 'Модератор');


--
-- Data for Name: class_action; Type: TABLE DATA; Schema: ws; Owner: -
--

INSERT INTO class_action VALUES (1, 1, 11, 'Чтение онлайн');
INSERT INTO class_action VALUES (1, 2, 12, 'Авторизованное чтение');
INSERT INTO class_action VALUES (1, 3, 13, 'Системное чтение');
INSERT INTO class_action VALUES (1, 4, 14, 'Авторизованная запись');
INSERT INTO class_action VALUES (1, 5, 15, 'Системная запись');
INSERT INTO class_action VALUES (1, 6, 16, 'Обслуживание');
INSERT INTO class_action VALUES (1, 7, 17, 'Использование онлайн');
INSERT INTO class_action VALUES (1, 8, 18, 'Только для неавторизованных');
INSERT INTO class_action VALUES (2, 1, 21, 'Публичное чтение');
INSERT INTO class_action VALUES (3, 1, 31, 'Авторизация');
INSERT INTO class_action VALUES (3, 2, 32, 'Просмотр публичных данных');
INSERT INTO class_action VALUES (3, 3, 33, 'Просмотр профиля');
INSERT INTO class_action VALUES (3, 4, 34, 'Изменение данных');
INSERT INTO class_action VALUES (3, 5, 35, 'Администрирование');
INSERT INTO class_action VALUES (10, 1, 101, 'Чтение');
INSERT INTO class_action VALUES (10, 2, 102, 'Комментирование');
INSERT INTO class_action VALUES (10, 3, 103, 'Редактирование');
INSERT INTO class_action VALUES (10, 4, 104, 'Создание');
INSERT INTO class_action VALUES (10, 5, 105, 'Модерация');
INSERT INTO class_action VALUES (11, 1, 111, 'Чтение');
INSERT INTO class_action VALUES (11, 2, 112, 'Комментирование');
INSERT INTO class_action VALUES (11, 3, 113, 'Редактирование');
INSERT INTO class_action VALUES (11, 5, 115, 'Модерация');


--
-- Data for Name: class_action_acl; Type: TABLE DATA; Schema: ws; Owner: -
--

INSERT INTO class_action_acl VALUES (1, 1, 1);
INSERT INTO class_action_acl VALUES (1, 1, 2);
INSERT INTO class_action_acl VALUES (1, 1, 3);
INSERT INTO class_action_acl VALUES (1, 1, 4);
INSERT INTO class_action_acl VALUES (1, 2, 2);
INSERT INTO class_action_acl VALUES (1, 3, 3);
INSERT INTO class_action_acl VALUES (1, 3, 4);
INSERT INTO class_action_acl VALUES (1, 4, 2);
INSERT INTO class_action_acl VALUES (1, 5, 3);
INSERT INTO class_action_acl VALUES (1, 5, 4);
INSERT INTO class_action_acl VALUES (1, 6, 4);
INSERT INTO class_action_acl VALUES (1, 7, 1);
INSERT INTO class_action_acl VALUES (1, 7, 2);
INSERT INTO class_action_acl VALUES (1, 8, 1);
INSERT INTO class_action_acl VALUES (2, 1, 1);
INSERT INTO class_action_acl VALUES (10, 1, 2);
INSERT INTO class_action_acl VALUES (10, 1, 3);
INSERT INTO class_action_acl VALUES (10, 4, 4);
INSERT INTO class_action_acl VALUES (10, 1, 4);
INSERT INTO class_action_acl VALUES (10, 3, 4);
INSERT INTO class_action_acl VALUES (10, 2, 3);
INSERT INTO class_action_acl VALUES (10, 2, 4);
INSERT INTO class_action_acl VALUES (10, 4, 5);
INSERT INTO class_action_acl VALUES (10, 1, 5);
INSERT INTO class_action_acl VALUES (10, 3, 5);
INSERT INTO class_action_acl VALUES (10, 2, 5);
INSERT INTO class_action_acl VALUES (10, 5, 5);
INSERT INTO class_action_acl VALUES (11, 1, 2);
INSERT INTO class_action_acl VALUES (11, 1, 3);
INSERT INTO class_action_acl VALUES (11, 1, 4);
INSERT INTO class_action_acl VALUES (11, 3, 4);
INSERT INTO class_action_acl VALUES (11, 2, 3);
INSERT INTO class_action_acl VALUES (11, 2, 4);
INSERT INTO class_action_acl VALUES (11, 1, 5);
INSERT INTO class_action_acl VALUES (11, 3, 5);
INSERT INTO class_action_acl VALUES (11, 2, 5);
INSERT INTO class_action_acl VALUES (11, 5, 5);


--
-- Data for Name: class_status; Type: TABLE DATA; Schema: ws; Owner: -
--

INSERT INTO class_status VALUES (1, 1, 11, 'Онлайн');
INSERT INTO class_status VALUES (1, 2, 12, 'На обслуживании');
INSERT INTO class_status VALUES (2, 1, 21, 'Онлайн');
INSERT INTO class_status VALUES (3, 1, 31, 'Не определен');
INSERT INTO class_status VALUES (3, 2, 32, 'Регистрация');
INSERT INTO class_status VALUES (3, 3, 32, 'Авторизация');
INSERT INTO class_status VALUES (3, 4, 33, 'Активен');
INSERT INTO class_status VALUES (3, 5, 34, 'Заблокирован');
INSERT INTO class_status VALUES (3, 6, 35, 'Отключен');
INSERT INTO class_status VALUES (10, 1, 101, 'Онлайн');
INSERT INTO class_status VALUES (10, 2, 102, 'Архив');
INSERT INTO class_status VALUES (10, 9, 109, 'Удалена');
INSERT INTO class_status VALUES (11, 1, 111, 'Онлайн');
INSERT INTO class_status VALUES (11, 2, 112, 'Архив');
INSERT INTO class_status VALUES (11, 3, 113, 'Черновик');
INSERT INTO class_status VALUES (11, 9, 119, 'Удалена');


--
-- Data for Name: class_status_action; Type: TABLE DATA; Schema: ws; Owner: -
--

INSERT INTO class_status_action VALUES (1, 1, 1);
INSERT INTO class_status_action VALUES (1, 1, 2);
INSERT INTO class_status_action VALUES (1, 1, 3);
INSERT INTO class_status_action VALUES (1, 1, 4);
INSERT INTO class_status_action VALUES (1, 1, 5);
INSERT INTO class_status_action VALUES (1, 1, 7);
INSERT INTO class_status_action VALUES (1, 1, 8);
INSERT INTO class_status_action VALUES (1, 2, 2);
INSERT INTO class_status_action VALUES (1, 2, 3);
INSERT INTO class_status_action VALUES (1, 2, 5);
INSERT INTO class_status_action VALUES (1, 2, 6);
INSERT INTO class_status_action VALUES (2, 1, 1);
INSERT INTO class_status_action VALUES (11, 1, 2);
INSERT INTO class_status_action VALUES (10, 1, 5);
INSERT INTO class_status_action VALUES (10, 1, 2);
INSERT INTO class_status_action VALUES (10, 1, 3);
INSERT INTO class_status_action VALUES (10, 1, 4);
INSERT INTO class_status_action VALUES (10, 1, 1);
INSERT INTO class_status_action VALUES (11, 1, 3);
INSERT INTO class_status_action VALUES (11, 1, 1);
INSERT INTO class_status_action VALUES (10, 2, 1);
INSERT INTO class_status_action VALUES (11, 1, 5);
INSERT INTO class_status_action VALUES (11, 3, 3);
INSERT INTO class_status_action VALUES (11, 3, 5);


--
-- Data for Name: class_status_action_acl_addon; Type: TABLE DATA; Schema: ws; Owner: -
--

INSERT INTO class_status_action_acl_addon VALUES (11, 3, 1, 4, true);
INSERT INTO class_status_action_acl_addon VALUES (11, 3, 1, 5, true);


--
-- Data for Name: compile_errors; Type: TABLE DATA; Schema: ws; Owner: -
--



--
-- Data for Name: dt; Type: TABLE DATA; Schema: ws; Owner: -
--

INSERT INTO dt VALUES ('text', 'text', 'text', true, NULL, 'Текст', false, false, false);
INSERT INTO dt VALUES ('boolean', 'boolean', 'boolean', true, NULL, 'Да/Нет', false, false, false);
INSERT INTO dt VALUES ('numeric', 'numeric', 'numeric', true, NULL, 'Число', false, false, false);
INSERT INTO dt VALUES ('interval', 'interval', 'interval', true, NULL, 'Интервал', false, false, false);
INSERT INTO dt VALUES ('timestamp', 'timestamp', 'timestamp', true, NULL, 'Момент', false, false, false);
INSERT INTO dt VALUES ('time', 'time', 'time', true, NULL, 'Время', false, false, false);
INSERT INTO dt VALUES ('date', 'date', 'date', true, NULL, 'Дата', false, false, false);
INSERT INTO dt VALUES ('inet', 'inet', 'inet', true, NULL, 'ip адрес', false, false, false);
INSERT INTO dt VALUES ('real', 'real', 'real', true, NULL, 'Число', false, false, false);
INSERT INTO dt VALUES ('integer', 'integer', 'integer', true, NULL, 'Целое', false, false, false);
INSERT INTO dt VALUES ('smallint', 'smallint', 'smallint', true, NULL, 'Короткое целое', false, false, false);
INSERT INTO dt VALUES ('oid', 'oid', 'oid', true, NULL, 'OID', false, false, false);
INSERT INTO dt VALUES ('double', 'double', 'double', true, NULL, 'Длинное вещественное число', false, false, false);
INSERT INTO dt VALUES ('bigint', 'bigint', 'bigint', true, NULL, 'Длинное целое', false, false, false);
INSERT INTO dt VALUES ('json', 'json', 'json', true, NULL, 'Данные в формате JSON', false, false, false);
INSERT INTO dt VALUES ('uuid', 'uuid', 'uuid', true, NULL, 'Universally Unique IDentifier', false, false, false);
INSERT INTO dt VALUES ('bpchar', 'bpchar', 'bpchar', true, NULL, 'Blank Padded Char', false, false, false);
INSERT INTO dt VALUES ('ws.d_id', 'integer', 'integer', true, NULL, 'Идентификатор', false, false, false);
INSERT INTO dt VALUES ('ws.d_id32', 'integer', 'integer', true, NULL, 'Идентификатор справочника', false, false, false);
INSERT INTO dt VALUES ('ws.d_stamp', 'timestamp', 'timestamp', true, NULL, 'Момент времени с точностью до секунды', false, false, false);
INSERT INTO dt VALUES ('ws.d_rating', 'numeric', 'numeric', true, NULL, 'Рейтинг компании', false, false, false);
INSERT INTO dt VALUES ('ws.d_sort', 'integer', 'integer', true, NULL, 'Порядок сортировки', false, false, false);
INSERT INTO dt VALUES ('ws.d_regexp', 'text', 'text', true, NULL, 'Регулярное выражение', false, false, false);
INSERT INTO dt VALUES ('ws.d_decimal_positive', 'numeric', 'numeric', true, NULL, 'Вещественное > 0', false, false, false);
INSERT INTO dt VALUES ('ws.d_id_positive', 'integer', 'integer', true, NULL, 'Целое > 0', false, false, false);
INSERT INTO dt VALUES ('ws.d_decimal_non_neg', 'numeric', 'numeric', true, NULL, 'Вещественное >= 0', false, false, false);
INSERT INTO dt VALUES ('ws.d_zip', 'text', 'text', true, NULL, 'Почтовый индекс', false, false, false);
INSERT INTO dt VALUES ('ws.d_text', 'text', 'text', true, NULL, 'Текст', false, false, false);
INSERT INTO dt VALUES ('ws.d_string', 'text', 'text', true, NULL, 'Текстовая строка', false, false, false);
INSERT INTO dt VALUES ('ws.d_login', 'text', 'text', true, NULL, 'Логин', false, false, false);
INSERT INTO dt VALUES ('ws.d_email', 'text', 'text', true, NULL, 'Адрес email', false, false, false);
INSERT INTO dt VALUES ('ws.d_emails', 'text', 'text', true, NULL, 'Список адресов email', true, false, false);
INSERT INTO dt VALUES ('ws.d_path', 'text', 'text', true, NULL, 'Относительный путь', false, false, false);
INSERT INTO dt VALUES ('ws.d_class', 'ws.d_id32', 'integer', true, NULL, 'ID класса', false, false, false);
INSERT INTO dt VALUES ('ws.d_cnt', 'integer', 'integer', true, NULL, 'Количество элементов', false, false, false);
INSERT INTO dt VALUES ('ws.d_amount', 'numeric', 'numeric', true, NULL, 'Количество товара', false, false, false);
INSERT INTO dt VALUES ('ws.d_format', 'text', 'text', true, NULL, 'Формат для printf', false, false, false);
INSERT INTO dt VALUES ('ws.d_code', 'text', 'text', true, NULL, 'Имя переменной', false, false, false);
INSERT INTO dt VALUES ('ws.d_code_arg', 'text', 'text', true, NULL, 'Имя аргумента', false, false, false);
INSERT INTO dt VALUES ('ws.d_codei', 'text', 'text', true, NULL, 'Имя переменной в любом регистре', false, false, false);
INSERT INTO dt VALUES ('ws.d_code_like', 'text', 'text', true, NULL, 'Шаблон имени переменной', false, false, false);
INSERT INTO dt VALUES ('ws.d_sub', 'text', 'text', true, NULL, 'Имя внешнего метода', false, false, false);
INSERT INTO dt VALUES ('ws.d_lang', 'text', 'text', true, NULL, 'Идентификатор языка', false, false, false);
INSERT INTO dt VALUES ('ws.d_errcode', 'bpchar', 'bpchar', true, NULL, 'Код ошибки', false, false, false);
INSERT INTO dt VALUES ('ws.d_money', 'numeric', 'numeric', true, NULL, 'Деньги', false, false, false);
INSERT INTO dt VALUES ('ws.d_acl', 'ws.d_id32', 'integer', true, NULL, 'Уровень доступа', false, false, false);
INSERT INTO dt VALUES ('ws.d_bitmask', 'ws.d_id32', 'integer', true, NULL, 'Битовая маска', false, false, false);
INSERT INTO dt VALUES ('ws.t_pg_proc_info', NULL, NULL, true, NULL, 'Параметры хранимой процедуры', false, true, false);
INSERT INTO dt VALUES ('ws.t_acl_check', NULL, NULL, true, NULL, 'Результат проверки ACL', false, true, false);
INSERT INTO dt VALUES ('ws.d_acls', 'ws.d_acl', 'integer', true, NULL, 'Массив уровней доступа', true, false, false);
INSERT INTO dt VALUES ('ws.d_booleana', 'boolean', 'boolean', true, NULL, 'Массив boolean', true, false, false);
INSERT INTO dt VALUES ('ws.d_texta', 'text', 'text', true, NULL, 'Массив text', true, false, false);
INSERT INTO dt VALUES ('ws.d_id32a', 'ws.d_id32', 'integer', true, NULL, 'Массив d_id32', true, false, false);
INSERT INTO dt VALUES ('ws.d_codea', 'ws.d_code', 'text', true, NULL, 'Массив d_code', true, false, false);
INSERT INTO dt VALUES ('ws.d_ida', 'ws.d_id', 'integer', true, NULL, 'Массив d_id', true, false, false);
INSERT INTO dt VALUES ('ws.d_moneya', 'ws.d_money', 'numeric', true, NULL, 'Массив d_money', true, false, false);
INSERT INTO dt VALUES ('ws.z_uncache', NULL, NULL, true, NULL, 'Аргументы функций cache_uncache', false, true, false);
INSERT INTO dt VALUES ('ws.z_acl_check', NULL, NULL, true, NULL, 'Аргументы функций acl_check', false, true, false);
INSERT INTO dt VALUES ('ws.z_store_get', NULL, NULL, true, NULL, 'Аргументы функций store_get', false, true, false);
INSERT INTO dt VALUES ('ws.z_store_set', NULL, NULL, true, NULL, 'Аргументы функций store_set', false, true, false);
INSERT INTO dt VALUES ('ws.t_date_info', NULL, NULL, true, NULL, 'Атрибуты даты', false, true, false);
INSERT INTO dt VALUES ('ws.z_date_info', NULL, NULL, true, NULL, 'Aргументы метода ws.date_info', false, true, false);
INSERT INTO dt VALUES ('ws.t_month_info', NULL, NULL, true, NULL, 'Атрибуты месяца', false, true, false);
INSERT INTO dt VALUES ('ws.z_month_info', NULL, NULL, true, NULL, 'Aргументы метода ws.month_info', false, true, false);
INSERT INTO dt VALUES ('ws.z_year_months', NULL, NULL, true, NULL, 'Aргументы метода ws.year_months', false, true, false);
INSERT INTO dt VALUES ('ws.ref', NULL, NULL, true, NULL, 'Справочник', false, true, false);
INSERT INTO dt VALUES ('ws.z_ref_info', NULL, NULL, true, NULL, 'Aргументы метода ws.ref_info', false, true, false);
INSERT INTO dt VALUES ('ws.ref_item', NULL, NULL, true, NULL, 'Позиция справочника', false, true, false);
INSERT INTO dt VALUES ('ws.z_ref', NULL, NULL, true, NULL, 'Aргументы метода ws.ref', false, true, false);
INSERT INTO dt VALUES ('ws.t_page_info', NULL, NULL, true, NULL, 'Параметры страницы', false, true, false);
INSERT INTO dt VALUES ('ws.z_page_by_code', NULL, NULL, true, NULL, 'Aргументы метода ws.page_by_code', false, true, false);
INSERT INTO dt VALUES ('ws.z_page_path', NULL, NULL, true, NULL, 'Aргументы метода ws.page_path', false, true, false);
INSERT INTO dt VALUES ('ws.z_page_childs', NULL, NULL, true, NULL, 'Aргументы метода ws.page_childs', false, true, false);
INSERT INTO dt VALUES ('ws.z_page_by_action', NULL, NULL, true, NULL, 'Aргументы метода ws.page_by_action', false, true, false);
INSERT INTO dt VALUES ('ws.t_hashtable', NULL, NULL, true, NULL, 'Хэштаблица', false, true, false);
INSERT INTO dt VALUES ('ws.z_page_tree', NULL, NULL, true, NULL, 'Aргументы метода ws.page_tree', false, true, false);
INSERT INTO dt VALUES ('ws.class', NULL, NULL, true, NULL, 'Класс объекта', false, true, false);
INSERT INTO dt VALUES ('ws.z_class', NULL, NULL, true, NULL, 'Aргументы метода ws.class', false, true, false);
INSERT INTO dt VALUES ('ws.method', NULL, NULL, true, NULL, 'Метод API', false, true, false);
INSERT INTO dt VALUES ('ws.z_method_lookup', NULL, NULL, true, NULL, 'Aргументы метода ws.method_lookup', false, true, false);
INSERT INTO dt VALUES ('ws.z_class_id', NULL, NULL, true, NULL, 'Aргументы метода ws.class_id', false, true, false);
INSERT INTO dt VALUES ('ws.z_page_by_uri', NULL, NULL, true, NULL, 'Aргументы метода ws.page_by_uri', false, true, false);
INSERT INTO dt VALUES ('i18n_def.error', NULL, NULL, true, NULL, 'Описание ошибки', false, true, false);
INSERT INTO dt VALUES ('ws.z_error_info', NULL, NULL, true, NULL, 'Aргументы метода ws.error_info', false, true, false);
INSERT INTO dt VALUES ('ws.method_rv_format', NULL, NULL, true, NULL, 'Формат результатов метода', false, true, false);
INSERT INTO dt VALUES ('ws.z_method_rvf', NULL, NULL, true, NULL, 'Aргументы метода ws.method_rvf', false, true, false);
INSERT INTO dt VALUES ('ws.z_method_by_code', NULL, NULL, true, NULL, 'Aргументы метода ws.method_by_code', false, true, false);
INSERT INTO dt VALUES ('ws.z_method_by_action', NULL, NULL, true, NULL, 'Aргументы метода ws.method_by_action', false, true, false);
INSERT INTO dt VALUES ('ws.facet', NULL, NULL, true, NULL, 'Вид ограничений типов', false, true, false);
INSERT INTO dt VALUES ('ws.z_facet', NULL, NULL, true, NULL, 'Aргументы метода ws.facet', false, true, false);
INSERT INTO dt VALUES ('ws.dt_facet', NULL, NULL, true, NULL, 'Значение ограничения типа', false, true, false);
INSERT INTO dt VALUES ('ws.z_dt_facet', NULL, NULL, true, NULL, 'Aргументы метода ws.dt_facet', false, true, false);
INSERT INTO dt VALUES ('ws.dt_part', NULL, NULL, true, NULL, 'Поля композитного типа', false, true, false);
INSERT INTO dt VALUES ('ws.z_dt_part', NULL, NULL, true, NULL, 'Aргументы метода ws.dt_part', false, true, false);
INSERT INTO dt VALUES ('ws.csaa', NULL, NULL, true, NULL, 'Синоним class_status_action_acl_ext', false, true, false);
INSERT INTO dt VALUES ('ws.z_class_status_action_acl', NULL, NULL, true, NULL, 'Aргументы метода ws.class_status_action_acl', false, true, false);
INSERT INTO dt VALUES ('ws.class_action', NULL, NULL, true, NULL, 'Акция объекта', false, true, false);
INSERT INTO dt VALUES ('ws.z_class_action', NULL, NULL, true, NULL, 'Aргументы метода ws.class_action', false, true, false);
INSERT INTO dt VALUES ('ws.class_status', NULL, NULL, true, NULL, 'Статус объекта', false, true, false);
INSERT INTO dt VALUES ('ws.z_class_status', NULL, NULL, true, NULL, 'Aргументы метода ws.class_status', false, true, false);
INSERT INTO dt VALUES ('ws.class_acl', NULL, NULL, true, NULL, 'Уровень доступа к объекту', false, true, false);
INSERT INTO dt VALUES ('ws.z_class_acl', NULL, NULL, true, NULL, 'Aргументы метода ws.class_acl', false, true, false);
INSERT INTO dt VALUES ('ws.dt', NULL, NULL, true, NULL, 'Описание типа', false, true, false);
INSERT INTO dt VALUES ('ws.z_dt', NULL, NULL, true, NULL, 'Aргументы метода ws.dt', false, true, false);
INSERT INTO dt VALUES ('ws.z_acls_eff_ids', NULL, NULL, true, NULL, 'Aргументы метода ws.acls_eff_ids', false, true, false);
INSERT INTO dt VALUES ('ws.z_acls_eff', NULL, NULL, true, NULL, 'Aргументы метода ws.acls_eff', false, true, false);
INSERT INTO dt VALUES ('ws.z_system_acl', NULL, NULL, true, NULL, 'Aргументы метода ws.system_acl', false, true, false);
INSERT INTO dt VALUES ('ws.d_sid', 'text', 'text', true, NULL, 'Идентификатор сессии', false, false, false);
INSERT INTO dt VALUES ('ws.z_info_acl', NULL, NULL, true, NULL, 'Aргументы метода ws.info_acl', false, true, false);
INSERT INTO dt VALUES ('cfg.z_cache', NULL, NULL, true, NULL, 'Aргументы метода cfg.cache', false, true, false);
INSERT INTO dt VALUES ('fs.z_file_new_path_mk', NULL, NULL, true, NULL, 'Aргументы метода fs.file_new_path_mk', false, true, false);
INSERT INTO dt VALUES ('fs.file_store', NULL, NULL, true, NULL, 'fs.file_store', false, true, false);
INSERT INTO dt VALUES ('fs.z_file_store', NULL, NULL, true, NULL, 'Aргументы метода fs.file_store', false, true, false);
INSERT INTO dt VALUES ('acc.account_attr', NULL, NULL, true, NULL, 'acc.account_attr', false, true, false);
INSERT INTO dt VALUES ('acc.z_profile', NULL, NULL, true, NULL, 'Aргументы метода acc.profile', false, true, false);
INSERT INTO dt VALUES ('wsd.session', NULL, NULL, true, NULL, 'Сессия авторизованного пользователя', false, true, false);
INSERT INTO dt VALUES ('acc.z_sid_info', NULL, NULL, true, NULL, 'Aргументы метода acc.sid_info', false, true, false);
INSERT INTO dt VALUES ('acc.session_info', NULL, NULL, true, NULL, 'acc.session_info', false, true, false);
INSERT INTO dt VALUES ('acc.z_login', NULL, NULL, true, NULL, 'Aргументы метода acc.login', false, true, false);
INSERT INTO dt VALUES ('acc.z_logout', NULL, NULL, true, NULL, 'Aргументы метода acc.logout', false, true, false);
INSERT INTO dt VALUES ('wiki.d_links', 'ws.d_path', 'text', true, NULL, 'Массив ссылок wiki', true, false, false);
INSERT INTO dt VALUES ('wiki.z_format', NULL, NULL, true, NULL, 'Аргументы метода format', false, true, false);
INSERT INTO dt VALUES ('wiki.z_add', NULL, NULL, true, NULL, 'Аргументы метода add', false, true, false);
INSERT INTO dt VALUES ('wiki.z_save', NULL, NULL, true, NULL, 'Аргументы метода save', false, true, false);
INSERT INTO dt VALUES ('wiki.z_status', NULL, NULL, true, NULL, 'Aргументы метода wiki.status', false, true, false);
INSERT INTO dt VALUES ('wiki.z_acl', NULL, NULL, true, NULL, 'Aргументы метода wiki.acl', false, true, false);
INSERT INTO dt VALUES ('wiki.z_id_by_code', NULL, NULL, true, NULL, 'Aргументы метода wiki.id_by_code', false, true, false);
INSERT INTO dt VALUES ('wiki.z_doc_id_by_code', NULL, NULL, true, NULL, 'Aргументы метода wiki.doc_id_by_code', false, true, false);
INSERT INTO dt VALUES ('wiki.z_doc_by_name', NULL, NULL, true, NULL, 'Aргументы метода wiki.doc_by_name', false, true, false);
INSERT INTO dt VALUES ('wiki.z_keyword_by_name', NULL, NULL, true, NULL, 'Aргументы метода wiki.keyword_by_name', false, true, false);
INSERT INTO dt VALUES ('wiki.doc_info', NULL, NULL, true, NULL, 'wiki.doc_info', false, true, false);
INSERT INTO dt VALUES ('wiki.z_doc_info', NULL, NULL, true, NULL, 'Aргументы метода wiki.doc_info', false, true, false);
INSERT INTO dt VALUES ('wiki.z_doc_keyword', NULL, NULL, true, NULL, 'Aргументы метода wiki.doc_keyword', false, true, false);
INSERT INTO dt VALUES ('wiki.z_doc_src', NULL, NULL, true, NULL, 'Aргументы метода wiki.doc_src', false, true, false);
INSERT INTO dt VALUES ('wiki.doc_extra', NULL, NULL, true, NULL, 'Дополнительные данные статьи wiki', false, true, false);
INSERT INTO dt VALUES ('wiki.z_doc_extra', NULL, NULL, true, NULL, 'Aргументы метода wiki.doc_extra', false, true, false);
INSERT INTO dt VALUES ('wiki.doc_link', NULL, NULL, true, NULL, 'Ссылка на внутренние документы статьи wiki', false, true, false);
INSERT INTO dt VALUES ('wiki.z_doc_link', NULL, NULL, true, NULL, 'Aргументы метода wiki.doc_link', false, true, false);
INSERT INTO dt VALUES ('fs.file_info', NULL, NULL, true, NULL, 'Атрибуты внешнего файла объекта', false, true, false);
INSERT INTO dt VALUES ('wiki.z_doc_file', NULL, NULL, true, NULL, 'Aргументы метода wiki.doc_file', false, true, false);
INSERT INTO dt VALUES ('wsd.doc_diff', NULL, NULL, true, NULL, 'Изменения между ревизиями статьи wiki', false, true, false);
INSERT INTO dt VALUES ('wiki.z_doc_diff', NULL, NULL, true, NULL, 'Aргументы метода wiki.doc_diff', false, true, false);
INSERT INTO dt VALUES ('wiki.z_doc_status', NULL, NULL, true, NULL, 'Aргументы метода wiki.doc_status', false, true, false);
INSERT INTO dt VALUES ('wiki.z_doc_acl', NULL, NULL, true, NULL, 'Aргументы метода wiki.doc_acl', false, true, false);
INSERT INTO dt VALUES ('wiki.z_doc_create', NULL, NULL, true, NULL, 'Aргументы метода wiki.doc_create', false, true, false);
INSERT INTO dt VALUES ('wiki.z_doc_update_src', NULL, NULL, true, NULL, 'Aргументы метода wiki.doc_update_src', false, true, false);
INSERT INTO dt VALUES ('wiki.z_doc_update_attr', NULL, NULL, true, NULL, 'Aргументы метода wiki.doc_update_attr', false, true, false);
INSERT INTO dt VALUES ('wiki.z_doc_file_del', NULL, NULL, true, NULL, 'Aргументы метода wiki.doc_file_del', false, true, false);
INSERT INTO dt VALUES ('wiki.z_doc_file_add', NULL, NULL, true, NULL, 'Aргументы метода wiki.doc_file_add', false, true, false);
INSERT INTO dt VALUES ('app.z_add', NULL, NULL, true, NULL, 'Aргументы метода app.add', false, true, false);


--
-- Data for Name: dt_facet; Type: TABLE DATA; Schema: ws; Owner: -
--

INSERT INTO dt_facet VALUES ('boolean', 4, '^([01tf]|on|off)$', 'boolean', 'только 0,1,t,f,on или off');
INSERT INTO dt_facet VALUES ('numeric', 4, '^(\+|\-)?(\d)*(\.\d+)?$', 'numeric', '[знак]целая часть[.дробная часть]');
INSERT INTO dt_facet VALUES ('real', 4, '^(\+|\-)?(\d)*(\.\d+)?$', 'real', '[знак]целая часть[.дробная часть]');
INSERT INTO dt_facet VALUES ('integer', 4, '^(\+|\-)?\d+$', 'integer', '[знак]цифры');
INSERT INTO dt_facet VALUES ('smallint', 4, '^(\+|\-)?\d+$', 'smallint', '[знак]цифры');
INSERT INTO dt_facet VALUES ('bigint', 4, '^(\+|\-)?\d+$', 'bigint', '[знак]цифры');
INSERT INTO dt_facet VALUES ('oid', 4, '^d+$', 'oid', NULL);
INSERT INTO dt_facet VALUES ('date', 4, '^\d{1,2}\.\d{2}\.\d{4}$', 'date', 'ДД.ММ.ГГГГ');
INSERT INTO dt_facet VALUES ('integer', 10, '-2147483648', 'integer', NULL);
INSERT INTO dt_facet VALUES ('integer', 7, '2147483647', 'integer', NULL);
INSERT INTO dt_facet VALUES ('smallint', 10, '-32768', 'smallint', NULL);
INSERT INTO dt_facet VALUES ('smallint', 7, '32767', 'smallint', NULL);
INSERT INTO dt_facet VALUES ('ws.d_stamp', 4, '^\d{1,2}\.\d{2}\.\d{4}(?: +| +/ +)\d{2}:\d{2}(:\d{2})?$', 'timestamp', 'ДД.ММ.ГГГГ ЧЧ:ММ[:СС]');
INSERT INTO dt_facet VALUES ('ws.d_rating', 10, '-2', 'numeric', NULL);
INSERT INTO dt_facet VALUES ('ws.d_rating', 7, '2', 'numeric', NULL);
INSERT INTO dt_facet VALUES ('ws.d_decimal_positive', 9, '0', 'numeric', NULL);
INSERT INTO dt_facet VALUES ('ws.d_id_positive', 9, '0', 'integer', NULL);
INSERT INTO dt_facet VALUES ('ws.d_decimal_non_neg', 10, '0', 'numeric', NULL);
INSERT INTO dt_facet VALUES ('ws.d_zip', 4, '^[a-zA-Zа-яА-я0-9][a-zA-Zа-яА-я0-9 -]{2,11}', 'text', 'index');
INSERT INTO dt_facet VALUES ('ws.d_string', 4, '^[^
]', 'text', 'NO CR');
INSERT INTO dt_facet VALUES ('ws.d_login', 4, '^[a-zA-Z0-9\.+_@\-]{5,}$', 'text', 'login');
INSERT INTO dt_facet VALUES ('ws.d_email', 4, '(?:^$|^[^ ]+@[^ ]+\.[^ ]{2,6}$)', 'text', 'your@email.ru');
INSERT INTO dt_facet VALUES ('ws.d_emails', 4, '(?:^$|^[^ ]+@[^ ]+\.[^ ]{2,6}$)', 'text', 'your@email.ru');
INSERT INTO dt_facet VALUES ('ws.d_path', 4, '^(|[a-z\d_][a-z\d\.\-_/]+)$', 'text', NULL);
INSERT INTO dt_facet VALUES ('ws.d_code', 4, '^[a-z\d][a-z\d\.\-_]*$', 'text', NULL);
INSERT INTO dt_facet VALUES ('ws.d_code_arg', 4, '^[a-z\d_][a-z\d\.\-_]*$', 'text', NULL);
INSERT INTO dt_facet VALUES ('ws.d_codei', 4, '^[a-z\d][a-z\d\.\-_A-Z]*$', 'text', NULL);
INSERT INTO dt_facet VALUES ('ws.d_code_like', 4, '^[a-z\d\.\-_\%]+$', 'text', NULL);
INSERT INTO dt_facet VALUES ('ws.d_sub', 4, '^([a-z\d][a-z\d\.\-_]+)|([A-Z\d][a-z\d\.\-_:A-Z]+)$', 'text', NULL);
INSERT INTO dt_facet VALUES ('ws.d_lang', 4, '^(?:ru|en)$', 'text', NULL);
INSERT INTO dt_facet VALUES ('ws.d_errcode', 1, '5', 'bpchar', NULL);


--
-- Data for Name: dt_part; Type: TABLE DATA; Schema: ws; Owner: -
--

INSERT INTO dt_part VALUES ('ws.t_pg_proc_info', 1, 'schema', 'text', 'text', true, NULL, 'schema', false);
INSERT INTO dt_part VALUES ('ws.t_pg_proc_info', 2, 'name', 'text', 'text', true, NULL, 'name', false);
INSERT INTO dt_part VALUES ('ws.t_pg_proc_info', 3, 'anno', 'text', 'text', true, NULL, 'anno', false);
INSERT INTO dt_part VALUES ('ws.t_pg_proc_info', 4, 'rt_oid', 'oid', 'oid', true, NULL, 'rt_oid', false);
INSERT INTO dt_part VALUES ('ws.t_pg_proc_info', 5, 'rt_name', 'text', 'text', true, NULL, 'rt_name', false);
INSERT INTO dt_part VALUES ('ws.t_pg_proc_info', 6, 'is_set', 'boolean', 'boolean', true, NULL, 'is_set', false);
INSERT INTO dt_part VALUES ('ws.t_pg_proc_info', 7, 'args', 'text', 'text', true, NULL, 'args', false);
INSERT INTO dt_part VALUES ('ws.t_pg_proc_info', 8, 'args_pub', 'text', 'text', true, NULL, 'args_pub', false);
INSERT INTO dt_part VALUES ('ws.t_acl_check', 1, 'value', 'integer', 'integer', true, NULL, 'value', false);
INSERT INTO dt_part VALUES ('ws.t_acl_check', 2, 'id', 'integer', 'integer', true, NULL, 'id', false);
INSERT INTO dt_part VALUES ('ws.t_acl_check', 3, 'code', 'text', 'text', true, NULL, 'code', false);
INSERT INTO dt_part VALUES ('ws.t_acl_check', 4, 'name', 'text', 'text', true, NULL, 'name', false);
INSERT INTO dt_part VALUES ('ws.z_uncache', 1, 'code', 'text', 'text', true, NULL, 'код метода', false);
INSERT INTO dt_part VALUES ('ws.z_uncache', 2, 'key', 'text', 'text', true, NULL, 'ключ кэша', false);
INSERT INTO dt_part VALUES ('ws.z_acl_check', 1, '_sid', 'text', 'text', true, NULL, 'ID сессии', false);
INSERT INTO dt_part VALUES ('ws.z_acl_check', 2, 'class_id', 'ws.d_class', 'integer', true, NULL, 'ID класса', false);
INSERT INTO dt_part VALUES ('ws.z_acl_check', 3, 'action_id', 'ws.d_id32', 'integer', true, NULL, 'ID акции', false);
INSERT INTO dt_part VALUES ('ws.z_acl_check', 4, 'id', 'ws.d_id', 'integer', true, NULL, 'ID объекта', false);
INSERT INTO dt_part VALUES ('ws.z_acl_check', 5, 'id1', 'ws.d_id', 'integer', true, NULL, 'ID1 объекта', false);
INSERT INTO dt_part VALUES ('ws.z_acl_check', 6, 'id2', 'text', 'text', true, NULL, 'ID2 объекта', false);
INSERT INTO dt_part VALUES ('ws.z_store_get', 1, 'path', 'ws.d_path', 'text', true, NULL, 'ID данных', false);
INSERT INTO dt_part VALUES ('ws.z_store_set', 1, 'path', 'ws.d_path', 'text', true, NULL, 'ID данных', false);
INSERT INTO dt_part VALUES ('ws.z_store_set', 2, 'data', 'text', 'text', true, NULL, 'данные', false);
INSERT INTO dt_part VALUES ('ws.t_date_info', 1, 'date', 'date', 'date', true, NULL, 'date', false);
INSERT INTO dt_part VALUES ('ws.t_date_info', 2, 'day', 'ws.d_id32', 'integer', true, NULL, 'day', false);
INSERT INTO dt_part VALUES ('ws.t_date_info', 3, 'month', 'ws.d_id32', 'integer', true, NULL, 'month', false);
INSERT INTO dt_part VALUES ('ws.t_date_info', 4, 'year', 'ws.d_id32', 'integer', true, NULL, 'year', false);
INSERT INTO dt_part VALUES ('ws.t_date_info', 5, 'date_month', 'date', 'date', true, NULL, 'date_month', false);
INSERT INTO dt_part VALUES ('ws.t_date_info', 6, 'date_year', 'date', 'date', true, NULL, 'date_year', false);
INSERT INTO dt_part VALUES ('ws.t_date_info', 7, 'date_name', 'text', 'text', true, NULL, 'ДД месяц ГГГГ', false);
INSERT INTO dt_part VALUES ('ws.t_date_info', 8, 'month_name', 'text', 'text', true, NULL, 'месяц ГГГГ', false);
INSERT INTO dt_part VALUES ('ws.t_date_info', 9, 'date_name_doc', 'text', 'text', true, NULL, '(ДД|0Д) месяц ГГГГ', false);
INSERT INTO dt_part VALUES ('ws.t_date_info', 10, 'fmt_calend', 'text', 'text', true, NULL, 'fmt_calend', false);
INSERT INTO dt_part VALUES ('ws.t_date_info', 11, 'fmt_example', 'text', 'text', true, NULL, 'fmt_example', false);
INSERT INTO dt_part VALUES ('ws.z_date_info', 1, 'date', 'date', 'date', false, '(''now''::text)', '', false);
INSERT INTO dt_part VALUES ('ws.z_date_info', 2, 'offset', 'integer', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.t_month_info', 1, 'id', 'date', 'date', true, NULL, 'Дата - первое число месяца', false);
INSERT INTO dt_part VALUES ('ws.t_month_info', 2, 'date_month_last', 'date', 'date', true, NULL, 'Дата - последнее число месяца', false);
INSERT INTO dt_part VALUES ('ws.t_month_info', 3, 'date_month_prev', 'date', 'date', true, NULL, 'Дата - первое число предыдущего месяца', false);
INSERT INTO dt_part VALUES ('ws.t_month_info', 4, 'date_month_next', 'date', 'date', true, NULL, 'Дата - первое число следующего месяца', false);
INSERT INTO dt_part VALUES ('ws.t_month_info', 5, 'date_year', 'date', 'date', true, NULL, 'Дата - первое число года', false);
INSERT INTO dt_part VALUES ('ws.t_month_info', 6, 'month', 'ws.d_id32', 'integer', true, NULL, 'Номер месяца', false);
INSERT INTO dt_part VALUES ('ws.t_month_info', 7, 'year', 'ws.d_id32', 'integer', true, NULL, 'Год', false);
INSERT INTO dt_part VALUES ('ws.t_month_info', 8, 'key', 'text', 'text', true, NULL, 'ГГГГММ', false);
INSERT INTO dt_part VALUES ('ws.t_month_info', 9, 'month_name', 'text', 'text', true, NULL, 'месяц ГГГГ', false);
INSERT INTO dt_part VALUES ('ws.t_month_info', 10, 'month_name_ic', 'text', 'text', true, NULL, 'Месяц ГГГГ', false);
INSERT INTO dt_part VALUES ('ws.z_month_info', 1, 'date', 'date', 'date', false, '(''now''::text)', '', false);
INSERT INTO dt_part VALUES ('ws.z_year_months', 1, 'date', 'date', 'date', false, '(''now''::text)', 'Дата', false);
INSERT INTO dt_part VALUES ('ws.z_year_months', 2, 'date_min', 'date', 'date', true, NULL, 'Дата, месяцы раньше которой не включать', false);
INSERT INTO dt_part VALUES ('ws.z_year_months', 3, 'date_max', 'date', 'date', true, NULL, 'Дата, месяцы позднее которой не включать', false);
INSERT INTO dt_part VALUES ('ws.ref', 1, 'id', 'ws.d_id32', 'integer', false, NULL, 'ID', false);
INSERT INTO dt_part VALUES ('ws.ref', 2, 'class_id', 'ws.d_class', 'integer', false, NULL, 'class_id', false);
INSERT INTO dt_part VALUES ('ws.ref', 3, 'name', 'text', 'text', false, NULL, 'Название', false);
INSERT INTO dt_part VALUES ('ws.ref', 4, 'code', 'ws.d_code', 'text', true, NULL, 'Метод доступа', false);
INSERT INTO dt_part VALUES ('ws.ref', 5, 'updated_at', 'ws.d_stamp', 'timestamp', false, '''2010-01-01 00:00:00''::timestamp without time zone', 'Момент последнего изменения', false);
INSERT INTO dt_part VALUES ('ws.z_ref_info', 1, 'id', 'ws.d_id32', 'integer', false, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.ref_item', 1, 'ref_id', 'ws.d_id32', 'integer', false, NULL, 'ID справочника', false);
INSERT INTO dt_part VALUES ('ws.ref_item', 2, 'id', 'ws.d_id32', 'integer', false, NULL, 'ID позиции', false);
INSERT INTO dt_part VALUES ('ws.ref_item', 3, 'sort', 'ws.d_sort', 'integer', true, NULL, 'Порядок сортировки', false);
INSERT INTO dt_part VALUES ('ws.ref_item', 4, 'name', 'text', 'text', false, NULL, 'Название', false);
INSERT INTO dt_part VALUES ('ws.ref_item', 5, 'group_id', 'ws.d_id32', 'integer', false, '1', 'Внутренний ID группы', false);
INSERT INTO dt_part VALUES ('ws.ref_item', 6, 'deleted_at', 'ws.d_stamp', 'timestamp', true, NULL, 'Момент удаления', false);
INSERT INTO dt_part VALUES ('ws.z_ref', 1, 'id', 'ws.d_id32', 'integer', false, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_ref', 2, 'item_id', 'ws.d_id32', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.z_ref', 3, 'group_id', 'ws.d_id32', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.z_ref', 4, 'active_only', 'boolean', 'boolean', false, 'true', '', false);
INSERT INTO dt_part VALUES ('ws.t_page_info', 1, 'code', 'ws.d_code', 'text', true, NULL, 'code', false);
INSERT INTO dt_part VALUES ('ws.t_page_info', 2, 'up_code', 'ws.d_code', 'text', true, NULL, 'up_code', false);
INSERT INTO dt_part VALUES ('ws.t_page_info', 3, 'class_id', 'ws.d_class', 'integer', true, NULL, 'class_id', false);
INSERT INTO dt_part VALUES ('ws.t_page_info', 4, 'action_id', 'ws.d_id32', 'integer', true, NULL, 'action_id', false);
INSERT INTO dt_part VALUES ('ws.t_page_info', 5, 'group_id', 'ws.d_id32', 'integer', true, NULL, 'group_id', false);
INSERT INTO dt_part VALUES ('ws.t_page_info', 6, 'sort', 'ws.d_sort', 'integer', true, NULL, 'sort', false);
INSERT INTO dt_part VALUES ('ws.t_page_info', 7, 'uri', 'ws.d_regexp', 'text', true, NULL, 'uri', false);
INSERT INTO dt_part VALUES ('ws.t_page_info', 8, 'tmpl', 'ws.d_path', 'text', true, NULL, 'tmpl', false);
INSERT INTO dt_part VALUES ('ws.t_page_info', 9, 'id_fixed', 'ws.d_id', 'integer', true, NULL, 'id_fixed', false);
INSERT INTO dt_part VALUES ('ws.t_page_info', 10, 'id_session', 'ws.d_code', 'text', true, NULL, 'id_session', false);
INSERT INTO dt_part VALUES ('ws.t_page_info', 11, 'is_hidden', 'boolean', 'boolean', true, NULL, 'is_hidden', false);
INSERT INTO dt_part VALUES ('ws.t_page_info', 12, 'target', 'text', 'text', true, NULL, 'target', false);
INSERT INTO dt_part VALUES ('ws.t_page_info', 13, 'uri_re', 'text', 'text', true, NULL, 'uri_re', false);
INSERT INTO dt_part VALUES ('ws.t_page_info', 14, 'uri_fmt', 'text', 'text', true, NULL, 'uri_fmt', false);
INSERT INTO dt_part VALUES ('ws.t_page_info', 15, 'pkg', 'text', 'text', true, NULL, 'pkg', false);
INSERT INTO dt_part VALUES ('ws.t_page_info', 16, 'name', 'text', 'text', true, NULL, 'name', false);
INSERT INTO dt_part VALUES ('ws.t_page_info', 17, 'req', 'text', 'text', true, NULL, 'req', false);
INSERT INTO dt_part VALUES ('ws.t_page_info', 18, 'args', 'text', 'text', true, NULL, 'args', true);
INSERT INTO dt_part VALUES ('ws.t_page_info', 19, 'group_name', 'text', 'text', true, NULL, 'group_name', false);
INSERT INTO dt_part VALUES ('ws.z_page_by_code', 1, 'code', 'text', 'text', false, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_page_by_code', 2, 'id', 'text', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_page_by_code', 3, 'id1', 'text', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_page_by_code', 4, 'id2', 'text', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_page_path', 1, 'code', 'text', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_page_path', 2, 'id', 'text', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_page_path', 3, 'id1', 'text', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_page_path', 4, 'id2', 'text', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_page_childs', 1, 'code', 'text', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_page_childs', 2, 'id', 'text', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_page_childs', 3, 'id1', 'text', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_page_childs', 4, 'id2', 'text', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_page_by_action', 1, 'class_id', 'ws.d_class', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.z_page_by_action', 2, 'action_id', 'ws.d_id32', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.z_page_by_action', 3, 'id', 'text', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_page_by_action', 4, 'id1', 'text', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_page_by_action', 5, 'id2', 'text', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.t_hashtable', 1, 'id', 'text', 'text', true, NULL, 'ID', false);
INSERT INTO dt_part VALUES ('ws.t_hashtable', 2, 'name', 'text', 'text', true, NULL, 'Название', false);
INSERT INTO dt_part VALUES ('ws.z_page_tree', 1, 'code', 'text', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.class', 1, 'id', 'ws.d_class', 'integer', false, NULL, 'ID класса', false);
INSERT INTO dt_part VALUES ('ws.class', 2, 'up_id', 'ws.d_class', 'integer', true, NULL, 'ID класса-предка', false);
INSERT INTO dt_part VALUES ('ws.class', 3, 'id_count', 'ws.d_cnt', 'integer', false, '0', 'Количество идентификаторов экземпляра класса', false);
INSERT INTO dt_part VALUES ('ws.class', 4, 'is_ext', 'boolean', 'boolean', false, NULL, 'ID экземпляра предка входит в ID экземпляра', false);
INSERT INTO dt_part VALUES ('ws.class', 5, 'sort', 'ws.d_sort', 'integer', true, NULL, 'Сортировка в списке классов', false);
INSERT INTO dt_part VALUES ('ws.class', 6, 'code', 'ws.d_code', 'text', false, NULL, 'Код класса', false);
INSERT INTO dt_part VALUES ('ws.class', 7, 'name', 'text', 'text', false, NULL, 'Название класса', false);
INSERT INTO dt_part VALUES ('ws.z_class', 1, 'id', 'ws.d_class', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.method', 1, 'code', 'ws.d_code', 'text', false, NULL, 'внешнее имя метода', false);
INSERT INTO dt_part VALUES ('ws.method', 2, 'class_id', 'ws.d_class', 'integer', false, NULL, 'ID класса, к которому относится метод', false);
INSERT INTO dt_part VALUES ('ws.method', 3, 'action_id', 'ws.d_id32', 'integer', false, NULL, 'ID акции, которой соответствует метод', false);
INSERT INTO dt_part VALUES ('ws.method', 4, 'cache_id', 'ws.d_id32', 'integer', false, NULL, 'ID кэша, в котором размещается результат вызова метода', false);
INSERT INTO dt_part VALUES ('ws.method', 5, 'rvf_id', 'ws.d_id32', 'integer', false, NULL, 'ID формата результата (для SQL-методов)', false);
INSERT INTO dt_part VALUES ('ws.method', 6, 'is_write', 'boolean', 'boolean', false, 'false', 'метод меняет БД', false);
INSERT INTO dt_part VALUES ('ws.method', 7, 'is_i18n', 'boolean', 'boolean', false, 'false', 'метод поддерживает интернационализацию', false);
INSERT INTO dt_part VALUES ('ws.method', 8, 'is_sql', 'boolean', 'boolean', false, 'true', 'метод реализован как sql function', false);
INSERT INTO dt_part VALUES ('ws.method', 9, 'is_strict', 'boolean', 'boolean', true, 'false', 'отсутствие результата порождает ошибку', false);
INSERT INTO dt_part VALUES ('ws.method', 10, 'code_real', 'ws.d_sub', 'text', false, NULL, 'имя вызываемого метода (для не-sql - включая package)', false);
INSERT INTO dt_part VALUES ('ws.method', 11, 'arg_dt_code', 'ws.d_code', 'text', true, NULL, 'Код типа, описывающего аргументы', false);
INSERT INTO dt_part VALUES ('ws.method', 12, 'rv_dt_code', 'ws.d_code', 'text', true, NULL, 'Код типа результата', false);
INSERT INTO dt_part VALUES ('ws.method', 13, 'name', 'text', 'text', false, NULL, 'внешнее описание метода', false);
INSERT INTO dt_part VALUES ('ws.method', 14, 'args_exam', 'text', 'text', true, NULL, 'пример вызова функции', false);
INSERT INTO dt_part VALUES ('ws.method', 15, 'args', 'text', 'text', false, NULL, 'строка списка аргументов', false);
INSERT INTO dt_part VALUES ('ws.method', 16, 'pkg', 'text', 'text', false, 'pg_cs()', 'пакет, в котором метод зарегистрирован', false);
INSERT INTO dt_part VALUES ('ws.method', 17, 'realm_code', 'ws.d_code', 'text', true, NULL, 'код области вызова метода', false);
INSERT INTO dt_part VALUES ('ws.z_method_lookup', 1, 'code', 'ws.d_code_like', 'text', false, '%', '', false);
INSERT INTO dt_part VALUES ('ws.z_method_lookup', 2, 'page', 'ws.d_cnt', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.z_method_lookup', 3, 'by', 'ws.d_cnt', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.z_class_id', 1, 'code', 'ws.d_code', 'text', false, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_page_by_uri', 1, 'uri', 'text', 'text', false, '', '', false);
INSERT INTO dt_part VALUES ('i18n_def.error', 1, 'code', 'ws.d_errcode', 'bpchar', true, NULL, 'Код ошибки', false);
INSERT INTO dt_part VALUES ('i18n_def.error', 2, 'id_count', 'ws.d_cnt', 'integer', true, '0', 'Количество аргументов в строке сообщения', false);
INSERT INTO dt_part VALUES ('i18n_def.error', 3, 'message', 'ws.d_format', 'text', true, NULL, 'Форматированная строка сообщения об ошибке', false);
INSERT INTO dt_part VALUES ('ws.z_error_info', 1, 'code', 'ws.d_errcode', 'bpchar', false, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.method_rv_format', 1, 'id', 'ws.d_id32', 'integer', false, NULL, 'ID формата', false);
INSERT INTO dt_part VALUES ('ws.method_rv_format', 2, 'name', 'text', 'text', false, NULL, 'Название формата', false);
INSERT INTO dt_part VALUES ('ws.z_method_rvf', 1, 'id', 'ws.d_id32', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.z_method_by_code', 1, 'code', 'ws.d_code', 'text', false, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_method_by_action', 1, 'class_id', 'ws.d_class', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.z_method_by_action', 2, 'action_id', 'ws.d_id32', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.facet', 1, 'id', 'ws.d_id32', 'integer', false, NULL, 'ID ограничения', false);
INSERT INTO dt_part VALUES ('ws.facet', 2, 'code', 'ws.d_codei', 'text', false, NULL, 'Код ограничения', false);
INSERT INTO dt_part VALUES ('ws.facet', 3, 'anno', 'text', 'text', false, NULL, 'Аннотация', false);
INSERT INTO dt_part VALUES ('ws.z_facet', 1, 'id', 'ws.d_id32', 'integer', false, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.dt_facet', 1, 'code', 'ws.d_code', 'text', false, NULL, 'Код типа', false);
INSERT INTO dt_part VALUES ('ws.dt_facet', 2, 'facet_id', 'ws.d_id32', 'integer', false, NULL, 'ID ограничения', false);
INSERT INTO dt_part VALUES ('ws.dt_facet', 3, 'value', 'text', 'text', false, NULL, 'Значение ограничения', false);
INSERT INTO dt_part VALUES ('ws.dt_facet', 4, 'base_code', 'ws.d_code', 'text', false, NULL, 'Код базового типа', false);
INSERT INTO dt_part VALUES ('ws.dt_facet', 5, 'anno', 'text', 'text', true, NULL, 'Аннотация ограничения', false);
INSERT INTO dt_part VALUES ('ws.z_dt_facet', 1, 'code', 'ws.d_code', 'text', false, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.dt_part', 1, 'dt_code', 'ws.d_code', 'text', false, NULL, 'Код комплексного типа', false);
INSERT INTO dt_part VALUES ('ws.dt_part', 2, 'part_id', 'ws.d_cnt', 'integer', false, '0', 'ID поля', false);
INSERT INTO dt_part VALUES ('ws.dt_part', 3, 'code', 'ws.d_code_arg', 'text', false, NULL, 'Код поля', false);
INSERT INTO dt_part VALUES ('ws.dt_part', 4, 'parent_code', 'ws.d_code', 'text', false, NULL, 'Код родительского типа', false);
INSERT INTO dt_part VALUES ('ws.dt_part', 5, 'base_code', 'ws.d_code', 'text', false, NULL, 'Код базового типа', false);
INSERT INTO dt_part VALUES ('ws.dt_part', 6, 'allow_null', 'boolean', 'boolean', false, 'true', 'Разрешен NULL', false);
INSERT INTO dt_part VALUES ('ws.dt_part', 7, 'def_val', 'text', 'text', true, NULL, 'Значение по умолчанию', false);
INSERT INTO dt_part VALUES ('ws.dt_part', 8, 'anno', 'text', 'text', false, NULL, 'Аннотация', false);
INSERT INTO dt_part VALUES ('ws.dt_part', 9, 'is_list', 'boolean', 'boolean', false, 'false', 'Конструктор поля - массив', false);
INSERT INTO dt_part VALUES ('ws.z_dt_part', 1, 'code', 'ws.d_code', 'text', false, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_dt_part', 2, 'part_id', 'ws.d_id32', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.csaa', 1, 'class_id', 'ws.d_class', 'integer', true, NULL, 'ID класса', false);
INSERT INTO dt_part VALUES ('ws.csaa', 2, 'status_id', 'ws.d_id32', 'integer', true, NULL, 'ID статуса', false);
INSERT INTO dt_part VALUES ('ws.csaa', 3, 'action_id', 'ws.d_id32', 'integer', true, NULL, 'ID акции', false);
INSERT INTO dt_part VALUES ('ws.csaa', 4, 'acl_id', 'ws.d_acl', 'integer', true, NULL, 'ID уровня доступа', false);
INSERT INTO dt_part VALUES ('ws.csaa', 5, 'is_addon', 'boolean', 'boolean', true, NULL, 'Строка является добавлением разрешения', false);
INSERT INTO dt_part VALUES ('ws.csaa', 6, 'class', 'text', 'text', true, NULL, 'Название класса', false);
INSERT INTO dt_part VALUES ('ws.csaa', 7, 'status', 'text', 'text', true, NULL, 'Название статуса', false);
INSERT INTO dt_part VALUES ('ws.csaa', 8, 'action', 'text', 'text', true, NULL, 'Название акции', false);
INSERT INTO dt_part VALUES ('ws.csaa', 9, 'acl', 'text', 'text', true, NULL, 'Название уровня доступа', false);
INSERT INTO dt_part VALUES ('ws.z_class_status_action_acl', 1, 'class_id', 'ws.d_class', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.z_class_status_action_acl', 2, 'status_id', 'ws.d_id32', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.z_class_status_action_acl', 3, 'action_id', 'ws.d_id32', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.z_class_status_action_acl', 4, 'acl_id', 'ws.d_id32', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.class_action', 1, 'class_id', 'ws.d_class', 'integer', false, NULL, 'ID класса', false);
INSERT INTO dt_part VALUES ('ws.class_action', 2, 'id', 'ws.d_id32', 'integer', false, NULL, 'ID акции', false);
INSERT INTO dt_part VALUES ('ws.class_action', 3, 'sort', 'ws.d_sort', 'integer', true, NULL, 'Сортировка в списке акций', false);
INSERT INTO dt_part VALUES ('ws.class_action', 4, 'name', 'text', 'text', false, NULL, 'Название акции', false);
INSERT INTO dt_part VALUES ('ws.z_class_action', 1, 'class_id', 'ws.d_class', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.z_class_action', 2, 'id', 'ws.d_id32', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.class_status', 1, 'class_id', 'ws.d_class', 'integer', false, NULL, 'ID класса', false);
INSERT INTO dt_part VALUES ('ws.class_status', 2, 'id', 'ws.d_id32', 'integer', false, NULL, 'ID статуса', false);
INSERT INTO dt_part VALUES ('ws.class_status', 3, 'sort', 'ws.d_sort', 'integer', true, NULL, 'Сортировка в списке статусов', false);
INSERT INTO dt_part VALUES ('ws.class_status', 4, 'name', 'text', 'text', false, NULL, 'Название статуса', false);
INSERT INTO dt_part VALUES ('ws.z_class_status', 1, 'class_id', 'ws.d_class', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.z_class_status', 2, 'id', 'ws.d_id32', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.class_acl', 1, 'class_id', 'ws.d_class', 'integer', false, NULL, 'ID класса', false);
INSERT INTO dt_part VALUES ('ws.class_acl', 2, 'id', 'ws.d_acl', 'integer', false, NULL, 'ID уровня доступа', false);
INSERT INTO dt_part VALUES ('ws.class_acl', 3, 'is_sys', 'boolean', 'boolean', false, NULL, 'Не воказывать в интерфейсе', false);
INSERT INTO dt_part VALUES ('ws.class_acl', 4, 'sort', 'ws.d_sort', 'integer', true, NULL, 'Сортировка в списке уровней доступа', false);
INSERT INTO dt_part VALUES ('ws.class_acl', 5, 'name', 'text', 'text', false, NULL, 'Название уровня доступа', false);
INSERT INTO dt_part VALUES ('ws.z_class_acl', 1, 'class_id', 'ws.d_class', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.z_class_acl', 2, 'id', 'ws.d_id32', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('ws.dt', 1, 'code', 'ws.d_code', 'text', false, NULL, 'Код типа', false);
INSERT INTO dt_part VALUES ('ws.dt', 2, 'parent_code', 'ws.d_code', 'text', true, NULL, 'Код родительского типа', false);
INSERT INTO dt_part VALUES ('ws.dt', 3, 'base_code', 'ws.d_code', 'text', true, NULL, 'Код базового типа', false);
INSERT INTO dt_part VALUES ('ws.dt', 4, 'allow_null', 'boolean', 'boolean', false, 'true', 'Разрешен NULL', false);
INSERT INTO dt_part VALUES ('ws.dt', 5, 'def_val', 'text', 'text', true, NULL, 'Значение по умолчанию', false);
INSERT INTO dt_part VALUES ('ws.dt', 6, 'anno', 'text', 'text', false, NULL, 'Аннотация', false);
INSERT INTO dt_part VALUES ('ws.dt', 7, 'is_list', 'boolean', 'boolean', false, 'false', 'Конструктор типа - массив', false);
INSERT INTO dt_part VALUES ('ws.dt', 8, 'is_complex', 'boolean', 'boolean', false, 'false', 'Конструктор типа - структура', false);
INSERT INTO dt_part VALUES ('ws.dt', 9, 'is_sql', 'boolean', 'boolean', false, 'false', 'Тип создан в БД', false);
INSERT INTO dt_part VALUES ('ws.z_dt', 1, 'code', 'ws.d_code', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_acls_eff_ids', 1, 'class_id', 'ws.d_class', 'integer', false, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_acls_eff_ids', 2, 'status_id', 'ws.d_id32', 'integer', false, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_acls_eff_ids', 3, 'action_id', 'ws.d_id32', 'integer', false, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_acls_eff_ids', 4, 'acl_ids', 'ws.d_acls', 'integer', false, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_acls_eff', 1, 'class_id', 'ws.d_class', 'integer', false, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_acls_eff', 2, 'status_id', 'ws.d_id32', 'integer', false, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_acls_eff', 3, 'action_id', 'ws.d_id32', 'integer', false, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_acls_eff', 4, 'acl_ids', 'ws.d_acls', 'integer', false, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_system_acl', 1, '_sid', 'ws.d_sid', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('ws.z_info_acl', 1, '_sid', 'ws.d_sid', 'text', false, NULL, '', false);
INSERT INTO dt_part VALUES ('cfg.z_cache', 1, 'id', 'ws.d_id32', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('fs.z_file_new_path_mk', 1, 'folder_code', 'text', 'text', false, NULL, '', false);
INSERT INTO dt_part VALUES ('fs.z_file_new_path_mk', 2, 'obj_id', 'integer', 'integer', false, NULL, 'ID объекта', false);
INSERT INTO dt_part VALUES ('fs.z_file_new_path_mk', 3, 'name', 'text', 'text', false, NULL, 'Внешнее имя файла', false);
INSERT INTO dt_part VALUES ('fs.z_file_new_path_mk', 4, 'code', 'text', 'text', true, NULL, 'Код связи', false);
INSERT INTO dt_part VALUES ('fs.file_store', 1, 'id', 'integer', 'integer', true, NULL, 'id', false);
INSERT INTO dt_part VALUES ('fs.file_store', 2, 'path', 'text', 'text', true, NULL, 'path', false);
INSERT INTO dt_part VALUES ('fs.file_store', 3, 'size', 'integer', 'integer', true, NULL, 'size', false);
INSERT INTO dt_part VALUES ('fs.file_store', 4, 'csum', 'text', 'text', true, NULL, 'csum', false);
INSERT INTO dt_part VALUES ('fs.file_store', 5, 'name', 'text', 'text', true, NULL, 'name', false);
INSERT INTO dt_part VALUES ('fs.file_store', 6, 'created_at', 'timestamp', 'timestamp', true, NULL, 'created_at', false);
INSERT INTO dt_part VALUES ('fs.file_store', 7, 'ctype', 'text', 'text', true, NULL, 'ctype', false);
INSERT INTO dt_part VALUES ('fs.z_file_store', 1, 'id', 'integer', 'integer', false, NULL, '', false);
INSERT INTO dt_part VALUES ('acc.account_attr', 1, 'id', 'integer', 'integer', true, NULL, 'id', false);
INSERT INTO dt_part VALUES ('acc.account_attr', 2, 'status_id', 'integer', 'integer', true, NULL, 'status_id', false);
INSERT INTO dt_part VALUES ('acc.account_attr', 3, 'def_role_id', 'integer', 'integer', true, NULL, 'def_role_id', false);
INSERT INTO dt_part VALUES ('acc.account_attr', 4, 'login', 'text', 'text', true, NULL, 'login', false);
INSERT INTO dt_part VALUES ('acc.account_attr', 5, 'psw', 'text', 'text', true, NULL, 'psw', false);
INSERT INTO dt_part VALUES ('acc.account_attr', 6, 'name', 'text', 'text', true, NULL, 'name', false);
INSERT INTO dt_part VALUES ('acc.account_attr', 7, 'is_psw_plain', 'boolean', 'boolean', true, NULL, 'is_psw_plain', false);
INSERT INTO dt_part VALUES ('acc.account_attr', 8, 'is_ip_checked', 'boolean', 'boolean', true, NULL, 'is_ip_checked', false);
INSERT INTO dt_part VALUES ('acc.account_attr', 9, 'created_at', 'timestamp', 'timestamp', true, NULL, 'created_at', false);
INSERT INTO dt_part VALUES ('acc.account_attr', 10, 'updated_at', 'timestamp', 'timestamp', true, NULL, 'updated_at', false);
INSERT INTO dt_part VALUES ('acc.account_attr', 11, 'psw_updated_at', 'timestamp', 'timestamp', true, NULL, 'psw_updated_at', false);
INSERT INTO dt_part VALUES ('acc.account_attr', 12, 'status_name', 'text', 'text', true, NULL, 'status_name', false);
INSERT INTO dt_part VALUES ('acc.z_profile', 1, '_sid', 'text', 'text', false, NULL, 'ID сессии', false);
INSERT INTO dt_part VALUES ('wsd.session', 1, 'id', 'integer', 'integer', false, 'nextval(''wsd.session_id_seq''::regclass)', 'id', false);
INSERT INTO dt_part VALUES ('wsd.session', 2, 'account_id', 'integer', 'integer', false, NULL, 'account_id', false);
INSERT INTO dt_part VALUES ('wsd.session', 3, 'role_id', 'integer', 'integer', false, NULL, 'role_id', false);
INSERT INTO dt_part VALUES ('wsd.session', 4, 'sid', 'text', 'text', true, NULL, 'sid', false);
INSERT INTO dt_part VALUES ('wsd.session', 5, 'ip', 'text', 'text', false, NULL, 'ip', false);
INSERT INTO dt_part VALUES ('wsd.session', 6, 'is_ip_checked', 'boolean', 'boolean', false, NULL, 'is_ip_checked', false);
INSERT INTO dt_part VALUES ('wsd.session', 7, 'created_at', 'timestamp', 'timestamp', false, 'now()', 'created_at', false);
INSERT INTO dt_part VALUES ('wsd.session', 8, 'updated_at', 'timestamp', 'timestamp', false, 'now()', 'updated_at', false);
INSERT INTO dt_part VALUES ('wsd.session', 9, 'deleted_at', 'timestamp', 'timestamp', true, NULL, 'Признак и время завершения сессии', false);
INSERT INTO dt_part VALUES ('acc.z_sid_info', 1, '_sid', 'ws.d_sid', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('acc.z_sid_info', 2, '_ip', 'text', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('acc.session_info', 1, 'id', 'integer', 'integer', true, NULL, 'id', false);
INSERT INTO dt_part VALUES ('acc.session_info', 2, 'account_id', 'integer', 'integer', true, NULL, 'account_id', false);
INSERT INTO dt_part VALUES ('acc.session_info', 3, 'role_id', 'integer', 'integer', true, NULL, 'role_id', false);
INSERT INTO dt_part VALUES ('acc.session_info', 4, 'sid', 'text', 'text', true, NULL, 'sid', false);
INSERT INTO dt_part VALUES ('acc.session_info', 5, 'ip', 'text', 'text', true, NULL, 'ip', false);
INSERT INTO dt_part VALUES ('acc.session_info', 6, 'is_ip_checked', 'boolean', 'boolean', true, NULL, 'is_ip_checked', false);
INSERT INTO dt_part VALUES ('acc.session_info', 7, 'created_at', 'timestamp', 'timestamp', true, NULL, 'created_at', false);
INSERT INTO dt_part VALUES ('acc.session_info', 8, 'updated_at', 'timestamp', 'timestamp', true, NULL, 'updated_at', false);
INSERT INTO dt_part VALUES ('acc.session_info', 9, 'deleted_at', 'timestamp', 'timestamp', true, NULL, 'deleted_at', false);
INSERT INTO dt_part VALUES ('acc.session_info', 10, 'status_id', 'integer', 'integer', true, NULL, 'status_id', false);
INSERT INTO dt_part VALUES ('acc.session_info', 11, 'account_name', 'text', 'text', true, NULL, 'account_name', false);
INSERT INTO dt_part VALUES ('acc.session_info', 12, 'role_name', 'text', 'text', true, NULL, 'role_name', false);
INSERT INTO dt_part VALUES ('acc.z_login', 1, '_ip', 'text', 'text', false, NULL, 'IP-адреса сессии', false);
INSERT INTO dt_part VALUES ('acc.z_login', 2, 'login', 'text', 'text', false, NULL, 'пароль', false);
INSERT INTO dt_part VALUES ('acc.z_login', 3, 'psw', 'text', 'text', false, NULL, 'пароль', false);
INSERT INTO dt_part VALUES ('acc.z_login', 4, '_cook', 'text', 'text', true, NULL, 'ID cookie', false);
INSERT INTO dt_part VALUES ('acc.z_logout', 1, '_sid', 'ws.d_sid', 'text', true, NULL, 'ID сессии', false);
INSERT INTO dt_part VALUES ('wiki.z_format', 1, '_sid', 'text', 'text', true, NULL, 'ID сессии', false);
INSERT INTO dt_part VALUES ('wiki.z_format', 2, 'uri', 'text', 'text', true, NULL, 'Префикс адреса', false);
INSERT INTO dt_part VALUES ('wiki.z_format', 3, 'src', 'text', 'text', true, NULL, 'Текст в разметке wiki', false);
INSERT INTO dt_part VALUES ('wiki.z_format', 4, 'extended', 'boolean', 'boolean', true, NULL, 'Расширенный формат', false);
INSERT INTO dt_part VALUES ('wiki.z_format', 5, 'id', 'ws.d_id', 'integer', true, NULL, 'ID оригинала для diff', false);
INSERT INTO dt_part VALUES ('wiki.z_add', 1, '_sid', 'text', 'text', true, NULL, 'ID сессии', false);
INSERT INTO dt_part VALUES ('wiki.z_add', 2, 'uri', 'text', 'text', true, NULL, 'Префикс адреса', false);
INSERT INTO dt_part VALUES ('wiki.z_add', 3, 'id', 'ws.d_id', 'integer', true, NULL, 'ID wiki', false);
INSERT INTO dt_part VALUES ('wiki.z_add', 4, 'code', 'text', 'text', true, NULL, 'Адрес страницы', false);
INSERT INTO dt_part VALUES ('wiki.z_add', 5, 'src', 'text', 'text', true, NULL, 'Текст в разметке wiki', false);
INSERT INTO dt_part VALUES ('wiki.z_save', 1, '_sid', 'text', 'text', true, NULL, 'ID сессии', false);
INSERT INTO dt_part VALUES ('wiki.z_save', 2, 'uri', 'text', 'text', true, NULL, 'Префикс адреса', false);
INSERT INTO dt_part VALUES ('wiki.z_save', 3, 'id', 'ws.d_id', 'integer', true, NULL, 'ID статьи', false);
INSERT INTO dt_part VALUES ('wiki.z_save', 4, 'revision', 'ws.d_id', 'integer', true, NULL, 'Номер ревизии', false);
INSERT INTO dt_part VALUES ('wiki.z_save', 5, 'src', 'text', 'text', true, NULL, 'Текст в разметке wiki', false);
INSERT INTO dt_part VALUES ('wiki.z_status', 1, 'id', 'ws.d_id', 'integer', false, NULL, '', false);
INSERT INTO dt_part VALUES ('wiki.z_acl', 1, 'id', 'ws.d_id', 'integer', false, NULL, '', false);
INSERT INTO dt_part VALUES ('wiki.z_acl', 2, '_sid', 'ws.d_sid', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('wiki.z_id_by_code', 1, 'code', 'ws.d_code', 'text', false, NULL, '', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_id_by_code', 1, 'id', 'ws.d_id', 'integer', false, NULL, 'ID вики', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_id_by_code', 2, 'code', 'ws.d_path', 'text', false, '', 'Код документа', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_by_name', 1, 'id', 'ws.d_id32', 'integer', false, NULL, 'ID wiki', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_by_name', 2, 'string', 'text', 'text', false, NULL, '', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_by_name', 3, 'max_rows', 'ws.d_cnt', 'integer', false, '15', '', false);
INSERT INTO dt_part VALUES ('wiki.z_keyword_by_name', 1, 'id', 'ws.d_id32', 'integer', false, NULL, 'ID wiki', false);
INSERT INTO dt_part VALUES ('wiki.z_keyword_by_name', 2, 'string', 'text', 'text', false, NULL, '', false);
INSERT INTO dt_part VALUES ('wiki.z_keyword_by_name', 3, 'max_rows', 'ws.d_cnt', 'integer', false, '15', '', false);
INSERT INTO dt_part VALUES ('wiki.doc_info', 1, 'id', 'integer', 'integer', true, NULL, 'id', false);
INSERT INTO dt_part VALUES ('wiki.doc_info', 2, 'status_id', 'integer', 'integer', true, NULL, 'status_id', false);
INSERT INTO dt_part VALUES ('wiki.doc_info', 3, 'group_id', 'integer', 'integer', true, NULL, 'group_id', false);
INSERT INTO dt_part VALUES ('wiki.doc_info', 4, 'up_id', 'integer', 'integer', true, NULL, 'up_id', false);
INSERT INTO dt_part VALUES ('wiki.doc_info', 5, 'code', 'text', 'text', true, NULL, 'code', false);
INSERT INTO dt_part VALUES ('wiki.doc_info', 6, 'revision', 'integer', 'integer', true, NULL, 'revision', false);
INSERT INTO dt_part VALUES ('wiki.doc_info', 7, 'pub_date', 'date', 'date', true, NULL, 'pub_date', false);
INSERT INTO dt_part VALUES ('wiki.doc_info', 8, 'created_by', 'integer', 'integer', true, NULL, 'created_by', false);
INSERT INTO dt_part VALUES ('wiki.doc_info', 9, 'created_at', 'timestamp', 'timestamp', true, NULL, 'created_at', false);
INSERT INTO dt_part VALUES ('wiki.doc_info', 10, 'updated_by', 'integer', 'integer', true, NULL, 'updated_by', false);
INSERT INTO dt_part VALUES ('wiki.doc_info', 11, 'updated_at', 'timestamp', 'timestamp', true, NULL, 'updated_at', false);
INSERT INTO dt_part VALUES ('wiki.doc_info', 12, 'status_next_id', 'integer', 'integer', true, NULL, 'status_next_id', false);
INSERT INTO dt_part VALUES ('wiki.doc_info', 13, 'status_next_at', 'timestamp', 'timestamp', true, NULL, 'status_next_at', false);
INSERT INTO dt_part VALUES ('wiki.doc_info', 14, 'name', 'text', 'text', true, NULL, 'name', false);
INSERT INTO dt_part VALUES ('wiki.doc_info', 15, 'group_status_id', 'integer', 'integer', true, NULL, 'group_status_id', false);
INSERT INTO dt_part VALUES ('wiki.doc_info', 16, 'group_name', 'text', 'text', true, NULL, 'group_name', false);
INSERT INTO dt_part VALUES ('wiki.doc_info', 17, 'updated_by_name', 'text', 'text', true, NULL, 'updated_by_name', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_info', 1, 'id', 'ws.d_id', 'integer', false, NULL, 'ID статьи', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_keyword', 1, 'id', 'ws.d_id', 'integer', false, NULL, 'ID статьи', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_src', 1, 'id', 'ws.d_id', 'integer', false, NULL, 'ID статьи', false);
INSERT INTO dt_part VALUES ('wiki.doc_extra', 1, 'id', 'ws.d_id32', 'integer', false, NULL, 'ID статьи', false);
INSERT INTO dt_part VALUES ('wiki.doc_extra', 2, 'is_toc_preferred', 'boolean', 'boolean', false, 'false', 'В кратком списке выводить не аннотацию а содержание', false);
INSERT INTO dt_part VALUES ('wiki.doc_extra', 3, 'toc', 'text', 'text', true, NULL, 'toc', false);
INSERT INTO dt_part VALUES ('wiki.doc_extra', 4, 'anno', 'text', 'text', true, NULL, 'anno', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_extra', 1, 'id', 'ws.d_id', 'integer', false, NULL, 'ID статьи', false);
INSERT INTO dt_part VALUES ('wiki.doc_link', 1, 'id', 'ws.d_id32', 'integer', false, NULL, 'ID статьи', false);
INSERT INTO dt_part VALUES ('wiki.doc_link', 2, 'path', 'text', 'text', false, NULL, 'path', false);
INSERT INTO dt_part VALUES ('wiki.doc_link', 3, 'is_wiki', 'boolean', 'boolean', false, 'true', 'is_wiki', false);
INSERT INTO dt_part VALUES ('wiki.doc_link', 4, 'link_id', 'ws.d_id', 'integer', true, NULL, 'link_id', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_link', 1, 'id', 'ws.d_id', 'integer', false, NULL, 'ID статьи', false);
INSERT INTO dt_part VALUES ('fs.file_info', 1, 'name', 'text', 'text', true, NULL, 'Внешнее имя файла', false);
INSERT INTO dt_part VALUES ('fs.file_info', 2, 'size', 'integer', 'integer', true, NULL, 'Размер (байт)', false);
INSERT INTO dt_part VALUES ('fs.file_info', 3, 'csum', 'text', 'text', true, NULL, 'Контрольная сумма (sha1)', false);
INSERT INTO dt_part VALUES ('fs.file_info', 4, 'format_code', 'text', 'text', true, NULL, 'Код формата файла', false);
INSERT INTO dt_part VALUES ('fs.file_info', 5, 'created_by', 'integer', 'integer', true, NULL, 'Автор загрузки/генерации', false);
INSERT INTO dt_part VALUES ('fs.file_info', 6, 'created_at', 'timestamp', 'timestamp', true, NULL, 'Момент загрузки/генерации', false);
INSERT INTO dt_part VALUES ('fs.file_info', 7, 'anno', 'text', 'text', true, NULL, 'Комментарий', false);
INSERT INTO dt_part VALUES ('fs.file_info', 8, 'class_id', 'integer', 'integer', true, NULL, 'ID класса', false);
INSERT INTO dt_part VALUES ('fs.file_info', 9, 'obj_id', 'integer', 'integer', true, NULL, 'ID объекта', false);
INSERT INTO dt_part VALUES ('fs.file_info', 10, 'folder_code', 'text', 'text', true, NULL, 'Код связи', false);
INSERT INTO dt_part VALUES ('fs.file_info', 11, 'file_code', 'text', 'text', true, NULL, 'Код файла', false);
INSERT INTO dt_part VALUES ('fs.file_info', 12, 'ver', 'integer', 'integer', true, NULL, 'Версия внутри кода связи', false);
INSERT INTO dt_part VALUES ('fs.file_info', 13, 'id', 'integer', 'integer', true, NULL, 'ID файла', false);
INSERT INTO dt_part VALUES ('fs.file_info', 14, 'is_ver_last', 'boolean', 'boolean', true, NULL, 'Версия является последней', false);
INSERT INTO dt_part VALUES ('fs.file_info', 15, 'link_created_by', 'integer', 'integer', true, NULL, 'Автор привязки', false);
INSERT INTO dt_part VALUES ('fs.file_info', 16, 'link_created_at', 'timestamp', 'timestamp', true, NULL, 'Момент привязки', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_file', 1, 'id', 'ws.d_id', 'integer', false, NULL, '', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_file', 2, 'file_id', 'ws.d_id', 'integer', false, '0', '', false);
INSERT INTO dt_part VALUES ('wsd.doc_diff', 1, 'id', 'integer', 'integer', false, NULL, 'ID статьи', false);
INSERT INTO dt_part VALUES ('wsd.doc_diff', 2, 'revision', 'integer', 'integer', false, NULL, 'revision', false);
INSERT INTO dt_part VALUES ('wsd.doc_diff', 3, 'updated_by', 'integer', 'integer', false, NULL, 'updated_by', false);
INSERT INTO dt_part VALUES ('wsd.doc_diff', 4, 'updated_at', 'timestamp', 'timestamp', false, 'now()', 'updated_at', false);
INSERT INTO dt_part VALUES ('wsd.doc_diff', 5, 'diff_src', 'text', 'text', true, NULL, 'diff_src', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_diff', 1, 'id', 'ws.d_id', 'integer', false, NULL, 'ID статьи', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_diff', 2, 'revision', 'ws.d_cnt', 'integer', false, NULL, '', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_status', 1, 'id', 'ws.d_id', 'integer', false, NULL, '', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_acl', 1, 'id', 'ws.d_id', 'integer', false, NULL, '', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_acl', 2, '_sid', 'ws.d_sid', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_create', 1, '_sid', 'text', 'text', false, NULL, 'ID сессии', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_create', 2, 'id', 'ws.d_id', 'integer', false, NULL, 'ID wiki', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_create', 3, 'code', 'ws.d_path', 'text', false, '', 'Код статьи', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_create', 4, 'src', 'text', 'text', false, '', 'Текст в разметке wiki', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_create', 5, 'name', 'text', 'text', false, '', 'Название', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_create', 6, 'links', 'wiki.d_links', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_create', 7, 'anno', 'text', 'text', false, '', 'Аннотация', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_create', 8, 'toc', 'text', 'text', false, '', '', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_update_src', 1, '_sid', 'text', 'text', false, NULL, 'ID сессии', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_update_src', 2, 'id', 'ws.d_id', 'integer', false, NULL, 'ID статьи', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_update_src', 3, 'revision', 'ws.d_cnt', 'integer', false, NULL, 'Номер текущей ревизии', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_update_src', 4, 'src', 'text', 'text', false, '', 'Текст в разметке wiki', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_update_src', 5, 'name', 'text', 'text', false, '', 'Название', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_update_src', 6, 'links', 'wiki.d_links', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_update_src', 7, 'anno', 'text', 'text', false, '', 'Аннотация', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_update_src', 8, 'toc', 'text', 'text', false, '', '', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_update_src', 9, 'diff', 'text', 'text', false, '', 'Изменения от предыдущей версии', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_update_attr', 1, '_sid', 'text', 'text', false, NULL, 'ID сессии', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_update_attr', 2, 'id', 'ws.d_id', 'integer', false, NULL, 'ID статьи', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_update_attr', 3, 'status_id', 'ws.d_id32', 'integer', false, NULL, 'ID статуса', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_update_attr', 4, 'up_id', 'ws.d_id', 'integer', true, NULL, 'ID статьи-предка', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_update_attr', 5, 'status_next_id', 'ws.d_id', 'integer', true, NULL, '', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_update_attr', 6, 'status_next_at', 'ws.d_stamp', 'timestamp', true, NULL, '', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_update_attr', 7, 'keywords', 'ws.d_texta', 'text', true, NULL, '', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_file_del', 1, 'id', 'ws.d_id', 'integer', false, NULL, '', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_file_del', 2, 'file_id', 'ws.d_id', 'integer', false, NULL, '', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_file_add', 1, '_sid', 'text', 'text', false, NULL, 'ID сессии', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_file_add', 2, 'id', 'ws.d_id', 'integer', false, NULL, 'ID статьи', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_file_add', 3, '_path', 'text', 'text', false, NULL, 'Путь к файлу в хранилище nginx', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_file_add', 4, '_size', 'integer', 'integer', false, NULL, 'Размер (байт)', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_file_add', 5, '_csum', 'text', 'text', false, NULL, 'Контрольная сумма (sha1)', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_file_add', 6, 'name', 'text', 'text', false, NULL, 'Внешнее имя файла', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_file_add', 7, 'ctype', 'text', 'text', false, NULL, 'Content type', false);
INSERT INTO dt_part VALUES ('wiki.z_doc_file_add', 8, 'anno', 'text', 'text', true, NULL, 'Комментарий', false);
INSERT INTO dt_part VALUES ('app.z_add', 1, 'a', 'integer', 'integer', false, NULL, 'Слагаемое 1', false);
INSERT INTO dt_part VALUES ('app.z_add', 2, 'b', 'integer', 'integer', false, '0', 'Слагаемое 2', false);


--
-- Data for Name: error_data; Type: TABLE DATA; Schema: ws; Owner: -
--

INSERT INTO error_data VALUES ('Y0001');
INSERT INTO error_data VALUES ('Y0002');
INSERT INTO error_data VALUES ('Y0003');
INSERT INTO error_data VALUES ('Y0010');
INSERT INTO error_data VALUES ('Y0101');
INSERT INTO error_data VALUES ('Y0102');
INSERT INTO error_data VALUES ('Y0103');
INSERT INTO error_data VALUES ('Y0104');
INSERT INTO error_data VALUES ('Y0105');
INSERT INTO error_data VALUES ('Y0106');
INSERT INTO error_data VALUES ('Y0301');
INSERT INTO error_data VALUES ('Y0302');
INSERT INTO error_data VALUES ('Y0303');
INSERT INTO error_data VALUES ('Y9901');
INSERT INTO error_data VALUES ('Y9902');
INSERT INTO error_data VALUES ('Y9903');
INSERT INTO error_data VALUES ('Y9904');
INSERT INTO error_data VALUES ('Y9905');
INSERT INTO error_data VALUES ('Y0021');
INSERT INTO error_data VALUES ('Y0022');


--
-- Data for Name: facet; Type: TABLE DATA; Schema: ws; Owner: -
--

INSERT INTO facet VALUES (1, 'length', 'Длина');
INSERT INTO facet VALUES (2, 'minLength', 'Мин. длина');
INSERT INTO facet VALUES (3, 'maxLength', 'Макс. длина');
INSERT INTO facet VALUES (4, 'pattern', 'Шаблон');
INSERT INTO facet VALUES (5, 'enumeration', 'Список значений');
INSERT INTO facet VALUES (6, 'whiteSpace', 'Обработка пробелов');
INSERT INTO facet VALUES (7, 'maxInclusive', 'Не больше');
INSERT INTO facet VALUES (8, 'maxExclusive', 'Меньше');
INSERT INTO facet VALUES (9, 'minExclusive', 'Больше');
INSERT INTO facet VALUES (10, 'minInclusive', 'Не меньше');
INSERT INTO facet VALUES (11, 'totalDigits', 'Количество знаков');
INSERT INTO facet VALUES (12, 'fractionDigits', 'Знаков дробной части');


--
-- Data for Name: facet_dt_base; Type: TABLE DATA; Schema: ws; Owner: -
--

INSERT INTO facet_dt_base VALUES (1, 'text');
INSERT INTO facet_dt_base VALUES (2, 'text');
INSERT INTO facet_dt_base VALUES (3, 'text');
INSERT INTO facet_dt_base VALUES (6, 'text');
INSERT INTO facet_dt_base VALUES (7, 'numeric');
INSERT INTO facet_dt_base VALUES (8, 'numeric');
INSERT INTO facet_dt_base VALUES (9, 'numeric');
INSERT INTO facet_dt_base VALUES (10, 'numeric');
INSERT INTO facet_dt_base VALUES (11, 'numeric');
INSERT INTO facet_dt_base VALUES (12, 'numeric');
INSERT INTO facet_dt_base VALUES (7, 'integer');
INSERT INTO facet_dt_base VALUES (8, 'integer');
INSERT INTO facet_dt_base VALUES (9, 'integer');
INSERT INTO facet_dt_base VALUES (10, 'integer');
INSERT INTO facet_dt_base VALUES (11, 'integer');
INSERT INTO facet_dt_base VALUES (7, 'smallint');
INSERT INTO facet_dt_base VALUES (8, 'smallint');
INSERT INTO facet_dt_base VALUES (9, 'smallint');
INSERT INTO facet_dt_base VALUES (10, 'smallint');
INSERT INTO facet_dt_base VALUES (11, 'smallint');
INSERT INTO facet_dt_base VALUES (1, 'bpchar');
INSERT INTO facet_dt_base VALUES (4, 'text');
INSERT INTO facet_dt_base VALUES (4, 'boolean');
INSERT INTO facet_dt_base VALUES (4, 'numeric');
INSERT INTO facet_dt_base VALUES (4, 'interval');
INSERT INTO facet_dt_base VALUES (4, 'timestamp');
INSERT INTO facet_dt_base VALUES (4, 'time');
INSERT INTO facet_dt_base VALUES (4, 'date');
INSERT INTO facet_dt_base VALUES (4, 'inet');
INSERT INTO facet_dt_base VALUES (4, 'real');
INSERT INTO facet_dt_base VALUES (4, 'integer');
INSERT INTO facet_dt_base VALUES (4, 'smallint');
INSERT INTO facet_dt_base VALUES (4, 'oid');
INSERT INTO facet_dt_base VALUES (4, 'double');
INSERT INTO facet_dt_base VALUES (4, 'bigint');
INSERT INTO facet_dt_base VALUES (4, 'json');
INSERT INTO facet_dt_base VALUES (4, 'uuid');
INSERT INTO facet_dt_base VALUES (4, 'bpchar');


--
-- Data for Name: method; Type: TABLE DATA; Schema: ws; Owner: -
--

INSERT INTO method VALUES ('info.date', 2, 1, 2, 3, false, false, true, false, 'ws.date_info', 'ws.z_date_info', 'ws.t_date_info', 'Атрибуты заданной даты', '', 'date date, offset integer', 'ws', NULL);
INSERT INTO method VALUES ('info.month', 2, 1, 2, 3, false, false, true, false, 'ws.month_info', 'ws.z_month_info', 'ws.t_month_info', 'Атрибуты месяца заданной даты', '', 'date date', 'ws', NULL);
INSERT INTO method VALUES ('info.year_months', 2, 1, 2, 5, false, false, true, false, 'ws.year_months', 'ws.z_year_months', 'ws.t_month_info', 'Список атрибутов месяцев года заданной даты', '', 'date date, date_min date, date_max date', 'ws', NULL);
INSERT INTO method VALUES ('info.ref_info', 2, 1, 2, 7, false, false, true, false, 'ws.ref_info', 'ws.z_ref_info', 'ws.ref', 'Атрибуты справочника', 'id=65', 'id ws.d_id32', 'ws', NULL);
INSERT INTO method VALUES ('info.ref', 2, 1, 2, 7, false, false, true, false, 'ws.ref', 'ws.z_ref', 'ws.ref_item', 'Значение из справочника ws.ref', 'id=65', 'id ws.d_id32, item_id ws.d_id32, group_id ws.d_id32, active_only boolean', 'ws', NULL);
INSERT INTO method VALUES ('ws.page_by_code', 2, 1, 2, 3, false, true, true, false, 'ws.page_by_code', 'ws.z_page_by_code', 'ws.t_page_info', 'Атрибуты страницы  по коду и идентификаторам', 'code=api.smd', 'code text, id text, id1 text, id2 text', 'ws', NULL);
INSERT INTO method VALUES ('ws.page_path', 2, 1, 2, 7, false, true, true, false, 'ws.page_path', 'ws.z_page_path', 'ws.t_page_info', 'Атрибуты страниц пути от заданной до корневой', 'code=api.smd', 'code text, id text, id1 text, id2 text', 'ws', NULL);
INSERT INTO method VALUES ('ws.page_childs', 2, 1, 2, 7, false, true, true, false, 'ws.page_childs', 'ws.z_page_childs', 'ws.t_page_info', 'Атрибуты страниц, имеющих предком заданную', 'code=api', 'code text, id text, id1 text, id2 text', 'ws', NULL);
INSERT INTO method VALUES ('ws.page_by_action', 2, 1, 2, 3, false, true, true, false, 'ws.page_by_action', 'ws.z_page_by_action', 'ws.t_page_info', 'Атрибуты страницы  по акции и идентификаторам', '', 'class_id ws.d_class, action_id ws.d_id32, id text, id1 text, id2 text', 'ws', NULL);
INSERT INTO method VALUES ('ws.page_tree', 2, 1, 2, 7, false, false, true, false, 'ws.page_tree', 'ws.z_page_tree', 'ws.t_hashtable', 'Иерархия страниц, имеющих предком заданную или main', '', 'code text', 'ws', NULL);
INSERT INTO method VALUES ('ws.class', 2, 1, 2, 5, false, false, true, false, 'ws.class', 'ws.z_class', 'ws.class', 'Атрибуты классов по ID', '', 'id ws.d_class', 'ws', NULL);
INSERT INTO method VALUES ('ws.method_lookup', 2, 1, 2, 7, false, false, true, false, 'ws.method_lookup', 'ws.z_method_lookup', 'ws.method', 'Поиск метода по code', '', 'code ws.d_code_like, page ws.d_cnt, by ws.d_cnt', 'ws', NULL);
INSERT INTO method VALUES ('ws.class_id', 2, 1, 2, 2, false, false, true, false, 'ws.class_id', 'ws.z_class_id', 'ws.d_class', 'ID класса по коду', 'code=system', 'code ws.d_code', 'ws', NULL);
INSERT INTO method VALUES ('ws.page_by_uri', 2, 1, 2, 3, false, true, true, false, 'ws.page_by_uri', 'ws.z_page_by_uri', 'ws.t_page_info', 'Атрибуты страницы по uri', NULL, 'uri text', 'ws', NULL);
INSERT INTO method VALUES ('ws.error_info', 2, 1, 2, 3, false, true, true, false, 'ws.error_info', 'ws.z_error_info', 'i18n_def.error', 'Описание ошибки', NULL, 'code ws.d_errcode', 'ws', NULL);
INSERT INTO method VALUES ('ws.method_rvf', 2, 1, 2, 4, false, false, true, false, 'ws.method_rvf', 'ws.z_method_rvf', 'ws.method_rv_format', 'Список форматов результата метода', NULL, 'id ws.d_id32', 'ws', NULL);
INSERT INTO method VALUES ('ws.method_by_code', 2, 1, 2, 7, false, false, true, false, 'ws.method_by_code', 'ws.z_method_by_code', 'ws.method', 'Атрибуты метода по коду', NULL, 'code ws.d_code', 'ws', NULL);
INSERT INTO method VALUES ('ws.method_by_action', 2, 1, 2, 7, false, false, true, false, 'ws.method_by_action', 'ws.z_method_by_action', 'ws.method', 'Атрибуты страницы  по акции и идентификаторам', NULL, 'class_id ws.d_class, action_id ws.d_id32', 'ws', NULL);
INSERT INTO method VALUES ('ws.facet', 2, 1, 2, 5, false, false, true, false, 'ws.facet', 'ws.z_facet', 'ws.facet', 'Атрибуты ограничения по id', NULL, 'id ws.d_id32', 'ws', NULL);
INSERT INTO method VALUES ('ws.dt_facet', 2, 1, 2, 7, false, false, true, false, 'ws.dt_facet', 'ws.z_dt_facet', 'ws.dt_facet', 'Атрибуты ограничения типа по коду типа', NULL, 'code ws.d_code', 'ws', NULL);
INSERT INTO method VALUES ('ws.dt_part', 2, 1, 2, 7, false, false, true, false, 'ws.dt_part', 'ws.z_dt_part', 'ws.dt_part', 'Атрибуты полей комплексного типа', NULL, 'code ws.d_code, part_id ws.d_id32', 'ws', NULL);
INSERT INTO method VALUES ('ws.class_status_action_acl', 2, 1, 2, 7, false, false, true, false, 'ws.class_status_action_acl', 'ws.z_class_status_action_acl', 'ws.csaa', 'Статусы и ACL для заданной акции', NULL, 'class_id ws.d_class, status_id ws.d_id32, action_id ws.d_id32, acl_id ws.d_id32', 'ws', NULL);
INSERT INTO method VALUES ('ws.class_action', 2, 1, 2, 3, false, false, true, false, 'ws.class_action', 'ws.z_class_action', 'ws.class_action', 'Описание акции класса', NULL, 'class_id ws.d_class, id ws.d_id32', 'ws', NULL);
INSERT INTO method VALUES ('ws.class_status', 2, 1, 2, 3, false, false, true, false, 'ws.class_status', 'ws.z_class_status', 'ws.class_status', 'Название статуса по ID и коду класса', NULL, 'class_id ws.d_class, id ws.d_id32', 'ws', NULL);
INSERT INTO method VALUES ('ws.class_acl', 2, 1, 2, 3, false, false, true, false, 'ws.class_acl', 'ws.z_class_acl', 'ws.class_acl', 'Описание уровней доступа класса', NULL, 'class_id ws.d_class, id ws.d_id32', 'ws', NULL);
INSERT INTO method VALUES ('ws.dt', 2, 1, 2, 7, false, false, true, false, 'ws.dt', 'ws.z_dt', 'ws.dt', 'Атрибуты типа по маске кода', NULL, 'code ws.d_code', 'ws', NULL);
INSERT INTO method VALUES ('ws.acls_eff_ids', 2, 1, 2, 6, false, false, true, false, 'ws.acls_eff_ids', 'ws.z_acls_eff_ids', 'ws.d_acl', 'Список id эффективных ACL', NULL, 'class_id ws.d_class, status_id ws.d_id32, action_id ws.d_id32, acl_ids ws.d_acls', 'ws', NULL);
INSERT INTO method VALUES ('ws.acls_eff', 2, 1, 2, 4, false, false, true, false, 'ws.acls_eff', 'ws.z_acls_eff', 'ws.t_hashtable', 'Список эффективных ACL', NULL, 'class_id ws.d_class, status_id ws.d_id32, action_id ws.d_id32, acl_ids ws.d_acls', 'ws', NULL);
INSERT INTO method VALUES ('system.status', 2, 1, 2, 2, false, false, true, false, 'ws.system_status', NULL, 'ws.d_id32', 'Статус системы', NULL, '', 'ws', NULL);
INSERT INTO method VALUES ('system.acl', 2, 1, 2, 6, false, false, true, false, 'ws.system_acl', 'ws.z_system_acl', 'ws.d_acl', 'ACL sid для системы', NULL, '_sid ws.d_sid', 'ws', NULL);
INSERT INTO method VALUES ('info.status', 2, 1, 2, 2, false, false, true, false, 'ws.info_status', NULL, 'ws.d_id32', 'Статус инфо', NULL, '', 'ws', NULL);
INSERT INTO method VALUES ('info.acl', 2, 1, 2, 6, false, false, true, false, 'ws.info_acl', 'ws.z_info_acl', 'ws.d_acl', 'ACL sid для инфо', NULL, '_sid ws.d_sid', 'ws', NULL);
INSERT INTO method VALUES ('info.acl_check', 2, 1, 4, 3, false, false, false, false, 'acl:check', 'ws.z_acl_check', 'ws.d_acls', 'Получение acl на объект', NULL, '_sid text, class_id ws.d_class, action_id ws.d_id32, id ws.d_id, id1 ws.d_id, id2 text', 'ws', NULL);
INSERT INTO method VALUES ('ws.uncache', 2, 1, 1, 2, false, false, false, false, 'cache:uncache', 'ws.z_uncache', 'ws.d_id', 'Сброс кэша метода', NULL, 'code text, key text', 'ws', NULL);
INSERT INTO method VALUES ('cfg.cache', 2, 1, 2, 5, false, false, true, false, 'cfg.cache', 'cfg.z_cache', 'ws.t_hashtable', 'Атрибуты кэша по id', NULL, 'id ws.d_id32', 'cfg', NULL);
INSERT INTO method VALUES ('fe.file_new', 2, 1, 1, 3, true, false, true, false, 'fs.file_new_path_mk', 'fs.z_file_new_path_mk', 'ws.t_hashtable', 'ID и путь хранения для формируемого файла', NULL, 'folder_code text, obj_id integer, name text, code text', 'fs', 'fe_only');
INSERT INTO method VALUES ('fe.file_attr', 2, 1, 1, 3, false, false, true, false, 'fs.file_store', 'fs.z_file_store', 'fs.file_store', 'Атрибуты хранения файла', NULL, 'id integer', 'fs', 'fe_only');
INSERT INTO method VALUES ('fe.file_get', 2, 1, 1, 2, false, false, false, false, 'store:get', 'ws.z_store_get', 'ws.d_id', 'Получение данных из файлового хранилища', NULL, 'path ws.d_path', 'fs', 'fe_only');
INSERT INTO method VALUES ('fe.file_get64', 2, 1, 1, 2, false, false, false, false, 'store:get64', 'ws.z_store_get', 'ws.d_id', 'Получение данных  из файлового хранилища и конвертация в base64', NULL, 'path ws.d_path', 'fs', 'fe_only');
INSERT INTO method VALUES ('fe.file_set', 2, 1, 1, 3, true, false, false, false, 'store:set', 'ws.z_store_set', 'ws.d_id', 'Сохранение данных в файловом хранилище', NULL, 'path ws.d_path, data text', 'fs', 'fe_only');
INSERT INTO method VALUES ('acc.profile', 1, 2, 3, 3, false, false, true, false, 'acc.profile', 'acc.z_profile', 'acc.account_attr', 'Профиль текущего пользователя', NULL, '_sid text', 'acc', NULL);
INSERT INTO method VALUES ('acc.sid_info', 2, 1, 3, 3, true, false, true, false, 'acc.sid_info', 'acc.z_sid_info', 'wsd.session', 'Атрибуты своей сессии', NULL, '_sid ws.d_sid, _ip text', 'acc', NULL);
INSERT INTO method VALUES ('acc.login', 1, 8, 1, 3, true, false, true, false, 'acc.login', 'acc.z_login', 'acc.session_info', 'Авторизация пользователя', NULL, '_ip text, login text, psw text, _cook text', 'acc', NULL);
INSERT INTO method VALUES ('acc.logout', 1, 2, 1, 2, true, false, true, false, 'acc.logout', 'acc.z_logout', 'integer', 'Завершить авторизации пользователя и вернуть количество завершенных', NULL, '_sid ws.d_sid', 'acc', NULL);
INSERT INTO method VALUES ('wiki.status', 2, 1, 3, 2, false, false, true, false, 'wiki.status', 'wiki.z_status', 'ws.d_id32', 'Статус вики', NULL, 'id ws.d_id', 'wiki', NULL);
INSERT INTO method VALUES ('wiki.acl', 2, 1, 3, 6, false, false, true, false, 'wiki.acl', 'wiki.z_acl', 'ws.d_acl', 'ACL вики', NULL, 'id ws.d_id, _sid ws.d_sid', 'wiki', NULL);
INSERT INTO method VALUES ('wiki.id_by_code', 10, 1, 3, 2, false, false, true, false, 'wiki.id_by_code', 'wiki.z_id_by_code', 'ws.d_id32', 'ID wiki по ее коду', NULL, 'code ws.d_code', 'wiki', NULL);
INSERT INTO method VALUES ('wiki.doc_id_by_code', 10, 1, 3, 2, false, false, true, false, 'wiki.doc_id_by_code', 'wiki.z_doc_id_by_code', 'ws.d_id', 'ID документа по коду', NULL, 'id ws.d_id, code ws.d_path', 'wiki', NULL);
INSERT INTO method VALUES ('wiki.doc_by_name', 10, 1, 3, 7, false, false, true, false, 'wiki.doc_by_name', 'wiki.z_doc_by_name', 'ws.t_hashtable', 'список статей, название которых содержит string', NULL, 'id ws.d_id32, string text, max_rows ws.d_cnt', 'wiki', NULL);
INSERT INTO method VALUES ('wiki.keyword_by_name', 10, 1, 3, 6, false, false, true, false, 'wiki.keyword_by_name', 'wiki.z_keyword_by_name', 'text', 'список ключевых слов wiki, содержащих строку string', NULL, 'id ws.d_id32, string text, max_rows ws.d_cnt', 'wiki', NULL);
INSERT INTO method VALUES ('wiki.doc_info', 11, 1, 3, 3, false, false, true, false, 'wiki.doc_info', 'wiki.z_doc_info', 'wiki.doc_info', 'Атрибуты документа', NULL, 'id ws.d_id', 'wiki', NULL);
INSERT INTO method VALUES ('wiki.doc_keyword', 11, 1, 3, 6, false, false, true, false, 'wiki.doc_keyword', 'wiki.z_doc_keyword', 'text', 'список ключевых слов статьи', NULL, 'id ws.d_id', 'wiki', NULL);
INSERT INTO method VALUES ('wiki.doc_src', 11, 1, 3, 2, false, false, true, false, 'wiki.doc_src', 'wiki.z_doc_src', 'text', 'Текст документа', NULL, 'id ws.d_id', 'wiki', NULL);
INSERT INTO method VALUES ('wiki.doc_extra', 11, 1, 3, 3, false, false, true, false, 'wiki.doc_extra', 'wiki.z_doc_extra', 'wiki.doc_extra', 'Дополнительные данные', NULL, 'id ws.d_id', 'wiki', NULL);
INSERT INTO method VALUES ('wiki.doc_link', 11, 1, 3, 7, false, false, true, false, 'wiki.doc_link', 'wiki.z_doc_link', 'wiki.doc_link', 'Ссылки ни внутренние документы', NULL, 'id ws.d_id', 'wiki', NULL);
INSERT INTO method VALUES ('wiki.doc_file', 11, 1, 3, 7, false, false, true, false, 'wiki.doc_file', 'wiki.z_doc_file', 'fs.file_info', 'Атрибуты файлов статьи', NULL, 'id ws.d_id, file_id ws.d_id', 'wiki', NULL);
INSERT INTO method VALUES ('wiki.doc_diff', 11, 1, 3, 3, false, false, true, false, 'wiki.doc_diff', 'wiki.z_doc_diff', 'wsd.doc_diff', 'Изменения заданной ревизии', NULL, 'id ws.d_id, revision ws.d_cnt', 'wiki', NULL);
INSERT INTO method VALUES ('doc.status', 2, 1, 3, 2, false, false, true, false, 'wiki.doc_status', 'wiki.z_doc_status', 'ws.d_id32', 'Статус статьи вики', NULL, 'id ws.d_id', 'wiki', NULL);
INSERT INTO method VALUES ('doc.acl', 2, 1, 3, 6, false, false, true, false, 'wiki.doc_acl', 'wiki.z_doc_acl', 'ws.d_acl', 'ACL вики', NULL, 'id ws.d_id, _sid ws.d_sid', 'wiki', NULL);
INSERT INTO method VALUES ('wiki.doc_create', 10, 4, 1, 2, true, false, true, false, 'wiki.doc_create', 'wiki.z_doc_create', 'ws.d_id', 'Создание документа', NULL, '_sid text, id ws.d_id, code ws.d_path, src text, name text, links wiki.d_links, anno text, toc text', 'wiki', NULL);
INSERT INTO method VALUES ('wiki.doc_update_src', 11, 3, 1, 2, true, false, true, false, 'wiki.doc_update_src', 'wiki.z_doc_update_src', 'ws.d_id', 'Изменение пользователем текста документа', NULL, '_sid text, id ws.d_id, revision ws.d_cnt, src text, name text, links wiki.d_links, anno text, toc text, diff text', 'wiki', NULL);
INSERT INTO method VALUES ('wiki.doc_update_attr', 11, 3, 1, 2, true, false, true, false, 'wiki.doc_update_attr', 'wiki.z_doc_update_attr', 'ws.d_id', 'Изменение атрибутов документа', NULL, '_sid text, id ws.d_id, status_id ws.d_id32, up_id ws.d_id, status_next_id ws.d_id, status_next_at ws.d_stamp, keywords ws.d_texta', 'wiki', NULL);
INSERT INTO method VALUES ('wiki.doc_file_del', 11, 3, 1, 2, true, false, true, false, 'wiki.doc_file_del', 'wiki.z_doc_file_del', 'boolean', 'Удаление файла из статьи', NULL, 'id ws.d_id, file_id ws.d_id', 'wiki', NULL);
INSERT INTO method VALUES ('wiki.doc_file_add', 11, 3, 1, 3, true, false, true, false, 'wiki.doc_file_add', 'wiki.z_doc_file_add', 'fs.file_info', 'Добавление в статью загруженного файла', NULL, '_sid text, id ws.d_id, _path text, _size integer, _csum text, name text, ctype text, anno text', 'wiki', 'upload');
INSERT INTO method VALUES ('doc.format', 11, 1, 3, 2, false, false, false, false, 'wiki:format', 'wiki.z_format', 'text', 'Форматирование wiki в html', 'a_text="*Hello* _world_"', '_sid text, uri text, src text, extended boolean, id ws.d_id', 'wiki', NULL);
INSERT INTO method VALUES ('wiki.add', 10, 3, 3, 2, true, false, false, false, 'wiki:add', 'wiki.z_add', 'text', 'Создание статьи wiki', NULL, '_sid text, uri text, id ws.d_id, code text, src text', 'wiki', NULL);
INSERT INTO method VALUES ('doc.save', 11, 3, 3, 2, true, false, false, false, 'wiki:save', 'wiki.z_save', 'text', 'Сохранение статьи wiki', NULL, '_sid text, uri text, id ws.d_id, revision ws.d_id, src text', 'wiki', NULL);
INSERT INTO method VALUES ('info.add', 2, 1, 2, 2, false, false, true, false, 'app.add', 'app.z_add', 'integer', 'Сумма 2х целых', 'a=37, b=-37', 'a integer, b integer', 'app', NULL);


--
-- Data for Name: method_rv_format; Type: TABLE DATA; Schema: ws; Owner: -
--

INSERT INTO method_rv_format VALUES (1, 'нет');
INSERT INTO method_rv_format VALUES (2, 'скаляр');
INSERT INTO method_rv_format VALUES (3, 'хэш');
INSERT INTO method_rv_format VALUES (4, 'хэш {[i][0] -> [i][1]}');
INSERT INTO method_rv_format VALUES (5, 'хэш {([i]{id}|[i]{code}) -> %[i]}');
INSERT INTO method_rv_format VALUES (6, 'массив [i][0]');
INSERT INTO method_rv_format VALUES (7, 'массив хэшей');
INSERT INTO method_rv_format VALUES (8, 'массив массивов');
INSERT INTO method_rv_format VALUES (10, 'дерево хэшей из массива [tag1.tag2][value]');


--
-- Data for Name: page_data; Type: TABLE DATA; Schema: ws; Owner: -
--

INSERT INTO page_data VALUES ('main', NULL, 2, 1, NULL, 0, '$', 'app/index', NULL, NULL, true, '', '$', '', 'ws');
INSERT INTO page_data VALUES ('api', 'main', 2, 1, NULL, NULL, 'docs$', 'apidoc/index', NULL, NULL, true, '', 'docs$', 'docs', 'apidoc');
INSERT INTO page_data VALUES ('api.smd', 'api', 2, 1, NULL, 3, 'docs/smd$', 'apidoc/smd', NULL, NULL, true, '', 'docs/smd$', 'docs/smd', 'apidoc');
INSERT INTO page_data VALUES ('api.map', 'api', 2, 1, NULL, 2, 'docs/pagemap$', 'apidoc/pagemap', NULL, NULL, true, '', 'docs/pagemap$', 'docs/pagemap', 'apidoc');
INSERT INTO page_data VALUES ('api.xsd', 'api', 2, 1, NULL, 5, 'docs/xsd$', 'apidoc/xsd', NULL, NULL, true, '', 'docs/xsd$', 'docs/xsd', 'apidoc');
INSERT INTO page_data VALUES ('api.class', 'api', 2, 1, NULL, 1, 'docs/class$', 'apidoc/class', NULL, NULL, true, '', 'docs/class$', 'docs/class', 'apidoc');
INSERT INTO page_data VALUES ('api.smd1', 'api', 2, 1, NULL, 4, 'docs/smd1$', 'apidoc/smd1', NULL, NULL, true, '', 'docs/smd1$', 'docs/smd1', 'apidoc');
INSERT INTO page_data VALUES ('api.markup', 'api', 2, 1, NULL, 6, 'docs/markup$', 'apidoc/markup', NULL, NULL, true, '', 'docs/markup$', 'docs/markup', 'apidoc');
INSERT INTO page_data VALUES ('api.class.single', 'api.class', 2, 1, NULL, NULL, 'docs/class/:i$', 'apidoc/class', NULL, NULL, true, '', 'docs/class/(\d+)$', 'docs/class/%i', 'apidoc');
INSERT INTO page_data VALUES ('login', 'main', 1, 8, NULL, NULL, 'login$', 'acc/login', NULL, NULL, true, '', 'login$', 'login', 'acc');
INSERT INTO page_data VALUES ('logout', 'main', 1, 2, NULL, NULL, 'logout$', 'acc/logout', NULL, NULL, true, '', 'logout$', 'logout', 'acc');
INSERT INTO page_data VALUES ('wiki.wk', 'main', 10, 1, NULL, 8, '(wk):u$', 'wiki/index', 1, NULL, true, '', '(wk)((?:/[^/]+)*)$', 'wk%s', 'wiki');
INSERT INTO page_data VALUES ('wiki.wk.edit', 'wiki.wk', 10, 3, NULL, NULL, '(wk):u/edit$', 'wiki/edit', 1, NULL, true, '', '(wk)((?:/[^/]+)*)/edit$', 'wk%s/edit', 'wiki');
INSERT INTO page_data VALUES ('wiki.wk.history', 'wiki.wk', 10, 1, NULL, NULL, '(wk):u/history$', 'wiki/history', 1, NULL, true, '', '(wk)((?:/[^/]+)*)/history$', 'wk%s/history', 'wiki');
INSERT INTO page_data VALUES ('wiki.wk.file', 'wiki.wk', 10, 1, NULL, NULL, '(wk):u/file/:i/:s$', 'wiki/file_redirect', 1, NULL, true, '', '(wk)((?:/[^/]+)*)/file/(\d+)/([^/:]+)$', 'wk%s/file/%i/%s', 'wiki');
INSERT INTO page_data VALUES ('api.test', 'main', 2, 1, NULL, 7, 'docs/test$', 'app/test', NULL, NULL, true, '', 'docs/test$', 'docs/test', 'app');


--
-- Data for Name: pkg; Type: TABLE DATA; Schema: ws; Owner: -
--

INSERT INTO pkg VALUES (1, 'ws', '000', '+', 'jean', '', '', 'apache', NULL, '2013-03-18 18:36:52.789853');
INSERT INTO pkg VALUES (2, 'apidoc', '000', '+', 'jean', '', '', 'apache', NULL, '2013-03-18 18:37:00.438565');
INSERT INTO pkg VALUES (3, 'fs', '000', '+', 'jean', '', '', 'apache', NULL, '2013-03-18 18:37:00.438565');
INSERT INTO pkg VALUES (4, 'ev', '000', '+', 'jean', '', '', 'apache', NULL, '2013-03-18 18:37:00.438565');
INSERT INTO pkg VALUES (5, 'job', '000', '+', 'jean', '', '', 'apache', NULL, '2013-03-18 18:37:00.438565');
INSERT INTO pkg VALUES (6, 'acc', '000', '+', 'jean', '', '', 'apache', NULL, '2013-03-18 18:37:00.438565');
INSERT INTO pkg VALUES (7, 'wiki', '000', '+', 'jean', '', '', 'apache', NULL, '2013-03-18 18:37:00.438565');
INSERT INTO pkg VALUES (8, 'app', '000', '+', 'jean', '', '', 'apache', NULL, '2013-03-18 18:37:00.438565');
INSERT INTO pkg VALUES (9, 'i18n', '000', '+', 'jean', '', '', 'apache', NULL, '2013-03-18 18:37:00.438565');


--
-- Name: pkg_id_seq; Type: SEQUENCE SET; Schema: ws; Owner: -
--

SELECT pg_catalog.setval('pkg_id_seq', 9, true);


--
-- Data for Name: pkg_log; Type: TABLE DATA; Schema: ws; Owner: -
--

INSERT INTO pkg_log VALUES (1, 'ws', '000', '+', 'jean', '', '', 'apache', NULL, '2013-03-18 18:36:52.789853');
INSERT INTO pkg_log VALUES (2, 'apidoc', '000', '+', 'jean', '', '', 'apache', NULL, '2013-03-18 18:37:00.438565');
INSERT INTO pkg_log VALUES (3, 'fs', '000', '+', 'jean', '', '', 'apache', NULL, '2013-03-18 18:37:00.438565');
INSERT INTO pkg_log VALUES (4, 'ev', '000', '+', 'jean', '', '', 'apache', NULL, '2013-03-18 18:37:00.438565');
INSERT INTO pkg_log VALUES (5, 'job', '000', '+', 'jean', '', '', 'apache', NULL, '2013-03-18 18:37:00.438565');
INSERT INTO pkg_log VALUES (6, 'acc', '000', '+', 'jean', '', '', 'apache', NULL, '2013-03-18 18:37:00.438565');
INSERT INTO pkg_log VALUES (7, 'wiki', '000', '+', 'jean', '', '', 'apache', NULL, '2013-03-18 18:37:00.438565');
INSERT INTO pkg_log VALUES (8, 'app', '000', '+', 'jean', '', '', 'apache', NULL, '2013-03-18 18:37:00.438565');
INSERT INTO pkg_log VALUES (9, 'i18n', '000', '+', 'jean', '', '', 'apache', NULL, '2013-03-18 18:37:00.438565');


--
-- Data for Name: ref; Type: TABLE DATA; Schema: ws; Owner: -
--



--
-- Data for Name: ref_item; Type: TABLE DATA; Schema: ws; Owner: -
--



--
-- Data for Name: server; Type: TABLE DATA; Schema: ws; Owner: -
--

INSERT INTO server VALUES (1, 'http://localhost:8080', 'Основной сервер');


SET search_path = wsd, pg_catalog;

--
-- Data for Name: account; Type: TABLE DATA; Schema: wsd; Owner: -
--

INSERT INTO account VALUES (1, 4, 4, 'admin', 'pgws', 'Admin', true, true, '2013-03-18 18:37:00', '2013-03-18 18:37:00', '2013-03-18 18:37:00');
INSERT INTO account VALUES (2, 4, 5, 'pgws-job-service', 'change me at config.json and pkg/acc/sql/01_acc/81_wsd.sql', 'Job', true, true, '2013-03-18 18:37:00', '2013-03-18 18:37:00', '2013-03-18 18:37:00');


--
-- Data for Name: account_contact; Type: TABLE DATA; Schema: wsd; Owner: -
--



--
-- Name: account_id_seq; Type: SEQUENCE SET; Schema: wsd; Owner: -
--

SELECT pg_catalog.setval('account_id_seq', 2, true);


--
-- Data for Name: account_role; Type: TABLE DATA; Schema: wsd; Owner: -
--



--
-- Data for Name: doc; Type: TABLE DATA; Schema: wsd; Owner: -
--



--
-- Data for Name: doc_diff; Type: TABLE DATA; Schema: wsd; Owner: -
--



--
-- Data for Name: doc_group; Type: TABLE DATA; Schema: wsd; Owner: -
--

INSERT INTO doc_group VALUES (1, 1, 'wk', 'Public', 'Public info');
INSERT INTO doc_group VALUES (2, 1, 'sys', 'Internal', 'Internal info');


--
-- Name: doc_id_seq; Type: SEQUENCE SET; Schema: wsd; Owner: -
--

SELECT pg_catalog.setval('doc_id_seq', 1, false);


--
-- Data for Name: doc_keyword; Type: TABLE DATA; Schema: wsd; Owner: -
--



--
-- Data for Name: event; Type: TABLE DATA; Schema: wsd; Owner: -
--



--
-- Data for Name: event_notify; Type: TABLE DATA; Schema: wsd; Owner: -
--



--
-- Data for Name: event_notify_spec; Type: TABLE DATA; Schema: wsd; Owner: -
--



--
-- Data for Name: event_role_signup; Type: TABLE DATA; Schema: wsd; Owner: -
--



--
-- Name: event_seq; Type: SEQUENCE SET; Schema: wsd; Owner: -
--

SELECT pg_catalog.setval('event_seq', 1, false);


--
-- Data for Name: event_signup; Type: TABLE DATA; Schema: wsd; Owner: -
--



--
-- Data for Name: event_signup_profile; Type: TABLE DATA; Schema: wsd; Owner: -
--



--
-- Data for Name: event_spec; Type: TABLE DATA; Schema: wsd; Owner: -
--



--
-- Data for Name: file; Type: TABLE DATA; Schema: wsd; Owner: -
--



--
-- Data for Name: file_folder; Type: TABLE DATA; Schema: wsd; Owner: -
--

INSERT INTO file_folder VALUES ('wiki', 11, 1, false, false, NULL, NULL, 'wiki.wk.file', 'Файл статьи wiki', NULL, 'wiki');


--
-- Data for Name: file_folder_format; Type: TABLE DATA; Schema: wsd; Owner: -
--

INSERT INTO file_folder_format VALUES ('wiki', '*', false);


--
-- Name: file_id_seq; Type: SEQUENCE SET; Schema: wsd; Owner: -
--

SELECT pg_catalog.setval('file_id_seq', 1, false);


--
-- Data for Name: file_link; Type: TABLE DATA; Schema: wsd; Owner: -
--



--
-- Data for Name: job; Type: TABLE DATA; Schema: wsd; Owner: -
--

INSERT INTO job VALUES (1, '2013-03-18 23:50:00', 85800, 9, 2, -2, NULL, NULL, '2013-03-18', NULL, NULL, NULL, NULL, NULL, '2013-03-18 18:37:00.438565', NULL, NULL, NULL, NULL);


--
-- Data for Name: job_cron; Type: TABLE DATA; Schema: wsd; Owner: -
--

INSERT INTO job_cron VALUES (true, '2013-03-18 18:37:00.438565', NULL);


--
-- Data for Name: job_dust; Type: TABLE DATA; Schema: wsd; Owner: -
--



--
-- Data for Name: job_past; Type: TABLE DATA; Schema: wsd; Owner: -
--



--
-- Name: job_seq; Type: SEQUENCE SET; Schema: wsd; Owner: -
--

SELECT pg_catalog.setval('job_seq', 25, true);


--
-- Data for Name: job_todo; Type: TABLE DATA; Schema: wsd; Owner: -
--



--
-- Data for Name: pkg_script_protected; Type: TABLE DATA; Schema: wsd; Owner: -
--

INSERT INTO pkg_script_protected VALUES ('ws', '11_wsd.sql', '000', 'ws', '2013-03-18 18:36:52.789853');
INSERT INTO pkg_script_protected VALUES ('ws', '20_prop_wsd.sql', '000', 'cfg', '2013-03-18 18:36:52.789853');
INSERT INTO pkg_script_protected VALUES ('ws', '81_prop_owner_wsd.sql', '000', 'cfg', '2013-03-18 18:36:52.789853');
INSERT INTO pkg_script_protected VALUES ('ws', '83_prop_val_wsd.sql', '000', 'cfg', '2013-03-18 18:36:52.789853');
INSERT INTO pkg_script_protected VALUES ('fs', '20_wsd.sql', '000', 'fs', '2013-03-18 18:37:00.438565');
INSERT INTO pkg_script_protected VALUES ('ev', '20_wsd.sql', '000', 'ev', '2013-03-18 18:37:00.438565');
INSERT INTO pkg_script_protected VALUES ('ev', '82_wsd.sql', '000', 'ev', '2013-03-18 18:37:00.438565');
INSERT INTO pkg_script_protected VALUES ('job', '20_wsd.sql', '000', 'job', '2013-03-18 18:37:00.438565');
INSERT INTO pkg_script_protected VALUES ('job', '81_prop_owner_wsd.sql', '000', 'job', '2013-03-18 18:37:00.438565');
INSERT INTO pkg_script_protected VALUES ('job', '83_prop_val_wsd.sql', '000', 'job', '2013-03-18 18:37:00.438565');
INSERT INTO pkg_script_protected VALUES ('acc', '20_wsd.sql', '000', 'acc', '2013-03-18 18:37:00.438565');
INSERT INTO pkg_script_protected VALUES ('acc', '81_wsd.sql', '000', 'acc', '2013-03-18 18:37:00.438565');
INSERT INTO pkg_script_protected VALUES ('wiki', '20_wsd.sql', '000', 'wiki', '2013-03-18 18:37:00.438565');
INSERT INTO pkg_script_protected VALUES ('wiki', '81_wsd.sql', '000', 'wiki', '2013-03-18 18:37:00.438565');
INSERT INTO pkg_script_protected VALUES ('wiki', '82_prop_wsd.sql', '000', 'wiki', '2013-03-18 18:37:00.438565');


--
-- Data for Name: prop_group; Type: TABLE DATA; Schema: wsd; Owner: -
--

INSERT INTO prop_group VALUES ('fcgi', 'cfg', 3, true, 'Демон FastCGI', NULL);
INSERT INTO prop_group VALUES ('tm', 'cfg', 4, true, 'Демон TM', NULL);
INSERT INTO prop_group VALUES ('be', 'cfg', 2, true, 'Бэкенд', NULL);
INSERT INTO prop_group VALUES ('fe', 'cfg', 1, true, 'Фронтенд', NULL);
INSERT INTO prop_group VALUES ('db', 'cfg', 5, true, 'БД', NULL);
INSERT INTO prop_group VALUES ('cache', 'cfg', 6, false, 'Кэш', NULL);
INSERT INTO prop_group VALUES ('job', 'job', 4, true, 'Демон Job', NULL);


--
-- Data for Name: prop_owner; Type: TABLE DATA; Schema: wsd; Owner: -
--

INSERT INTO prop_owner VALUES ('fcgi', 1, 'cfg', 1, 'Первичный Демон FastCGI', NULL);
INSERT INTO prop_owner VALUES ('tm', 1, 'cfg', 1, 'Первичный Демон TM', NULL);
INSERT INTO prop_owner VALUES ('be', 1, 'cfg', 1, 'Первичный Бэкенд', NULL);
INSERT INTO prop_owner VALUES ('fe', 1, 'cfg', 1, 'Первичный Фронтенд', NULL);
INSERT INTO prop_owner VALUES ('db', 1, 'cfg', 1, 'БД', NULL);
INSERT INTO prop_owner VALUES ('cache', 1, 'cfg', 1, 'нет', NULL);
INSERT INTO prop_owner VALUES ('cache', 2, 'cfg', 2, 'метаданные системы', NULL);
INSERT INTO prop_owner VALUES ('cache', 3, 'cfg', 3, 'Анти-DoS', NULL);
INSERT INTO prop_owner VALUES ('cache', 4, 'cfg', 4, 'Данные сессий', NULL);
INSERT INTO prop_owner VALUES ('cache', 5, 'cfg', 5, 'Большие объекты', NULL);
INSERT INTO prop_owner VALUES ('job', 1, 'job', 1, 'Первичный Демон Job', NULL);


--
-- Data for Name: prop_value; Type: TABLE DATA; Schema: wsd; Owner: -
--

INSERT INTO prop_value VALUES ('db', 1, 'ws.daemon.db.sql.0', '2000-01-01', 'cfg', 'SET datestyle TO ''German''');
INSERT INTO prop_value VALUES ('db', 1, 'ws.daemon.db.sql.1', '2000-01-01', 'cfg', 'SET time zone local');
INSERT INTO prop_value VALUES ('fcgi', 1, 'ws.daemon.startup.sock_wait', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.lang.allowed.0', '2000-01-01', 'cfg', 'ru');
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.lang.allowed.1', '2000-01-01', 'cfg', 'en');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.lang.allowed.0', '2000-01-01', 'cfg', 'ru');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.lang.allowed.1', '2000-01-01', 'cfg', 'en');
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.fe.tt2.ENCODING', '2000-01-01', 'cfg', 'utf-8');
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.fe.tt2.CACHE_SIZE', '2000-01-01', 'cfg', '100');
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.fe.tt2.COMPILE_EXT', '2000-01-01', 'cfg', '.pm');
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.fe.tt2.EVAL_PERL', '2000-01-01', 'cfg', '0');
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.fe.tt2.PRE_CHOMP', '2000-01-01', 'cfg', '1');
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.fe.tt2.POST_CHOMP', '2000-01-01', 'cfg', '1');
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.fe.tt2.PLUGIN_BASE', '2000-01-01', 'cfg', 'PGWS::TT2::Plugin');
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.fe.post./pwl', '2000-01-01', 'cfg', '/pwl');
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.fe.post./api', '2000-01-01', 'cfg', '/api');
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.fe.post./api_cgi', '2000-01-01', 'cfg', '/cgi-bin/pwl.pl');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.log.syslog.default.default', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.log.syslog.default.init', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.log.syslog.default.cache', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.default.default', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.default.call', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.default.sid', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.default.acl', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.default.cache', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.default.validate', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.post.default', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.post.call', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.post.sid', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.post.acl', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.post.cache', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.post.validate', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.get.default', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.get.call', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.get.sid', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.get.acl', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.get.cache', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.get.validate', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.tmpl.default', '2000-01-01', 'cfg', '5');
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.tmpl.call', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.tmpl.sid', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.tmpl.acl', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.tmpl.cache', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.debug.tmpl.validate', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.default.default', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.default.call', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.default.sid', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.default.acl', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.default.cache', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.default.validate', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.post.default', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.post.call', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.post.sid', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.post.acl', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.post.cache', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.post.validate', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.get.default', '2000-01-01', 'cfg', '5');
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.get.call', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.get.sid', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.get.acl', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.get.cache', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.get.validate', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.tmpl.default', '2000-01-01', 'cfg', '5');
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.tmpl.call', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.tmpl.sid', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.tmpl.acl', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.tmpl.cache', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.tmpl.validate', '2000-01-01', 'cfg', NULL);
INSERT INTO prop_value VALUES ('tm', 1, 'ws.daemon.mgr.listen.job', '2000-01-01', 'cfg', 'jq_event');
INSERT INTO prop_value VALUES ('tm', 1, 'ws.daemon.mgr.listen_wait', '2000-01-01', 'cfg', '300');
INSERT INTO prop_value VALUES ('tm', 1, 'ws.daemon.startup.pm.n_processes', '2000-01-01', 'cfg', '1');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.bad_json.code', '2000-01-01', 'cfg', '-32700');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.bad_json.message', '2000-01-01', 'cfg', 'Parse error');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.bad_json.data', '2000-01-01', 'cfg', 'Invalid JSON was received by the server.');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.bad_req.code', '2000-01-01', 'cfg', '-32600');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.bad_req.message', '2000-01-01', 'cfg', 'Invalid Request');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.bad_req.data', '2000-01-01', 'cfg', 'The JSON sent is not a valid Request object.');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.no_mtd.code', '2000-01-01', 'cfg', '-32601');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.no_mtd.message', '2000-01-01', 'cfg', 'Method not found');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.no_mtd.data', '2000-01-01', 'cfg', 'The method does not exist / is not available.');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.bad_args.code', '2000-01-01', 'cfg', '-32602');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.bad_args.message', '2000-01-01', 'cfg', 'Invalid params');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.bad_args.data', '2000-01-01', 'cfg', 'Invalid method parameter(s).');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.int_err.code', '2000-01-01', 'cfg', '-32603');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.int_err.message', '2000-01-01', 'cfg', 'Internal error');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.int_err.data', '2000-01-01', 'cfg', 'Internal JSON-RPC error.');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.no_data.code', '2000-01-01', 'cfg', '-32001');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.no_data.message', '2000-01-01', 'cfg', 'Empty request');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.no_data.data', '2000-01-01', 'cfg', 'The request contains no data');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.srv_error.code', '2000-01-01', 'cfg', '-32002');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.srv_error.message', '2000-01-01', 'cfg', 'Server error');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.srv_error.data', '2000-01-01', 'cfg', 'Unhandled server error');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.db_error.code', '2000-01-01', 'cfg', '-32003');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.db_error.message', '2000-01-01', 'cfg', 'DB error');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.db_error.data', '2000-01-01', 'cfg', 'Unhandled database error');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.pl_error.code', '2000-01-01', 'cfg', '-32004');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.pl_error.message', '2000-01-01', 'cfg', 'Plugin error');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.pl_error.data', '2000-01-01', 'cfg', 'Unhandled plugin error');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.bad_sid.code', '2000-01-01', 'cfg', '-32005');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.bad_sid.message', '2000-01-01', 'cfg', 'SID error');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.bad_sid.data', '2000-01-01', 'cfg', 'Incorrect SID value');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.bad_realm.code', '2000-01-01', 'cfg', '-32006');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.bad_realm.message', '2000-01-01', 'cfg', 'Realm error');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.bad_realm.data', '2000-01-01', 'cfg', 'Incorrect Realm code');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.ws_bad_bt.code', '2000-01-01', 'cfg', '-32011');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.ws_bad_bt.message', '2000-01-01', 'cfg', 'Base type error');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.ws_bad_bt.data', '2000-01-01', 'cfg', 'Error found in base type definition');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.ws_bad_mt.code', '2000-01-01', 'cfg', '-32012');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.ws_bad_mt.message', '2000-01-01', 'cfg', 'Argument type');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.ws_bad_mt.data', '2000-01-01', 'cfg', 'Error found in argument type definition');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.ws_no_acc.code', '2000-01-01', 'cfg', '-32031');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.ws_no_acc.message', '2000-01-01', 'cfg', 'Access forbidden');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.ws_no_acc.data', '2000-01-01', 'cfg', 'Access to this method is forbidden');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.db_no_acc.code', '2000-01-01', 'cfg', '-32032');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.db_no_acc.message', '2000-01-01', 'cfg', 'Access forbidden');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.db_no_acc.data', '2000-01-01', 'cfg', 'Access to this method is forbidden');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.no_error.code', '2000-01-01', 'cfg', '-32099');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.no_error.message', '2000-01-01', 'cfg', 'Last error');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.error.no_error.data', '2000-01-01', 'cfg', 'Reserved as last error code');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.plugin.cache.lib', '2000-01-01', 'cfg', 'PGWS::Plugin::System::Cache');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.plugin.cache.pogc', '2000-01-01', 'cfg', 'cache');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.plugin.cache.poid', '2000-01-01', 'cfg', '0');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.plugin.cache.data_set', '2000-01-01', 'cfg', '1');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.plugin.acl.lib', '2000-01-01', 'cfg', 'PGWS::Plugin::System::ACL');
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.plugin.store.lib', '2000-01-01', 'cfg', 'PGWS::Plugin::System::Store');
INSERT INTO prop_value VALUES ('cache', 1, 'ws.plugin.cache.code', '2000-01-01', 'cfg', 'none');
INSERT INTO prop_value VALUES ('cache', 1, 'ws.plugin.cache.is_active', '2000-01-01', 'cfg', '0');
INSERT INTO prop_value VALUES ('cache', 2, 'ws.plugin.cache.code', '2000-01-01', 'cfg', 'meta');
INSERT INTO prop_value VALUES ('cache', 2, 'ws.plugin.cache.expire_time', '2000-01-01', 'cfg', '0');
INSERT INTO prop_value VALUES ('cache', 3, 'ws.plugin.cache.code', '2000-01-01', 'cfg', 'short');
INSERT INTO prop_value VALUES ('cache', 3, 'ws.plugin.cache.expire_time', '2000-01-01', 'cfg', '3');
INSERT INTO prop_value VALUES ('cache', 4, 'ws.plugin.cache.code', '2000-01-01', 'cfg', 'session');
INSERT INTO prop_value VALUES ('cache', 5, 'ws.plugin.cache.code', '2000-01-01', 'cfg', 'big');
INSERT INTO prop_value VALUES ('cache', 5, 'ws.plugin.cache.cache_size', '2000-01-01', 'cfg', '4096k');
INSERT INTO prop_value VALUES ('cache', 5, 'ws.plugin.cache.expire_time', '2000-01-01', 'cfg', '10m');
INSERT INTO prop_value VALUES ('job', 1, 'ws.daemon.mgr.listen.job', '2000-01-01', 'job', 'job_event');
INSERT INTO prop_value VALUES ('job', 1, 'ws.daemon.mgr.listen.stat', '2000-01-01', 'job', 'job_stat');
INSERT INTO prop_value VALUES ('job', 1, 'ws.daemon.mgr.listen.reload', '2000-01-01', 'job', 'job_reload');
INSERT INTO prop_value VALUES ('job', 1, 'ws.daemon.mgr.reload_key', '2000-01-01', 'job', 'job_secret_reload');
INSERT INTO prop_value VALUES ('job', 1, 'ws.daemon.startup.pm.n_processes', '2000-01-01', 'job', '5');
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.job.default', '2000-01-01', 'job', '6');
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.job.call', '2000-01-01', 'job', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.job.sid', '2000-01-01', 'job', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.job.acl', '2000-01-01', 'job', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.job.cache', '2000-01-01', 'job', NULL);
INSERT INTO prop_value VALUES ('fe', 1, 'ws.daemon.log.syslog.job.validate', '2000-01-01', 'job', NULL);
INSERT INTO prop_value VALUES ('be', 1, 'ws.daemon.be.plugin.wiki.lib', '2000-01-01', 'wiki', 'PGWS::Plugin::Wiki');


--
-- Data for Name: role; Type: TABLE DATA; Schema: wsd; Owner: -
--

INSERT INTO role VALUES (1, 1, false, 'Guest', '');
INSERT INTO role VALUES (2, 1, false, 'Logged in', '');
INSERT INTO role VALUES (3, 5, true, 'Any group member', '');
INSERT INTO role VALUES (4, 6, true, 'Admins', '');
INSERT INTO role VALUES (5, 6, false, 'Service', '');
INSERT INTO role VALUES (6, 6, true, 'Readers', '');
INSERT INTO role VALUES (7, 6, true, 'Writers', '');


--
-- Data for Name: role_acl; Type: TABLE DATA; Schema: wsd; Owner: -
--

INSERT INTO role_acl VALUES (4, 10, 1, 5);
INSERT INTO role_acl VALUES (1, 10, 1, 2);
INSERT INTO role_acl VALUES (2, 10, 1, 2);


--
-- Name: role_id_seq; Type: SEQUENCE SET; Schema: wsd; Owner: -
--

SELECT pg_catalog.setval('role_id_seq', 7, true);


--
-- Data for Name: role_team; Type: TABLE DATA; Schema: wsd; Owner: -
--

INSERT INTO role_team VALUES (3, 1);
INSERT INTO role_team VALUES (4, 1);
INSERT INTO role_team VALUES (5, 1);
INSERT INTO role_team VALUES (6, 1);


--
-- Data for Name: session; Type: TABLE DATA; Schema: wsd; Owner: -
--



--
-- Name: session_id_seq; Type: SEQUENCE SET; Schema: wsd; Owner: -
--

SELECT pg_catalog.setval('session_id_seq', 2, true);


--
-- Data for Name: team; Type: TABLE DATA; Schema: wsd; Owner: -
--

INSERT INTO team VALUES (1, 'Users', '');


--
-- Name: team_id_seq; Type: SEQUENCE SET; Schema: wsd; Owner: -
--

SELECT pg_catalog.setval('team_id_seq', 1, true);


SET search_path = cfg, pg_catalog;

--
-- Name: prop_pkey; Type: CONSTRAINT; Schema: cfg; Owner: -
--

ALTER TABLE ONLY prop
    ADD CONSTRAINT prop_pkey PRIMARY KEY (code);


SET search_path = ev, pg_catalog;

--
-- Name: form_pkey; Type: CONSTRAINT; Schema: ev; Owner: -
--

ALTER TABLE ONLY form
    ADD CONSTRAINT form_pkey PRIMARY KEY (code);


--
-- Name: kind_group_pkey; Type: CONSTRAINT; Schema: ev; Owner: -
--

ALTER TABLE ONLY kind_group
    ADD CONSTRAINT kind_group_pkey PRIMARY KEY (id);


--
-- Name: kind_pkey; Type: CONSTRAINT; Schema: ev; Owner: -
--

ALTER TABLE ONLY kind
    ADD CONSTRAINT kind_pkey PRIMARY KEY (id);


--
-- Name: signature_pkey; Type: CONSTRAINT; Schema: ev; Owner: -
--

ALTER TABLE ONLY signature
    ADD CONSTRAINT signature_pkey PRIMARY KEY (id);


--
-- Name: status_pkey; Type: CONSTRAINT; Schema: ev; Owner: -
--

ALTER TABLE ONLY status
    ADD CONSTRAINT status_pkey PRIMARY KEY (id);


SET search_path = fs, pg_catalog;

--
-- Name: file_format_pkey; Type: CONSTRAINT; Schema: fs; Owner: -
--

ALTER TABLE ONLY file_format
    ADD CONSTRAINT file_format_pkey PRIMARY KEY (code);


SET search_path = i18n_def, pg_catalog;

--
-- Name: error_message_pkey; Type: CONSTRAINT; Schema: i18n_def; Owner: -
--

ALTER TABLE ONLY error_message
    ADD CONSTRAINT error_message_pkey PRIMARY KEY (code);


--
-- Name: page_group_pkey; Type: CONSTRAINT; Schema: i18n_def; Owner: -
--

ALTER TABLE ONLY page_group
    ADD CONSTRAINT page_group_pkey PRIMARY KEY (id);


--
-- Name: page_name_pkey; Type: CONSTRAINT; Schema: i18n_def; Owner: -
--

ALTER TABLE ONLY page_name
    ADD CONSTRAINT page_name_pkey PRIMARY KEY (code);


SET search_path = i18n_en, pg_catalog;

--
-- Name: error_message_pkey; Type: CONSTRAINT; Schema: i18n_en; Owner: -
--

ALTER TABLE ONLY error_message
    ADD CONSTRAINT error_message_pkey PRIMARY KEY (code);


--
-- Name: page_group_pkey; Type: CONSTRAINT; Schema: i18n_en; Owner: -
--

ALTER TABLE ONLY page_group
    ADD CONSTRAINT page_group_pkey PRIMARY KEY (id);


--
-- Name: page_name_pkey; Type: CONSTRAINT; Schema: i18n_en; Owner: -
--

ALTER TABLE ONLY page_name
    ADD CONSTRAINT page_name_pkey PRIMARY KEY (code);


SET search_path = job, pg_catalog;

--
-- Name: arg_type_pkey; Type: CONSTRAINT; Schema: job; Owner: -
--

ALTER TABLE ONLY arg_type
    ADD CONSTRAINT arg_type_pkey PRIMARY KEY (id);


--
-- Name: handler_pkey; Type: CONSTRAINT; Schema: job; Owner: -
--

ALTER TABLE ONLY handler
    ADD CONSTRAINT handler_pkey PRIMARY KEY (id);


--
-- Name: handler_uk_type_id_code; Type: CONSTRAINT; Schema: job; Owner: -
--

ALTER TABLE ONLY handler
    ADD CONSTRAINT handler_uk_type_id_code UNIQUE (pkg, code);


--
-- Name: mgr_error_pkey; Type: CONSTRAINT; Schema: job; Owner: -
--

ALTER TABLE ONLY mgr_error
    ADD CONSTRAINT mgr_error_pkey PRIMARY KEY (pid, anno);


--
-- Name: mgr_stat_pkey; Type: CONSTRAINT; Schema: job; Owner: -
--

ALTER TABLE ONLY mgr_stat
    ADD CONSTRAINT mgr_stat_pkey PRIMARY KEY (pid);


--
-- Name: status_pkey; Type: CONSTRAINT; Schema: job; Owner: -
--

ALTER TABLE ONLY status
    ADD CONSTRAINT status_pkey PRIMARY KEY (id);


SET search_path = wiki, pg_catalog;

--
-- Name: doc_extra_pkey; Type: CONSTRAINT; Schema: wiki; Owner: -
--

ALTER TABLE ONLY doc_extra
    ADD CONSTRAINT doc_extra_pkey PRIMARY KEY (id);


--
-- Name: doc_link_pkey; Type: CONSTRAINT; Schema: wiki; Owner: -
--

ALTER TABLE ONLY doc_link
    ADD CONSTRAINT doc_link_pkey PRIMARY KEY (id, path);


SET search_path = ws, pg_catalog;

--
-- Name: class_acl_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY class_acl
    ADD CONSTRAINT class_acl_pkey PRIMARY KEY (class_id, id);


--
-- Name: class_action_acl_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY class_action_acl
    ADD CONSTRAINT class_action_acl_pkey PRIMARY KEY (class_id, action_id, acl_id);


--
-- Name: class_action_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY class_action
    ADD CONSTRAINT class_action_pkey PRIMARY KEY (class_id, id);


--
-- Name: class_code_key; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY class
    ADD CONSTRAINT class_code_key UNIQUE (code);


--
-- Name: class_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY class
    ADD CONSTRAINT class_pkey PRIMARY KEY (id);


--
-- Name: class_status_action_acl_addon_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY class_status_action_acl_addon
    ADD CONSTRAINT class_status_action_acl_addon_pkey PRIMARY KEY (class_id, status_id, action_id, acl_id);


--
-- Name: class_status_action_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY class_status_action
    ADD CONSTRAINT class_status_action_pkey PRIMARY KEY (class_id, status_id, action_id);


--
-- Name: class_status_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY class_status
    ADD CONSTRAINT class_status_pkey PRIMARY KEY (class_id, id);


--
-- Name: dt_code_base_code_key; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY dt
    ADD CONSTRAINT dt_code_base_code_key UNIQUE (code, base_code);


--
-- Name: dt_facet_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY dt_facet
    ADD CONSTRAINT dt_facet_pkey PRIMARY KEY (code, facet_id);


--
-- Name: dt_part_id_code_key; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY dt_part
    ADD CONSTRAINT dt_part_id_code_key UNIQUE (dt_code, code);


--
-- Name: dt_part_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY dt_part
    ADD CONSTRAINT dt_part_pkey PRIMARY KEY (dt_code, part_id);


--
-- Name: dt_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY dt
    ADD CONSTRAINT dt_pkey PRIMARY KEY (code);


--
-- Name: error_data_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY error_data
    ADD CONSTRAINT error_data_pkey PRIMARY KEY (code);


--
-- Name: facet_dt_base_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY facet_dt_base
    ADD CONSTRAINT facet_dt_base_pkey PRIMARY KEY (id, base_code);


--
-- Name: facet_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY facet
    ADD CONSTRAINT facet_pkey PRIMARY KEY (id);


--
-- Name: method_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY method
    ADD CONSTRAINT method_pkey PRIMARY KEY (code);


--
-- Name: method_rv_format_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY method_rv_format
    ADD CONSTRAINT method_rv_format_pkey PRIMARY KEY (id);


--
-- Name: page_data_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY page_data
    ADD CONSTRAINT page_data_pkey PRIMARY KEY (code);


--
-- Name: page_data_uri_key; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY page_data
    ADD CONSTRAINT page_data_uri_key UNIQUE (uri);


--
-- Name: pkg_id_key; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY pkg
    ADD CONSTRAINT pkg_id_key UNIQUE (id);


--
-- Name: pkg_log_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY pkg_log
    ADD CONSTRAINT pkg_log_pkey PRIMARY KEY (id);


--
-- Name: pkg_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY pkg
    ADD CONSTRAINT pkg_pkey PRIMARY KEY (code);


--
-- Name: ref_item_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY ref_item
    ADD CONSTRAINT ref_item_pkey PRIMARY KEY (ref_id, id);


--
-- Name: ref_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY ref
    ADD CONSTRAINT ref_pkey PRIMARY KEY (id);


--
-- Name: server_pkey; Type: CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY server
    ADD CONSTRAINT server_pkey PRIMARY KEY (id);


SET search_path = wsd, pg_catalog;

--
-- Name: account_contact_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY account_contact
    ADD CONSTRAINT account_contact_pkey PRIMARY KEY (account_id, contact_type_id, value);


--
-- Name: account_login_key; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY account
    ADD CONSTRAINT account_login_key UNIQUE (login);


--
-- Name: account_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: account_role_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY account_role
    ADD CONSTRAINT account_role_pkey PRIMARY KEY (account_id, role_id);


--
-- Name: doc_diff_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY doc_diff
    ADD CONSTRAINT doc_diff_pkey PRIMARY KEY (id, revision);


--
-- Name: doc_group_code_key; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY doc_group
    ADD CONSTRAINT doc_group_code_key UNIQUE (code);


--
-- Name: doc_group_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY doc_group
    ADD CONSTRAINT doc_group_pkey PRIMARY KEY (id);


--
-- Name: doc_keyword_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY doc_keyword
    ADD CONSTRAINT doc_keyword_pkey PRIMARY KEY (id, name);


--
-- Name: doc_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY doc
    ADD CONSTRAINT doc_pkey PRIMARY KEY (id);


--
-- Name: event_notify_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY event_notify
    ADD CONSTRAINT event_notify_pkey PRIMARY KEY (event_id, account_id, role_id, cause_id);


--
-- Name: event_notify_spec_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY event_notify_spec
    ADD CONSTRAINT event_notify_spec_pkey PRIMARY KEY (event_id, account_id, role_id, spec_id);


--
-- Name: event_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_pkey PRIMARY KEY (id);


--
-- Name: event_role_signup_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY event_role_signup
    ADD CONSTRAINT event_role_signup_pkey PRIMARY KEY (role_id, kind_id, spec_id);


--
-- Name: event_signup_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY event_signup
    ADD CONSTRAINT event_signup_pkey PRIMARY KEY (account_id, role_id, kind_id, spec_id);


--
-- Name: event_signup_profile_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY event_signup_profile
    ADD CONSTRAINT event_signup_profile_pkey PRIMARY KEY (account_id, profile_id);


--
-- Name: event_spec_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY event_spec
    ADD CONSTRAINT event_spec_pkey PRIMARY KEY (event_id, spec_id);


--
-- Name: file_folder_format_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY file_folder_format
    ADD CONSTRAINT file_folder_format_pkey PRIMARY KEY (folder_code, format_code);


--
-- Name: file_folder_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY file_folder
    ADD CONSTRAINT file_folder_pkey PRIMARY KEY (code);


--
-- Name: file_link_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY file_link
    ADD CONSTRAINT file_link_pkey PRIMARY KEY (class_id, obj_id, folder_code, format_code, file_code, ver);


--
-- Name: file_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY file
    ADD CONSTRAINT file_pkey PRIMARY KEY (id);


--
-- Name: group_id_code_ukey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY doc
    ADD CONSTRAINT group_id_code_ukey UNIQUE (group_id, code);


--
-- Name: job_cron_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY job_cron
    ADD CONSTRAINT job_cron_pkey PRIMARY KEY (is_active);


--
-- Name: job_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY job
    ADD CONSTRAINT job_pkey PRIMARY KEY (id);


--
-- Name: job_todo_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY job_todo
    ADD CONSTRAINT job_todo_pkey PRIMARY KEY (id);


--
-- Name: pkg_script_protected_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY pkg_script_protected
    ADD CONSTRAINT pkg_script_protected_pkey PRIMARY KEY (pkg, code, ver);


--
-- Name: prop_group_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY prop_group
    ADD CONSTRAINT prop_group_pkey PRIMARY KEY (pogc);


--
-- Name: prop_id_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY prop_owner
    ADD CONSTRAINT prop_id_pkey PRIMARY KEY (pogc, poid);


--
-- Name: prop_value_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY prop_value
    ADD CONSTRAINT prop_value_pkey PRIMARY KEY (pogc, poid, code, valid_from);


--
-- Name: role_acl_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY role_acl
    ADD CONSTRAINT role_acl_pkey PRIMARY KEY (role_id, class_id, object_id);


--
-- Name: role_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- Name: role_team_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY role_team
    ADD CONSTRAINT role_team_pkey PRIMARY KEY (role_id);


--
-- Name: session_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY session
    ADD CONSTRAINT session_pkey PRIMARY KEY (id);


--
-- Name: session_sid_key; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY session
    ADD CONSTRAINT session_sid_key UNIQUE (sid);


--
-- Name: team_pkey; Type: CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY team
    ADD CONSTRAINT team_pkey PRIMARY KEY (id);


SET search_path = cfg, pg_catalog;

--
-- Name: prop_code; Type: INDEX; Schema: cfg; Owner: -
--

CREATE INDEX prop_code ON prop USING btree (lower((code)::text) text_pattern_ops);


SET search_path = ws, pg_catalog;

--
-- Name: method_code; Type: INDEX; Schema: ws; Owner: -
--

CREATE INDEX method_code ON method USING btree (lower((code)::text) text_pattern_ops);


SET search_path = wsd, pg_catalog;

--
-- Name: sid_deleted_at; Type: INDEX; Schema: wsd; Owner: -
--

CREATE INDEX sid_deleted_at ON session USING btree (sid, deleted_at);


SET search_path = i18n_def, pg_catalog;

--
-- Name: error_ins; Type: RULE; Schema: i18n_def; Owner: -
--

CREATE RULE error_ins AS ON INSERT TO error DO INSTEAD (INSERT INTO ws.error_data (code) VALUES (new.code); INSERT INTO error_message (code, id_count, message) VALUES (new.code, new.id_count, new.message); );


--
-- Name: page_ins; Type: RULE; Schema: i18n_def; Owner: -
--

CREATE RULE page_ins AS ON INSERT TO page DO INSTEAD (INSERT INTO ws.page_data (code, up_code, class_id, action_id, group_id, sort, uri, tmpl, id_fixed, id_session, is_hidden, target, uri_re, uri_fmt, pkg) VALUES (new.code, new.up_code, new.class_id, new.action_id, new.group_id, new.sort, new.uri, new.tmpl, new.id_fixed, new.id_session, DEFAULT, DEFAULT, new.uri_re, new.uri_fmt, COALESCE(new.pkg, (ws.pg_cs())::text)); UPDATE ws.page_data SET is_hidden = COALESCE(new.is_hidden, page_data.is_hidden), target = COALESCE(new.target, page_data.target) WHERE ((page_data.code)::text = (new.code)::text); INSERT INTO page_name (code, name) VALUES (new.code, new.name); );


SET search_path = i18n_en, pg_catalog;

--
-- Name: error_ins; Type: RULE; Schema: i18n_en; Owner: -
--

CREATE RULE error_ins AS ON INSERT TO error DO INSTEAD (INSERT INTO ws.error_data (code) VALUES (new.code); INSERT INTO error_message (code, id_count, message) VALUES (new.code, new.id_count, new.message); );


--
-- Name: page_ins; Type: RULE; Schema: i18n_en; Owner: -
--

CREATE RULE page_ins AS ON INSERT TO page DO INSTEAD (INSERT INTO ws.page_data (code, up_code, class_id, action_id, group_id, sort, uri, tmpl, id_fixed, id_session, is_hidden, target, uri_re, uri_fmt, pkg) VALUES (new.code, new.up_code, new.class_id, new.action_id, new.group_id, new.sort, new.uri, new.tmpl, new.id_fixed, new.id_session, DEFAULT, DEFAULT, new.uri_re, new.uri_fmt, COALESCE(new.pkg, (ws.pg_cs())::text)); UPDATE ws.page_data SET is_hidden = COALESCE(new.is_hidden, page_data.is_hidden), target = COALESCE(new.target, page_data.target) WHERE ((page_data.code)::text = (new.code)::text); INSERT INTO page_name (code, name) VALUES (new.code, new.name); );


SET search_path = cfg, pg_catalog;

--
-- Name: prop_is_mask; Type: TRIGGER; Schema: cfg; Owner: -
--

CREATE TRIGGER prop_is_mask BEFORE INSERT OR UPDATE ON prop FOR EACH ROW EXECUTE PROCEDURE prop_calc_is_mask();


SET search_path = ws, pg_catalog;

--
-- Name: insupd; Type: TRIGGER; Schema: ws; Owner: -
--

CREATE TRIGGER insupd BEFORE INSERT OR UPDATE ON dt FOR EACH ROW EXECUTE PROCEDURE dt_insupd_trigger();


--
-- Name: insupd; Type: TRIGGER; Schema: ws; Owner: -
--

CREATE TRIGGER insupd BEFORE INSERT OR UPDATE ON dt_part FOR EACH ROW EXECUTE PROCEDURE dt_part_insupd_trigger();


--
-- Name: insupd; Type: TRIGGER; Schema: ws; Owner: -
--

CREATE TRIGGER insupd BEFORE INSERT OR UPDATE ON dt_facet FOR EACH ROW EXECUTE PROCEDURE dt_facet_insupd_trigger();


--
-- Name: insupd; Type: TRIGGER; Schema: ws; Owner: -
--

CREATE TRIGGER insupd BEFORE INSERT OR UPDATE ON page_data FOR EACH ROW EXECUTE PROCEDURE page_insupd_trigger();


--
-- Name: insupd; Type: TRIGGER; Schema: ws; Owner: -
--

CREATE TRIGGER insupd BEFORE INSERT OR UPDATE ON method FOR EACH ROW EXECUTE PROCEDURE method_insupd_trigger();


SET search_path = wsd, pg_catalog;

--
-- Name: handler_id_update_forbidden; Type: TRIGGER; Schema: wsd; Owner: -
--

CREATE TRIGGER handler_id_update_forbidden AFTER UPDATE ON job FOR EACH ROW WHEN ((old.handler_id <> new.handler_id)) EXECUTE PROCEDURE ws.tr_exception('handler_id update is forbidden');


--
-- Name: handler_id_update_forbidden; Type: TRIGGER; Schema: wsd; Owner: -
--

CREATE TRIGGER handler_id_update_forbidden AFTER UPDATE ON job_todo FOR EACH ROW WHEN ((old.handler_id <> new.handler_id)) EXECUTE PROCEDURE ws.tr_exception('handler_id update is forbidden');


--
-- Name: insupd; Type: TRIGGER; Schema: wsd; Owner: -
--

CREATE TRIGGER insupd BEFORE INSERT OR UPDATE ON prop_value FOR EACH ROW EXECUTE PROCEDURE cfg.prop_value_insupd_trigger();


--
-- Name: notify_oninsert; Type: TRIGGER; Schema: wsd; Owner: -
--

CREATE TRIGGER notify_oninsert AFTER INSERT ON job FOR EACH ROW WHEN ((new.status_id = job.const_status_id_ready())) EXECUTE PROCEDURE ws.tr_notify('job_event');


--
-- Name: notify_onupdate; Type: TRIGGER; Schema: wsd; Owner: -
--

CREATE TRIGGER notify_onupdate AFTER UPDATE ON job FOR EACH ROW WHEN (((old.status_id <> new.status_id) AND (new.status_id = ANY (ARRAY[job.const_status_id_ready(), job.const_status_id_again()])))) EXECUTE PROCEDURE ws.tr_notify('job_event');


SET search_path = ev, pg_catalog;

--
-- Name: kind_signature_id_fkey; Type: FK CONSTRAINT; Schema: ev; Owner: -
--

ALTER TABLE ONLY kind
    ADD CONSTRAINT kind_signature_id_fkey FOREIGN KEY (signature_id) REFERENCES signature(id);


SET search_path = i18n_def, pg_catalog;

--
-- Name: error_message_code_fkey; Type: FK CONSTRAINT; Schema: i18n_def; Owner: -
--

ALTER TABLE ONLY error_message
    ADD CONSTRAINT error_message_code_fkey FOREIGN KEY (code) REFERENCES ws.error_data(code) ON DELETE CASCADE;


--
-- Name: page_name_code_fkey; Type: FK CONSTRAINT; Schema: i18n_def; Owner: -
--

ALTER TABLE ONLY page_name
    ADD CONSTRAINT page_name_code_fkey FOREIGN KEY (code) REFERENCES ws.page_data(code) ON DELETE CASCADE;


SET search_path = i18n_en, pg_catalog;

--
-- Name: error_message_code_fkey; Type: FK CONSTRAINT; Schema: i18n_en; Owner: -
--

ALTER TABLE ONLY error_message
    ADD CONSTRAINT error_message_code_fkey FOREIGN KEY (code) REFERENCES ws.error_data(code) ON DELETE CASCADE;


--
-- Name: page_name_code_fkey; Type: FK CONSTRAINT; Schema: i18n_en; Owner: -
--

ALTER TABLE ONLY page_name
    ADD CONSTRAINT page_name_code_fkey FOREIGN KEY (code) REFERENCES ws.page_data(code) ON DELETE CASCADE;


SET search_path = job, pg_catalog;

--
-- Name: handler_arg_date2_type_fkey; Type: FK CONSTRAINT; Schema: job; Owner: -
--

ALTER TABLE ONLY handler
    ADD CONSTRAINT handler_arg_date2_type_fkey FOREIGN KEY (arg_date2_type) REFERENCES arg_type(id);


--
-- Name: handler_arg_date_type_fkey; Type: FK CONSTRAINT; Schema: job; Owner: -
--

ALTER TABLE ONLY handler
    ADD CONSTRAINT handler_arg_date_type_fkey FOREIGN KEY (arg_date_type) REFERENCES arg_type(id);


--
-- Name: handler_arg_id2_type_fkey; Type: FK CONSTRAINT; Schema: job; Owner: -
--

ALTER TABLE ONLY handler
    ADD CONSTRAINT handler_arg_id2_type_fkey FOREIGN KEY (arg_id2_type) REFERENCES arg_type(id);


--
-- Name: handler_arg_id3_type_fkey; Type: FK CONSTRAINT; Schema: job; Owner: -
--

ALTER TABLE ONLY handler
    ADD CONSTRAINT handler_arg_id3_type_fkey FOREIGN KEY (arg_id3_type) REFERENCES arg_type(id);


--
-- Name: handler_arg_id_type_fkey; Type: FK CONSTRAINT; Schema: job; Owner: -
--

ALTER TABLE ONLY handler
    ADD CONSTRAINT handler_arg_id_type_fkey FOREIGN KEY (arg_id_type) REFERENCES arg_type(id);


--
-- Name: handler_arg_more_type_fkey; Type: FK CONSTRAINT; Schema: job; Owner: -
--

ALTER TABLE ONLY handler
    ADD CONSTRAINT handler_arg_more_type_fkey FOREIGN KEY (arg_more_type) REFERENCES arg_type(id);


--
-- Name: handler_arg_num_type_fkey; Type: FK CONSTRAINT; Schema: job; Owner: -
--

ALTER TABLE ONLY handler
    ADD CONSTRAINT handler_arg_num_type_fkey FOREIGN KEY (arg_num_type) REFERENCES arg_type(id);


--
-- Name: handler_def_status_id_fkey; Type: FK CONSTRAINT; Schema: job; Owner: -
--

ALTER TABLE ONLY handler
    ADD CONSTRAINT handler_def_status_id_fkey FOREIGN KEY (def_status_id) REFERENCES status(id);


--
-- Name: handler_next_handler_id_fkey; Type: FK CONSTRAINT; Schema: job; Owner: -
--

ALTER TABLE ONLY handler
    ADD CONSTRAINT handler_next_handler_id_fkey FOREIGN KEY (next_handler_id) REFERENCES handler(id);


--
-- Name: handler_pkg_fkey; Type: FK CONSTRAINT; Schema: job; Owner: -
--

ALTER TABLE ONLY handler
    ADD CONSTRAINT handler_pkg_fkey FOREIGN KEY (pkg) REFERENCES ws.pkg(code);


SET search_path = wiki, pg_catalog;

--
-- Name: doc_extra_id_fkey; Type: FK CONSTRAINT; Schema: wiki; Owner: -
--

ALTER TABLE ONLY doc_extra
    ADD CONSTRAINT doc_extra_id_fkey FOREIGN KEY (id) REFERENCES wsd.doc(id);


--
-- Name: doc_link_id_fkey; Type: FK CONSTRAINT; Schema: wiki; Owner: -
--

ALTER TABLE ONLY doc_link
    ADD CONSTRAINT doc_link_id_fkey FOREIGN KEY (id) REFERENCES wsd.doc(id);


--
-- Name: doc_link_link_id_fkey; Type: FK CONSTRAINT; Schema: wiki; Owner: -
--

ALTER TABLE ONLY doc_link
    ADD CONSTRAINT doc_link_link_id_fkey FOREIGN KEY (link_id) REFERENCES wsd.doc(id);


SET search_path = ws, pg_catalog;

--
-- Name: class_acl_class_id_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY class_acl
    ADD CONSTRAINT class_acl_class_id_fkey FOREIGN KEY (class_id) REFERENCES class(id);


--
-- Name: class_action_acl_class_id_acl_id_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY class_action_acl
    ADD CONSTRAINT class_action_acl_class_id_acl_id_fkey FOREIGN KEY (class_id, acl_id) REFERENCES class_acl(class_id, id);


--
-- Name: class_action_acl_class_id_action_id_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY class_action_acl
    ADD CONSTRAINT class_action_acl_class_id_action_id_fkey FOREIGN KEY (class_id, action_id) REFERENCES class_action(class_id, id);


--
-- Name: class_action_class_id_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY class_action
    ADD CONSTRAINT class_action_class_id_fkey FOREIGN KEY (class_id) REFERENCES class(id);


--
-- Name: class_status_action_acl_addon_class_id_acl_id_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY class_status_action_acl_addon
    ADD CONSTRAINT class_status_action_acl_addon_class_id_acl_id_fkey FOREIGN KEY (class_id, acl_id) REFERENCES class_acl(class_id, id);


--
-- Name: class_status_action_acl_addon_class_id_action_id_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY class_status_action_acl_addon
    ADD CONSTRAINT class_status_action_acl_addon_class_id_action_id_fkey FOREIGN KEY (class_id, action_id) REFERENCES class_action(class_id, id);


--
-- Name: class_status_action_acl_addon_class_id_status_id_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY class_status_action_acl_addon
    ADD CONSTRAINT class_status_action_acl_addon_class_id_status_id_fkey FOREIGN KEY (class_id, status_id) REFERENCES class_status(class_id, id);


--
-- Name: class_status_action_class_id_action_id_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY class_status_action
    ADD CONSTRAINT class_status_action_class_id_action_id_fkey FOREIGN KEY (class_id, action_id) REFERENCES class_action(class_id, id);


--
-- Name: class_status_action_class_id_status_id_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY class_status_action
    ADD CONSTRAINT class_status_action_class_id_status_id_fkey FOREIGN KEY (class_id, status_id) REFERENCES class_status(class_id, id);


--
-- Name: class_status_class_id_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY class_status
    ADD CONSTRAINT class_status_class_id_fkey FOREIGN KEY (class_id) REFERENCES class(id);


--
-- Name: dt_base_code_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY dt
    ADD CONSTRAINT dt_base_code_fkey FOREIGN KEY (base_code) REFERENCES dt(code);


--
-- Name: dt_facet_fkey_dt; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY dt_facet
    ADD CONSTRAINT dt_facet_fkey_dt FOREIGN KEY (code, base_code) REFERENCES dt(code, base_code);


--
-- Name: dt_facet_fkey_facet_dt_base; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY dt_facet
    ADD CONSTRAINT dt_facet_fkey_facet_dt_base FOREIGN KEY (facet_id, base_code) REFERENCES facet_dt_base(id, base_code);


--
-- Name: dt_parent_code_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY dt
    ADD CONSTRAINT dt_parent_code_fkey FOREIGN KEY (parent_code) REFERENCES dt(code);


--
-- Name: dt_part_base_code_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY dt_part
    ADD CONSTRAINT dt_part_base_code_fkey FOREIGN KEY (base_code) REFERENCES dt(code);


--
-- Name: dt_part_dt_code_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY dt_part
    ADD CONSTRAINT dt_part_dt_code_fkey FOREIGN KEY (dt_code) REFERENCES dt(code);


--
-- Name: dt_part_parent_code_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY dt_part
    ADD CONSTRAINT dt_part_parent_code_fkey FOREIGN KEY (parent_code) REFERENCES dt(code);


--
-- Name: facet_dt_base_base_code_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY facet_dt_base
    ADD CONSTRAINT facet_dt_base_base_code_fkey FOREIGN KEY (base_code) REFERENCES dt(code);


--
-- Name: facet_dt_base_id_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY facet_dt_base
    ADD CONSTRAINT facet_dt_base_id_fkey FOREIGN KEY (id) REFERENCES facet(id);


--
-- Name: method_arg_dt_code_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY method
    ADD CONSTRAINT method_arg_dt_code_fkey FOREIGN KEY (arg_dt_code) REFERENCES dt(code);


--
-- Name: method_class_id_action_id_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY method
    ADD CONSTRAINT method_class_id_action_id_fkey FOREIGN KEY (class_id, action_id) REFERENCES class_action(class_id, id);


--
-- Name: method_rv_dt_code_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY method
    ADD CONSTRAINT method_rv_dt_code_fkey FOREIGN KEY (rv_dt_code) REFERENCES dt(code);


--
-- Name: method_rvf_id_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY method
    ADD CONSTRAINT method_rvf_id_fkey FOREIGN KEY (rvf_id) REFERENCES method_rv_format(id);


--
-- Name: page_data_group_id_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY page_data
    ADD CONSTRAINT page_data_group_id_fkey FOREIGN KEY (group_id) REFERENCES i18n_def.page_group(id);


--
-- Name: page_data_up_code_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY page_data
    ADD CONSTRAINT page_data_up_code_fkey FOREIGN KEY (up_code) REFERENCES page_data(code);


--
-- Name: page_fkey_class_action; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY page_data
    ADD CONSTRAINT page_fkey_class_action FOREIGN KEY (class_id, action_id) REFERENCES class_action(class_id, id);


--
-- Name: ref_class_id_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY ref
    ADD CONSTRAINT ref_class_id_fkey FOREIGN KEY (class_id) REFERENCES class(id);


--
-- Name: ref_item_ref_id_fkey; Type: FK CONSTRAINT; Schema: ws; Owner: -
--

ALTER TABLE ONLY ref_item
    ADD CONSTRAINT ref_item_ref_id_fkey FOREIGN KEY (ref_id) REFERENCES ref(id);


SET search_path = wsd, pg_catalog;

--
-- Name: account_contact_account_id_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY account_contact
    ADD CONSTRAINT account_contact_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(id);


--
-- Name: account_def_role_id_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY account
    ADD CONSTRAINT account_def_role_id_fkey FOREIGN KEY (def_role_id) REFERENCES role(id);


--
-- Name: account_role_account_id_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY account_role
    ADD CONSTRAINT account_role_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(id);


--
-- Name: account_role_role_id_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY account_role
    ADD CONSTRAINT account_role_role_id_fkey FOREIGN KEY (role_id) REFERENCES role(id);


--
-- Name: doc_created_by_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY doc
    ADD CONSTRAINT doc_created_by_fkey FOREIGN KEY (created_by) REFERENCES account(id);


--
-- Name: doc_diff_id_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY doc_diff
    ADD CONSTRAINT doc_diff_id_fkey FOREIGN KEY (id) REFERENCES doc(id);


--
-- Name: doc_diff_updated_by_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY doc_diff
    ADD CONSTRAINT doc_diff_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES account(id);


--
-- Name: doc_group_id_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY doc
    ADD CONSTRAINT doc_group_id_fkey FOREIGN KEY (group_id) REFERENCES doc_group(id);


--
-- Name: doc_keyword_id_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY doc_keyword
    ADD CONSTRAINT doc_keyword_id_fkey FOREIGN KEY (id) REFERENCES doc(id);


--
-- Name: doc_up_id_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY doc
    ADD CONSTRAINT doc_up_id_fkey FOREIGN KEY (up_id) REFERENCES doc(id);


--
-- Name: doc_updated_by_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY doc
    ADD CONSTRAINT doc_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES account(id);


--
-- Name: event_fk_status_id; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_fk_status_id FOREIGN KEY (status_id) REFERENCES ev.status(id);


--
-- Name: event_notify_event_id_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY event_notify
    ADD CONSTRAINT event_notify_event_id_fkey FOREIGN KEY (event_id) REFERENCES event(id);


--
-- Name: event_signup_account_id_profile_id_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY event_signup
    ADD CONSTRAINT event_signup_account_id_profile_id_fkey FOREIGN KEY (account_id, profile_id) REFERENCES event_signup_profile(account_id, profile_id);


--
-- Name: event_signup_role_id_kind_id_spec_id_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY event_signup
    ADD CONSTRAINT event_signup_role_id_kind_id_spec_id_fkey FOREIGN KEY (role_id, kind_id, spec_id) REFERENCES event_role_signup(role_id, kind_id, spec_id);


--
-- Name: file_folder_format_folder_code_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY file_folder_format
    ADD CONSTRAINT file_folder_format_folder_code_fkey FOREIGN KEY (folder_code) REFERENCES file_folder(code);


--
-- Name: file_link_folder_code_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY file_link
    ADD CONSTRAINT file_link_folder_code_fkey FOREIGN KEY (folder_code) REFERENCES file_folder(code);


--
-- Name: file_link_id_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY file_link
    ADD CONSTRAINT file_link_id_fkey FOREIGN KEY (id) REFERENCES file(id);


--
-- Name: file_link_up_id_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY file_link
    ADD CONSTRAINT file_link_up_id_fkey FOREIGN KEY (up_id) REFERENCES file(id);


--
-- Name: fs_fk_format_code; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY file_folder_format
    ADD CONSTRAINT fs_fk_format_code FOREIGN KEY (format_code) REFERENCES fs.file_format(code);


--
-- Name: fs_fk_format_code; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY file
    ADD CONSTRAINT fs_fk_format_code FOREIGN KEY (format_code) REFERENCES fs.file_format(code);


--
-- Name: fs_fk_format_code; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY file_link
    ADD CONSTRAINT fs_fk_format_code FOREIGN KEY (format_code) REFERENCES fs.file_format(code);


--
-- Name: job_fk_status_id; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY job
    ADD CONSTRAINT job_fk_status_id FOREIGN KEY (status_id) REFERENCES job.status(id);


--
-- Name: job_fk_status_id; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY job_todo
    ADD CONSTRAINT job_fk_status_id FOREIGN KEY (status_id) REFERENCES job.status(id);


--
-- Name: prop_owner_pogc_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY prop_owner
    ADD CONSTRAINT prop_owner_pogc_fkey FOREIGN KEY (pogc) REFERENCES prop_group(pogc);


--
-- Name: prop_value_pogc_poid_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY prop_value
    ADD CONSTRAINT prop_value_pogc_poid_fkey FOREIGN KEY (pogc, poid) REFERENCES prop_owner(pogc, poid);


--
-- Name: role_acl_role_id_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY role_acl
    ADD CONSTRAINT role_acl_role_id_fkey FOREIGN KEY (role_id) REFERENCES role(id);


--
-- Name: role_team_role_id_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY role_team
    ADD CONSTRAINT role_team_role_id_fkey FOREIGN KEY (role_id) REFERENCES role(id);


--
-- Name: role_team_team_id_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY role_team
    ADD CONSTRAINT role_team_team_id_fkey FOREIGN KEY (team_id) REFERENCES team(id);


--
-- Name: session_account_id_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY session
    ADD CONSTRAINT session_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(id);


--
-- Name: session_role_id_fkey; Type: FK CONSTRAINT; Schema: wsd; Owner: -
--

ALTER TABLE ONLY session
    ADD CONSTRAINT session_role_id_fkey FOREIGN KEY (role_id) REFERENCES role(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

