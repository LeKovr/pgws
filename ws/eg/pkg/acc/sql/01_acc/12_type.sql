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

  PGWS. Типы и домены

*/
/* ------------------------------------------------------------------------- */
CREATE DOMAIN acc.d_link AS d_id32;
SELECT pg_c('d', 'd_link', 'Связь');

/* ------------------------------------------------------------------------- */
CREATE DOMAIN acc.d_sex VARCHAR(6) CHECK(VALUE IN ('female', 'male'));
SELECT pg_c('d', 'd_sex', 'Пол пользователя');

/* ------------------------------------------------------------------------- */
-- \d -> [0-9] для в 9.0
CREATE DOMAIN acc.d_password AS TEXT CHECK (VALUE ~ '^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{4,16}$');
SELECT pg_c('d', 'd_password', 'Пароль');
