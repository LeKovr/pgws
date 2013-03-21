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

    Внутренние константы пакета. Используются хранимым кодом.
*/

/* ------------------------------------------------------------------------- */
SET LOCAL search_path = wiki, ws, i18n_def, public;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_class_id() RETURNS d_class IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 20::ws.d_class
$_$;
SELECT pg_c('f', 'const_class_id', 'ID класса wiki');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_doc_class_id() RETURNS d_class IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 21::ws.d_class
$_$;
SELECT pg_c('f', 'const_doc_class_id', 'ID класса статьи wiki');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_online() RETURNS d_id32 IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 1::ws.d_id32
$_$;
SELECT pg_c('f', 'const_status_id_online', 'ID статуcа wiki, при котором статьи имеют свой статус');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION wiki.const_doc_status_id_draft() RETURNS d_id32 IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 3::ws.d_id32
$_$;
SELECT pg_c('f', 'wiki.const_doc_status_id_draft', 'ID начального статуcа статьи wiki');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_nogroupcode() RETURNS ws.d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y9901'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_nogroupcode', 'Код ошибки поиска группы по коду');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_norevision() RETURNS ws.d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y9902'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_norevision', 'Код ошибки соответствия версии документа');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_codeexists() RETURNS ws.d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y9903'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_codeexists', 'Код ошибки повторного создания кода документа');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_nochgtosave() RETURNS ws.d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y9904'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_nochgtosave', 'Код ошибки сохранения версии, не содержащей изменений');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_nodoc() RETURNS ws.d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y9905'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_nodoc', 'Код ошибки поиска статьи');
