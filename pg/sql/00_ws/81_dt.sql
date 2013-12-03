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
, ('refcursor',  'refcursor',  'Служебный тип для возврата 2го результата метода');
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

/* ------------------------------------------------------------------------- */
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

/* ------------------------------------------------------------------------- */
-- parent для массива хэшей, но они пока не поддерживаются DBD::Pg
INSERT INTO facet_dt_base SELECT 4, code FROM dt WHERE code = parent_code; --  AND code <> 'composite';

/* ------------------------------------------------------------------------- */
INSERT INTO dt (code, parent_code, anno, is_list) VALUES 
  (pg_cs('d_acls'),    'd_acl',  'Массив уровней доступа', true)
, (pg_cs('d_booleana'),'boolean','Массив boolean', true)
, (pg_cs('d_texta'),   'text',   'Массив text', true)
, (pg_cs('d_id32a'),   'd_id32', 'Массив d_id32', true)
, (pg_cs('d_codea'),   'd_code', 'Массив d_code', true)
, (pg_cs('d_ida'),     'd_id',   'Массив d_id', true)
, (pg_cs('d_moneya'),  'd_money','Массив d_money', true);

/* ------------------------------------------------------------------------- */
INSERT INTO dt_facet (code, facet_id, value, anno) VALUES 
  ('boolean',  facet_id('pattern'), E'^([01tf]|on|off)$', 'только 0,1,t,f,on или off')
, ('numeric',  facet_id('pattern'), E'^(\\+|\\-)?(\\d)*(\\.\\d+)?$','[знак]целая часть[.дробная часть]')
, ('real',     facet_id('pattern'), E'^(\\+|\\-)?(\\d)*(\\.\\d+)?$','[знак]целая часть[.дробная часть]')
, ('integer',  facet_id('pattern'), E'^(\\+|\\-)?\\d+$', '[знак]цифры')
, ('smallint', facet_id('pattern'), E'^(\\+|\\-)?\\d+$', '[знак]цифры')
, ('bigint',   facet_id('pattern'), E'^(\\+|\\-)?\\d+$', '[знак]цифры')
, ('date',     facet_id('pattern'), E'^\\d{1,2}\\.\\d{2}\\.\\d{4}$', 'ДД.ММ.ГГГГ')
, ('d_stamp',  facet_id('pattern'), E'^\\d{1,2}\\.\\d{2}\\.\\d{4}(?: +| +/ +)\\d{2}:\\d{2}(:\\d{2})?$', 'ДД.ММ.ГГГГ ЧЧ:ММ[:СС]')
, ('d_string', facet_id('pattern'), E'^[^\n]','NO CR')
, ('d_email',  facet_id('pattern'), E'(?:^$|^[^ ]+@[^ ]+\\.[^ ]{2,6}$)','your@email.ru')
, ('d_emails', facet_id('pattern'), E'(?:^$|^[^ ]+@[^ ]+\\.[^ ]{2,6}$)','your@email.ru');

-- TODO: INSERT INTO dt_facet VALUES ('uuid'), facet_id('pattern'), E'????');
-- INSERT INTO dt_facet VALUES ('integer'), facet_id('fractionDigits'), 0);

/* ------------------------------------------------------------------------- */
INSERT INTO dt_facet VALUES ('oid',       facet_id('pattern'),      E'^\d+$');
INSERT INTO dt_facet VALUES ('integer',   facet_id('minInclusive'), -2147483648);
INSERT INTO dt_facet VALUES ('integer',   facet_id('maxInclusive'), 2147483647);
INSERT INTO dt_facet VALUES ('smallint',  facet_id('minInclusive'), -32768);
INSERT INTO dt_facet VALUES ('smallint',  facet_id('maxInclusive'), 32767);
INSERT INTO dt_facet VALUES ('d_rating',  facet_id('minInclusive'), -2);
INSERT INTO dt_facet VALUES ('d_rating',  facet_id('maxInclusive'), 2);
INSERT INTO dt_facet VALUES ('d_errcode', facet_id('length'),       5);

/* ------------------------------------------------------------------------- */
INSERT INTO dt (code, anno, is_complex) VALUES 
  (pg_cs('z_uncache'),   'Аргументы функций cache_uncache', true)
, (pg_cs('z_acl_check'), 'Аргументы функций acl_check',     true);

/* ------------------------------------------------------------------------- */
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES 
  (pg_cs('z_uncache'),   1, 'code',      'text',    'код метода')
, (pg_cs('z_uncache'),   2, 'key',       'text',    'ключ кэша')
, (pg_cs('z_acl_check'), 1, '_sid',      'text',    'ID сессии')
, (pg_cs('z_acl_check'), 2, 'class_id',  'd_class', 'ID класса')
, (pg_cs('z_acl_check'), 3, 'action_id', 'd_id32',  'ID акции')
, (pg_cs('z_acl_check'), 4, 'id',        'd_id',    'ID объекта')
, (pg_cs('z_acl_check'), 5, 'id1',       'd_id',    'ID1 объекта')
, (pg_cs('z_acl_check'), 6, 'id2',       'text',    'ID2 объекта');
/*
  -- RESERVED
INSERT INTO dt (code, anno, is_complex) VALUES (pg_cs('z_cache_reset'), 'Аргументы функций cache_reset', true);
INSERT INTO dt_part (dt_code, part_id, code, parent_code, anno) VALUES (pg_cs('z_cache_reset'), 1, 'keys', pg_cs('text'), 'ключи');
*/
