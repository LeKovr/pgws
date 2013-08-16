#
# Поиск динамических страниц в кэше PGWS
# при недоступности FCGI сервера

# проверим кэш если fcgi недоступен
# эта строка должна заменить последующие значение error_page, поэтому
# блок должен подключаться до pgws-site.conf

error_page                      500 502                 =200 @cacheor500;

location @cacheor500 {
  # если нет в кэше 
  error_page                      404                       =502 /.error502.html;

  root =FILE_STORE_ROOT==FILE_URI=/www-cache/$server_name;
  try_files $uri $uri/index.html =404;
}
