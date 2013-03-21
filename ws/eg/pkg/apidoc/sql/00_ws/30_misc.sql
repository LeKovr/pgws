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

    Регистрация методов и страниц
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ws.register_pages_apidoc(a_menu_sort ws.d_sort DEFAULT NULL) RETURNS VOID LANGUAGE 'sql' AS
$_$
  INSERT INTO i18n_def.page (code, up_code, class_id, action_id, sort, uri, tmpl, name) VALUES
    ('api',             'main', 2, 1, $1, 'docs$',        'apidoc/index',   'Описание API')
  , ('api.smd',         'api', 2, 1, 3, 'docs/smd$',    'apidoc/smd',     'Описание методов')
  , ('api.map',         'api', 2, 1, 1, 'docs/pagemap$','apidoc/pagemap', 'Описание страниц')
  , ('api.xsd',         'api', 2, 1, 5, 'docs/xsd$',    'apidoc/xsd',     'Описание типов')
  , ('api.class',       'api', 2, 1, 2, 'docs/class$',  'apidoc/class',   'Описание классов')
  , ('api.smd1',        'api', 2, 1, 4, 'docs/smd1$',   'apidoc/smd1',    'Описание методов (JS)')
  , ('api.markup',      'api', 2, 1, 6, 'docs/markup$',   'apidoc/markup',    'Примеры разметки страниц')
  , ('api.class.single','api.class', 2, 1, NULL, 'docs/class/:i$',  'apidoc/class',   'Описание класса')
 ;
$_$;

/* ------------------------------------------------------------------------- */
