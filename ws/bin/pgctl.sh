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
    $0 db COMMAND [SRC] [PKG]

  Where COMMAND is one from
    init - create DB objects
    make - compile code
    drop - drop DB objects
    erase - drop DB objects

    create - create database (if shell user granted)

    comment - show column comments for table SRC

    doc  - make docs for schema SRC (Default: ws)
    dump - dump schema SRC (Default: all)
    restore - restore dump from SRC

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
-- SET CONSTRAINTS ALL DEFERRED;
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
\set TEST $bd/$name
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
file_protected_csum() {
  local pkg=$1
  local schema=$2
  local file=$3

  ${PG_BINDIR}psql -X -d "$CONN" -P tuples_only -c "SELECT csum FROM wsd.pkg_script_protected WHERE pkg = '$pkg' AND schema = '$schema' AND code = '$file'" 2>> /dev/null | while read result ; do
    echo $result
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
  local use_flag

  [[ "$src" ]] || src="pgws"
  if [ "$src" == "pgws" ] ; then
    src=$PGWS
    [[ "$pkg" != "" ]] || { pkg=$PGWS_PKG ; use_flag=1 ; }
  else
    [[ "$src" == "pkg" ]] || pkg="$src $pkg"
    src=$PGWS_APP
    [[ "$pkg" ]] || { pkg=$PGWS_APP_PKG ; use_flag=1 ; }
  fi

  cat <<EOF
  DB Source:   $src
  DB Package:  $pkg
EOF
  db_show_logfile

  schema_mask="??_*"
  db_run_sql_begin $BLD/build.sql

  log_end=""
  op_is_del=""
  [[ "$run_op" == "drop" || "$run_op" == "erase" ]] && op_is_del=1
  local path=$PGWS_ROOT/$src
  if [[ "$src" == "$PGWS" ]] ; then
    [[ "$run_op" == "init" ]] && log_end="1"
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
      echo -n "$pn: "
      echo "\\qecho '-- ******* Package: $pn --'" >> $BLD/build.sql
      echo "\\set PKG $pn" >> $BLD/build.sql
    fi
    echo "\\set SCH $sn" >> $BLD/build.sql
    echo "\\qecho '-- ------- Schema: $sn'" >> $BLD/build.sql
    if [[ "$pn:$sn" != "ws:ws" || "$run_op" != "init" ]] ; then
      # начало выполнения операции (не вызывается только для init пакета ws)
      echo "SELECT ws.pkg_op_before('$run_op', '$pn', '$sn', '$LOGNAME', '$USERNAME', '$SSH_CLIENT');" >> $BLD/build.sql
    fi

    [ -d "$BLD/$bd" ] || mkdir $BLD/$bd
    echo -n > $BLD/errors.diff
    pushd $s > /dev/null
    local search_set=""
    for f in $file_mask ; do
      if [ -f "$f" ] ; then
        echo -n "."
        n=$(basename $f)
#        echo "Found: $s/$f"
        echo "Processing file: $s/$f" >> $LOGFILE
        local csum=""
        if test $f -nt $BLD/$bd/$n ; then
          # $f is newer than $BLD/$bd/$n

          csum=$(perl -I$PGWS_ROOT/lib -MPGWS::Utils -e "print PGWS::Utils::data_sha1('$f');")
          echo "\\qecho '----- ($csum) $pn:$sn:$n -----'">> $BLD/build.sql
          # вариант с заменой 1го вхождения + поддержка plperl
          $AWK_BIN "{ print gensub(/(\\\$_\\\$)($| +#?)/, \"\\\1\\\2 /* $pn:$sn:\" FILENAME \" / \" FNR \" */ \",\"g\")};" $f > $BLD/$bd/$n
          # вариант без удаления прошлых комментариев
          # awk "{gsub(/\\\$_\\\$(\$| #?)/, \"/* $pn:$sn:$n / \" FNR \" */ \$_\$ /* $pn:$sn:$n / \" FNR \" */ \")}; 1" $f > $BLD/$bd/$n
          # вариант с удалением прошлых комментариев
          # awk "{gsub(/(\/\* .+ \/ [0-9]+ \*\/ )?\\\$_\\\$( \/\* .+ \/ [0-9]+ \*\/)?/, \"/* $pn:$sn:$n / \" FNR \" */ \$_\$ /* $pn:$sn:$n / \" FNR \" */ \")}; 1" $f > $BLD/$bd/$n
        fi
        # настройка search_path для init и make
        if [[ ! "$search_set" ]] && [[ "$n" > "12_00" ]]; then
          # echo "SET LOCAL search_path = $sn, ws, i18n_def, public;" >> $BLD/build.sql
          echo "DO \$_\$ BEGIN IF (SELECT count(1) FROM pg_namespace WHERE nspname = '$sn') > 0 THEN SET search_path = $sn, ws, i18n_def, public; ELSE SET search_path = ws, i18n_def, public; END IF; END; \$_\$;" >> $BLD/build.sql
          search_set=1
        fi

        local db_csum=""
        local skip_file=""
        if [[ "$n" =~ .+_wsd_[0-9]{3}\.sql ]]; then  # old bash: ${X%_wsd_[0-9][0-9][0-9].sql}
          # protected script
          [[ "$csum" == "" ]] && csum=$(perl -I$PGWS_ROOT/lib -MPGWS::Utils -e "print PGWS::Utils::data_sha1('$f');") # "
          local db_csum=$(file_protected_csum $pn $sn $n)
          if [[ "$db_csum" ]]; then
            if [[ "$db_csum" != "$csum" ]]; then
              echo "!!!WARNING!!! Changed control sum of protected file $f. Use 'db erase' or 'git checkout -- $f'"
              skip_file=1
            else
              # already installed. Skip
              skip_file=1
            fi
          else
            # save csum
            db_csum=$csum
          fi
        fi
        # однократный запуск PROTECTED
        if [[ ! "$skip_file" ]]; then
          echo "\\set FILE $n" >> $BLD/build.sql
          echo "\i $bd/$n" >> $BLD/build.sql
          [[ "$db_csum" ]] && echo "INSERT INTO wsd.pkg_script_protected (pkg, schema, code, csum) VALUES ('$pn', '$sn', '$n', '$db_csum');" >> $BLD/build.sql 
        else
          echo "\\qecho '----- SKIPPED PROTECTED FILE  -----'" >> $BLD/build.sql
          [[ "$db_csum" != "$csum" ]] && echo "\\qecho '!!!WARNING!!! db csum $db_csum <> file csum $csum'" >> $BLD/build.sql
        fi
      fi
    done
    popd > /dev/null
    if [[ ! "$op_is_del" ]] ; then
      # тесты для init и make
      echo "SET LOCAL search_path = i18n_def, public;" >> $BLD/build.sql

      # TODO: 01_require.sql
      [ -f $s/9?_*.inc ] && cp $s/9?_*.inc $BLD/$bd/
      for f in $s/9?_*.sql ; do
        echo -n "."
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

    # завершение выполнения операции (не вызывается только для drop/erase схемы ws пакета ws)
    ( [[ "$pn:$sn" != "ws:ws" ]] || [[ ! "$op_is_del" ]] ) \
      && echo "SELECT ws.pkg_op_after('$run_op', '$pn', '$sn', '$LOGNAME', '$USERNAME', '$SSH_CLIENT');" >> $BLD/build.sql
    p_pre=$p
    echo .
  done

  test_op=$(cat $BLD/test.cnt)
  TEST_TTL=$(($test_op))
  rm $BLD/test.cnt
  popd > /dev/null

  db_run_sql_end $BLD/build.sql
  # print last "Ok"
  [[ "$op_is_del" ]] || echo "SELECT ws.test(NULL);" >> $BLD/build.sql
  pushd $BLD > /dev/null

  # Get passwords
  PSW_JOB=$(cat psw_job)
  PSW_DEFAULT=$(cat psw_default)
  [[ "$PSW_JOB" ]] || PSW_JOB="not set. Run make clean-conf ; make conf"
  [[ "$PSW_DEFAULT" ]] || PSW_DEFAULT="not set. Run make clean-conf ; make conf"
  # не сохраняем пароли в других файлах

  echo "Running build.sql..."
  [[ "$DO_SQL" ]] && ${PG_BINDIR}psql -X -P footer=off -d "$CONN" -f build.sql \
    -v PSW_JOB="$PSW_JOB" -v PSW_DEFAULT="$PSW_DEFAULT" 3>&1 1>$LOGFILE 2>&3 | log $TEST_TTL
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
    [[ "$run_op" == "init" ]] && [[ "$use_flag" ]] && touch $flagfile
    [[ "$op_is_del" ]] && [ -f $flagfile ] && [[ "$use_flag" ]] && rm $flagfile
    echo "Complete"
    [[ "$op_is_del" ]] || echo "Default system password: $PSW_DEFAULT"
  else
#    echo "*** Errors found"
#    grep ERROR $LOGFILE || echo "    None."
    [ -s "$BLD/errors.diff" ] && { echo "*** Diff:" ; cat "$BLD/errors.diff" ; }
    exit 1
  fi

}

