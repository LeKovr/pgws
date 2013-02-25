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

    Типы данных
*/

/* ------------------------------------------------------------------------- */
INSERT INTO dt (parent_code, code, anno) VALUES
  ('text',       'text',       'Текст')
, ('boolean',    'boolean',    'Да/Нет')
, ('numeric',    'numeric',    'Число')
, ('interval',   'interval',   'Интервал')
, ('timestamp',  'timestamp',  'Момент')
, ('time',       'time',       'Время')
, ('date',       'date',       'Дата')
, ('inet',       'inet',       'ip адрес')
, ('real',       'real',       'Число')
, ('integer',    'integer',    'Целое')
, ('smallint',   'smallint',   'Короткое целое')
, ('oid',        'oid',        'OID')
, ('double',     'double',     'Длинное вещественное число')
, ('bigint',     'bigint',     'Длинное целое')
, ('json',       'json',       'Данные в формате JSON')
, ('uuid',       'uuid',       'Universally Unique IDentifier')
;

-- parent для массива хэшей, но они пока не поддерживаются DBD::Pg
-- INSERT INTO dt (id, parent_code, code, anno) VALUES (21, 21, 'composite', 'Структура');


/* ------------------------------------------------------------------------- */
INSERT INTO facet (id, code, anno) VALUES
  ( 1, 'length',         'Длина')
, ( 2, 'minLength',      'Мин. длина')
, ( 3, 'maxLength',      'Макс. длина')
, ( 4, 'pattern',        'Шаблон')
, ( 5, 'enumeration',    'Список значений')
, ( 6, 'whiteSpace',     'Обработка пробелов') --  (preserve|replace|collapse)
, ( 7, 'maxInclusive',   'Не больше')
, ( 8, 'maxExclusive',   'Меньше')
, ( 9, 'minExclusive',   'Больше')
, (10, 'minInclusive',   'Не меньше')
, (11, 'totalDigits',    'Количество знаков')
, (12, 'fractionDigits', 'Знаков дробной части')
;

INSERT INTO facet_dt_base (id, base_code) VALUES
  ( 1, 'text')
, ( 2, 'text')
, ( 3, 'text')
, ( 6, 'text')

, ( 7, 'numeric')
, ( 8, 'numeric')
, ( 9, 'numeric')
, (10, 'numeric')
, (11, 'numeric')
, (12, 'numeric')

, ( 7, 'integer')
, ( 8, 'integer')
, ( 9, 'integer')
, (10, 'integer')
, (11, 'integer')

, ( 7, 'smallint')
, ( 8, 'smallint')
, ( 9, 'smallint')
, (10, 'smallint')
, (11, 'smallint')
;

-- parent для массива хэшей, но они пока не поддерживаются DBD::Pg
INSERT INTO facet_dt_base SELECT 4, code FROM dt WHERE code = parent_code; --  AND id <> dt_code('composite');

INSERT INTO dt_facet (code, facet_id, value, anno) VALUES (dt_code('boolean'), facet_id('pattern'), E'^([01tf]|on|off)$', 'только 0,1,t,f,on или off');
INSERT INTO dt_facet (code, facet_id, value, anno) VALUES (dt_code('numeric'), facet_id('pattern'), E'^(\\+|\\-)?(\\d)*(\\.\\d+)?$','[знак]целая часть[.дробная часть]');
INSERT INTO dt_facet (code, facet_id, value, anno) VALUES (dt_code('real'), facet_id('pattern'), E'^(\\+|\\-)?(\\d)*(\\.\\d+)?$','[знак]целая часть[.дробная часть]');
INSERT INTO dt_facet (code, facet_id, value, anno) VALUES (dt_code('integer'), facet_id('pattern'), E'^(\\+|\\-)?\\d+$', '[знак]цифры');
INSERT INTO dt_facet (code, facet_id, value, anno) VALUES (dt_code('smallint'), facet_id('pattern'), E'^(\\+|\\-)?\\d+$', '[знак]цифры');
INSERT INTO dt_facet (code, facet_id, value, anno) VALUES (dt_code('bigint'),  facet_id('pattern'), E'^(\\+|\\-)?\\d+$', '[знак]цифры');

