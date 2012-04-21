/*

    Copyright (c) 2010, 2012 Tender.Pro http://tender.pro.
    [SQL_LICENSE]

*/
-- 89_reg.sql - Регистрация методов и страниц
/* ------------------------------------------------------------------------- */
\qecho '-- FD: apidoc:ws:89_reg.sql / 9 --'

/* ------------------------------------------------------------------------- */
INSERT INTO i18n_def.page (code, up_code, class_id, action_id, sort, uri, tmpl, name) VALUES
   ('api',     'main', 2, 1, 999, 'docs$',        'apidoc/index',   'Описание API')
 , ('api.smd',  'api', 2, 1, 3, 'docs/smd$',    'apidoc/smd',     'Описание методов')
 , ('api.map',  'api', 2, 1, 2, 'docs/pagemap$','apidoc/pagemap', 'Описание страниц')
 , ('api.xsd',  'api', 2, 1, 5, 'docs/xsd$',    'apidoc/xsd',     'Описание типов')
 , ('api.class','api', 2, 1, 1, 'docs/class$',  'apidoc/class',   'Описание классов')
 , ('api.smd1', 'api', 2, 1, 4, 'docs/smd1$',   'apidoc/smd1',    'Описание методов (JS)')
 , ('api.class.single','api.class', 2, 1, null, 'docs/class/:i$',  'apidoc/class',   'Описание класса')
;

/* ------------------------------------------------------------------------- */
\qecho '-- FD: apidoc:ws:89_reg.sql / 23 --'
