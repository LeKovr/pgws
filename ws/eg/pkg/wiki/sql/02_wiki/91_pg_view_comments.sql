
SELECT ws.test('wiki.pg_view_comments');

select * from ws.pg_view_comments('wiki.doc_info')
union
select * from ws.pg_view_comments('wiki.doc_keyword_info')
;
