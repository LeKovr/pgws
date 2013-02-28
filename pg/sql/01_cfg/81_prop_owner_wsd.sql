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

    Реестр свойств.
*/

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.pkg_script_protected (pkg, code, ver) VALUES (:'PKG', :'FILE', :'VER');

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.prop_group (pogc, sort, name) VALUES
  ('fcgi',  3, 'Демон FastCGI')
, ('tm',    4, 'Демон TM')
, ('be',    2, 'Бэкенд')
, ('fe',    1, 'Фронтенд')
, ('db',    5, 'БД')
;
INSERT INTO wsd.prop_group (pogc, sort, is_id_required, name) VALUES
  ('cache', 6, FALSE, 'Кэш')
;

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.prop_owner (pogc, poid, sort, name) VALUES
  ('fcgi',  1,  1,  'Первичный Демон FastCGI')
, ('tm',    1,  1,  'Первичный Демон TM')
, ('be',    1,  1,  'Первичный Бэкенд')
, ('fe',    1,  1,  'Первичный Фронтенд')
, ('db',    1,  1,  'БД')
, ('cache', 1,  1,  'нет')
, ('cache', 2,  2,  'метаданные системы')
, ('cache', 3,  3,  'Анти-DoS')
, ('cache', 4,  4,  'Данные сессий')
, ('cache', 5,  5,  'Большие объекты')
;
