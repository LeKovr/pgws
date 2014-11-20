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

    Тесты на заполнение пакетом CFG
*/

/* ------------------------------------------------------------------------- */
SELECT ws.test('cfg.prop_group');
SELECT * FROM cfg.prop_group WHERE pogc IN ('be','fe','db','fcgi') ORDER BY sort, pogc;

SELECT ws.test('cfg.prop_owner');
SELECT * FROM cfg.prop_owner WHERE pogc IN ('be','fe','db','fcgi') ORDER BY sort, pogc;

/*
  эти значения могут быть изменены в процессе эксплуатации
  и это помешает прохождению теста при db make

SELECT ws.test('cfg.prop');
SELECT code, pkg, pogc_list, def_value FROM cfg.prop WHERE code ~ '^ws.daemon.(fe|be|lang)' ORDER BY 1,2;

SELECT ws.test('wsd.prop_value');
  SELECT v.* 
    FROM wsd.prop_value v 
      JOIN cfg.prop p ON v.code ~ ws.mask2regexp(p.code) 
    WHERE p.pkg = 'cfg' 
      AND v.pogc = ANY(ARRAY['fe','be','fcgi','db','cache']) -- TODO: rm cache
    ORDER BY 1,2,3
    ;
*/

SELECT ws.test('ws.method');
SELECT code,code_real,name FROM ws.method where code ~ '^cfg.';

SELECT ws.test('wsd.pkg_default_protected');
SELECT pkg, wsd_rel, wsd_col, func, schema FROM wsd.pkg_default_protected WHERE schema LIKE 'cfg' ORDER BY 2,3;
