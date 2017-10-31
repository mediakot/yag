# Yag – yet another grid 0.9b
Плагин для удобного редактирования множества документов в табличном виде

## О плагине
Основано на Webix https://webix.com/download-webix-gpl/ , DocLister(SimpleTab) https://github.com/AgelxNash/DocLister и MODxAPI

## Возможности
<ul>
	<li>Full-ajax</li>
	<li>Функция отмены действий Undo</li>
	<li>inline или modal редактирование richtext</li>
	<li>Темы</li>
	<li>Пагинация</li>
	<li>Массовые действия: публиковать, снять с публикации, удалить</li>
	<li>Экспорт/Импорт XLSX (Эксперементально)</li>
	<li>Добавление новых документов</li>
</ul>

## Установка
1. Скопировать папку assets в корень сайта. Создать.
2. Создать новый плагин и вставить туда код:

```php
/**
 * yag
 *
 * @category    plugin
 * @version     0.9b
 * @license     http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @internal    @properties &tabname=Заголовок вкладки;text;Yag; &skin=Шкурка;list;webix,air,aircompact,clouds,contrast,flat,glamour,light,metro,terrace,touch,web;webix;;Скин; &templates=Шаблоны, в которых выводить вкладку плагина;text; &templatesItems=Шаблоны, которые выводить в таблице;text; &tableConfig=Конфигурация таблицы;text; pagetitle:1,content:3;;Заполняется в формате имя_поля:пропорция_ширины (напр.:image:1,pagetitle:3);&ExpImpConfig=Конфигурация Экспорта/Импорта;text;id,pagetitle,content;;Поля которые будут в экспортруемом/импортируемом ХLSХ-файле, через запятую;&editaction=Редактирование ячейки;list;click,dblclick;click;;по одинарному или двойному щелчку&rtEditor=Тип редактора richtext;list;inline,modal;;modal;Выводить редактор прямо в таблице(inline) или в модальном окне;&deletedAction=Удаленные доки?;list;hide,show;show;Если выбрано show, то строки с удаленными документами будут отображены и подсвечены красным;&resizeColumns=Изменение ширины колонок;list;true,false;false;;Можно ли менять ширину колонок вручную;&sizePager=Количество документов на одной странице;text;10;10;
 * @internal    @events OnDocFormRender
 * @internal    @modx_category Manager and Admin
 * @internal    @installset base
 * @internal    @legacy_names YetAnotherGrid
 * @author      mkot
 * @firstupdate  06.09.2017
 * @lastupdate 31.10.2017
 */

 return require MODX_BASE_PATH.'assets/plugins/yag/plugin.yag.php';
```

3. Поставить галочку «Анализировать DocBlock» и сохранить

## Документация

### Вкладка «Конфигурация»
* Загаловок вкладки. Под каким именем будет отобрадаться вкладка. По-умолчанию «YAG»
* Шкурка. Скин таблицы. На выбор доступно 12 цветовых схем. Свои можно сделать вот здесь: <https://webix.com/skin-builder/>
* Шаблоны, в которых выводить вкладку плагина. Укажите те шаблоны, в которых будет вкладка Yag. Например, можно указать шаблон каталога.
* Шаблоны, которые выводить в таблице. Укажите те шаблоны, которые будут выводиться в таблице. Например, можно указать шаблоны товаров.
* Конфигурация. Здесь задается конфигурация таблицы в формате _название_переменной1:относительная_ширина_1,название_переменной_2:относительная_ширина_2_ (напр. image:1,pagetitle:3) . Относительная ширина это пропорциональная ширина столбцов, например, если вы для первого столбца задали 1, а для второго 3, то при ширине окна 1000px первый столбец займет 250px, а второй 750px.
* Конфигурация Экспорта/Импорта. Задаются, те поля которые будут экспортироваться в файл XLSX и, соответственно, импортироваться из него.
* Редактирование. Как будет активироваться редактирование в таблице по одинарному или двойному щелчку.
* Тип редактора richtext. Для полей у которых тип редактора richtext можно указать как будет происходить редактирование: прямо в таблице(inline) или в модальном окне(modal)
* Удаленные доки. Если выбрано show, то строки с помеченными на удаление документами по-умолчанию будут отображены и подсвечены красным, иначе они будут скрыты
* Изменение ширины колонок. Разрешить изменение ширины колонок.
* Количество документов на одной странице. Сколько документов будет отображено на одной странице таблицы. По-умолчанию 10.

### Работа с таблицей

![Управление в таблице](http://skrinshoter.ru/i/311017/krB8QLCt.jpg)

1. Кнопка «Скрыть/Показать» управляет отображением помеченными на удаление документами.
2. Выпадающий список «Действие». Позволяет выбрать действие с отмеченными документами.
3. Кнопка «Применить» выполняет выбранное действие с отмеченными документами.
4. Кнопка «Импорт». Импортуриует XLSX-файл. Рекомендуется для импорта использовать заранее экспортрованный по кнопке «Экспорт» файл. **Добавление новых документов через XLSX-файл пока не реализовано**.
5.  Кнопка «Экспорт». Экспортрует XLSX-файл с полями, которые указаны в конфигурации плагина (в поле «Конфигурация Экспорта/Импорта»).
6. «Undo». Отмена действий. Может глючить...
7. «Добавить». Открывает модальное окно добавления нового документа.

