
fetch() {
cat <<-EOF
LeKovr-jQuery-Form-3.14.zip https://nodeload.github.com/LeKovr/form/zipball/3.14
LeKovr-formEV-v0.3.zip https://nodeload.github.com/LeKovr/formEV/zipball/v0.3
trentrichardson-jQuery-Timepicker-Addon-v1.0.1-0.zip http://nodeload.github.com/trentrichardson/jQuery-Timepicker-Addon/zipball/v1.0.1
jquery-ui-1.8.22.zip http://jquery-ui.googlecode.com/files/jquery-ui-1.8.22.zip
jquery-ui-themes-1.8.22.zip http://jquery-ui.googlecode.com/files/jquery-ui-themes-1.8.22.zip
jquery-1.7.2.min.js http://code.jquery.com/jquery-1.7.2.min.js
jquery-1.7.2.js http://code.jquery.com/jquery-1.7.2.js 
jquery.json-2.3.min.js http://jquery-json.googlecode.com/files/jquery.json-2.3.min.js
jquery.json-2.3.js http://jquery-json.googlecode.com/files/jquery.json-2.3.js
EOF
}


DIR=downloads
SRC=src
WWW=www


mk_ln() {
  local src=$1
  local dest=$2
  [ -d ../www/$dest ] || mkdir -p ../www/$dest
  [ -e ../www/$dest/$src ] || ln -s $PWD/$src ../www/$dest/$src
}

mk_lnd() {
  local src=$1
  local dest=$2
  local dir=$3
  local name=$4
  [[ "$name" ]] || name=$src
  [ -d ../www/$dest ] || mkdir -p ../www/$dest
  [ -e ../www/$dest/$name ] || ln -s $PWD/$dir$src ../www/$dest/$name
}

for d in $DIR $SRC $WWW ; do
  [ -d $d ] || mkdir $d
done

pushd $DIR > /dev/null

echo "Fetch..."
fetch | while read dest src ; do
 [ -e $dest ] || curl -R -o $dest $src
done

echo "Make src..."
for s in * ; do
  [[ $s != ${s%.done} ]] && continue
  if [[ $s != ${s%.zip} ]] ; then
    [ -e $s.done ] && continue
    unzip $s -d ../src/ && touch $s.done
  else
    [ -e ../src/$s ] || cp -p $s ../src/
  fi
done

popd > /dev/null

pushd $SRC > /dev/null
for s in * ; do
  case "$s" in
    jquery-ui-themes-*)
      echo "theme setup"
      mk_lnd themes css $s/ ui
      ;;
    jquery-ui-*)
      echo "ui setup"
      mk_lnd ui js $s/
      ;;
    trentrichardson-jQuery-Timepicker-Addon-*)
      echo "Timepicker setup"
      mk_lnd jquery-ui-timepicker-addon.js js/addon $s/
      mk_lnd localization js/addon $s/ i18n
      mk_lnd jquery-ui-timepicker-addon.css css $s/
      ;;
    LeKovr-form-*)
      echo "jquery.form setup"
      mk_lnd jquery.form.js js/addon $s/
      ;;
    LeKovr-formEV-*)
      echo "jquery.formEV setup"
      mk_lnd jquery.formev.js js/addon $s/
      ;;
    *)
      echo "js setup ($s)"
      if [[ $s != ${s%.min.js} ]] ; then
        mk_ln $s js/core/minified
      else
        mk_ln $s js/core
      fi
    ;;
  esac
done