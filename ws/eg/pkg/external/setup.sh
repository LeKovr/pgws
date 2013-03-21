
fetch() {
cat <<-EOF
LeKovr-jQuery-Form-3.14.zip https://nodeload.github.com/LeKovr/form/zip/3.14
LeKovr-formEV-v0.3.zip https://nodeload.github.com/LeKovr/formEV/zip/v0.3
trentrichardson-jQuery-Timepicker-Addon-v1.0.5-0.zip http://nodeload.github.com/trentrichardson/jQuery-Timepicker-Addon/zip/v1.0.5
jquery-ui-1.8.22.zip http://jquery-ui.googlecode.com/files/jquery-ui-1.8.22.zip
jquery-ui-themes-1.8.22.zip http://jquery-ui.googlecode.com/files/jquery-ui-themes-1.8.22.zip
jquery-1.7.2.min.js http://code.jquery.com/jquery-1.7.2.min.js
jquery-1.7.2.js http://code.jquery.com/jquery-1.7.2.js 
jquery.json-2.3.min.js http://jquery-json.googlecode.com/files/jquery.json-2.3.min.js
jquery.json-2.3.js http://jquery-json.googlecode.com/files/jquery.json-2.3.js
jquery-cookie-1.3.1.zip https://nodeload.github.com/carhartl/jquery-cookie/zip/v1.3.1
bootstrap-2.3.0.zip https://github.com/twitter/bootstrap/archive/v2.3.0.zip
EOF
}


DIR=downloads
SRC=src
WWW=www
WWW_skin=www/css/skin

mk_ln() {
  local src=$1
  local dest=$2
  local up="../../.."
  [[ "${dest/\/*\/}" == "${dest/\/.}" ]] || up="../../../.."
  [ -d ../www/$dest ] || mkdir -p ../www/$dest
  [ -e ../www/$dest/$src ] || ln -s $up/src/$src ../www/$dest/$src
}

mk_lnd() {
  local src=$1
  local dest=$2
  local dir=$3
  local name=$4
  [[ "$name" ]] || name=$src
  local up="../.."
  [[ "$dest" == "${dest/\/}" ]] || up="../../.."
  # js/core/minified
  [[ "$dest" != "${dest/\/*\/}" ]] && up="../../../.."

  [ -d ../www/$dest ] || mkdir -p ../www/$dest
  [ -e ../www/$dest/$name ] || ln -s $up/src/$dir$src ../www/$dest/$name
}

for d in $DIR $SRC $WWW $WWW_skin ; do
  [ -d $d ] || mkdir $d
done

pushd $DIR > /dev/null

echo "Fetch..."
fetch | while read dest src ; do
 [ -e $dest ] || curl -L -k -R -o $dest $src
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
    jQuery-Timepicker-Addon-*)
      echo "Timepicker setup"
      mk_lnd jquery-ui-timepicker-addon.js js/addon $s/
      mk_lnd jquery-ui-sliderAccess.js js/addon $s/
      mk_lnd localization js/addon $s/ i18n
      mk_lnd jquery-ui-timepicker-addon.css css $s/
      ;;
    form-*)
      echo "jquery.form setup"
      mk_lnd jquery.form.js js/addon $s/
      ;;
    formEV-*)
      echo "jquery.formEV setup"
      mk_lnd jquery.formev.js js/addon $s/
      ;;
    bootstrap-*)
      echo "bootstrap setup"
      mk_lnd bootstrap.js js/core $s/docs/assets/js/
      mk_lnd bootstrap.min.js js/core/minified $s/docs/assets/js/
      # mk_lnd bootstrap.css css $s/docs/assets/css/
      [ -e ../www/css/bootstrap.css ] && rm ../www/css/bootstrap.css
      perl -pi -e 's/..\/img/\/img\/external/g' < $s/docs/assets/css/bootstrap.css > ../www/css/bootstrap.css
      mk_lnd glyphicons-halflings.png img $s/img/
      mk_lnd glyphicons-halflings-white.png img $s/img/
      ;;
    jquery-cookie-*)
      echo "jquery cookie setup"
      mk_lnd jquery.cookie.js js/core $s/
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
popd > /dev/null

for style in amelia cerulean cosmo cyborg journal readable simplex slate spacelab spruce superhero united ; do
  if [ ! -f $WWW_skin/$style.css ] ; then
    echo "Load $style"
    curl -L -k -R -o $WWW_skin/$style.css http://bootswatch.com/$style/bootstrap.css
  fi
done

echo "Setup external files complete"
