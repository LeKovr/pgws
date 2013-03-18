
/* ------------------------------------------------------------------------- */

SELECT ws.test('dt_register_sample');

SET SEARCH_PATH='ws';
CREATE DOMAIN d_test_1 AS INT; 
CREATE DOMAIN d_test_2 AS TEXT;
SELECT pg_c('d','d_test_1', 'Домен 1')
, pg_c('d','d_test_2',   'Домен 2')
;
CREATE TYPE ws.t_test AS (
  _a    d_test_1
 ,_b    d_test_2)
;
SELECT pg_c('t','t_test', 'Тест авторегистрации домена')
, pg_c('c','t_test._a',   'Кол. a')
, pg_c('c','t_test._b',   'Кол. b')
;
SELECT pg_register_type('t_test');
SELECT * FROM ws.dt('ws.t_test');
SELECT * FROM ws.dt_part('ws.t_test');
SELECT * FROM ws.dt('ws.d_test_1');
SELECT * FROM ws.dt('ws.d_test_2');

/* ------------------------------------------------------------------------- */
