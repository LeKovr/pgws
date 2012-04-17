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
db_run_sql_begin() {
  local file=$1
  cat > $file <<EOF
/* ------------------------------------------------------------------------- */
\qecho '-- FD: _build.sql / BEGIN --'

BEGIN;
\set ON_ERROR_STOP 1
SET CLIENT_ENCODING TO 'utf-8';

EOF
}

# ------------------------------------------------------------------------------
db_run_sql_end() {
  local file=$1
  cat >> $file <<EOF
COMMIT;

\qecho '-- FD: _build.psql / END --'
/* ------------------------------------------------------------------------- */
EOF
}

# ------------------------------------------------------------------------------
db_run_test_end() {
  local file=$1
  cat >> $file <<EOF
\o
truncate ws.compile_errors;
\copy ws.compile_errors(data) from errors.diff
\! cat errors.diff
select ws.compile_errors_chk();
EOF
}

# ------------------------------------------------------------------------------
db_run() {
  local run_op=$1 ; shift
  local file_mask=$1 ; shift
  local src=$1 ; shift
  local pkg=$@

  # TODO
  local ver="000"

  echo "Logfile: $LOGFILE"

  schema_mask="??_*"
  db_run_sql_begin $BLD/build.sql

  log_end=""
  local path=$PGWS_ROOT/$src
  if [[ "$src" == "$PGWS" ]] ; then
    [[ "$run_op" == "add" ]] && log_end="1"
  fi

  pushd $path > /dev/null
  echo "Seeking dirs in $pkg..."
  local dirs=$BLD/build.dirs
  echo -n > $dirs
  for tag in $pkg ; do
    if [ -d "$tag/sql" ] ; then
      for s in $tag/sql/$schema_mask ; do
        echo "Found: $s"
        echo $s >> $dirs
      done
    fi
  done
  echo "Seeking files..."
  local cat_cmd="cat"
  if [[ "$run_op" == "del" ]] ; then
    cat_cmd="tac"
    local is_tac=$(whereis -b $cat_cmd)
    [[ "$D" == "$cat_cmd:" ]] && cat_cmd="tail -r"
  fi
  for s in $($cat_cmd $dirs) ; do
    pn=${s%%/sql*}    # package name
    sn=${s#*/sql/??_} # schema name
    bd=$pn-${s#*/sql/} # build dir
##echo "SM=$sn LOG=$log_end OP=$run_op"
    [[ ! "$log_end" ]] && echo "SELECT ws.pkg_$run_op('$pn', '$ver', '$LOGNAME', '$USERNAME', '$SSH_CLIENT');" >> $BLD/build.sql

#    [[ ! "$log_end" ]] && [[ "$sn" != "ws" ]] && echo "SET LOCAL search_path = $sn, i18n_def, ws, public;" >> $BLD/build.sql
#    [[ ! "$log_end" ]] && [[ "$sn" == "ws" ]] && echo "SET LOCAL search_path = ws, i18n_def, public;" >> $BLD/build.sql

    [ -d "$BLD/$bd" ] || mkdir $BLD/$bd

    for f in $s/$file_mask ; do
      if [ -f "$f" ] ; then
        n=$(basename $f)
        echo "Found: $f"
        echo "Processing file: $f" >> $LOGFILE
        awk "{gsub(/-- FD:(.*)--/, \"-- FD: $pn:$sn:$n / \" FNR \" --\")}; 1" $f > $BLD/$bd/$n
        echo "\i $bd/$n" >> $BLD/build.sql
      fi
    done
    if [[ "$run_op" != "del" ]] ; then
      echo "SET LOCAL search_path = i18n_def, public;" >> $BLD/build.sql

      # TODO: 01_require.sql
      for f in $s/9?_*.sql ; do
        [ -s "$f" ] || continue
        n=$(basename $f)
        echo "Processing file: $f" >> $LOGFILE
        awk "{gsub(/-- FD:(.*)--/, \"-- FD: $pn:$sn:$n / \" FNR \" --\")}; 1" $f > $BLD/$bd/$n
        n1=${n%.sql} # remove ext
        echo "\o $bd/$n1.out" >> $BLD/build.sql
        echo "\i $bd/$n" >> $BLD/build.sql
        cp $s/$n1.out $BLD/$n1.out.orig
        echo "\! diff -c $n1.out.orig $n1.out | tr \"\t\" \" \" > errors.diff" >> $BLD/build.sql
        db_run_test_end $BLD/build.sql
      done

    fi

    [[ -f "$BLD/keep_sql" ]] || echo "\! rm -rf $bd" >> $BLD/build.sql
    [[ "$log_end" ]] && echo "SELECT ws.pkg_$run_op('$pn', '$ver', '$LOGNAME', '$USERNAME', '$SSH_CLIENT');" >> $BLD/build.sql
  done
  popd > /dev/null

  db_run_sql_end $BLD/build.sql

  pushd $BLD > /dev/null
  [[ "$DO_SQL" ]] && psql -X -P footer=off -d "$CONN" -f build.sql > $LOGFILE 2>&1
  RETVAL=$?
  popd > /dev/null
  if [[ $RETVAL -eq 0 ]] ; then
    echo "Complete"
    [ -f "$BLD/errors.diff" ] && rm "$BLD/errors.diff"
  else
    echo "*** Errors found:"
    grep ERROR $LOGFILE
  fi

}

# ------------------------------------------------------------------------------
db_help() {
cat <<EOF
'dbhelp'
Usage: $0 db (init|make|drop) [SRC] [PKG]
  Where
    init - create DB objects
    make - compile code
    drop - drop DB objects

    SRC  - pgws|pkg. Default: pgws
    PKG  - dirname(s) from SRC. Default: "$PGWS_PKG" (if SRC=pgws) or "$PGWS_APP_PKG"
EOF
}

# ------------------------------------------------------------------------------
CONN=$(perl $PGWS_ROOT/$PGWS/$PGWS_WS/bin/json2conninfo.pl < $PGWS_ROOT/conf/db.json)
[[ "$CONN" ]] || { echo "Fatal: No DB connect info"; exit 1; }

DO_SQL=1

echo "DB connect:  $CONN"
echo "DB Command:  $@"

cmd=$1
shift
src=$1
shift
pkg=$@

[[ "$src" ]] || src="pgws"
if [ "$src" == "pgws" ] ; then
  src=$PGWS
  [[ "$pkg" != "" ]] || pkg=$PGWS_PKG
else
  src=$PGWS_APP
  [[ "$pkg" ]] || pkg=$PGWS_APP_PKG
fi

echo "DB source:   $src"
echo "DB package:  $pkg"

BLD=$PGWS_ROOT/var/build

case "$cmd" in
  init)
    db_run add "[1-8]?_*.sql" $src "$pkg"
    ;;
  drop)
    db_run del "0?_*.sql" $src "$pkg"
    ;;
  make)
    db_run make "11_*.sql [3-6]?_*.sql" $src "$pkg"
    ;;
  *)
    db_help
    ;;
esac
