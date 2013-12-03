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
CREATE OR REPLACE FUNCTION object_acl(
  a_class_id d_id
, a_id       d_id
, a__sid     d_sid DEFAULT NULL
) RETURNS SETOF d_acl STABLE LANGUAGE 'plpgsql' AS
$_$
  -- a_class_id: ID класса
  -- a_id:       ID пользователя
  -- a__sid:     Код сессии
  DECLARE
    r_session            acc.session_info;
    v_method_link        ws.d_sub;
    v_method_object_team ws.d_sub;
    v_link_id            acc.d_link;
    v_object_team_id     ws.d_id;
    v_account_team_id    ws.d_id;
    v_role_ids           ws.d_ida;
    v_team_link_id       ws.d_id32 := acc.const_team_link_id_other(); -- любой объект - чужой команды
  BEGIN
    RAISE DEBUG 'object_acl(%, %, %)', a_class_id, a_id, a__sid;
    SELECT INTO r_session
      *
      FROM acc.sid_info_internal(a__sid)
    ;
    IF NOT FOUND THEN
      -- не авторизован
      v_role_ids := ARRAY[acc.const_role_id_guest()]::ws.d_ida;
    ELSE
      v_role_ids := ARRAY[r_session.role_id]::ws.d_ida; -- id_noteam уже тут
      IF r_session.team_id IS NOT NULL THEN
        -- добавить acc.const_role_id_login()
        v_role_ids := v_role_ids || acc.const_role_id_login();

        -- посчитать team_link_id
        v_account_team_id := r_session.team_id;
        RAISE DEBUG 'USER TEAM = %', v_account_team_id;
        v_method_object_team:=ws.method_code_real(ws.class_code(a_class_id) || '.team_link_id');
        IF v_method_object_team IS NOT NULL THEN
          -- team_link_id получаем сразу, без определения team_id
          EXECUTE 
            'SELECT ' || v_method_object_team || '($1, $2)'
            INTO v_team_link_id
            USING a_id, v_account_team_id
          ;
        ELSE
          v_method_object_team:=ws.method_code_real(ws.class_code(a_class_id) || '.team_id');
          IF v_method_object_team IS NULL THEN
            -- не найден метод расчета связи
            RAISE EXCEPTION '%', ws.error_str(acc.const_error_class(), a_class_id::text);
          END IF;
          -- team_link считаем по object.team()
          EXECUTE 
            'SELECT ' || v_method_object_team || '($1)'
            INTO v_object_team_id
            USING a_id
          ;
          v_team_link_id := acc.team_team_link_id(v_object_team_id, v_account_team_id);
        END IF;
      END IF;
    END IF;

    RAISE DEBUG 'USER ROLES = %', v_role_ids;
    RAISE DEBUG 'TEAM LINK ID = %', v_team_link_id;

    -- считаем link_id
    v_method_link:=ws.method_code_real(ws.class_code(a_class_id) || '.link_id');
    IF v_method_link IS NULL THEN
      RAISE EXCEPTION 'Class link function %.link() not found', ws.class_code(a_class_id);
    END IF;

    EXECUTE
      'SELECT ' || v_method_link || '($1, $2)'
      INTO v_link_id
      USING a_id, a__sid
    ;
    RAISE DEBUG 'LINK ID = %', v_link_id;
    RETURN QUERY
      SELECT DISTINCT
        acl_id::ws.d_acl
        FROM wsd.permission_acl p
          JOIN wsd.role_permission rp USING (perm_id)
        WHERE p.class_id = a_class_id
          AND p.link_id = v_link_id 
          AND p.team_link_id = v_team_link_id
          AND rp.role_id = ANY (v_role_ids)
    ;
  END;
$_$;
SELECT pg_c('f', 'object_acl', 'Получить уровень доступа пользователя сессии a_sid на экземпляр a_id класса a_class_id');
