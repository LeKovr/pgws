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

    Справочники
*/

/* ------------------------------------------------------------------------- */
CREATE TABLE ref_data (
  code            d_code PRIMARY KEY
, is_dt_vary      bool NOT NULL DEFAULT FALSE
, acls            d_acls
, method_code     d_code
, acls_upd        d_acls DEFAULT ws.const_ref_acls_internal()
, method_code_upd d_code
, pkg             d_code  NOT NULL
);
SELECT pg_c('r', 'ref_data',            'Данные справочников')
, pg_c('c', 'ref_data.code',            'Код')
, pg_c('c', 'ref_data.is_dt_vary',      'Тип структуры справочника не совпадает с i18n_def.ref_item')
, pg_c('c', 'ref_data.acls',            'Список ACL чтения (если есть ограничения)')
, pg_c('c', 'ref_data.method_code',     'Код метода доступа к справочнику')
, pg_c('c', 'ref_data.acls_upd',        'Список ACL изменения (если разрешена)')
, pg_c('c', 'ref_data.method_code_upd', 'Код метода изменения справочника')
, pg_c('c', 'ref_data.pkg',             'Пакет, создавший справочник')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE ref_item_data (
  code        ws.d_code REFERENCES ref_data ON DELETE CASCADE
, item_code   TEXT 
, group_id    ws.d_id32 NOT NULL DEFAULT 1
, code_addon  TEXT
, CONSTRAINT  ref_item_data_pkey PRIMARY KEY (code, item_code)
);
SELECT pg_c('r', 'ref_item_data', 'Позиция справочника')
, pg_c('c', 'ref_item_data.code',        'Код справочника')
, pg_c('c', 'ref_item_data.item_code',   'Код позиции')
, pg_c('c', 'ref_item_data.group_id',    'Внутренний ID группы')
, pg_c('c', 'ref_item_data.code_addon',  'Дополнительный код (опция)')
;
