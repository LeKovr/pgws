
\qecho '***************** Type: ' :CODE
\qecho

SELECT *
, ws.dt_parent_base_code(code)
, ws.dt_is_complex(code)
  FROM ws.dt
  WHERE code = :'CODE'
;

\C dt_facet
SELECT * FROM ws.dt_facet(:'CODE');

-- TODO: не работает в pg 9.0
-- \C
-- SELECT * FROM ws.dt_tree(:'CODE');

\C dt_part
SELECT * FROM ws.dt_part(:'CODE');

\C
SELECT * FROM ws.dt_parts(:'CODE');
