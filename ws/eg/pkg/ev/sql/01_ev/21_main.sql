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

    Основные таблицы пакета
*/

/* ------------------------------------------------------------------------- */

CREATE TABLE kind_group (
  id              d_id32    PRIMARY KEY
, sort            ws.d_sort NOT NULL
, name            d_string  NOT NULL
, anno            d_text    NOT NULL
);
SELECT pg_c('r', 'kind_group',  'Группа вида события')
, pg_c('c', 'kind_group.id',    'ID группы')
, pg_c('c', 'kind_group.sort',  'Сортировка')
, pg_c('c', 'kind_group.name',  'Название')
, pg_c('c', 'kind_group.anno',  'Аннотация')
;
/* ------------------------------------------------------------------------- */
CREATE TABLE status (
  id              d_id32    PRIMARY KEY
, name            d_string  NOT NULL
);
SELECT pg_c('r', 'status',  'Статус события')
, pg_c('c', 'status.id',    'ID группы')
, pg_c('c', 'status.name',  'Название')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE form (
  code            d_code    PRIMARY KEY
, sort            ws.d_sort NOT NULL
, is_email        BOOL      NOT NULL DEFAULT TRUE
, name            d_string  NOT NULL
);
SELECT pg_c('r', 'form',    'Формат уведомления')
, pg_c('c', 'form.code',    'Код формата')
, pg_c('c', 'form.sort',    'Сортировка')
, pg_c('c', 'form.is_email','Отправляется по электронной почте')
, pg_c('c', 'form.name',    'Название')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE signature (
  id              d_id32    PRIMARY KEY
, name            d_string  NOT NULL
, email           d_string  NOT NULL
, tmpl            ws.d_path NOT NULL
);
SELECT pg_c('r', 'signature',  'Подпись уведомлений')
, pg_c('c', 'signature.id',    'ID подписи')
, pg_c('c', 'signature.name',  'Имя отправителя')
, pg_c('c', 'signature.email', 'Email отправителя')
, pg_c('c', 'signature.tmpl',  'Файл шаблона')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE kind (
  id              d_id32    PRIMARY KEY
, group_id        d_id32    NOT NULL
, class_id        d_id32    NOT NULL
, def_prio        d_id32    NOT NULL
, keep_days       d_id32    NOT NULL DEFAULT 0
, has_spec        BOOL      NOT NULL DEFAULT FALSE
, pkg             TEXT      NOT NULL DEFAULT ws.pg_cs()
, signature_id    d_id32    /*NOT NULL */ REFERENCES ev.signature
, tmpl            d_path    NOT NULL
, form_codes      d_codea   NOT NULL
, name            d_string  NOT NULL
, name_fmt        d_string
, name_count       d_cnt     NOT NULL DEFAULT 0
, spec_name       d_string
, anno            d_text    NOT NULL
);
SELECT pg_c('r', 'kind',          'Вид события')
, pg_c('c', 'kind.id',            'ID вида')
, pg_c('c', 'kind.group_id',      'ID группы вида')
, pg_c('c', 'kind.class_id',      'ID класса')
, pg_c('c', 'kind.def_prio',      'Приоритет по умолчанию')
, pg_c('c', 'kind.keep_days',     'Кол-во дней хранения уведомления о событии')
, pg_c('c', 'kind.has_spec',      'Есть спецификация')
, pg_c('c', 'kind.pkg',           'Пакет')
, pg_c('c', 'kind.signature_id',  'ID подписи')
, pg_c('c', 'kind.tmpl',          'Файл шаблона')
, pg_c('c', 'kind.form_codes',    'Массив кодов допустимых форматов')
, pg_c('c', 'kind.name',          'Название')
, pg_c('c', 'kind.name_fmt',      'Строка формата названия')
, pg_c('c', 'kind.name_count',     'Кол-во аргументов строки формата')
, pg_c('c', 'kind.spec_name',     'Название спецификации (если она есть)')
, pg_c('c', 'kind.anno',          'Аннотация')
;

CREATE TABLE role (
	id ws.d_id32,
	title text,
	CONSTRAINT role_pkey PRIMARY KEY ( id )
);
SELECT pg_c( 'r', 'role', 'Эмуляция системы ролей для модуля ev' )
, pg_c('c', 'role.id',    'ID роли')
, pg_c('c', 'role.title', 'Название роли')
;

CREATE TABLE account_role (
	account_id ws.d_id32,
	role_id    ws.d_id32
);
SELECT ws.pg_c( 'r', 'account_role', 'Эмуляция системы ролей для модуля ev' )
, pg_c('c', 'account_role.account_id', 'ID аккаунта')
, pg_c('c', 'account_role.role_id',    'ID роли')
;
