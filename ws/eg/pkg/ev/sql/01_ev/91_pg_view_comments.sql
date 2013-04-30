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

    Тест автодокументирования VIEW
*/

SELECT ws.test('ev.pg_view_comments');

SELECT * FROM ws.pg_view_comments('ev.signup_joined'); 
SELECT * FROM ws.pg_view_comments('ev.signup'); 
SELECT * FROM ws.pg_view_comments('ev.kind_info'); 
SELECT * FROM ws.pg_view_comments('ev.role_signup_info'); 
SELECT * FROM ws.pg_view_comments('ev.team_role_signup'); 
SELECT * FROM ws.pg_view_comments('ev.event_info'); 
