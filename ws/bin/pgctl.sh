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

AWK_BIN=gawk
# ------------------------------------------------------------------------------
db_anno() {
  echo "  db    - Database control"
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
    erase - drop DB objects

    doc  - make docs for schema SRC (Default: ws)
    dump - dump schema SRC (Default: i18n_def)

    restore KEY - restore schema(s) from dbdump-KEY.tar.gz

    SRC  - pgws|pkg. Default: pgws
    PKG  - dirname(s) from SRC. Default: "$PGWS_PKG" (if SRC=pgws) or "$PGWS_APP_PKG"

EOF
}

# ------------------------------------------------------------------------------
db_show_logfile() {
  cat <<EOF
  Logfile:     $LOGFILE
  ---------------------------------------------------------
EOF
}

# ------------------------------------------------------------------------------
db_run_sql_begin() {
  local file=$1
  cat > $file <<EOF
/* ------------------------------------------------------------------------- */
\qecho '-- _build.sql / BEGIN --'

BEGIN;
\set ON_ERROR_STOP 1
SET CLIENT_ENCODING TO 'utf-8';
EOF
  if [[ "$BUILD_DEBUG" ]] ; then
    echo "SET CLIENT_MIN_MESSAGES TO 'DEBUG';" >> $file
  else
    echo "SET CLIENT_MIN_MESSAGES TO 'WARNING';" >> $file
  fi
}

# ------------------------------------------------------------------------------
db_run_sql_end() {
  local file=$1
  cat >> $file <<EOF
COMMIT;

\qecho '-- _build.psql / END --'
/* ------------------------------------------------------------------------- */
EOF
}

