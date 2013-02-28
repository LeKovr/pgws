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

    Таблицы блока управления свойствами
*/

/* ------------------------------------------------------------------------- */
CREATE TABLE prop (
  code        d_prop_code PRIMARY KEY
, pkg         TEXT NOT NULL DEFAULT ws.pg_cs()
, pogc_list   d_texta NOT NULL
, is_mask     BOOL NOT NULL -- рассчитывается RULE
, def_value   TEXT
, name        TEXT NOT NULL
, value_fmt   TEXT
, anno        TEXT
);

SELECT pg_c('r', 'prop',        'Справочник свойств')
, pg_c('c', 'prop.code',        'Код свойства')
, pg_c('c', 'prop.pkg',         'Пакет, в котором добавлено свойство')
, pg_c('c', 'prop.pogc_list',   'Массив кодов разрешенных групп (prop_group)')
, pg_c('c', 'prop.is_mask',     'Свойство не атомарно')
, pg_c('c', 'prop.def_value',   'Значение по умолчанию')
, pg_c('c', 'prop.name',        'Название')
, pg_c('c', 'prop.value_fmt',   'Строка формата для вывода значения')
, pg_c('c', 'prop.anno',        'Аннотация')
;

-- Индекс для автокомплита и поиска
CREATE INDEX prop_code ON prop USING btree(lower(code)  text_pattern_ops);
