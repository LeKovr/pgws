
SELECT ws.test('pg_view_comments');

select * from ws.pg_view_comments('ws.class_status_action_acl')
union
select * from ws.pg_view_comments('ws.class_status_action_ext')
union
select * from ws.pg_view_comments('ws.csa')
union
select * from ws.pg_view_comments('ws.class_action_acl_ext')
union
select * from ws.pg_view_comments('ws.caa')
union
select * from ws.pg_view_comments('ws.class_status_action_acl_ext')
union
select * from ws.pg_view_comments('ws.csaa')
union
select * from ws.pg_view_comments('i18n_def.page')
union
select * from ws.pg_view_comments('i18n_def.error')
union
select * from ws.pg_view_comments('ws.pg_const')
order by 1,2
;

/*
  Вынесено отдельно c исключением столбца rel_src_col, т.к. 
  в 9.2 изменились названия столбцов pg_catalog.pg_stat_activity

  В 9.1: procpid current_query
  В 9.2: pid     query
*/
select rel, code, rel_src, status_id, anno from ws.pg_view_comments('ws.pg_sql');

