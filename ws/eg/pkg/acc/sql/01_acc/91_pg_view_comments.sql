
SELECT ws.test('acc.pg_view_comments');

select * from ws.pg_view_comments('acc.account_attr')
union
select * from ws.pg_view_comments('acc.account_attr_pub')
union
select * from ws.pg_view_comments('acc.session_info')
;