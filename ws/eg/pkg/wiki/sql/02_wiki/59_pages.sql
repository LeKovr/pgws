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
CREATE OR REPLACE FUNCTION wiki.register_pages(
  a_menu_parent ws.d_code -- код страницы-предка
, a_code        ws.d_code -- Код группы статей
, a_link_prefix ws.d_path -- префик адресов страниц
, a_menu_sort ws.d_sort DEFAULT NULL -- сортировка в списке страниц
) RETURNS VOID LANGUAGE 'plpgsql' AS
$_$
DECLARE
  v_class_id ws.d_id := wiki.const_class_id();      -- wiki class id
  v_wiki_id  ws.d_id := wiki.id_by_code($2);
  v_prefix ws.d_code := 'wiki.' || a_code;
  v_code_re text := '(' || a_link_prefix || '):u';
  BEGIN
    INSERT INTO i18n_def.page (code, up_code, class_id, action_id, sort, uri, tmpl, id_fixed, name) VALUES
      (v_prefix,               a_menu_parent,       v_class_id, 1, a_menu_sort,   a_link_prefix || '$',       'wiki/index',          v_wiki_id, wiki.name_by_code(a_code))
    , (v_prefix || '.doc',     v_prefix,            v_class_id, 1, NULL, v_code_re || '$',           'wiki/index',          v_wiki_id, wiki.name_by_code(a_code))
    , (v_prefix || '.doc.edit',    v_prefix || '.doc',  v_class_id, 3, NULL, v_code_re || '/edit$',      'wiki/edit',           v_wiki_id, 'Редактирование')
    , (v_prefix || '.doc.history', v_prefix || '.doc',  v_class_id, 1, NULL, v_code_re || '/history$',   'wiki/history',        v_wiki_id, 'История изменений')
    ;
  END;
$_$;

/*
api.smd1 доступен только авторизованному, т.к. требует API и не подлежит кэшированию
*/

/* ------------------------------------------------------------------------- */
