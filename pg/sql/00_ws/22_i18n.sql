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
-- 22_i18n.sql - Таблицы поддержки интернационализации
/* ------------------------------------------------------------------------- */
\qecho '-- FD: pg:ws:22_i18n.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE TABLE i18n_def.page_name (
  code         d_code  PRIMARY KEY REFERENCES page_data ON DELETE CASCADE
  , name       text     NOT NULL
);

/* ------------------------------------------------------------------------- */
CREATE TABLE i18n_def.error_message (
  code        d_errcode PRIMARY KEY REFERENCES error_data ON DELETE CASCADE
 , id_count   d_cnt     NOT NULL DEFAULT 0
 , message    d_format  NOT NULL
);

/* ------------------------------------------------------------------------- */
\qecho '-- FD: pg:ws:22_i18n.sql / 39 --'
