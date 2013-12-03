
# run only when www does not exists
[ -d www ] && exit

fetch() {
cat <<-EOF
LeKovr-jQuery-Form-3.14.zip https://codeload.github.com/LeKovr/form/zip/3.14
LeKovr-formEV-v0.3.zip https://codeload.github.com/LeKovr/formEV/zip/v0.3
trentrichardson-jQuery-Timepicker-Addon-v1.0.5-0.zip https://codeload.github.com/trentrichardson/jQuery-Timepicker-Addon/zip/v1.0.5
#jquery-ui-1.8.22.zip http://jquery-ui.googlecode.com/files/jquery-ui-1.8.22.zip
jquery-ui-1.10.3.zip http://jqueryui.com/resources/download/jquery-ui-1.10.3.zip
#jquery-ui-themes-1.8.22.zip http://jquery-ui.googlecode.com/files/jquery-ui-themes-1.8.22.zip
jquery-ui-themes-1.10.3.zip http://jqueryui.com/resources/download/jquery-ui-themes-1.10.3.zip
jquery-1.7.2.min.js http://code.jquery.com/jquery-1.7.2.min.js
jquery-1.7.2.js http://code.jquery.com/jquery-1.7.2.js 
jquery.json-2.3.min.js http://jquery-json.googlecode.com/files/jquery.json-2.3.min.js
jquery.json-2.3.js http://jquery-json.googlecode.com/files/jquery.json-2.3.js
jquery-cookie-1.3.1.zip https://codeload.github.com/carhartl/jquery-cookie/zip/v1.3.1
bootstrap-2.3.1.zip https://github.com/twbs/bootstrap/archive/v2.3.1.zip
bootswatch-2.3.1.zip https://github.com/thomaspark/bootswatch/archive/v2.3.1.zip
highlight.zip http://softwaremaniacs.org/soft/highlight/download/ "bash.js=on&css.js=on&diff.js=on&xml.js=on&http.js=on&ini.js=on&json.js=on&javascript.js=on&perl.js=on&sql.js=on&markdown.js=on&nginx.js=on"  
bootbox.js https://github.com/makeusabrew/bootbox/releases/v3.3.0/1140/bootbox.js
jquery.fileupload-8.4.2.zip https://github.com/blueimp/jQuery-File-Upload/archive/8.4.2.zip
bootstrap-datepicker.zip https://codeload.github.com/eternicode/bootstrap-datepicker/legacy.zip/v1.0.1
bootstrap-timepicker.zip https://codeload.github.com/tarruda/bootstrap-datetimepicker/zip/master
qunit.zip https://github.com/jquery/qunit/archive/master.zip
bootstrap-wysiwyg.zip https://github.com/mindmup/bootstrap-wysiwyg/archive/master.zip

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
  [ -e ../www/$dest/$src ] || cp -pr $src ../www/$dest/$src
}

mk_lnd() {
  local src=$1
  local dest=$2
  local dir=$3
  local name=$4
  [[ "$name" ]] || name=$src

  [ -d ../www/$dest ] || mkdir -p ../www/$dest
  [ -e ../www/$dest/$name ] || cp -pr $dir$src ../www/$dest/$name
}

for d in $DIR $WWW $WWW_skin ; do
  [ -d $d ] || mkdir -p $d
done

pushd $DIR > /dev/null

echo "Fetch..."
fetch | while read dest src post; do
  [[ $dest != ${dest###} ]] && continue
  [[ "$post" ]] && post="-d \"$post\""
  [ -e $dest ] || curl -L -k -R $post -o $dest $src
done

echo "Make src..."
for s in * ; do
  [[ $s != ${s%.done} ]] && continue
  if [[ $s != ${s%.zip} ]] ; then
    [ -e $s.done ] && continue
    unzip $s -d ../src/ && touch $s.done
  else
    [ -e ../src/$s ] || cp -pr $s ../src/
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
    bootstrap-2.*)
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
    jQuery-File-Upload*)
      echo "Fileupload setup"
      mk_lnd jquery.fileupload.js js/core $s/js/
      mk_lnd jquery.fileupload-ui.css css $s/css/
      ;;
    eternicode-bootstrap-datepicker*)
      echo "bootstrap-datepicker setup"
      mk_lnd bootstrap-datepicker.js js/core $s/js/
      mk_lnd bootstrap-datepicker.ru.js js/core $s/js/locales/
      mk_lnd datepicker.css css $s/css/
      ;;
    bootstrap-datetimepicker*)
      echo "bootstrap-timepicker setup"
      mk_lnd bootstrap-datetimepicker.min.js js/core $s/build/js/
      mk_lnd bootstrap-datetimepicker.min.css css $s/build/css/
      ;;
    qunit-master*)
      echo "qunit setup"
    #  mk_lnd qunit.js js/core $s/src/
      mk_lnd qunit.css css $s/src/
    ;;
    bootstrap-wysiwyg-master*)
      echo "bootstrap-wysiwyg-master setup"
      mk_lnd bootstrap-wysiwyg.js js/core $s/
      mk_lnd jquery.hotkeys.js js/core $s/external/
    ;;
    bootswatch-*)
      echo "bootswatch skins setup"
      for style in amelia cerulean cosmo cyborg journal readable simplex slate spacelab spruce superhero united ; do
        if [ ! -f ../$WWW_skin/$style.css ] ; then
          echo "Link $style"
          perl -pi -e 's/..\/img/\/img\/external/g' < $s/$style/bootstrap.css > ../$WWW_skin/$style.css
        fi
      done
      ;;
    highlight.js)
      echo "highlight setup"
      mk_lnd highlight.pack.js js/addon $s/
      mk_lnd default.css css/highlight $s/styles/
      ;;
    *)
      echo "js setup ($s)"
      if [[ $s != ${s%.min.js} ]] ; then
        mk_ln $s js/core/minified
      elif [[ $s != ${s%.js} ]] ; then
        mk_ln $s js/core
      fi
    ;;
  esac
done
popd > /dev/null

echo "Setup external files complete"
