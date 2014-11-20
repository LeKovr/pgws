/*

    Copyright (c) 2010, 2012 Tender.Pro http://tender.pro.

    This file is part of PGWS - Postgresql WebServices.

    PGWS is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    PGWS is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with PGWS.  If not, see <http://www.gnu.org/licenses/>.

    Реестр свойств.
*/

/* ------------------------------------------------------------------------- */
INSERT INTO prop (code,                 pogc_list,                  def_value, name) VALUES

  ('ws.daemon.db.sql.:i',               ARRAY['db'],                '',       'SQL настройки соединения с БД')

, ('ws.daemon.startup.sock_wait',       ARRAY['fcgi' ],             '10',     'Максимальная длина очереди ожидающих входящих запросов FCGI до обрыва новых соединений, шт')

, ('ws.daemon.startup.pm.n_processes',  ARRAY['fcgi'],              '5',     'Количество запускаемых процессов, шт')
, ('ws.daemon.startup.pm.die_timeout',  ARRAY['fcgi'],              '4',      'Время ожидания корректного завершения процесса, сек')

, ('ws.daemon.fcgi.frontend_poid',      ARRAY['fcgi'],              '1',      'POID настроек фронтенда')
, ('ws.daemon.fcgi.core_poid',          ARRAY['fcgi'],              '1',      'POID настроек бэкенда')

, ('ws.daemon.fe.tmpl.frame_default',   ARRAY['fe'],                'default','Название фрейма страниц по умолчанию')
, ('ws.daemon.fe.tmpl.css.cookie',      ARRAY['fe'],                'PGWS_css','Название cookie для хранения названия css')
, ('ws.daemon.lang.default',            ARRAY['fe','be'],           ws.const_lang_default(),     'Код язык сайта по умолчанию')
, ('ws.daemon.lang.allowed.:i',         ARRAY['fe','be'],           '',       'Допустимые коды языка сайта')
, ('ws.daemon.fe.tt2.:s',               ARRAY['fe'],                '',       'Параметр конфигурации TemplateToolkit')

, ('ws.daemon.fe.sid_arg',              ARRAY['fe'],                '',       'Если задан - брать ID сессии из этого аргумента запроса, а не из cookie')
, ('ws.daemon.fe.error_500',            ARRAY['fe'],                '/error/','Адрес внешнего редиректа при фатальной ошибке PGWS')
, ('ws.daemon.fe.site_is_hidden',       ARRAY['fe'],                '1',      'Не выводить внешние счетчики на страницах')

, ('ws.daemon.fe.def.sid',              ARRAY['fe'],                'account.sid_info',   'Метод получения информации о сессии')
, ('ws.daemon.fe.def.login',            ARRAY['fe'],                'account.login',  'Метод авторизации')
, ('ws.daemon.fe.def.logout',           ARRAY['fe'],                'account.logout', 'Метод завершения сессии')

, ('ws.daemon.fe.def.acl',              ARRAY['fe'],                'info.acl_check', '')
, ('ws.daemon.fe.def.uri',              ARRAY['fe'],                'ws.page_by_uri', 'Метод получения страницы по URI')
, ('ws.daemon.fe.def.code',             ARRAY['fe'],                'ws.page_by_code','Метод получения страницы по коду')

, ('ws.daemon.fe.tmpl.ext',             ARRAY['fe'],                '.tt2',       'Расширение файлов шаблонов')

, ('ws.daemon.fe.tmpl.error',           ARRAY['fe'],                'app_common/error', 'Шаблон страницы описаний ошибок')
, ('ws.daemon.fe.tmpl.pages',           ARRAY['fe'],                'page/','Каталог шаблонов, вызываемых по GET-запросу')
, ('ws.daemon.fe.tmpl.jobs',            ARRAY['fe'],                'job/', 'Каталог шаблонов, вызываемых из Job')

, ('ws.daemon.be.check_prefix',         ARRAY['be'],                'check:', 'Префикс запроса на валидацию аргументов ACL')
, ('ws.daemon.be.acl_prefix',           ARRAY['be'],                'acl:',   'Префикс запроса на проверку ACL')

, ('ws.daemon.be.nocache_prefix',       ARRAY['be'],                'nc:',   'Префикс запроса без проверки кэша')

, ('ws.daemon.be.db_noacc_code',        ARRAY['be'],                '42501',   'Код ошибки БД при запрете доступа')
, ('ws.daemon.be.acl_trigger',          ARRAY['be'],                'account.log(in|out)',   'Regexp кодов методов меняющих ACL')

, ('ws.daemon.lang.sql.default',        ARRAY['be'],                'SET search_path TO i18n_def, public', 'Выбор языка по умолчанию')
, ('ws.daemon.lang.sql.other',          ARRAY['be'],                'SET search_path TO i18n_%s, i18n_def, public', 'Выбор языка')
, ('ws.daemon.lang.sql.encoding',       ARRAY['be'],                $_$SET client_encoding TO '%s'$_$, 'Выбор кодировки')

, ('ws.daemon.be.def_method.code',      ARRAY['be'],                'ws.method_by_code', '')
, ('ws.daemon.be.def_method.code_real', ARRAY['be'],                'ws.method_by_code', '')
, ('ws.daemon.be.def_method.is_sql',    ARRAY['be'],                '1', '')
, ('ws.daemon.be.def_method.rvf_id',    ARRAY['be'],                '3', '')

