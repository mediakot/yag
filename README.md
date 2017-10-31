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
1.Скопировать папку assets в корень сайта. Создать.
2.Создать новый плагин и вставить туда код:

```php
/**
 * yag
 *
 * @category    plugin
 * @version     0.9b
 * @license     http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @internal    @properties &tabname=Заголовок вкладки;text;Yag; &skin=Шкурка;list;webix,air,aircompact,clouds,contrast,flat,glamour,light,metro,terrace,touch,web;webix;;Скин; &templates=Шаблоны, в которых выводить вкладку плагина;text; &templatesItems=Шаблоны, которые выводить в таблице;text; &tableConfig=Конфигурация таблицы;text; pagetitle:1,content:3;;Заполняется в формате имя_поля:пропорция_ширины (напр.:id:1,pagetitle:3);&ExpImpConfig=Конфигурация Экспорта/Импорта;text;id,pagetitle,content;;Поля которые будут в экспортруемом/импортируемом ХLSХ-файле, через запятую;&editaction=Редактирование ячейки;list;click,dblclick;click;;по одинарному или двойному щелчку&rtEditor=Тип редактора richtext;list;inline,modal;;modal;Выводить редактор прямо в таблице(inline) или в модальном окне;&deletedAction=Показывать по-умолчанию помеченные на удаление?;list;hide,show;show;Если выбрано показывать, то строки с удаленными документами будут подсвечены красным;&resizeColumns=Изменение ширины колонок;list;true,false;false;;Можно ли менять ширину колонок вручную;&sizePager=Количество документов на одной странице;text;10;10;
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

Поставить галочку «Анализировать DocBlock» и сохранить

## Документация