INSERT INTO dt_facet VALUES (dt_code('oid'), facet_id('pattern'), E'^\d+$');

-- TODO: INSERT INTO dt_facet VALUES (dt_code('uuid'), facet_id('pattern'), E'????');

INSERT INTO dt_facet (code, facet_id, value, anno) VALUES (dt_code('date'), facet_id('pattern'), E'^\\d{1,2}\\.\\d{2}\\.\\d{4}$', 'ДД.ММ.ГГГГ');

-- INSERT INTO dt_facet VALUES (dt_code('integer'), facet_id('fractionDigits'), 0);
INSERT INTO dt_facet VALUES (dt_code('integer'), facet_id('minInclusive'), -2147483648);
INSERT INTO dt_facet VALUES (dt_code('integer'), facet_id('maxInclusive'), 2147483647);

INSERT INTO dt_facet VALUES (dt_code('smallint'), facet_id('minInclusive'), -32768);
INSERT INTO dt_facet VALUES (dt_code('smallint'), facet_id('maxInclusive'), 32767);

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_id'), dt_code('integer'), 'Идентификатор');

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_id32'), dt_code('smallint'), 'Идентификатор справочника');

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_stamp'), dt_code('timestamp'), 'Момент времени с точностью до секунды');
INSERT INTO dt_facet (code, facet_id, value, anno) VALUES (dt_code('d_stamp'), facet_id('pattern')
, E'^\\d{1,2}\\.\\d{2}\\.\\d{4}(?: +| +/ +)\\d{2}:\\d{2}(:\\d{2})?$', 'ДД.ММ.ГГГГ ЧЧ:ММ[:СС]');

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_rating'), dt_code('numeric'), 'Рейтинг компании');
INSERT INTO dt_facet VALUES (dt_code('d_rating'), facet_id('minInclusive'), -2);
INSERT INTO dt_facet VALUES (dt_code('d_rating'), facet_id('maxInclusive'), 2);

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_sort'), dt_code('smallint'), 'Порядок сортировки');
INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_regexp'), dt_code('text'), 'Регулярное выражение');

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_decimal_positive'), dt_code('numeric'), 'Вещественное > 0');
INSERT INTO dt_facet VALUES (dt_code('d_decimal_positive'), facet_id('minExclusive'), 0);

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_id_positive'), dt_code('integer'), 'Целое > 0');
INSERT INTO dt_facet VALUES (dt_code('d_id_positive'), facet_id('minExclusive'), 0);

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_decimal_non_neg'), dt_code('numeric'), 'Вещественное >= 0');
INSERT INTO dt_facet VALUES (dt_code('d_decimal_non_neg'), facet_id('minInclusive'), 0);

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_sid'), dt_code('text'), 'Идентификатор сессии');

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_zip'), dt_code('text'), 'Почтовый индекс');
INSERT INTO dt_facet (code, facet_id, value, anno) VALUES (dt_code('d_zip'), facet_id('pattern'), E'^[a-zA-Zа-яА-я0-9][a-zA-Zа-яА-я0-9 \-]{2,11}','index');

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_text'), dt_code('text'), 'Текст');

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_string'), dt_code('text'), 'Текстовая строка');
INSERT INTO dt_facet (code, facet_id, value, anno) VALUES (dt_code('d_string'), facet_id('pattern'), E'^[^\n]','NO CR');


INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_login'), dt_code('text'), 'Логин');
INSERT INTO dt_facet (code, facet_id, value, anno) VALUES (dt_code('d_login'), facet_id('pattern'), E'^[a-zA-Z0-9\\.+_@\\-]{5,}$','login');

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_email'), dt_code('text'), 'Адрес email');
INSERT INTO dt_facet (code, facet_id, value, anno) VALUES (dt_code('d_email'), facet_id('pattern'), E'(?:^$|^[^ ]+@[^ ]+\\.[^ ]{2,6}$)','your@email.ru');

