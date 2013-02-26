
Tritter bootstrap based style
=============================


To switch to this style use sql:

INSERT INTO wsd.prop_value (pogc, poid, code, pkg, value) VALUES ('fe',1,'ws.daemon.fe.tmpl.layout_default','ws','style02');

and do

pgws.sh fcgi restart
