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

*/
-- 51_i18n.sql - Функции поддержки интернационализации
/* ------------------------------------------------------------------------- */
\qecho '-- FD: pg:ws:51_i18n.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION i18n_def.date_name (a_date DATE) RETURNS TEXT IMMUTABLE LANGUAGE 'plpgsql' AS
$_$  -- FD: pg:ws:51_i18n.sql / 27 --
  DECLARE
    m_names TEXT := 'января февраля марта апреля мая июня июля августа сентября октября ноября декабря';
  BEGIN
    RETURN date_part('day', a_date)
          ||' '||split_part(m_names, ' '::text, date_part('month', a_date)::int)
          ||' '||date_part('year', a_date)
    ;
  END
$_$;
SELECT pg_c('f', 'i18n_def.date_name', 'Название даты вида "1 января 2007"');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION i18n_def.date_name_doc (a_date DATE) RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$  -- FD: pg:ws:51_i18n.sql / 41 --
  SELECT CASE WHEN date_part('day', $1) < 10 THEN '0' ELSE '' END || date_name($1)
$_$;
SELECT pg_c('f', 'i18n_def.date_name_doc', 'Название даты вида "01 января 2007"');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION i18n_def.month_name (a_date DATE) RETURNS TEXT IMMUTABLE LANGUAGE 'plpgsql' AS
$_$  -- FD: pg:ws:51_i18n.sql / 48 --
  DECLARE
    m_names TEXT := 'январь февраль март апрель май июнь июль август сентябрь октябрь ноябрь декабрь';
  BEGIN
    RETURN split_part(m_names, ' '::text, date_part('month', a_date)::int)
          ||' '||date_part('year', a_date)
    ;
  END
$_$;
SELECT pg_c('f', 'i18n_def.month_name', 'Название месяца вида "январь 2007"');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION i18n_def.month_amount_name(a_id INTEGER) RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$  -- FD: pg:ws:51_i18n.sql / 61 --
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
SELECT pg_c('f', 'i18n_def.month_amount_name', 'Название периода из заданного числа месяцев (252 max)');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION i18n_def.amount2words (source DECIMAL, up_mode INTEGER) RETURNS TEXT IMMUTABLE LANGUAGE 'plpgsql' AS
$_$  -- FD: pg:ws:51_i18n.sql / 76 --
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
$_$;
SELECT pg_c('f', 'i18n_def.amount2words', 'Сумма прописью в рублях и копейках');

/* ------------------------------------------------------------------------- */
\qecho '-- FD: pg:ws:51_i18n.sql / 190 --'