INSERT INTO dt (code, parent_code, anno, is_list) VALUES (pg_cs('d_emails'), dt_code('text'), 'Список адресов email', true);
INSERT INTO dt_facet (code, facet_id, value, anno) VALUES (dt_code('d_emails'), facet_id('pattern'), E'(?:^$|^[^ ]+@[^ ]+\\.[^ ]{2,6}$)','your@email.ru');

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_path'), dt_code('text'), 'Относительный путь');
INSERT INTO dt_facet VALUES (dt_code('d_path'), facet_id('pattern'), E'^(|[a-z\\d_][a-z\\d\\.\\-_/]+)$');

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_class'), dt_code('d_id32'), 'ID класса');

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_non_neg_int'), dt_code('d_id'), 'Неотрицательное целое');
INSERT INTO dt_facet VALUES (dt_code('d_non_neg_int'), facet_id('minInclusive'), 0);

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_cnt'), dt_code('d_non_neg_int'), 'Количество элементов');
INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_amount'), dt_code('numeric'), 'Количество товара');

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_format'), dt_code('text'), 'Формат для printf');

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_code'), dt_code('text'), 'Имя переменной');
INSERT INTO dt_facet VALUES (dt_code('d_code'), facet_id('pattern'), E'^[a-z\\d][a-z\\d\\.\\-_]*$');

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_code_arg'), dt_code('text'), 'Имя аргумента');
INSERT INTO dt_facet VALUES (dt_code('d_code_arg'), facet_id('pattern'), E'^[a-z\\d_][a-z\\d\\.\\-_]*$');

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_codei'), dt_code('text'), 'Имя переменной в любом регистре');
INSERT INTO dt_facet VALUES (dt_code('d_codei'), facet_id('pattern'), E'^[a-z\\d][a-z\\d\\.\\-_A-Z]*$');

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_code_like'), dt_code('text'), 'Шаблон имени переменной');
INSERT INTO dt_facet VALUES (dt_code('d_code_like'), facet_id('pattern'), E'^[a-z\\d\\.\\-_\\%]+$');

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_sub'), dt_code('text'), 'Имя внешнего метода');
INSERT INTO dt_facet VALUES (dt_code('d_sub'), facet_id('pattern'), E'^([a-z\\d][a-z\\d\\.\\-_]+)|([A-Z\\d][a-z\\d\\.\\-_\:A-Z]+)$');

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_lang'), ws.dt_code('text'), 'Идентификатор языка');
INSERT INTO dt_facet VALUES (dt_code('d_lang'), facet_id('pattern'), E'^(?:ru|en)$');

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_errcode'), dt_code('text'), 'Код ошибки');
INSERT INTO dt_facet VALUES (dt_code('d_errcode'), facet_id('length'), 5);

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_money'), dt_code('numeric'), 'Деньги');

INSERT INTO dt (code, anno, is_complex) VALUES (pg_cs('t_hashtable'), 'Хэштаблица', true);
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_hashtable'), 1, 'id',  dt_code('d_id32'), 'ID');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_hashtable'), 2, 'name', dt_code('text'), 'Название');

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_acl'), dt_code('d_id32'), 'Уровень доступа');
INSERT INTO dt (code, parent_code, anno, is_list) VALUES (pg_cs('d_acls'), dt_code('d_acl'), 'Массив уровней доступа', true);

INSERT INTO dt (code, parent_code, anno) VALUES (pg_cs('d_bitmask'), dt_code('d_id32'), 'Битовая маска');

INSERT INTO dt (code, parent_code, anno, is_list) VALUES (pg_cs('d_booleana'), dt_code('boolean'), 'Массив boolean', true);
INSERT INTO dt (code, parent_code, anno, is_list) VALUES (pg_cs('d_texta'), dt_code('text'), 'Массив text', true);
INSERT INTO dt (code, parent_code, anno, is_list) VALUES (pg_cs('d_id32a'), dt_code('d_id32'), 'Массив d_id32', true);
INSERT INTO dt (code, parent_code, anno, is_list) VALUES (pg_cs('d_codea'), dt_code('d_code'), 'Массив d_code', true);

