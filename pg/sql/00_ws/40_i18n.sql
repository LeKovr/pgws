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
-- 40_i18n.sql - Представления поддержки интернационализации
/* ------------------------------------------------------------------------- */
\qecho '-- FD: pg:ws:40_i18n.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW i18n_def.page AS
  SELECT
    d.*
    , n.name
    FROM ws.page_data d
      JOIN i18n_def.page_name n
      USING (code)
;
ALTER VIEW i18n_def.page ALTER COLUMN target SET DEFAULT '';

/* ------------------------------------------------------------------------- */
COMMENT ON VIEW i18n_def.page IS 'Страница сайта';
COMMENT ON COLUMN i18n_def.page.code       IS 'Идентификатор страницы';
COMMENT ON COLUMN i18n_def.page.up_code    IS 'идентификатор страницы верхнего уровня';
COMMENT ON COLUMN i18n_def.page.class_id   IS 'ID класса, к которому относится страница';
COMMENT ON COLUMN i18n_def.page.action_id  IS 'ID акции, к которой относится страница';
COMMENT ON COLUMN i18n_def.page.group_id   IS 'ID группы страниц для меню';
COMMENT ON COLUMN i18n_def.page.sort       IS 'порядок сортировки в меню страниц одного уровня (NULL - нет в меню)';
COMMENT ON COLUMN i18n_def.page.uri        IS 'мета-маска с именами переменных, которой должен соответствовать URI запроса';
COMMENT ON COLUMN i18n_def.page.tmpl       IS 'файл шаблона (NULL для внешних адресов)';
COMMENT ON COLUMN i18n_def.page.id_source  IS 'ID объекта взять из этого поля сессии';
COMMENT ON COLUMN i18n_def.page.is_hidden  IS 'Запрет включения в разметку страницы внешних блоков';
COMMENT ON COLUMN i18n_def.page.target     IS 'значение атрибута target в формируемых ссылках';
COMMENT ON COLUMN i18n_def.page.uri_re     IS 'regexp URI, вычисляется триггером при insert/update';
COMMENT ON COLUMN i18n_def.page.uri_fmt    IS 'строка формата для генерации URI, вычисляется триггером при insert/update';
COMMENT ON COLUMN i18n_def.page.name       IS 'Заголовок страницы в карте сайта';

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE RULE page_ins AS ON INSERT TO i18n_def.page
    DO INSTEAD (
    INSERT INTO ws.page_data
      (code, up_code, class_id, action_id, group_id, sort, uri, tmpl, id_source, is_hidden, target, uri_re, uri_fmt)
      VALUES (
           NEW.code
           , NEW.up_code
           , NEW.class_id
           , NEW.action_id
           , NEW.group_id
           , NEW.sort
           , NEW.uri
           , NEW.tmpl
           , NEW.id_source
           , DEFAULT
           , DEFAULT
           , NEW.uri_re
           , NEW.uri_fmt
           )
    ;
    -- http://postgresql.1045698.n5.nabble.com/Using-Insert-Default-in-a-condition-expression-td1922835.html
    UPDATE ws.page_data SET
      is_hidden = COALESCE(NEW.is_hidden, is_hidden)
      , target = COALESCE(NEW.target, target)
      WHERE code = NEW.code
    ;
    INSERT INTO i18n_def.page_name VALUES (
           NEW.code
           , NEW.name
          )
    )
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW i18n_def.error AS
  SELECT * FROM i18n_def.error_message
;
ALTER VIEW i18n_def.error ALTER COLUMN id_count SET DEFAULT 0;
COMMENT ON VIEW i18n_def.error IS 'Описание ошибки';

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE RULE error_ins AS ON INSERT TO i18n_def.error
  DO INSTEAD (
    INSERT INTO ws.error_data (code) VALUES (NEW.code);
    INSERT INTO i18n_def.error_message (code, id_count, message) VALUES (NEW.code, NEW.id_count, NEW.message)
  )
;

/* ------------------------------------------------------------------------- */
\qecho '-- FD: pg:ws:40_i18n.sql / 103 --'