# ------------------------------------------------------------------------------
db_dump() {
  local schema=$1
  local format=$2
  [[ "$schema" ]] || schema="all"
  [[ "$format" == "t" ]] || format="p --inserts -O"
  local ext=".tar"
  [[ "$format" == "t" ]] || ext=".sql"
  local key=$(date "+%y%m%d_%H%M")
  local file=$PGWS_ROOT/var/dump-$schema-$key$ext
  [ -f $file ] && rm -f $file
  local schema_arg="-n $schema"
  [[ "$schema" == "all" ]] && schema_arg=""
  echo "  Dumping  $file .."
  ${PG_BINDIR}pg_dump -F $format -f $file $schema_arg --no-tablespaces -E UTF-8 "$CONN";
  echo "  Gzipping $file.gz .."
  gzip -9 $file
  echo "  Dump of $schema schema(s) complete"
}

# ------------------------------------------------------------------------------
db_restore() {
  local key=$1
  local file=$PGWS_ROOT/var/$key

  [ -f "$file" ] || { echo "Error: Dump file $file not found. " ; exit 1 ; }

  db_show_logfile

  [[ "$key" != ${key%.gz} ]] && { gunzip $file ; file=${file%.gz} ; }
  # [ -L $file.gz ] && { filegz=$(readlink $file.gz); file=${filegz%.gz} ; }
  echo "Restoring schema from $file.."
  if [[ "$file" != ${file%.tar} ]] ; then
    ${PG_BINDIR}pg_restore -d "$CONN" --single-transaction -O $file > $LOGFILE 2>&1
    RETVAL=$?
  else
    ${PG_BINDIR}psql -X -P footer=off -d "$CONN" -f $file > $LOGFILE 2>&1
    RETVAL=$?
  fi
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
  c0=${CONN#*dbname=} ; c=${c0%% *}
  postgresql_autodoc -s $schema -f $BLD/$schema -d "$c"
}

# ------------------------------------------------------------------------------
db_comment() {
  for t in $@ ; do
    echo "$t..."
    echo "/* ------------------------------------------------------------------------- */" 1>&2
    ${PG_BINDIR}psql -X -d "$CONN" -t --pset format=unaligned -c "SELECT ws.pg_comment('$t')" 1>&2
    echo "" 1>&2
  done
  echo "Done."
}

# ------------------------------------------------------------------------------
db_create() {

  local bin="createdb"
  local has_bin=$(whereis -b $bin)
  if [[ "$has_bin" == "$bin:" ]] ; then
    echo "$bin must be in search path to use this feature"
    exit
  fi
  c0=${CONN#*dbname=} ; c=${c0%% *}
  u0=${CONN#*user=} ;   u=${u0%% *}
  echo -n "Create database \"$c\"..."
  ${PG_BINDIR}psql -X -d "$CONN" -P tuples_only -c "SELECT NULL" > /dev/null 2>> $LOGFILE && { echo "Database already exists" ; exit ; }
  createdb -O $u -E UTF8 -T template0 --lc-collate=C --lc-ctype='ru_RU.UTF-8' $c && createlang plperl $c && echo "OK"
  # TODO: ALTER DATABASE $c SET lc_messages='en_US.utf8';
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
    db_run init "[1-8]?_*.sql" $src "$pkg"
    ;;
  drop)
    db_run drop "00_*.sql 02_*.sql" $src "$pkg"
    ;;
  erase)
    echo "!!!WARNING!!! Erase will drop persistent data"
    read -t 5 -n 1 -p "Continue? [N]"
    [[ "$REPLY" != ${REPLY%[yY]} ]] || { echo "No confirm" ; exit ; }
    db_run erase "0?_*.sql" $src "$pkg"
    ;;
  erase_force)
    echo "!!!WARNING!!! Erase will drop persistent data"
    read -t 5 -n 1 -p "Continue? [Y]"
    [[ "$REPLY" != ${REPLY%[nN]} ]] && { echo "No confirm" ; exit ; }
    db_run erase "0?_*.sql" $src "$pkg"
    ;;
  make)
    db_run make "1[4-9]_*.sql [3-6]?_*.sql" $src "$pkg"
    ;;
  doc)
    db_doc $src
    ;;
  comment)
    db_comment $src $@
    ;;
  dump)
    db_dump $src $@
    ;;
  restore)
    db_restore $src $@
    ;;
  create)
    db_create
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