, ('ws.daemon.be.def.class',            ARRAY['be'],                'ws.class', '')
, ('ws.daemon.be.def.sid',              ARRAY['be'],                'account.sid_info', '')
, ('ws.daemon.be.def.err',              ARRAY['be'],                'ws.error_info', '')
, ('ws.daemon.be.def.acl',              ARRAY['be'],                'info.acl_check', '')
, ('ws.daemon.be.def.acl_eff',          ARRAY['be'],                'ws.acls_eff', '')
, ('ws.daemon.be.def.dt',               ARRAY['be'],                'ws.dt', '')
, ('ws.daemon.be.def.dt_part',          ARRAY['be'],                'ws.dt_part', '')
, ('ws.daemon.be.def.dt_facet',         ARRAY['be'],                'ws.dt_facet', '')
, ('ws.daemon.be.def.facet',            ARRAY['be'],                'ws.facet', '')
, ('ws.daemon.be.def.uncache',          ARRAY['be'],                'ws.uncache', '')

, ('ws.daemon.be.def_suffix.status',    ARRAY['be'],                '.status', '')
, ('ws.daemon.be.def_suffix.acl',       ARRAY['be'],                '.acl', '')

, ('ws.daemon.be.plugin.:s.lib',        ARRAY['be'],                '',       'Пакет плагина')
, ('ws.daemon.be.plugin.:s.pogc',       ARRAY['be'],                '',       'POGC настроек плагина (если используется)')
, ('ws.daemon.be.plugin.:s.poid',       ARRAY['be'],                '',       'POID настроек плагина')
, ('ws.daemon.be.plugin.:s.data_set',   ARRAY['be'],                '',       'Сохранять дамп настроек плагина')

, ('ws.plugin.cache.code',              ARRAY['cache'],             '',       'Код кэша')
, ('ws.plugin.cache.is_active',         ARRAY['cache'],             '1',      'Кэш включен')
, ('ws.plugin.cache.cache_size',        ARRAY['cache'],             '1024k',  'Размер кэша')
, ('ws.plugin.cache.page_size',         ARRAY['cache'],             '64k',    'Максимальный размер элемента хранения')
, ('ws.plugin.cache.expire_time',       ARRAY['cache'],             '10s',    'Максимальное время хранения элемента')
, ('ws.plugin.cache.enable_stats',      ARRAY['cache'],             '1',      'Собирать статистику работы с кэшем')

, ('ws.daemon.be.error.:s.code',        ARRAY['be'],                '', 'Код ошибки JSON-RPC 2.0')
, ('ws.daemon.be.error.:s.message',     ARRAY['be'],                '', 'Название ошибки JSON-RPC 2.0')
, ('ws.daemon.be.error.:s.data',        ARRAY['be'],                '', 'Аннотация ошибки JSON-RPC 2.0')

, ('ws.daemon.log.encoding',                            ARRAY['be','fe'],             'UTF-8', 'Кодировка по умолчанию')
, ('ws.daemon.log.default_level',                       ARRAY['be','fe'],             '3', 'Уровень детализации по умолчанию')
, ('ws.daemon.log.syslog.default.(default,init,cache)', ARRAY['be'],                  '3', 'Уровень детализации в файле для запросов инициализации ядра')

, ('ws.daemon.log.syslog.default.(default,call,sid,acl,cache,validate)',ARRAY['fe'],  '3', 'Уровень детализации в файле по умолчанию')
, ('ws.daemon.log.syslog.post.(default,call,sid,acl,cache,validate)',   ARRAY['fe'],  '3', 'Уровень детализации в файле для запросов POST')
, ('ws.daemon.log.syslog.get.(default,call,sid,acl,cache,validate)',    ARRAY['fe'],  '3', 'Уровень детализации в файле для запросов GET')
, ('ws.daemon.log.syslog.tmpl.(default,call,sid,acl,cache,validate)',   ARRAY['fe'],  '3', 'Уровень детализации в файле для запросов из шаблонов')

, ('ws.daemon.log.debug.default.(default,call,sid,acl,cache,validate)', ARRAY['fe'],  '3', 'Уровень детализации в интерфейсе по умолчанию')
, ('ws.daemon.log.debug.post.(default,call,sid,acl,cache,validate)',    ARRAY['fe'],  '3', 'Уровень детализации в интерфейсе для запросов POST')
, ('ws.daemon.log.debug.get.(default,call,sid,acl,cache,validate)',     ARRAY['fe'],  '3', 'Уровень детализации в интерфейсе для запросов GET')
, ('ws.daemon.log.debug.tmpl.(default,call,sid,acl,cache,validate)',    ARRAY['fe'],  '3', 'Уровень детализации в интерфейсе для запросов из шаблонов')

;

/* ------------------------------------------------------------------------- */
-- ALTER TABLE wsd.prop_value ADD CONSTRAINT prop_value_code_fkey FOREIGN KEY (code) REFERENCES job.prop(code);
-- ALTER TABLE wsd.prop_value ADD CONSTRAINT prop_value_group_id_fkey FOREIGN KEY (group_id) REFERENCES job.prop_group(id);

/*
  для совместимости с версиями, где уже установлен 83_prop_val_wsd_000.sql,
  временно добавляем устаревшие для пакета cfg свойства
  (будут удалены в 84_prop.sql)
*/
UPDATE cfg.prop SET pogc_list = array_append(pogc_list, 'tm') WHERE code IN (
  'ws.daemon.startup.pm.n_processes'
, 'ws.daemon.startup.pm.die_timeout'
);
INSERT INTO cfg.prop (code,            pogc_list,                 def_value, name) VALUES
 ('ws.daemon.mgr.listen_wait',         ARRAY['tm'],               '60',     'Время ожидания уведомления внутри итерации, сек')
, ('ws.daemon.mgr.listen.job',         ARRAY['tm'],               '',       'Канал уведомлений (NOTIFY) о добавлении задания')
;

