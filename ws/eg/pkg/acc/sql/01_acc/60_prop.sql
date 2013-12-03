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

    Функции триггеров пакета acc
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_value_account_owner_insupd() RETURNS TRIGGER IMMUTABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_rows INTEGER;
  BEGIN
      SELECT INTO v_rows
        count(1)
        FROM wsd.account
        WHERE NEW.poid = id
      ;

    IF v_rows = 0 THEN
      RAISE EXCEPTION 'Not account with id=%', NEW.poid;
    END IF;

    RETURN NEW;
  END;
$_$;
SELECT pg_c('f', 'prop_value_account_owner_insupd', 'Проверка наличия владельца пользовательских свойств');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_value_team_owner_insupd() RETURNS TRIGGER IMMUTABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_rows INTEGER;
  BEGIN
      SELECT INTO v_rows
        count(1)
        FROM wsd.team
        WHERE NEW.poid = id
      ;

    IF v_rows = 0 THEN
      RAISE EXCEPTION 'Not team with id=%', NEW.poid;
    END IF;

    RETURN NEW;
  END;
$_$;
SELECT pg_c('f', 'prop_value_team_owner_insupd', 'Проверка наличия владельца командных свойств');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_copy_value_account_insupd() RETURNS TRIGGER VOLATILE LANGUAGE 'plpgsql' AS
$_$
  BEGIN
    IF NEW.code = 'abp.name.short' THEN
      UPDATE wsd.account SET
          name = cfg.prop_value(acc.const_account_group_prop(), NEW.poid, 'abp.name.short')
        WHERE id = NEW.poid
      ;
    END IF;

    RETURN NEW;
  END;
$_$;
SELECT pg_c('f', 'prop_copy_value_account_insupd', 'Копирование актуальных значений в account');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION prop_copy_value_team_insupd() RETURNS TRIGGER VOLATILE LANGUAGE 'plpgsql' AS
$_$
  BEGIN
    IF NEW.code = 'abp.name.short' THEN
      UPDATE wsd.team SET
          name = cfg.prop_value(acc.const_team_group_prop(), NEW.poid, 'abp.name.short')
        WHERE id = NEW.poid
      ;
    END IF;

    RETURN NEW;
  END;
$_$;
SELECT pg_c('f', 'prop_copy_value_team_insupd', 'Копирование актуальных значений в team');
