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

    Данные основных таблиц пакета
*/

\set AID acc.const_class_id()

/* ------------------------------------------------------------------------- */
INSERT INTO ev.kind_group (id, sort, name, anno) VALUES 
  (1, 1, 'Система','Информация о системных событиях')
;

/* ------------------------------------------------------------------------- */
INSERT INTO ev.signature (  id, name, email, tmpl ) VALUES 
  ( 1, 'PGWS support', 'support@localhost', NULL)
;

/* ------------------------------------------------------------------------- */
INSERT INTO ev.kind 
  ( id, group_id, class_id, def_prio, tmpl,         form_codes, name, name_fmt,   name_count, anno) VALUES
  ( 1,  1,        :AID,     3, 'account_login_self', ARRAY[1],   'Авторизация своей учетной записи', 'Пользователь %s авторизован в системе',  1
  , 'Уведомление пользователя о том, что под его учетной записью произведена авторизация в системе' )
, ( 2,  1,        :AID,     2, 'account_login_team', ARRAY[1],   'Авторизация учетной записи своей команды', 'Пользователь %s (%s) авторизован в системе',  2
  , 'Уведомление администратора команды об авторизации ее участника')
;

INSERT INTO ev.kind 
  ( id, group_id, class_id, def_prio, tmpl,         form_codes, name, name_fmt,   name_count, has_spec, spec_name, anno) VALUES
  ( 3,  1,        :AID,     1, 'account_login_any',   ARRAY[1],   'Авторизация учетной записи', 'Пользователь %s: новая сессия (%s)',  2, TRUE, 'ID пользователя', 'Уведомление об авторизации заданного (или любого) пользователя')
;


