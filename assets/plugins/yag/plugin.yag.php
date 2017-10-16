/**
 * yag
 *
 * @category    plugin
 * @version     0.9a
 * @license     http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @internal    @properties &tabname=Заголовок вкладки;text;Yag; &skin=Шкурка;list;webix,air,aircompact,clouds,contrast,flat,glamour,light,metro,terrace,touch,web;webix;;Скин; &templates=Шаблоны, в которых выводить вкладку плагина;text; &templatesItems=Шаблоны, которые выводить в таблице;text; &tableConfig=Конфигурация таблицы;text;id:0.5, pagetitle:1,content:3;;Заполняется в формате имя_поля:пропорция_ширины (напр.:id:1,pagetitle:3);&ExpImpConfig=Конфигурация Экспорта/Импорта;text;id,pagetitle,content;;Поля которые будут в экспортруемом/импортируемом ХLSХ-файле, через запятую;&editaction=Редактирование ячейки;list;click,dblclick;click;;по одинарному или двойному щелчку&rtEditor=Тип редактора richtext;list;inline,modal;;modal;Выводить редактор прямо в таблице(inline) или в модальном окне;
 * @internal    @events OnDocFormRender
 * @internal    @modx_category Manager and Admin
 * @internal    @installset base
 * @internal    @legacy_names YetAnotherGrid
 * @author      mkot
 * @firstupdate  06.09.2017
 * @lastupdate 15.10.2017
 */

if (IN_MANAGER_MODE != 'true') die();

$output = '';
global $modx_lang_attribute;
global $_lang;

	$e = &$modx->Event;
	if ($e->name == 'OnDocFormRender')
	{
		include_once(MODX_BASE_PATH . 'assets/plugins/yag/lib/core.class.php');
		$yagrid = new \YAGcore\YAGcore($modx, $modx_lang_attribute, $_lang);
		if ($modx->getAllChildren($id)){
        $output = $yagrid->render();
		} else {
			return;
		}
		//$modx->logEvent(123, 1, $output, 'Всё Ок evoWGrid');
		if ($output) $e->output($output);
	}