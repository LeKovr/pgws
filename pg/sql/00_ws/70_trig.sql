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

    Создание триггеров
*/

/* ------------------------------------------------------------------------- */
CREATE TRIGGER insupd BEFORE INSERT OR UPDATE ON dt
  FOR EACH ROW EXECUTE PROCEDURE dt_insupd_trigger()
;

/* ------------------------------------------------------------------------- */
CREATE TRIGGER insupd BEFORE INSERT OR UPDATE ON dt_part
  FOR EACH ROW EXECUTE PROCEDURE dt_part_insupd_trigger()
;

/* ------------------------------------------------------------------------- */
CREATE TRIGGER insupd BEFORE INSERT OR UPDATE ON dt_facet
  FOR EACH ROW EXECUTE PROCEDURE dt_facet_insupd_trigger()
;

/* ------------------------------------------------------------------------- */
CREATE TRIGGER insupd BEFORE INSERT OR UPDATE ON page_data
  FOR EACH ROW EXECUTE PROCEDURE page_insupd_trigger()
;

/* ------------------------------------------------------------------------- */
CREATE TRIGGER insupd BEFORE INSERT OR UPDATE ON method
  FOR EACH ROW EXECUTE PROCEDURE method_insupd_trigger()
;