# ------------------------------------------------------------------------------
db_run_test() {
  local bd=$1
  local test=$2
  local name=$3
  local point=$4
  local file=$5
  cat >> $file <<EOF
SAVEPOINT ${point}_test;
\o $bd/$name.out
\i $bd/$n
\o
ROLLBACK TO SAVEPOINT ${point}_test;
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
is_file_protected() {
  local pkg=$1
  local ver=$2
  local file=$3

  ${PG_BINDIR}psql -X -d "$CONN" -P tuples_only -c "SELECT code FROM wsd.pkg_script_protected WHERE pkg = '$pkg' AND ver='$ver' AND code = '$file'" 2>> /dev/null | while read result ; do
    [[ "$result" == "$file" ]] && echo "1"
  done
}

# ------------------------------------------------------------------------------
TEST_CNT="0"
TEST_TTL="0"

log() {
  local test_total=$1
  ret="0"
  while read data
  do
    d=${data#* WARNING:  ::}
    if [[ "$data" != "$d" ]] ; then
     [[ "$TEST_CNT" == "0" ]] || echo "Ok"
     TEST_CNT=$(($TEST_CNT+1))
     [[ "$d" ]] && echo -n "($TEST_CNT/$TEST_TTL) $d "
    else
      [[ "$TEST_CNT" == "0" ]] || echo "FAIL"
      echo "$data" >> ${LOGFILE}.err
      echo "$data"
      ret="1"
    fi
  done
  return $ret
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
    [[ "$src" == "pkg" ]] || pkg="$src $pkg"
    src=$PGWS_APP
    [[ "$pkg" ]] || pkg=$PGWS_APP_PKG
  fi

  # TODO
  local ver="000"

  cat <<EOF
  DB Source:   $src
  DB Package:  $pkg
EOF
  db_show_logfile

  schema_mask="??_*"
  db_run_sql_begin $BLD/build.sql

  log_end=""
  op_is_del=""
  [[ "$run_op" == "del" || "$run_op" == "erase" ]] && op_is_del=1
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
  if [[ "$op_is_del" ]] ; then
    cat_cmd="tac"
    local is_tac=$(whereis -b $cat_cmd)
    [[ "$is_tac" == "$cat_cmd:" ]] && cat_cmd="tail -r"
  fi
  local p_pre=""
  echo -n "0" > $BLD/test.cnt
  $cat_cmd $dirs | while read p s ; do
    pn=${s%%/sql*}    # package name
    sn=${s#*/sql/??_} # schema name
    bd=$pn-${s#*/sql/} # build dir
    dn="${sn}_data"   # persistent data schema
    [[ "$pn" == "pg" ]] && pn="ws" # system package got project name
    if [[ "$p" != "$p_pre" ]] ; then
      echo "\\qecho '-- ******* Package: $pn --'" >> $BLD/build.sql
      echo "\\set PKG $pn" >> $BLD/build.sql
      echo "\\set VER $ver" >> $BLD/build.sql
      # операция add для всех пакетов, кроме ws, регистрируется в начале
      if [[ "$p" != "$p_pre" ]] && [[ "$pn" != "ws" ]] && [[ "$run_op" == "add" ]] ; then
        echo "SELECT ws.pkg_$run_op('$pn', '$ver', '$LOGNAME', '$USERNAME', '$SSH_CLIENT');" >> $BLD/build.sql
        p_pre=$p
      fi
    fi
    echo "\\qecho '-- ------- Schema: $sn'" >> $BLD/build.sql

    [ -d "$BLD/$bd" ] || mkdir $BLD/$bd
    echo -n > $BLD/errors.diff
    pushd $s > /dev/null
    for f in $file_mask ; do
      if [ -f "$f" ] ; then
        n=$(basename $f)
#        echo "Found: $s/$f"
        echo "Processing file: $s/$f" >> $LOGFILE
        # вариант с заменой 1го вхождения + поддержка plperl
        $AWK_BIN "{ print gensub(/(\\\$_\\\$)($| +#?)/, \"\\\1\\\2 /* $pn:$sn:\" FILENAME \" / \" FNR \" */ \",\"g\")};" $f > $BLD/$bd/$n
        # вариант без удаления прошлых комментариев
        # awk "{gsub(/\\\$_\\\$(\$| #?)/, \"/* $pn:$sn:$n / \" FNR \" */ \$_\$ /* $pn:$sn:$n / \" FNR \" */ \")}; 1" $f > $BLD/$bd/$n
        # вариант с удалением прошлых комментариев
        # awk "{gsub(/(\/\* .+ \/ [0-9]+ \*\/ )?\\\$_\\\$( \/\* .+ \/ [0-9]+ \*\/)?/, \"/* $pn:$sn:$n / \" FNR \" */ \$_\$ /* $pn:$sn:$n / \" FNR \" */ \")}; 1" $f > $BLD/$bd/$n
        local is_prot=$(is_file_protected $pn $ver $n)
        if [[ ! $is_prot ]]; then
          echo "\\qecho '----- $pn:$sn:$n -----'">> $BLD/build.sql
          echo "\\set FILE $n" >> $BLD/build.sql
          echo "\i $bd/$n" >> $BLD/build.sql
        else
          echo "\\qecho '----- PROTECTED FILE $pn:$sn:$n -----'">> $BLD/build.sql
        fi
      fi
    done
    popd > /dev/null
    if [[ ! "$op_is_del" ]] ; then
      echo "SET LOCAL search_path = i18n_def, public;" >> $BLD/build.sql

      # TODO: 01_require.sql
      for f in $s/9?_*.sql ; do
        [ -s "$f" ] || continue
        n=$(basename $f)
#        echo "Found test: $f"
        echo "Processing file: $f" >> $LOGFILE
        c=$(grep -ciE "^\s*select\s+ws.test\(" $f)
        [[ "$c" ]] && echo -n "+$c" >> $BLD/test.cnt
        cp -p $f $BLD/$bd/$n # no replaces in test file
        n1=${n%.sql} # remove ext
        db_run_test $bd $n $n1 $sn $BLD/build.sql
        cp $s/$n1.out $BLD/$bd/$n1.out.orig 2>>  $BLD/errors.diff
        echo "\! diff -c $bd/$n1.out.orig $bd/$n1.out | tr \"\t\" \" \" >> errors.diff" >> $BLD/build.sql
        db_run_test_end $BLD/build.sql
      done
    fi

    [[ -f "$BLD/keep_sql" ]] || echo "\! rm -rf $bd" >> $BLD/build.sql

    [[ "$p" != "$p_pre" ]] && ( [[ "$pn" != "ws" ]] || [[ ! "$op_is_del" ]] ) \
      && echo "SELECT ws.pkg_$run_op('$pn', '$ver', '$LOGNAME', '$USERNAME', '$SSH_CLIENT');" >> $BLD/build.sql
    p_pre=$p
  done

  test_op=$(cat $BLD/test.cnt)
  TEST_TTL=$(($test_op))
  rm $BLD/test.cnt
  popd > /dev/null

  db_run_sql_end $BLD/build.sql
  # print last "Ok"
  [[ "$op_is_del" ]] || echo "SELECT ws.test(NULL);" >> $BLD/build.sql
  pushd $BLD > /dev/null
  echo "Running build.sql..."
  [[ "$DO_SQL" ]] && ${PG_BINDIR}psql -X -P footer=off -d "$CONN" -f build.sql 3>&1 1>$LOGFILE 2>&3 | log $TEST_TTL
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
    [[ "$op_is_del" ]] && [ -f $flagfile ] && rm $flagfile
    echo "Complete"
  else
#    echo "*** Errors found"
#    grep ERROR $LOGFILE || echo "    None."
    [ -s "$BLD/errors.diff" ] && { echo "*** Diff:" ; cat "$BLD/errors.diff" ; }
  fi

}

# ------------------------------------------------------------------------------
db_dump() {
  local schema=$1
  [[ "$schema" ]] || schema="i18n_def"
  local file=$BLD/$schema.sql
  [ -f $file ] && rm -f $file
  ${PG_BINDIR}pg_dump -F p -f $file -n $schema -O --inserts --no-tablespaces -E UTF-8 "$CONN";
  echo "Dump of $schema saved to $file"
}

# ------------------------------------------------------------------------------
db_dumpdata() {
  local key=$(date "+%y%m%d_%H%M")
  local file=$PGWS_ROOT/var/dbdump-$key.tar
  echo "Dumping *_data to $file.gz..."
  [ -f $file.gz ] && { echo "File exists. Aborting" ; exit ; }
  ${PG_BINDIR}pg_dump -F t -f $file -n "*_data" -E UTF-8 "$CONN"
  gzip -9 $file
  echo "Dump complete."
}

# ------------------------------------------------------------------------------
db_restoredata() {
  local key=$1
  local file=$PGWS_ROOT/var/dbdump-$key.tar
  db_show_logfile

  # [ -L $file.gz ] && { filegz=$(readlink $file.gz); file=${filegz%.gz} ; }
  echo "Restoring *_data from $file.gz..."
  [ -f $file ] || gunzip $file.gz
  ${PG_BINDIR}pg_restore -d "$CONN" --single-transaction $file > $LOGFILE 2>&1
  RETVAL=$?
  if [[ $RETVAL -eq 0 ]] ; then
    echo "Restore complete."
  else
    echo "*** Errors:"
    grep ERROR $LOGFILE || echo "    None."
  fi
}

# ------------------------------------------------------------------------------
db_dropdata() {
  db_show_logfile
  ${PG_BINDIR}psql -X -d "$CONN" -P tuples_only -c "SELECT code FROM ws_data.pkg_oper" 2>> $LOGFILE | while read schema ; do
    if [[ "$schema" ]] ; then
      echo "Dropping schema $schema..."
      ${PG_BINDIR}psql -X -d "$CONN" -c "DROP SCHEMA $schema CASCADE" >> $LOGFILE 2>&1
    fi
  done
  grep ERROR $LOGFILE || echo "Dropdata complete."
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

CONN=$(perl $PGWS_ROOT/$PGWS/$PGWS_WS/bin/json2var.pl DB < $PGWS_ROOT/config.json)
[[ "$CONN" ]] || { echo "Fatal: No DB connect info"; exit 1; }

DO_SQL=1
BLD=$PGWS_ROOT/var/build

[[ "$cmd" == "anno" ]] || cat <<EOF
  Connect:  $CONN
  ---------------------------------------------------------
EOF

cmd=$1
shift
src=$1
shift
pkg=$@

case "$cmd" in
  init)
    db_run add "[1-8]?_*.sql" $src "$pkg"
    ;;
  drop)
    db_run del "00_*.sql" $src "$pkg"
    ;;
  erase)
    db_run erase "0?_*.sql" $src "$pkg"
    ;;
  make)
    db_run make "19_*.sql [3-6]?_*.sql" $src "$pkg"
    ;;
  doc)
    db_doc $src
    ;;
  dump)
    db_dump $src
    ;;
#  dumpdata)
#    db_dumpdata
#    ;;
#  restoredata)
#    db_restoredata $src
#    ;;
#  dropdata)
#    db_dropdata
#    ;;
  anno)
    db_anno
    ;;
  *)
    db_help
    ;;
esac
