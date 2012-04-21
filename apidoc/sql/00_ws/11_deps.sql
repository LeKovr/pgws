/*

    Copyright (c) 2010, 2012 Tender.Pro http://tender.pro.
    [SQL_LICENSE]

*/
-- 11_deps.sql - Контроль зависимостей
/* ------------------------------------------------------------------------- */
\qecho '-- FD: apidoc:ws:11_deps.sql / 9 --'

SET LOCAL search_path = ws, i18n_def, public;

SELECT ws.pkg_require('pgws');

/* ------------------------------------------------------------------------- */
\qecho '-- FD: apidoc:ws:11_deps.sql / 16 --'
