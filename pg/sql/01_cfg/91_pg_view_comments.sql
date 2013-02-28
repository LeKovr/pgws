
SELECT ws.test('pg_view_comments');

select * from ws.pg_view_comments('cfg.prop_owner_attr')
union
select * from ws.pg_view_comments('cfg.prop_attr')
;