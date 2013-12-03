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
  См. также: select * from ws.pg_const WHERE schema='fs';
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_kind_code_any() RETURNS d_code IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'z_any'::ws.d_code -- такой код будет последний в списке
$_$;
SELECT pg_c('f', 'const_kind_code_any', 'Файл любого формата');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_kind_code_data() RETURNS d_code IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'data'::ws.d_code
$_$;
SELECT pg_c('f', 'const_kind_code_data', 'Файл с данными (xml, json)');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_folder_code_default() RETURNS d_code IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'files'::ws.d_code 
$_$;
SELECT pg_c('f', 'const_folder_code_default', 'Код папки файлов по умолчанию');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_parse_json_file() RETURNS d_errcode IMMUTABLE LANGUAGE 'sql' AS 
$_$
  SELECT 'Y0301'::ws.d_errcode 
$_$;
SELECT pg_c('f', 'const_error_parse_json_file', 'Ошибка парсинга json-файла');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_parse_xml_file() RETURNS d_errcode IMMUTABLE LANGUAGE 'sql' AS 
$_$
  SELECT 'Y0302'::ws.d_errcode 
$_$;
SELECT pg_c('f', 'const_error_parse_xml_file', 'Ошибка парсинга xml-файла');

/* ------------------------------------------------------------------------- */
