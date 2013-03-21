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

    Методы универсальной проверки доступа
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION object_acl(a_class_id d_id, a_id d_id, a__sid d_sid DEFAULT NULL) RETURNS SETOF d_acl STABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    r_session   wsd.session;
    v_acl_id    ws.d_acl;
  BEGIN
    -- текущая роль пользователя
    SELECT INTO r_session
      *
      FROM wsd.session
      WHERE sid = a__sid
        AND deleted_at IS NULL
    ;
    IF NOT FOUND THEN
      RETURN QUERY
        SELECT acl_id::ws.d_acl
          FROM wsd.role_acl
          WHERE role_id = acc.const_role_id_guest()
            AND class_id = a_class_id
            AND object_id = a_id
      ;
    ELSE
      RETURN QUERY
        SELECT acl_id::ws.d_acl
          FROM wsd.role_acl
          WHERE role_id IN (r_session.role_id, acc.const_role_id_user())
            AND class_id = a_class_id
            AND object_id = a_id
      ;
      -- TODO: поддержка отношений объекта и группы пользователя
      RETURN QUERY
        SELECT acl_id::ws.d_acl
          FROM wsd.object_class_role ocr
            JOIN wsd.class_role cr ON cr.id = ocr.class_role_id AND cr.class_id = a_class_id AND cr.obj_id = a_id
            JOIN wsd.class_role_acl cra ON cra.class_role_id = cr.id
          WHERE ocr.class_id = ws.class_id('account')
            AND ocr.obj_id = r_session.account_id
      ;
    END IF;
    RETURN;
  END;
$_$;
SELECT pg_c('f', 'object_acl', 'Получить уровень доступа пользователя сессии a_sid на экземпляр a_id класса a_class_id');
