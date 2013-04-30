
CREATE TYPE ws.t_facet_info AS (
  code ws.d_code
, base_code ws.d_code
, facet_id ws.d_id32
, value text
, anno text  
);

CREATE OR REPLACE FUNCTION ws.dt_facets(a_type ws.d_code) RETURNS SETOF ws.t_facet_info VOLATILE LANGUAGE 'plpgsql' AS
$_$
  BEGIN
    RETURN QUERY (SELECT a.code, a.base_code, a.facet_id, a.value, a.anno 
              FROM ws.dt_facet a INNER JOIN ws.dt b on a.code = b.code and a.base_code = b.base_code
              WHERE b.code = a_type); 
  END;
$_$;

SELECT * FROM ws.dt_facets('ws.d_stamp');
SELECT * FROM ws.dt_facets('ws.d_rating');
SELECT * FROM ws.dt_facets('ws.d_string');
SELECT * FROM ws.dt_facets('ws.d_email');
SELECT * FROM ws.dt_facets('ws.d_emails');
SELECT * FROM ws.dt_facets('ws.d_path');
SELECT * FROM ws.dt_facets('ws.d_non_neg_int');
SELECT * FROM ws.dt_facets('ws.d_code');
SELECT * FROM ws.dt_facets('ws.d_code_arg');
SELECT * FROM ws.dt_facets('ws.d_codei');
SELECT * FROM ws.dt_facets('ws.d_code_like');
SELECT * FROM ws.dt_facets('ws.d_sub');
SELECT * FROM ws.dt_facets('ws.d_errcode');

/* у этих доменов в ядре авторегистрации не происходит

SELECT * FROM ws.dt_facets('ws.d_id');
SELECT * FROM ws.dt_facets('ws.d_id32');
SELECT * FROM ws.dt_facets('ws.d_sort');
SELECT * FROM ws.dt_facets('ws.d_regexp');
SELECT * FROM ws.dt_facets('ws.d_decimal_positive');
SELECT * FROM ws.dt_facets('ws.d_id_positive');
SELECT * FROM ws.dt_facets('ws.d_decimal_non_neg');
SELECT * FROM ws.dt_facets('ws.d_sid');
SELECT * FROM ws.dt_facets('ws.d_zip');
SELECT * FROM ws.dt_facets('ws.d_text');
SELECT * FROM ws.dt_facets('ws.d_login');
SELECT * FROM ws.dt_facets('ws.d_class');
SELECT * FROM ws.dt_facets('ws.d_cnt');             
SELECT * FROM ws.dt_facets('ws.d_amount');
SELECT * FROM ws.dt_facets('ws.d_format');
SELECT * FROM ws.dt_facets('ws.d_lang');
SELECT * FROM ws.dt_facets('ws.d_money');
SELECT * FROM ws.dt_facets('ws.d_acl');
SELECT * FROM ws.dt_facets('ws.d_acls');
SELECT * FROM ws.dt_facets('ws.d_bitmask');
SELECT * FROM ws.dt_facets('ws.d_booleana');
SELECT * FROM ws.dt_facets('ws.d_texta');
SELECT * FROM ws.dt_facets('ws.d_id32a');
SELECT * FROM ws.dt_facets('ws.d_codea');
SELECT * FROM ws.dt_facets('ws.d_ida');
SELECT * FROM ws.dt_facets('ws.d_moneya');

*/

