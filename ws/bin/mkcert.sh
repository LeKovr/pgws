#!/bin/bash

DIR=../eg/conf
mkcert() {
  SITE=$1
  CERT=$2
  /usr/bin/openssl req -newkey rsa:1024 -keyout $DIR/$SITE.key -nodes -x509 -days 365 -set_serial $CERT -out $DIR/$SITE.crt << EOF
RU
Russia
Moscow
Tender.Pro
IT Department
$SITE
admin@tender.pro
EOF

}

mkcert www.pgws.local $$

