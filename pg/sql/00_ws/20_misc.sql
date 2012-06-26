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
-- 20_misc.sql - Вспомогательные таблицы
/* ------------------------------------------------------------------------- */
\qecho '-- FD: pgws:ws:20_misc.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE TABLE cache (
  id           d_id32   PRIMARY KEY
  , is_active  bool     NOT NULL
  , code       d_code   NOT NULL -- внешнее имя метода
  , name       text     NOT NULL
);
COMMENT ON TABLE cache IS 'Вид кэша';

/* ------------------------------------------------------------------------- */
CREATE TABLE method_rv_format (
  id           d_id32   PRIMARY KEY
  , name       text     NOT NULL
);
COMMENT ON TABLE method_rv_format IS 'Формат результатов метода';

/* ------------------------------------------------------------------------- */
CREATE TABLE server (
  id           d_id32   PRIMARY KEY
  , uri        text     NOT NULL
  , name       text     NOT NULL
);
COMMENT ON TABLE server IS 'Сервер горизонтального масштабирования';

/* ------------------------------------------------------------------------- */
CREATE TABLE error_data (
  code        d_errcode PRIMARY KEY
);

/* ------------------------------------------------------------------------- */
CREATE TABLE i18n_def.page_group (
  id           d_id32   PRIMARY KEY
  , name       text     NOT NULL
);

COMMENT ON TABLE i18n_def.page_group       IS 'Группа страниц для меню';
COMMENT ON COLUMN i18n_def.page_group.id   IS 'ID группы';
COMMENT ON COLUMN i18n_def.page_group.name IS 'Название';

/* ------------------------------------------------------------------------- */
CREATE TABLE i18n_def.cfg_group (
  id           d_id32   PRIMARY KEY
  , name       text     NOT NULL
);

COMMENT ON TABLE i18n_def.cfg_group       IS 'Группа параметров конфигурации';
COMMENT ON COLUMN i18n_def.cfg_group.id   IS 'ID группы';
COMMENT ON COLUMN i18n_def.cfg_group.name IS 'Название';

/* ------------------------------------------------------------------------- */
\qecho '-- FD: pgws:ws:20_misc.sql / 75 --'
