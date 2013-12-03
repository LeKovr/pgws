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

    Классы и акции
*/

/* ------------------------------------------------------------------------- */
\set AID acc.const_class_id()
\set TID acc.const_team_class_id()
\set RID acc.const_role_class_id()

/* ------------------------------------------------------------------------- */
INSERT INTO team_link(id, name) VALUES
  (acc.const_team_link_id_owner(),   'Свой')
, (acc.const_team_link_id_other(),   'Чужой')
, (acc.const_team_link_id_system(),  'Система')
;

/* ------------------------------------------------------------------------- */
INSERT INTO account_contact_type(id, name) VALUES
  (acc.const_account_contact_mobile_phone_id(), 'Mobile phone')
, (acc.const_account_contact_email_id(),        'Email')
;
