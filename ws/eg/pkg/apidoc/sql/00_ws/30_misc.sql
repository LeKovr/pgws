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
  a_menu_parent ws.d_code
, a_class_id ws.d_class
, a_action_id ws.d_id32
, a_link_prefix ws.d_path
, a_menu_sort ws.d_sort DEFAULT NULL
, a_is_api_used BOOLEAN DEFAULT TRUE
) RETURNS VOID LANGUAGE 'plpgsql' AS
$_$
-- a_class_id: ID класса
-- a_action_id: ID акции
-- a_menu_parent: код страницы-предка
-- a_link_prefix: префикc адресов страниц
-- a_menu_sort: сортировка в списке страниц
-- a_is_api_used: использовать API
BEGIN

  INSERT INTO i18n_def.page (code, up_code, class_id, action_id, sort, uri, tmpl, name) VALUES
  /*  ($1,             ,           2, 1, $3,   NULL,               NULL,             'Описание API')
  ,*/ 
    ('api.map',   a_menu_parent,  a_class_id, a_action_id, a_menu_sort + 1, a_link_prefix || '/pagemap$',  'apidoc/pagemap', 'Карта сайта')
  , ('api.class', a_menu_parent,  a_class_id, a_action_id, a_menu_sort + 2, a_link_prefix || '/class$',    'apidoc/class',   'Классы объектов')
  , ('api.smd',   a_menu_parent,  a_class_id, a_action_id, a_menu_sort + 3, a_link_prefix || '/smd$',      'apidoc/smd',     'Методы API')
  , ('api.xsd',   a_menu_parent,  a_class_id, a_action_id, a_menu_sort + 5, a_link_prefix || '/xsd$',      'apidoc/xsd',     'Типы данных')
  , ('api.class.single', 'api.class',  a_class_id, a_action_id,       NULL, a_link_prefix || '/class/:i$', 'apidoc/class', 'Описание класса')
 ;

  IF a_is_api_used THEN
    -- эта страница работает только при доступном API
    INSERT INTO i18n_def.page (code, up_code, class_id, action_id, sort, uri, tmpl, name) VALUES
      ('api.smd1',a_menu_parent,  a_class_id, a_action_id, a_menu_sort + 4, a_link_prefix || '/smd1$',     'apidoc/smd1',   'Методы API (JS)')
    ;
  END IF;
END;
$_$;

/*
api.smd1 доступен только авторизованному, т.к. требует API и не подлежит кэшированию
*/

/* ------------------------------------------------------------------------- */
