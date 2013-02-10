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

    Триггеры
*/

/* ------------------------------------------------------------------------- */

/* ------------------------------------------------------------------------- */
CREATE TRIGGER
  notify_oninsert
  AFTER INSERT ON wsd.job
  FOR EACH ROW
  WHEN (NEW.status_id = job.const_status_id_ready())
  EXECUTE PROCEDURE ws.tr_notify('job_event')
;

/* ------------------------------------------------------------------------- */
CREATE TRIGGER
  notify_onupdate
  AFTER UPDATE ON wsd.job
  FOR EACH ROW
  WHEN (OLD.status_id <> NEW.status_id
   AND NEW.status_id IN (job.const_status_id_ready(), job.const_status_id_again()))
  EXECUTE PROCEDURE ws.tr_notify('job_event')
;

/* ------------------------------------------------------------------------- */
CREATE TRIGGER
  handler_id_update_forbidden
  AFTER UPDATE ON wsd.job
  FOR EACH ROW
  WHEN (OLD.handler_id <> NEW.handler_id)
  EXECUTE PROCEDURE ws.tr_exception('handler_id update is forbidden')
;

/* ------------------------------------------------------------------------- */
CREATE TRIGGER
  handler_id_update_forbidden
  AFTER UPDATE ON wsd.job_todo
  FOR EACH ROW
  WHEN (OLD.handler_id <> NEW.handler_id)
  EXECUTE PROCEDURE ws.tr_exception('handler_id update is forbidden')
;

-- TODO: forbid direct insert/update into wsd.job*
/* ------------------------------------------------------------------------- */

