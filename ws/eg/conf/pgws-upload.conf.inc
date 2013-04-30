  # настройка nginx-upload модуля
  # сюда будут отправляться данные из POST форм
  location ~ ^/upload/(_.*)$ {

    # увеличиваем лимит на размер загружаемых данных
#    client_max_body_size 250m;
    client_max_body_size 2m;

    # бэкенд, который выполнится уже после загрузки данных
    upload_pass /api/$1;
    # и директория, куда сохраняются загруженные файлы
    # значение без последнего каталога должно совпадать с FILE_STORE_PATH в config.json
    upload_store =FILE_STORE_ROOT==FILE_URI=/upload; # 1;

    # укажем, какие дополнительные данные передать бэкенду
    upload_set_form_field         name    "$upload_file_name";
    upload_set_form_field         ctype   "$upload_content_type";
    upload_set_form_field         _path   "$upload_tmp_path";

    # значение должно совпадать с FE_REALM_UPLOAD в config.json
    upload_set_form_field         _realm  "upload:=PSW_UPLOAD=";

    # Inform backend about hash and size of a file
    upload_aggregate_form_field   _csum   "$upload_file_sha1";
    upload_aggregate_form_field   _size   "$upload_file_size";

    # Pass matching fields from client to backend
    upload_pass_form_field        "^(anno|sid|id)$";

    # в случае возникновения этих ошибок файлы будут удалены
    upload_cleanup 400 404 405 413 499 500-505;

    # урезаем скорость
    # это мне необходимо для долгой загрузки файлов
    # чтобы дебажить скрипт и успеть налюбоваться на процесс загрузки
     upload_limit_rate 10k;

    # включаем информирование для "upload" (см. в начале)
    track_uploads proxied 1m;
  }

  # сюда приходят ajax-запросы со страницы
  location = /upload/status {

    # информируем их о процессе загрузки
    report_uploads proxied;
  }

  # URI должен совпадать с FILE_URI в config.json
  location =FILE_URI=/ {
    internal;
    root                          =FILE_STORE_ROOT=;
  }
