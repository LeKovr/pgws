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

    Регистрация методов и ошибок
*/

/* ------------------------------------------------------------------------- */
INSERT INTO method (code, class_id , action_id, cache_id, rvf_id, code_real, args_exam)
  VALUES ('info.add', 2, 1, 2, 2, pg_cs('add'), 'a=37, b=-37')
;

/* ------------------------------------------------------------------------- */
-- ошибки уровня приложения. Коды синхронизированы с кодами PostgreSQL
-- см. "http://www.postgresql.org/docs/8.4/static/errcodes-appendix.html"

INSERT INTO i18n_def.error (code, id_count, message) VALUES
  (   'Y0021', 1, 'нет доступа к результату суммы при а = %i')
  , ( 'Y0022', 1, 'нет данных по a = %i')
;
