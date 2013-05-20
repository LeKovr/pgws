/*


  PGWS. Типы и домены

*/
/* ------------------------------------------------------------------------- */
-- домен для пакета acc
CREATE DOMAIN acc.d_link AS d_id32;

/* ------------------------------------------------------------------------- */
CREATE DOMAIN acc.d_sex VARCHAR(6) CHECK(VALUE IN ('female', 'male'));
SELECT pg_c('d','d_sex', 'Пол пользователя');

CREATE DOMAIN acc.d_password AS TEXT CHECK (VALUE ~ E'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{4,16}$');
SELECT pg_c('d','d_password', 'Пароль');
