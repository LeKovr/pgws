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

    Вспомогательные функции, использующие i18n
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION date_info(
  a_date DATE DEFAULT CURRENT_DATE
, a_offset INTEGER DEFAULT 0
) RETURNS t_date_info IMMUTABLE LANGUAGE 'plpgsql' AS
$_$
  -- a_date:   дата
  -- a_offset: смещение
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
$_$;
SELECT pg_c('f', 'date_info', 'Атрибуты заданной даты');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION month_info(a_date DATE DEFAULT CURRENT_DATE) RETURNS t_month_info IMMUTABLE LANGUAGE 'sql' AS
$_$
  -- a_date:  дата
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
SELECT pg_c('f', 'month_info', 'Атрибуты месяца заданной даты');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION year_months(
  a_date     DATE DEFAULT CURRENT_DATE
, a_date_min DATE DEFAULT NULL
, a_date_max DATE DEFAULT NULL
) RETURNS SETOF t_month_info IMMUTABLE LANGUAGE 'plpgsql' AS
$_$
  -- Список атрибутов месяцев года заданной даты
  -- a_date:      Дата
  -- a_date_min:  Дата, месяцы раньше которой не включать
  -- a_date_max:  Дата, месяцы позднее которой не включать
  DECLARE
    v_i         INTEGER;
    v_date      DATE;
    v_date_curr DATE;
    r           ws.t_month_info;
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
$_$;
SELECT pg_c('f', 'year_months', 'Список атрибутов месяцев года заданной даты');
