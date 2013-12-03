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

    Тесты
*/

/* ------------------------------------------------------------------------- */
SELECT ws.test('test_email');

CREATE TEMP TABLE TEST_ADRESSES (
  ADRESS  TEXT
, IsValid SMALLINT
);

INSERT INTO TEST_ADRESSES (ADRESS, IsValid) VALUES 
  ('NICE_andsimple@example.com', 1)
, ('very.common@example.com', 1)
, ('a.little.lengthy.but.fine@dept.example.com', 1)
, ('disposable.style.email.with+symbol@example.com', 1)
, ('user@[IPv6:2001:db8:1ff::a0b:dbd0]', 1)
, ('"much.more unusual"@example.com', 1)
, ('"very.unusual.@.unusual.com"@example.com', 1)
, (E'"very.(),:;<>[]\".VERY.\"very@\\ \"very\".unusual"@strange.example.com', 1)
, ('postbox@com', 1)
, ('admin@mailserver1', 1)
, ('!#$%&''*+-/=?^_`{}|~@example.org', 1)
, (E'"()<>[]:,;@\\\"!#$%&''*+-/=?^_`{}| ~.a"@example.org', 1)
, ('" "@example.org', 1)
, ('üñîçøðé@example.com', 1)
, ('Abc.example.com', 0)
, ('A@b@c@example.com', 0)
, (E'a"b(c)d,e:f;g<h>i[j\k]l@example.com', 0)
, ('just"not"right@example.com', 0)
, (E'this is"not\allowed@example.com', 0)
, (E'this\ still\"not\\allowed@example.com', 0)
, ('xxx@example..com', 0)
, ('a.little.lengthy..but.fine@dept.example.com', 0)
;

\t
SELECT'                                   ВАЛИДНЫЕ АДРЕСА';
\t

SELECT row_number() OVER () as rnum
     , ADRESS
     , acc.is_email_valid (ADRESS) AS RESULT
     , CASE WHEN acc.is_email_valid (ADRESS) THEN 'OK' ELSE 'FAIL' END AS NEW_ITOG
  FROM TEST_ADRESSES 
  WHERE IsValid=1
;

\t
SELECT'                                   НЕКОРРЕКТНЫЕ АДРЕСА';
\t

SELECT row_number() OVER () as rnum
     , ADRESS
     , acc.is_email_valid (ADRESS) AS RESULT
     , CASE WHEN acc.is_email_valid (ADRESS) THEN 'FAIL' ELSE 'OK' END AS NEW_ITOG
  FROM TEST_ADRESSES 
  WHERE IsValid=0
;
