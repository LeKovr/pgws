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

    Регистрация страниц сайта
*/

/* ------------------------------------------------------------------------- */

SELECT wiki.register_pages('group.info', 'help', 'help', 4);
SELECT wiki.register_pages('group.info.devel', 'devdocs', 'devdocs', 10);

SELECT wiki.register_pages('samples', 'wk1', 'wk1', 6);
SELECT wiki.register_pages('samples', 'wk2', 'wk2', 7);

INSERT INTO i18n_def.page (code, up_code, class_id, action_id, sort, uri, tmpl, name) VALUES
 ('wiki.fs', 'main', wiki.const_class_id(), 1, NULL, 'wikistore/:i/:s:u$', 'fs/file', 'Файл статьи wiki')
;
