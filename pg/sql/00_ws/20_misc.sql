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

    Вспомогательные таблицы
*/

/* ------------------------------------------------------------------------- */
CREATE TABLE method_rv_format (
  id         d_id32   PRIMARY KEY
, name       text     NOT NULL
);
SELECT pg_c('r', 'method_rv_format', 'Формат результатов метода')
, pg_c('c', 'method_rv_format.id',   'ID формата')
, pg_c('c', 'method_rv_format.name', 'Название формата')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE server (
  id         d_id32   PRIMARY KEY
, uri        text     NOT NULL
, name       text     NOT NULL
);
SELECT pg_c('r', 'server', 'Сервер горизонтального масштабирования (reserved)')
, pg_c('c', 'server.id',   'ID сервера')
, pg_c('c', 'server.uri',  'Адрес сервера')
, pg_c('c', 'server.name', 'Название сервера')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE error_data (
  code        d_errcode PRIMARY KEY
);
SELECT pg_c('r', 'error_data', 'Коды ошибок (без строк локализации)')
, pg_c('c', 'error_data.code',   'Код ошибки')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE i18n_def.page_group (
  id         d_id32   PRIMARY KEY
, name       text     NOT NULL
);
SELECT pg_c('r', 'i18n_def.page_group', 'Группа страниц для меню')
, pg_c('c', 'i18n_def.page_group.id',   'ID группы')
, pg_c('c', 'i18n_def.page_group.name', 'Название')
;
