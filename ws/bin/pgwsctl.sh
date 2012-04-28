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
init_tmpl() {
  local src=$1
  local dirs=$2
  local dest=$PGWS_ROOT/var/tmpl
  pushd $PGWS_ROOT/$src > /dev/null
  for tag in $dirs ; do
    if [ -d $tag/tmpl ] ; then
      local d=$tag/tmpl
      pushd $d > /dev/null
      local n=${d%/tmpl}
      for f in * ; do
        if [ -d $f ] && [[ "$f" != "macro" ]] ; then
          [ -d $dest/$f ] || { echo "mkdir $f" ; mkdir -p $dest/$f ; }
          [ -e $dest/$f/$n ] || { echo "$n: $f" ; ln -s $PWD/$f $dest/$f/$n ; }
        fi
      done
      [ -f config.tt2 ] && [ ! -s $dest/config.tt2 ] && { echo "$n: config.tt2" ; ln -sf $PWD/config.tt2 $dest/config.tt2; }
      popd > /dev/null
    fi
  done
  d="app/tmpl/macro"
  if [ -d $d ] ; then
    [ -d $dest/macro ] || { echo "mkdir macro" ; mkdir -p $dest/macro ; }
    pushd $d > /dev/null
    for f in * ; do
      [ -e $dest/macro/$f ] || { echo "$d: $f" ; ln -s $PWD/$f $dest/macro/$f ; }
    done
    popd > /dev/null
  fi
#  [ -s $dest/config.tt2 ] || ln -s $PWD/app/tmpl/config.tt2 $dest/config.tt2
  popd > /dev/null
}

# ------------------------------------------------------------------------------
init_lib() {
  local src=$1
  local dirs=$2
  local dest=$PGWS_ROOT/lib
  pushd $PGWS_ROOT/$src > /dev/null
  for tag in $dirs ; do
    if [ -d $tag/lib ] ; then
      local d=$tag/tmpl
      pushd "$tag" > /dev/null
      for file in $(find lib -name *.pm) ; do 
        local d0=$(dirname $file) # filedir
        local n=${d0#lib}
        local f=${file#$d0/}
        [ -d $dest$n ] || { echo "mkdir $n" ; mkdir -p $dest$n ; }
        [ -e $dest$n/$f ] || { echo "$n: $f" ; ln -s $PWD/lib$n/$f $dest$n/$f ; }
      done
      popd > /dev/null
    fi
  done
  popd > /dev/null
}

# ------------------------------------------------------------------------------
fcgi_cmd() {
  local cmd=$1

  if [[ "$cmd" == "start" || "$cmd" == "restart" ]] ; then
    [[ "$PGWS_APP_PKG" ]] && init_tmpl $PGWS_APP "$PGWS_APP_PKG"
    init_tmpl $PGWS "$PGWS_PKG"

    [[ "$PGWS_APP_PKG" ]] && init_lib $PGWS_APP "$PGWS_APP_PKG"
    init_lib $PGWS "$PGWS_PKG"

    [ -s $PGWS_ROOT/var/i18n ] || { echo "var: i18n" ; ln -s $PGWS_ROOT/pkg/i18n/src/templates $PGWS_ROOT/var/i18n; }

  fi
  local bin=$PGWS_ROOT/$PGWS/$PGWS_WS/bin
  case "$cmd" in
    restart)
      $SUDO_CMD "cd $PGWS_ROOT && perl $bin/fcgid.pl stop"
      $SUDO_CMD "cd $PGWS_ROOT && perl $bin/cachectl.pl clear > /dev/null"
      # TODO: get path from conf/fcgi.json
      # [ -f "$PGWS_ROOT/var/log/fcgid*.log" ] && mv $PGWS_ROOT/var/log/fcgid*.log *.$$
      $SUDO_CMD "cd $PGWS_ROOT && perl $bin/fcgid.pl start"
      ;;
    *)
      $SUDO_CMD "cd $PGWS_ROOT && perl $bin/fcgid.pl $cmd"
      ;;
  esac
}

# ------------------------------------------------------------------------------
tm_cmd() {
  local cmd=$1

  [[ "$PGWS_APP_PKG" ]] && init_tmpl $PGWS_APP "$PGWS_APP_PKG"
  init_tmpl $PGWS "$PGWS_PKG"

  [[ "$PGWS_APP_PKG" ]] && init_lib $PGWS_APP "$PGWS_APP_PKG"
  init_lib $PGWS "$PGWS_PKG"

  local bin=$PGWS_ROOT/$PGWS/$PGWS_WS/bin
  case "$cmd" in
    restart)
      $SUDO_CMD "cd $PGWS_ROOT && perl $bin/tmd.pl stop"
      $SUDO_CMD "cd $PGWS_ROOT && perl $bin/tmd.pl start"
      ;;
    *)
      $SUDO_CMD "cd $PGWS_ROOT && perl $bin/tmd.pl $cmd"
      ;;
  esac
}

# ------------------------------------------------------------------------------
help() {
cat <<EOF
Vars:
  PGWS:        $PGWS
  APP:         $PGWS_APP
  PGWS PKG:    $PGWS_PKG
  PGWS_APP:    $PGWS_APP_PKG

Usage:
    $0 (db|fcgi|tm|cache|i18n) CMD [AGRS]

  Where

    db    - Database control module. See $0 db help
    fcgi  - FastCGI daemon control. See $0 fcgi help
    tm    - Task Manager daemon control. See $0 tm help
    cache - Cache control. See $0 cache help
    i18n  - i18n control


EOF
}

# ------------------------------------------------------------------------------
CMD=$1
shift

LOG=$PGWS_ROOT/var/log
STAMP=$(date +%y%m%d-%H%m)-$$
LOGFILE=$LOG/$CMD-$STAMP.log

DBCTL=$PGWS_ROOT/$PGWS/$PGWS_WS/bin/${PGWS_DB}ctl.sh
I18NCTL=$PGWS_ROOT/$PGWS/$PGWS_WS/bin/i18nctl.sh

SUDO_CMD=$(lookup_sudo)
cat <<EOF
  =========================================================
  Copyright (c) 2010, 2012 Tender.Pro http://tender.pro.
  PGWS - Postgresql WebServices.

  pgws.sh - PGWS control script

  Root:        $PGWS_ROOT
  Command:     $CMD $@
  Daemon user: $PGWS_RUNAS
  ---------------------------------------------------------
EOF

case "$CMD" in
  init)
    init
    ;;
  db)
    . $DBCTL "$@"
    ;;
  i18n)
    . $I18NCTL "$@"
    ;;
  fcgi)
    fcgi_cmd $1
    ;;
  tm)
    tm_cmd $1
    ;;
  cache)
    $SUDO_CMD cd $PGWS_ROOT && perl $PGWS_ROOT/$PGWS/$PGWS_WS/bin/cachectl.pl $@
    ;;
  *)
    help
    ;;
esac

# ------------------------------------------------------------------------------
