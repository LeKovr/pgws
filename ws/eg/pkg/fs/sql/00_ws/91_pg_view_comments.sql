
SELECT ws.test('fs.pg_view_comments');

select * from ws.pg_view_comments('fs.file_store')
union
select * from ws.pg_view_comments('fs.file_info')
;
