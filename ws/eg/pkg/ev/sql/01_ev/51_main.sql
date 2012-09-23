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

    Методы диспетчера Ev
*/

/* ------------------------------------------------------------------------- */

CREATE OR REPLACE FUNCTION kind_class_id(a_id ws.d_id32)  RETURNS INTEGER LANGUAGE 'sql' AS
$_$
  SELECT class_id FROM ev.kind WHERE id = $1;
$_$;
SELECT pg_c('f', 'kind_class_id', 'ID класса по ID вида события');

CREATE OR REPLACE FUNCTION kind(a_id ws.d_id32) RETURNS SETOF ev.kind LANGUAGE 'sql' AS
$_$
  SELECT * FROM ev.kind WHERE $1 IN (id,0);
$_$;
SELECT pg_c('f', 'kind', 'Вид события по ID');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ev.create(
  a_kind_id     ws.d_id
, a_status_id   ws.d_id32
, a_created_by  ws.d_id
, a_arg_id      ws.d_id DEFAULT NULL
, a_arg_id2     ws.d_id DEFAULT NULL
, a_arg_name    TEXT    DEFAULT NULL
, a_arg_name2   TEXT    DEFAULT NULL
) RETURNS d_id VOLATILE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    r ev.kind;
    v_id INTEGER;
  BEGIN
    r := ev.kind(a_kind_id);
    INSERT INTO wsd.event (
      kind_id
    , status_id
    , created_by
    , arg_id
    , arg_id2
    , arg_name
    , arg_name2
    , class_id
    ) VALUES (
      r.id
    , COALESCE($2, ev.const_status_id_draft())
    , $3
    , $4
    , $5
    , $6
    , $7
    , r.class_id
    )
    RETURNING id INTO v_id
    ;
    RETURN v_id;
  END;
$_$;
SELECT pg_c('f', 'create', 'Создать событие');



/* ------------------------------------------------------------------------- */