INSERT INTO dt (code, parent_code, anno, is_list) VALUES (pg_cs('d_ida'), dt_code('d_id'), 'Массив d_id', true);
INSERT INTO dt (code, parent_code, anno, is_list) VALUES (pg_cs('d_moneya'), dt_code('d_money'), 'Массив d_money', true);

INSERT INTO dt (code, anno, is_complex) VALUES (pg_cs('z_uncache'), 'Аргументы функций cache_uncache', true);
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('z_uncache'), 1, 'code', dt_code('text'), 'код метода');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('z_uncache'), 2, 'key', dt_code('text'), 'ключ кэша');

/*
  -- RESERVED
INSERT INTO dt (code, anno, is_complex) VALUES (pg_cs('z_cache_reset'), 'Аргументы функций cache_reset', true);
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('z_cache_reset'), 1, 'keys', dt_code('text'), 'ключи');
*/

INSERT INTO dt (code, anno, is_complex) VALUES (pg_cs('z_acl_check'), 'Аргументы функций acl_check', true);
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('z_acl_check'), 1, '_sid', dt_code('text'), 'ID сессии');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('z_acl_check'), 2, 'class_id', dt_code('d_class'), 'ID класса');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('z_acl_check'), 3, 'action_id', dt_code('d_id32'), 'ID акции');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('z_acl_check'), 4, 'id', dt_code('d_id'), 'ID объекта');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('z_acl_check'), 5, 'id1', dt_code('d_id'), 'ID1 объекта');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('z_acl_check'), 6, 'id2', dt_code('text'), 'ID2 объекта');

INSERT INTO dt (code, anno, is_complex) VALUES (pg_cs('z_store_get'), 'Аргументы функций store_get', true);
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('z_store_get'), 1, 'path',   dt_code('d_path'), 'ID данных');

INSERT INTO dt (code, anno, is_complex) VALUES (pg_cs('z_store_set'), 'Аргументы функций store_set', true);
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('z_store_set'), 1, 'path',   dt_code('d_path'), 'ID данных');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('z_store_set'), 2, 'data',   dt_code('text'), 'данные');

INSERT INTO dt (code, anno, is_complex) VALUES (pg_cs('t_page_info'), 'Параметры страницы', true);

INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_page_info'), 1, 'req', dt_code('text'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_page_info'), 2, 'code', dt_code('d_code'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_page_info'), 3, 'up_code', dt_code('d_code'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_page_info'), 4, 'class_id', dt_code('d_class'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_page_info'), 5, 'action_id', dt_code('d_id32'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_page_info'), 6, 'sort', dt_code('d_sort'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_page_info'), 7, 'uri', dt_code('d_regexp'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_page_info'), 8, 'tmpl', dt_code('d_path'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_page_info'), 9, 'name', dt_code('text'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_page_info'), 10, 'uri_re', dt_code('text'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_page_info'), 11, 'uri_fmt', dt_code('text'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno, is_list) VALUES (dt_code('t_page_info'), 12, 'args', dt_code('text'), '', true);

INSERT INTO dt (code, anno, is_complex) VALUES (pg_cs('t_pg_proc_info'), 'Параметры хранимой процедуры', true);
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_pg_proc_info'), 1, 'schema', dt_code('text'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_pg_proc_info'), 2, 'name', dt_code('text'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_pg_proc_info'), 3, 'anno', dt_code('text'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_pg_proc_info'), 4, 'rt_oid', dt_code('oid'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_pg_proc_info'), 5, 'rt_name', dt_code('text'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_pg_proc_info'), 6, 'is_set', dt_code('boolean'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_pg_proc_info'), 7, 'args', dt_code('text'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_pg_proc_info'), 8, 'args_pub', dt_code('text'), '');

INSERT INTO dt (code, anno, is_complex) VALUES (pg_cs('t_acl_check'), 'Результат проверки ACL', true);
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_acl_check'), 1, 'value', dt_code('integer'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_acl_check'), 2, 'id', dt_code('integer'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_acl_check'), 3, 'code', dt_code('text'), '');
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (dt_code('t_acl_check'), 4, 'name', dt_code('text'), '');

/* ------------------------------------------------------------------------- */
