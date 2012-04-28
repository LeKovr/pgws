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

*/
-- 80_class.sql - Данные классов и акций
/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:82_doc.sql / 23 --'

/* ------------------------------------------------------------------------- */
INSERT INTO doc_group (id, code, name, anno) VALUES
  (1, 'wk', 'Public','Public info')
  , (2, 'sys', 'Internal', 'Internal info')
;

/* ------------------------------------------------------------------------- */
INSERT INTO doc (group_id, code, created_by, name, src) VALUES
  (1, 'p1', 1, 'Brief test', '# sdfsdsdfdsf\n\n## dfd\n## sss\n\nttt\n---\n[wewew](http://ddd)\n\n* dsds\n* sdssd\n\n[dfdf]\n')
;

/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:82_doc.sql / 37 --'
