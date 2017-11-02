/**
 * yag
 *
 * @category    plugin
 * @version     0.9b
 * @license     http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @internal    @properties &tabname=Заголовок вкладки;text;Yag; &skin=Шкурка;list;evo,webix,air,aircompact,clouds,contrast,flat,glamour,light,metro,terrace,touch,web;evo;;Скин; &templates=Шаблоны, в которых выводить вкладку плагина;text; &templatesItems=Шаблоны, которые выводить в таблице;text; &tableConfig=Конфигурация таблицы;text; pagetitle:1,content:3;;Заполняется в формате имя_поля:пропорция_ширины (напр.:image:1,pagetitle:3);&ExpImpConfig=Конфигурация Экспорта/Импорта;text;id,pagetitle,content;;Поля которые будут в экспортруемом/импортируемом ХLSХ-файле, через запятую;&editaction=Редактирование ячейки;list;click,dblclick;click;;по одинарному или двойному щелчку&rtEditor=Тип редактора richtext;list;inline,modal;;modal;Выводить редактор прямо в таблице(inline) или в модальном окне;&deletedAction=Показывать по-умолчанию помеченные на удаление?;list;hide,show;show;Если выбрано показывать, то строки с удаленными документами будут подсвечены красным;&resizeColumns=Изменение ширины колонок;list;true,false;false;;Можно ли менять ширину колонок вручную;&sizePager=Количество документов на одной странице;text;5;5;
 * @internal    @events OnDocFormRender
 * @internal    @modx_category Manager and Admin
 * @internal    @installset base
 * @internal    @legacy_names YetAnotherGrid
 * @author      mkot
 * @firstupdate  06.09.2017
 * @lastupdate 15.10.2017
 */

 return require MODX_BASE_PATH.'assets/plugins/yag/plugin.yag.php';