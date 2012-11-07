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
INSERT INTO i18n_def.page (code, up_code, class_id, action_id, sort, pkg, uri, tmpl, name) VALUES
   ('api',     'main', 2, 1, NULL,:'PKG', 'docs$',        'apidoc/index',   'Описание API')
 , ('api.smd',  'api', 2, 1, 3, :'PKG', 'docs/smd$',    'apidoc/smd',     'Описание методов')
 , ('api.map',  'api', 2, 1, 2, :'PKG', 'docs/pagemap$','apidoc/pagemap', 'Описание страниц')
 , ('api.xsd',  'api', 2, 1, 5, :'PKG', 'docs/xsd$',    'apidoc/xsd',     'Описание типов')
 , ('api.class','api', 2, 1, 1, :'PKG', 'docs/class$',  'apidoc/class',   'Описание классов')
 , ('api.smd1', 'api', 2, 1, 4, :'PKG', 'docs/smd1$',   'apidoc/smd1',    'Описание методов (JS)')
 , ('api.class.single','api.class', 2, 1, null, :'PKG', 'docs/class/:i$',  'apidoc/class',   'Описание класса')
;

/* ------------------------------------------------------------------------- */
