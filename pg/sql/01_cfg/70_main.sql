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

    Создание триггеров и настройка умолчаний для объектов пакета cfg
*/

/* ------------------------------------------------------------------------- */
CREATE TRIGGER prop_is_mask BEFORE INSERT OR UPDATE ON prop
  FOR EACH ROW EXECUTE PROCEDURE prop_calc_is_mask()
;

/* ------------------------------------------------------------------------- */
ALTER TABLE wsd.prop_group ALTER COLUMN pkg SET DEFAULT ws.pg_cs();

ALTER TABLE wsd.prop_owner ALTER COLUMN pkg SET DEFAULT ws.pg_cs();

ALTER TABLE wsd.prop_value ALTER COLUMN pkg SET DEFAULT ws.pg_cs();

/* ------------------------------------------------------------------------- */
CREATE TRIGGER insupd BEFORE INSERT OR UPDATE ON wsd.prop_value
  FOR EACH ROW EXECUTE PROCEDURE cfg.prop_value_insupd_trigger()
;

/* ------------------------------------------------------------------------- */
