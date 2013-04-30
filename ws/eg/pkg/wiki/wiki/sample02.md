Title: Синтаксис wiki
TOC:   UnOrdered

Описание синтаксиса, поддерживаемого данной вики.
Основа синтаксиса - [MultiMarkdown](https://github.com/fletcher/MultiMarkdown/wiki), к которому добавлено несколько расширений.

<!-- CUT -->

## Расширения синтаксиса

### Якоря в латиннице
: Каждый заголовок получает id, состоящий из собственного текста, переведенный в латинницу.
  Это сделано для повышения ЧПУ[^friendly_url] ссылок внутрь страницы

### Содержание (список заголовков)
: Если в метаданных документа (блок от начала до первой пустой строки) задано значение `TOC`,
  то в начало документа будет добавлено содержание

### Аннотация
: Если в тексте присутствует комментарий `<!-- CUT -->`, то блок от начала
  до этого места выделяется как аннотация и доступен отдельно

[^friendly_url]:**ч**еловеко **п**онятный **у**рл, [Википедия](http://ru.wikipedia.org/wiki/ЧПУ_(интернет)).

# варианты заголовков

Этот вариант даст `<h1>`

Главный заголовок
=================

Этот вариант даст `<h1>` и станет первым в содержании (сначала проверяются строки из *=* и *-*, потом - c *#*)

## Содержание формируется из таких

Заголовок этого блока попадет в toc

## Выделение в тексте

*single asterisks*

_single underscores_

**double asterisks**

__double underscores__


## пример таблицы


|---| ---:|
|fdf|dfdfd|
|333|![image][]|
[Пример таблицы1]

---

|            |           Grouping          ||
First Header | Second Header | Third Header |
------------ | :-----------: | -----------: |
Content      |          *Long Cell*        ||
Content      |   **Cell**    |     Cell     |

New section  |       More    |     Data     |
And more     |            And more         ||
[Пример таблицы2]

*TODO* Этот формат планируется доработать

## пример кода

Можно апострофами `CREATE FUNCTION` выделить, а можно блок.

И еще -
`&#8212;` is the decimal-encoded equivalent of `&mdash;`.

Без апострофов -
&#8212; is the decimal-encoded equivalent of &mdash;.

Отступ в 4 пробела приводит к выделению кода

    if ($list_type eq 'ol' and $self->{trust_list_start_value}) {
      my ($num) = $marker =~ /^(\d+)[.]/;
      return "<ol start='$num'>\n" . $content . "</ol>\n";
    }
    <h3 class="example1" id="big-red2" style="color:red">Bingo</h3>

## Форматированные блоки

можно использовать html, но там не будет escape

<pre>
#### заголовок 4
---
<h4>заголовок h4</h4>

<h3 class="example1" style="color:red">заголовок h4 со стилем</h3>
</pre>

## Ссылки

### Внутри документа

Заголовки переводятся в латинницу и это становится их идентификатором.
В результате [Ссылки] делаются тривиально.

### Внутри wiki

See my [About](/about/) page for details.

[](dsfsdf/aaad)

[](dsfsdf/aaad#asdda)

[](dsfsdf/aaad#asdda?d=33&s=22)

### Внешние

*вариант 1*

This is [Некий пример](http://example.com/ "Title") inline link.
[Почта](mailto:dsfsdf@ww.ru)

*вариант 2*

[This link](http://example.net/) has no title attribute.

*вариант 3 (референсные)*

This is [an example][id] reference-style link.

[id]: http://example.com/  "Optional Title Here"

I get 10 times more traffic from [Гугль][] than from
[Яху][] or [МикроСН][].

[Гугль]:    http://google.com/        "Google"
[Яху]:      http://search.yahoo.com/  "Yahoo Search"
[МикроСН]:  http://search.msn.com/    "MSN Search"

*вариант 4*

Visit [Daring Fireball][] for more information.


[Daring Fireball]: http://daringfireball.net/

*вариант 5*

Можно [ссылкам] задавать атрибуты

[ссылкам]: http://path.to/link.html "Some Link" class=external
style="border: solid black 1px;"

*вариант 6*

<http://google.com>

<jean@tender.pro>


## Изображения

Можно просто вставить картинку ![Alt text](http://pgws.tender.pro/images/octocat-icon.png "Optional title")

Можно задать атрибуты ![image][] и вставить так

[image]: /img/style01/pgws-logo.png "Image title" width=60px height=60px

## Цитаты

### Внутри текста

> Первого уровня
> Первого уровня
>> Второго уровня
Второго уровня

Все как в email

### Ссылками

This is a statement that should be attributed to
its source[p. 23][#Doe:2006].
And following is the description of the reference to be
used in the bibliography.
[#Doe:2006]: John Doe. *Some Big Fancy Book*.

## Сноски

Кроме всяких прочих наворотов, можно не ограничивать себя отсутствием аозможности делать сноски. Вот такого рода пример многозначителен[^latin_tag_only] и поясняется внизу документа. При этом якорь пояснения задается.
[^latin_tag_only]: Вы шутите, слово "многозначителен" не нуждается в пояснениях.

## Списки определений

Apple
: Pomaceous fruit of plants of the genus Malus in
  the family Rosaceae.
: An american computer company.

Orange
: The fruit of an evergreen tree of the genus Citrus.

*Примечание*
Пока что термин не должен начинаться с кириллицы, этот момент в TODO.

