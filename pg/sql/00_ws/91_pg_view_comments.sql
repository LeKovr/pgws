
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
select * from ws.pg_view_comments('ws.pg_sql')
union
select * from ws.pg_view_comments('ws.pg_const')
;