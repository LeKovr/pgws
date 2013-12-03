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

    Представления поддержки интернационализации
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW i18n_def.page AS SELECT
  d.*
, n.name
  FROM ws.page_data d
    JOIN i18n_def.page_name n
    USING (code)
;
SELECT pg_c('v', 'i18n_def.page', 'Страница сайта');

/* ------------------------------------------------------------------------- */
ALTER VIEW i18n_def.page ALTER COLUMN target SET DEFAULT '';

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE RULE page_ins AS ON INSERT TO i18n_def.page
  DO INSTEAD (
  INSERT INTO ws.page_data
    (code, up_code, class_id, action_id, group_id, sort, uri, tmpl, id_fixed, id_session, is_hidden, target, uri_re, uri_fmt, pkg)
    VALUES (
      NEW.code
    , NEW.up_code
    , NEW.class_id
    , NEW.action_id
    , NEW.group_id
    , NEW.sort
    , NEW.uri
    , NEW.tmpl
    , NEW.id_fixed
    , NEW.id_session
    , DEFAULT
    , DEFAULT
    , NEW.uri_re
    , NEW.uri_fmt
    , COALESCE(NEW.pkg, ws.pg_pkg())
    )
  ;
  -- http://postgresql.1045698.n5.nabble.com/Using-Insert-Default-in-a-condition-expression-td1922835.html
  UPDATE ws.page_data SET
    is_hidden = COALESCE(NEW.is_hidden, is_hidden)
  , target = COALESCE(NEW.target, target)
    WHERE code = NEW.code
  ;
  INSERT INTO i18n_def.page_name VALUES (
    NEW.code
  , NEW.name
  )
);

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW i18n_def.error AS
  SELECT * FROM i18n_def.error_message
;
SELECT pg_c('v', 'i18n_def.error', 'Описание ошибки');
ALTER VIEW i18n_def.error ALTER COLUMN id_count SET DEFAULT 0;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE RULE error_ins AS ON INSERT TO i18n_def.error
  DO INSTEAD (
    INSERT INTO ws.error_data (code) VALUES (NEW.code);
    INSERT INTO i18n_def.error_message (code, id_count, message) VALUES (NEW.code, NEW.id_count, NEW.message)
  )
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW i18n_def.ref AS SELECT
  d.*
, n.name
, n.anno
, n.synced_at
  FROM ws.ref_data d
    JOIN i18n_def.ref_name n
    USING (code)
;
SELECT pg_c('v', 'i18n_def.ref', 'Справочник');

/* ------------------------------------------------------------------------- */
ALTER VIEW i18n_def.ref ALTER COLUMN pkg SET DEFAULT ws.pg_cs();
ALTER VIEW i18n_def.ref ALTER COLUMN acls_upd SET DEFAULT ws.const_ref_acls_internal();
ALTER VIEW i18n_def.ref ALTER COLUMN is_dt_vary SET DEFAULT FALSE;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE RULE ref_ins AS ON INSERT TO i18n_def.ref
  DO INSTEAD (
    INSERT INTO ws.ref_data (code, acls, acls_upd, is_dt_vary, method_code, method_code_upd, pkg) VALUES
      (NEW.code, NEW.acls, NEW.acls_upd, NEW.is_dt_vary, NEW.method_code, NEW.method_code_upd, NEW.pkg);
    INSERT INTO i18n_def.ref_name (code, name, anno) VALUES (NEW.code, NEW.name, NEW.anno)
  )
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW i18n_def.ref_item AS SELECT
  d.*
, n.sort
, n.name
, n.anno
  FROM ws.ref_item_data d
    JOIN i18n_def.ref_item_name n
    USING (code, item_code)
;
SELECT pg_c('v', 'i18n_def.ref_item', 'Позиция справочника');
-- Нет RULE для обновления, т.к. обновление производится только кодом (ws.ref_update)

/* ------------------------------------------------------------------------- */
-- TODO: перенести ws.ref_item в i18n_def
CREATE OR REPLACE VIEW i18n_def.timezone AS
  SELECT
    tn.name AS code
  , n.sort
  , tn.abbrev
  , tn.utc_offset
  , tn.is_dst 
  , n.name
    FROM pg_catalog.pg_timezone_names tn
      JOIN i18n_def.ref_item_name n
      ON (tn.name = n.item_code) -- привязка к name а не abbrev, т.к. difference between abbreviations and full names: abbreviations always represent a fixed offset from UTC, whereas most of the full names imply a local daylight-savings time rule, and so have two possible UTC offsets. 
    WHERE n.code = ws.const_ref_code_timezone()
    ORDER BY n.sort
;
SELECT pg_c('v', 'i18n_def.timezone', 'Часовой пояс');
