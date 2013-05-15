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
CREATE OR REPLACE FUNCTION ws.register_pages_apidoc(
  a_menu_parent ws.d_code -- код страницы-предка
, a_link_prefix ws.d_path -- префик адресов страниц
, a_menu_sort ws.d_sort DEFAULT NULL -- сортировка в списке страниц
) RETURNS VOID LANGUAGE 'sql' AS
$_$
  INSERT INTO i18n_def.page (code, up_code, class_id, action_id, sort, uri, tmpl, name) VALUES
  /*  ($1,             ,           2, 1, $3,   NULL,               NULL,             'Описание API')
  ,*/ 
    ('api.map',         $1,        2, 1, $3 + 1,    $2 || '/pagemap$',  'apidoc/pagemap', 'Карта сайта')
  , ('api.class',       $1,        2, 1, $3 + 2,    $2 || '/class$',    'apidoc/class',   'Классы объектов')
  , ('api.smd',         $1,        2, 1, $3 + 3,    $2 || '/smd$',      'apidoc/smd',     'Методы API')
  , ('api.smd1',        $1,        1, 2, $3 + 4,    $2 || '/smd1$',     'apidoc/smd1',    'Методы API (JS)')
  , ('api.xsd',         $1,        2, 1, $3 + 5,    $2 || '/xsd$',      'apidoc/xsd',     'Типы данных')
  , ('api.perm',        $1,        2, 1, $3 + 6,    $2 || '/perm$',     'apidoc/perm',    'Разрешения')
  , ('api.role',        $1,        2, 1, $3 + 7,    $2 || '/role$',     'apidoc/role',    'Роли')
  , ('api.class.single','api.class',  2, 1,         NULL, $2 || '/class/:i$', 'apidoc/class', 'Описание класса')
 ;
$_$;

/*
api.smd1 доступен только авторизованному, т.к. требует API и не подлежит кэшированию
*/

/* ------------------------------------------------------------------------- */
