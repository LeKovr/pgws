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

    Создание триггеров для объектов пакета acc
*/

/* ------------------------------------------------------------------------- */
CREATE TRIGGER check_account_owner_insupd BEFORE INSERT OR UPDATE ON wsd.prop_value
  FOR EACH ROW
  WHEN (NEW.pogc IN (acc.const_account_group_prop()))
  EXECUTE PROCEDURE acc.prop_value_account_owner_insupd()
;

/* ------------------------------------------------------------------------- */
CREATE TRIGGER check_team_owner_insupd BEFORE INSERT OR UPDATE ON wsd.prop_value
  FOR EACH ROW
  WHEN (NEW.pogc IN (acc.const_team_group_prop()))
  EXECUTE PROCEDURE acc.prop_value_team_owner_insupd()
;

/* ------------------------------------------------------------------------- */
CREATE TRIGGER value_copy_into_team AFTER INSERT OR UPDATE ON wsd.prop_value
  FOR EACH ROW
  WHEN (NEW.pogc IN (acc.const_team_group_prop()))
  EXECUTE PROCEDURE acc.prop_copy_value_team_insupd()
;

/* ------------------------------------------------------------------------- */
CREATE TRIGGER value_copy_into_account AFTER INSERT OR UPDATE ON wsd.prop_value
  FOR EACH ROW
  WHEN (NEW.pogc IN (acc.const_account_group_prop()))
  EXECUTE PROCEDURE acc.prop_copy_value_account_insupd()
;

/* ------------------------------------------------------------------------- */




