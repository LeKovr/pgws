/*


  PGWS. Типы и домены

*/
/* ------------------------------------------------------------------------- */

SET LOCAL search_path = job, ws, i18n_def, public;

/* ------------------------------------------------------------------------- */
CREATE TYPE t_attr AS (
  class_id    INTEGER
, status_id   INTEGER
, arg_id      INTEGER
, arg_date    DATE
, arg_num     DECIMAL
, arg_more    TEXT
, arg_id2     INTEGER
, arg_date2   DATE
, arg_id3     INTEGER
);
SELECT pg_c('t', 't_attr', 'Атрибуты задачи')
, pg_c('c', 't_attr.class_id' , 'класс задачи (обработчика)')
, pg_c('c', 't_attr.status_id', 'текущий статус')
, pg_c('c', 't_attr.arg_id'   , 'аргумент id')
, pg_c('c', 't_attr.arg_date' , 'аргумент date')
, pg_c('c', 't_attr.arg_num'  , 'аргумент num')
, pg_c('c', 't_attr.arg_more' , 'аргумент more')
, pg_c('c', 't_attr.arg_id2'  , 'аргумент id2')
, pg_c('c', 't_attr.arg_date2', 'аргумент, 2я дата для периодов')
, pg_c('c', 't_attr.arg_id3'  , 'аргумент id3')
;

/* Описание хэша данных для темплейта */
-- TYPE jq.tmpl_def AS t_hashtable

/* ------------------------------------------------------------------------- */
