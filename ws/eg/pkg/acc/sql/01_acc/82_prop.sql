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

    Реестр свойств. Добавление групп владельцев

*/
\set TG  acc.const_team_group_prop()
\set AG  acc.const_account_group_prop()

/* ------------------------------------------------------------------------- */
INSERT INTO cfg.prop_group (pogc, sort, name, is_system) VALUES
  (:TG, 7, 'Компания',     FALSE)
, (:AG, 8, 'Пользователь', FALSE)
;

/* ------------------------------------------------------------------------- */
INSERT INTO cfg.prop (code, pogc_list, def_value, name, anno, has_log) VALUES
  ('abp.name.short',  ARRAY[:AG,:TG],   '',    'Имя',                     'Имя, которое публикуется на сайте',                     TRUE)
, ('abp.person.gender',ARRAY[:AG],      '',    'Пол',                     'Необходмио для корректного обращения в сообщениях',     FALSE)
, ('abp.anno',        ARRAY[:TG],       '',    'Описание',                'Описание команды',                                      TRUE)
, ('isv.show.email',  ARRAY[:AG,:TG],   'all', 'Кому показывать email',   'Варианты: (all, register, into_team)',                  FALSE)
, ('isv.show.phone',  ARRAY[:AG,:TG],   'all', 'Кому показывать телефон', 'Варианты: (all, register, into_team)',                  FALSE)
, ('object.promo',    ARRAY[:AG,:TG],   '',    'Промо-объект',            'Является автоматически сгенерированным промо-объектом', FALSE)
;
