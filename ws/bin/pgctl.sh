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

  [[ "$src" ]] || src="pgws"
  if [ "$src" == "pgws" ] ; then
    src=$PGWS
    [[ "$pkg" != "" ]] || pkg=$PGWS_PKG
  else
    src=$PGWS_APP
    [[ "$pkg" ]] || pkg=$PGWS_APP_PKG
  fi

  # TODO
  local ver="000"

  cat <<EOF
  DB Source:   $src
  DB Package:  $pkg
  Logfile:     $LOGFILE
  ---------------------------------------------------------
EOF

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
        echo "$tag $s" >> $dirs
      done
    fi
  done
  echo "Seeking files..."
  local cat_cmd="cat"
  if [[ "$run_op" == "del" ]] ; then
    cat_cmd="tac"
    local is_tac=$(whereis -b $cat_cmd)
    [[ "$is_tac" == "$cat_cmd:" ]] && cat_cmd="tail -r"
  fi
  local p_pre=""
  $cat_cmd $dirs | while read p s ; do
    pn=${s%%/sql*}    # package name
    sn=${s#*/sql/??_} # schema name
    bd=$pn-${s#*/sql/} # build dir
    [[ "$p" != "$p_pre" ]] && echo "\\qecho '-- ******* Package: $pn --'" >> $BLD/build.sql

    [[ "$p" != "$p_pre" ]] && [[ "$pn" != "pg" ]] && echo "SELECT ws.pkg_$run_op('$pn', '$ver', '$LOGNAME', '$USERNAME', '$SSH_CLIENT');" >> $BLD/build.sql

    echo "\\qecho '-- ------- Schema: $sn'" >> $BLD/build.sql
    [ -d "$BLD/$bd" ] || mkdir $BLD/$bd
    echo -n > $BLD/errors.diff
    pushd $s > /dev/null
    for f in $file_mask ; do
      if [ -f "$f" ] ; then
        n=$(basename $f)
        echo "Found: $s/$f"
        echo "Processing file: $s/$f" >> $LOGFILE
        awk "{gsub(/-- FD:(.*)--/, \"-- FD: $pn:$sn:$n / \" FNR \" --\")}; 1" $f > $BLD/$bd/$n
        echo "\i $bd/$n" >> $BLD/build.sql
      fi
    done
    popd > /dev/null
    if [[ "$run_op" != "del" ]] ; then
      echo "SET LOCAL search_path = i18n_def, public;" >> $BLD/build.sql

      # TODO: 01_require.sql
      for f in $s/9?_*.sql ; do
        [ -s "$f" ] || continue
        n=$(basename $f)
        echo "Found test: $f"
        echo "Processing file: $f" >> $LOGFILE
        awk "{gsub(/-- FD:(.*)--/, \"-- FD: $pn:$sn:$n / \" FNR \" --\")}; 1" $f > $BLD/$bd/$n
        n1=${n%.sql} # remove ext
        echo "\o $bd/$n1.out" >> $BLD/build.sql
        echo "\i $bd/$n" >> $BLD/build.sql
        cp $s/$n1.out $BLD/$bd/$n1.out.orig 2>>  $BLD/errors.diff
        echo "\! diff -c $bd/$n1.out.orig $bd/$n1.out | tr \"\t\" \" \" >> errors.diff" >> $BLD/build.sql
        db_run_test_end $BLD/build.sql
      done
    fi

    [[ -f "$BLD/keep_sql" ]] || echo "\! rm -rf $bd" >> $BLD/build.sql
    [[ "$p" != "$p_pre" ]] && [[ "$pn" == "pg" ]] && [[ "$run_op" == "add" ]] \
      && echo "SELECT ws.pkg_$run_op('$pn', '$ver', '$LOGNAME', '$USERNAME', '$SSH_CLIENT');" >> $BLD/build.sql
    p_pre=$p
  done
  popd > /dev/null

  db_run_sql_end $BLD/build.sql

  pushd $BLD > /dev/null
  [[ "$DO_SQL" ]] && psql -X -P footer=off -d "$CONN" -f build.sql > $LOGFILE 2>&1
  RETVAL=$?
  popd > /dev/null
  if [[ $RETVAL -eq 0 ]] ; then
    [ -f "$BLD/errors.diff" ] && rm "$BLD/errors.diff"
    local flag=$PGWS_ROOT/var/.build
    if [[ "$src" == "pgws" ]] ; then
      local flagfile=${flag}.pgws
    else
      local flagfile=${flag}.pkg
    fi
    [[ "$run_op" == "add" ]] && touch $flagfile
    [[ "$run_op" == "del" ]] && [ -f $flagfile ] && rm $flagfile
    echo "Complete"
  else
    echo "*** Errors:"
    grep ERROR $LOGFILE || echo "    None."
    [ -s "$BLD/errors.diff" ] && { echo "*** Diff:" ; cat "$BLD/errors.diff" ; }
  fi

}

# ------------------------------------------------------------------------------
db_dump() {
  local schema=$1
  [[ "$schema" ]] || schema="i18n_def"
  local file=$BLD/$schema.sql
  [ -f $file ] && rm -f $file
  pg_dump -F p -f $file -n $schema -O --inserts --no-tablespaces -E UTF-8 "$CONN";
  echo "Dump of $schema saved to $file"
}

# ------------------------------------------------------------------------------
db_doc() {
  local schema=$1
  [[ "$schema" ]] || schema="ws"

  local bin="postgresql_autodoc"
  local has_bin=$(whereis -b $bin)
  if [[ "$has_bin" == "$bin:" ]] ; then
    echo "$bin must be installed to use doc feature"
    exit
  fi
  c=${CONN#dbname=}
  postgresql_autodoc -s $schema -f $BLD/$schema -d "$c"
}
# ------------------------------------------------------------------------------
db_help() {
cat <<EOF
  Usage:
    $0 db (init|make|drop|doc) [SRC] [PKG]

  Where
    init - create DB objects
    make - compile code
    drop - drop DB objects
    doc  - make docs for schema SRC (Default: ws)
    dump - dump schema SRC (Default: i18n_def)

    SRC  - pgws|pkg. Default: pgws
    PKG  - dirname(s) from SRC. Default: "$PGWS_PKG" (if SRC=pgws) or "$PGWS_APP_PKG"
EOF
}

# ------------------------------------------------------------------------------
CONN=$(perl $PGWS_ROOT/$PGWS/$PGWS_WS/bin/json2conninfo.pl < $PGWS_ROOT/conf/db.json)
[[ "$CONN" ]] || { echo "Fatal: No DB connect info"; exit 1; }

DO_SQL=1
BLD=$PGWS_ROOT/var/build

cat <<EOF
  DB Command:  $@
  DB Connect:  $CONN
  ---------------------------------------------------------
EOF

cmd=$1
shift
src=$1
shift
pkg=$@

case "$cmd" in
  init)
    db_run add "[1-9]?_*.sql" $src "$pkg"
    ;;
  drop)
    db_run del "0?_*.sql" $src "$pkg"
    ;;
  make)
    db_run make "11_*.sql [3-6]?_*.sql" $src "$pkg"
    ;;
  doc)
    db_doc $src
    ;;
  dump)
    db_dump $src
    ;;
  *)
    db_help
    ;;
esac
