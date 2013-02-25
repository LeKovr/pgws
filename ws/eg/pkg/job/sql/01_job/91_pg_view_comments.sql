
SELECT ws.test('job.pg_view_comments');

select * from ws.pg_view_comments('job.stored')
union
select * from ws.pg_view_comments('job.srv_attr')
union
select * from ws.pg_view_comments('job.arg_attr')
;
