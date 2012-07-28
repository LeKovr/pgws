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
# pgwsctl.sh - PGWS control script functions
#

# ------------------------------------------------------------------------------
pgws_help() {
  cat <<EOF

  Usage:

    $0 MODULE CMD [AGRS]

  Where MODULE is one from:
EOF

  for f in var/ctl/*.sh ; do
    [[ "$f" == "var/ctl/pgwsctl.sh" ]] || { echo -n "  " ; . $f anno ; }
  done

  cat <<EOF

    Each module has own help for CMD. See $0 MODULE help

EOF
}

# ------------------------------------------------------------------------------
lookup_sudo() {
  local sudo=$(whereis -b sudo)
  if [[ "$sudo" == "sudo:" ]] ; then
    sudo="su -l $PGWS_RUNAS -c "
  else
    sudo="sudo -u $PGWS_RUNAS /usr/bin/env bash -c "
  fi
  echo "$sudo"
}

# ------------------------------------------------------------------------------
pgws_run_perl() {
  local bin=$1; shift
  $SUDO_CMD "cd $PGWS_ROOT && perl $PGWS/$PGWS_WS/bin/starter.pl $bin $1 $2 $3 $4"
}

# ------------------------------------------------------------------------------
CMD=$1
shift

LOG=$PGWS_ROOT/var/log
STAMP=$(date +%y%m%d-%H%m)-$$
LOGFILE=$LOG/$CMD-$STAMP.log

saveIFS="$IFS"
IFS=$'\n'
array=($(perl $PGWS_ROOT/$PGWS/$PGWS_WS/bin/json2var.pl PACKAGES DAEMON_USER < $PGWS_ROOT/config.json))
IFS="$saveIFS"
PGWS_APP_PKG=${array[0]}
PGWS_RUNAS=${array[1]}

[[ "$PGWS_RUNAS" ]] || PGWS_RUNAS=$USER

SUDO_CMD=$(lookup_sudo)

cat <<EOF
  =========================================================
  Copyright (c) 2010, 2012 Tender.Pro http://tender.pro.
  PGWS - Postgresql WebServices.

  pgws.sh - PGWS control script

  Root:        $PGWS_ROOT
  Command:     $CMD $@
  Packages:    $PGWS_APP_PKG
  Daemon user: $PGWS_RUNAS
  Sudo:        $SUDO_CMD
  ---------------------------------------------------------
EOF

[[ "$CMD" == "db" ]] && CMD=$PGWS_DB

if [ -f var/ctl/${CMD}ctl.sh ] ; then
  . var/ctl/${CMD}ctl.sh anno
  echo "  ---------------------------------------------------------"
  . var/ctl/${CMD}ctl.sh "$@"
else
  pgws_help
fi

# ------------------------------------------------------------------------------
