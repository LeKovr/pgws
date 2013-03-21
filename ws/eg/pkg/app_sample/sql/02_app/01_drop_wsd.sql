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

    Удаление данных из схемы wsd
*/

/* ------------------------------------------------------------------------- */

SELECT cfg.prop_clean_pkg(:'PKG', TRUE);

/* ------------------------------------------------------------------------- */
-- wiki
DELETE FROM wsd.doc;
DELETE FROM wsd.doc_group;
DELETE FROM wsd.role_acl WHERE class_id = wiki.const_class_id();
DELETE FROM wsd.file_folder_format WHERE folder_code = 'wiki';
DELETE FROM wsd.file_folder WHERE pkg = :'PKG';

/* ------------------------------------------------------------------------- */
DELETE FROM wsd.pkg_script_protected WHERE pkg = :'PKG';
