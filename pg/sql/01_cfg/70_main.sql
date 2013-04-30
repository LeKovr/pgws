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
CREATE TRIGGER insupd BEFORE INSERT OR UPDATE ON wsd.prop_value
  FOR EACH ROW
  EXECUTE PROCEDURE cfg.prop_value_insupd_trigger()
;

/* ------------------------------------------------------------------------- */
CREATE TRIGGER value_insupd BEFORE INSERT OR UPDATE ON wsd.prop_value
  FOR EACH ROW
  WHEN (NEW.valid_from <> '2000-01-01'::date)
  EXECUTE PROCEDURE cfg.prop_value_insupd_has_log()
;

/* ------------------------------------------------------------------------- */
CREATE TRIGGER check_system_owner_insupd BEFORE INSERT OR UPDATE ON wsd.prop_value
  FOR EACH ROW
  WHEN (cfg.prop_is_pogc_system(NEW.pogc))
  EXECUTE PROCEDURE cfg.prop_value_system_owner_insupd()
;

/* ------------------------------------------------------------------------- */
CREATE TRIGGER validation_valid_from BEFORE INSERT OR UPDATE ON wsd.prop_value
  FOR EACH ROW
  WHEN (NEW.valid_from > now())
  EXECUTE PROCEDURE cfg.prop_validation_valid_from()
;

/* ------------------------------------------------------------------------- */
CREATE TRIGGER insupd_check_prop BEFORE INSERT OR UPDATE ON method
  FOR EACH ROW EXECUTE PROCEDURE cfg.prop_value_check_method_fkeys()
;

/* ------------------------------------------------------------------------- */
