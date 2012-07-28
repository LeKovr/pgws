#
#    Copyright (c) 2010, 2012 Tender.Pro http://tender.pro.

#    This file is part of PGWS - Postgresql WebServices.

#    PGWS is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    PGWS is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.

#    You should have received a copy of the GNU Affero General Public License
#    along with PGWS.  If not, see <http://www.gnu.org/licenses/>.
#
# pgctl.sh - Postgresql schema control script
#

# ------------------------------------------------------------------------------
cache_anno() {
  echo "  cache - Cache control"
}

# ------------------------------------------------------------------------------
cache_help() {
  cat <<EOF

  Usage:
    $0 cache CMD TAG DIR

  Where
    CMD - command (stat|load|save|clear)
    TAG - cache tag from conf/cache.json
    DIR - directory for save/load

  Example:
    pgws.sh cache save meta e11
    pgws.sh cache load meta e11
    pgws.sh cache stat meta
    pgws.sh cache clear

EOF
}

# ------------------------------------------------------------------------------

cmd=$1
case "$cmd" in
  (save|load|stat|clear)
    pgws_run_perl $PGWS/$PGWS_WS/bin/cachectl.pl "$@"
    ;;
  anno)
    cache_anno
    ;;
  *)
    cache_help
    ;;
esac
