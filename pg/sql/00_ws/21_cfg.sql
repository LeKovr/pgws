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
-- 20_cfg.sql - Конфигурация
/* ------------------------------------------------------------------------- */
\qecho '-- FD: pgws:ws:21_cfg.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE TABLE сfg (
  class_id   d_class  NOT NULL REFERENCES class
  , code       d_code
  , pkg_code   d_code   NOT NULL REFERENCES ws.pkg
  , group_id   d_id32   REFERENCES i18n_def.cfg_group
  , is_timed   bool     NOT NULL DEFAULT FALSE
  , sort       d_sort
  , type_code  d_code
  , def_value  d_text
  , ref_id     d_id32   REFERENCES ref
  , name       d_string NOT NULL
  , anno       d_text
  , CONSTRAINT cfg_pkey PRIMARY KEY (class_id, code)
);

COMMENT ON TABLE  сfg IS 'Переменные конфигурации';
COMMENT ON COLUMN сfg.code       IS 'Код';
COMMENT ON COLUMN сfg.name       IS 'Название';

 /*   код настройки
ID класса
ID пакета
    ID группы настроек
есть ограничение по времени
    сортировка
    тип
    по умолчанию
    ID справочника
    название
*/


/* ------------------------------------------------------------------------- */
\qecho '-- FD: pgws:ws:21_cfg.sql / 59 --'
