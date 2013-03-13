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
# i18nctl.sh - Internationalisation support control script
#

# ------------------------------------------------------------------------------
i18n_anno() {
  echo "  i18n  - i18n control"
}

# ------------------------------------------------------------------------------
i18n_help() {
  cat <<EOF

  Usage:
    $0 i18n (init|make|clean)

  Where
    init [LANG] - create or update .po files from DB and templates for LANG
    make [LANG] - compile .po files and generate schema sql for LANG
    clean [LANG] - remove temp files

    LANG - translation name. Default: en

  After schema sql generation, you should load all of them into DB with command:

    pgws.sh db init pkg i18n

EOF
}

# ------------------------------------------------------------------------------
i18n_init() {
  local lang=$1 ; shift

  # check xgettext from Locale::Maketext::Lexicon
  xbin=xgettext.pl
  local has_bin=$(whereis -b $xbin)
  if [[ "$has_bin" == "$xbin:" ]] ; then
    echo "$xbin must be installed to use i18n feature"
    exit
  fi

  # Dump database
  local schema=i18n_def
  BIN=$PGWS_ROOT/$PGWS/$PGWS_WS/bin
  DBCTL=$BIN/${PGWS_DB}ctl.sh

  # [ -f $BLD/$schema.sql ] || 
  { echo "Dumping $schema" ; . $DBCTL dump $schema ; }
  # [ -f $BLD/$schema.tpl ] || 
  { echo "Prepare tpl" ; perl $BIN/quotedump4po.pl < $BLD/$schema.sql > $BLD/$schema.i18n ; }

  # Parse templates
  pushd $PGWS_ROOT > /dev/null
  local dest=pkg/i18n/src

  # TODO: simple but runs in shell only
  # local pkgs=${PGWS_APP_PKG// /,}
  # find pkg/{$pkgs}/tmpl/ -name *.tt2 2>/dev/null > $BLD/list.tpl
  # local pkgs=${PGWS_PKG// /|}
  # find pgws/*/tmpl/ -name *.tt2 | grep -E "^pgws/($pkgs)" > $BLD/${schema}.lst
  local pkgs=${PGWS_APP_PKG// /|}
  find pkg/*/tmpl/ -name *.tt2 | grep -E "^pkg/($pkgs)" >> $BLD/${schema}.lst

  for d in database templates ; do [ -d $dest/$d ] || mkdir -p $dest/$d ; done

  echo "Parse tmpls into $dest/templates/$lang.po..."
  $xbin -f $BLD/${schema}.lst -P tt2 -W -d $lang -o $dest/templates/$lang.po

  echo "Parse sql into $dest/database/$lang.po..."
  $xbin -w var/build/$schema.i18n -P generic -d $lang -o $dest/database/$lang.po

  popd > /dev/null
}

# ------------------------------------------------------------------------------
i18n_make() {
  local lang=$1 ; shift
  BIN=$PGWS_ROOT/$PGWS/$PGWS_WS/bin
  DBCTL=$BIN/${PGWS_DB}ctl.sh

  local schema=i18n
  local dest=pkg/i18n/sql/90_${schema}_$lang

  pushd $PGWS_ROOT > /dev/null
  echo "Prepare dump file"
  perl $BIN/i18n2dump.pl $lang < $BLD/${schema}_def.i18n > $dest/20_dump.sql

}
# ------------------------------------------------------------------------------
i18n_clean() {
  local schema=i18n_def
  for ext in sql i18n lst ; do
    [ -f $BLD/$schema.$ext ] && rm -f $BLD/$schema.$ext
  done
}

# ------------------------------------------------------------------------------

cmd=$1
shift
lang=$1
shift

[[ "$lang" ]] || lang="en"

[[ "$cmd" == "anno" ]] || cat <<EOF
  Language:    $lang
  ---------------------------------------------------------
EOF

BLD=$PGWS_ROOT/var/build

case "$cmd" in
  init)
    i18n_init $lang
    ;;
  make)
    i18n_make $lang
    ;;
  clean)
    i18n_clean
    ;;
  anno)
    i18n_anno
    ;;
  *)
    i18n_help
    ;;
esac
