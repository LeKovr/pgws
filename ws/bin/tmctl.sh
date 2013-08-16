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
tm_anno() {
  echo "  tm    - External Task Manager daemon control"
}

# ------------------------------------------------------------------------------
tm_help() {
  cat <<EOF

  Usage:
    $0 (start|status|check|restart|reload|stop)

  Where
    start   - run daemon if not running or raise error
    status  - print daemon status
    check   - run daemon if not running or exit
    restart - restart daemon
    reload  - restart workers
    stop    - stop daemon

EOF
}


# ------------------------------------------------------------------------------

cmd=$1

TM_CMD=$(perl $PGWS_ROOT/$PGWS/$PGWS_WS/bin/json2var.pl TM_CMD < $PGWS_ROOT/config.json)

if [[ ! "$TM_CMD" ]] ; then
  echo "  Service does not configured. Skipping."
  exit
fi
case "$cmd" in
  (start|status|check|restart|reload|stop)
    pgws_run_perl $PGWS/$PGWS_WS/bin/tmd.pl "$@"
    ;;
  anno)
    tm_anno
    ;;
  *)
    tm_help
    ;;
esac
