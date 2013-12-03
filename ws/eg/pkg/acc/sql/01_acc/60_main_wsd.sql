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
CREATE OR REPLACE FUNCTION account_contact_insupd_trigger() RETURNS TRIGGER IMMUTABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_rows INTEGER;
  BEGIN
      SELECT INTO v_rows
        count(1)
        FROM wsd.account
        WHERE NEW.account_id = id
      ;

    IF v_rows = 0 THEN
      RAISE EXCEPTION 'Not account with id=%', NEW.account_id;
    END IF;

    RETURN NEW;
  END;
$_$;
SELECT pg_c('f', 'account_contact_insupd_trigger', 'Проверка наличия пользователя для контакта');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION validation_email_trigger() RETURNS TRIGGER IMMUTABLE LANGUAGE 'plpgsql' AS
$_$
  BEGIN
    IF NOT acc.is_email_valid (new.value) THEN
      RAISE EXCEPTION '%', ws.perror_str(acc.const_error_email_validation(), 'value', NEW.value);
    END IF;
    RETURN NEW;
  END;
$_$;
SELECT pg_c('f', 'validation_email_trigger', 'Проверка валидности email');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION validation_phone_trigger() RETURNS TRIGGER IMMUTABLE LANGUAGE 'plpgsql' AS
$_$
  BEGIN

    IF NEW.value !~ E'^((8|\\+7)[\\- ]?)?(\\(?\\d{3,5}\\)?[\\- ]?)?[\\d\\- ]{5,10}$' THEN
      RAISE EXCEPTION '%', ws.perror_str(acc.const_error_mobile_phone_validation(), 'value', NEW.value);
    END IF;

    RETURN NEW;
  END;
$_$;
SELECT pg_c('f', 'validation_phone_trigger', 'Проверка валидности номера телефона');
