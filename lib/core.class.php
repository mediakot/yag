<?php namespace YAGcore;

include_once(MODX_BASE_PATH . 'assets/lib/SimpleTab/plugin.class.php');

use \SimpleTab\Plugin;
/**
 * Class YAGcore
 * @package yag
 */
//$this->modx->logEvent(123, 1, var_export(,true) , 'Test core yag');
class YAGcore extends Plugin
{
    public $pluginName = 'yag';
    public $tpl = 'assets/plugins/yag/tpl/template.tpl';
    public $emptyTpl = 'assets/plugins/yag/tpl/empty.tpl';
    public $jsListDefault = 'assets/plugins/yag/js/scripts.json';
    public $cssListDefault = 'assets/plugins/yag/css/styles.json';
    public $cssListCustom = 'assets/plugins/yag/css/custom.json';
    public $_lang = array();
    public $id = '';
    public $table = 'site_content';
    public $tvTable = 'site_tmplvars';
    public $tv_tmplts = 'site_tmplvar_templates';
    private $tableConfig = ''; //Конфиг таблицы
    private $unEditable =array('id'); //Поля, которые не следует  редактировать
    private $modalFields =array('content'); //Поля, для которых нужно модальное окно
    private $chboxFields =array('published','hidemenu');//Поля, которые нужно отоброжать чекбоксом
   /* public $pluginEvents = array();*/

public function __construct($modx, $lang_attribute = 'en', $_lang)
    {
        $this->id = $this->modx->documentObject['id'];
        $this->tvTable=$modx->getFullTableName($this->tvTable);
        $this->tv_tmplts=$modx->getFullTableName($this->tv_tmplts);
        Plugin::__construct($modx,$lang_attribute = 'en');
        $this->_lang = $_lang;
        $this->langExtend();
        $this->tableHeader();
    }

    public function prerender()
        {
                //$this->registerEvents($this->pluginEvents);

            $output = $this->assets->registerJQuery();
            $tpl = MODX_BASE_PATH . $this->tpl;
            if ($this->fs->checkFile($tpl)) {
                $output .= '[+js+][+styles+]' . file_get_contents($tpl);
            } else {
                $this->modx->logEvent(0, 3, "Cannot load {$this->tpl} .", $this->pluginName);

                return false;
            }
            return $output;
        }


    public function getTplPlaceholders()
        {
            //Здесь можно добавлять плейсхолдеры, который будут вставлены в template
            $ph = array(
                'tableConfig'  => $this->tableConfig,
                'expImpConfig' => $this->expImpConfig(),
                'lang'         => $this->lang_attribute,
                'url'          => $this->modx->config['site_url'] . 'assets/plugins/yag/ajax.php',
                'site_url'     => $this->modx->config['site_url'],
                'manager_url'  => MODX_MANAGER_URL,
                'thumb_prefix' => $this->modx->config['site_url'] . 'assets/plugins/simplegallery/ajax.php?mode=thumb&url=',
                'kcfinder_url' => MODX_MANAGER_URL . "media/browser/mcpuk/browse.php?type=images",
                'editaction'   => $this->params['editaction'],
                'site_manager_url' => $this->modx->config['site_manager_url'],
                'id'           => $this->id,
                //Параметры из конфига плагина
                'style'        => $this->params['skin'],
                'rtEditor'     => $this->params['rtEditor'],
                'deletedAction'  => $this->params['deletedAction'],
                'resizeColumns'=> $this->params['resizeColumns'],
                'sizePager'    => $this->params['sizePager'],
                'templatesItems' => $this->params['templatesItems'],
            );

             return array_merge($this->params, $ph);
        }

    //Формирование заголовка таблицы, а также как будет редактироваться каждая колонка
    private function tableHeader(){
        $headTitles = $this->getConfigArray($this->params['tableConfig']);
        array_unshift($headTitles, array("id",0.5),array("ch",0.5));
        $sort = "raw";
        foreach ($headTitles as $key => $value) {
            //Если есть в _lang массиве переменная, значит это стандартное поле, иначе TV
            if ($this->_lang[$value[0]]){
                $header = 'header:"'.$this->_lang[$value[0]].'"';
            }
            else{
                $tvCaption = $this->getTVCaption($value[0]);
                $header = 'header:"'.$tvCaption['caption'].'"';
            }

            if(!$tvCaption AND !$header){continue;}
            switch(true){
                case ($value[0]=="ch"):
                    $sort="";
                    $header="header:{ content:\"masterCheckbox\" }";
                    $editor="checkValue:'on',  uncheckValue:'off', template:\"{common.checkbox()}\",";
                    break;
                case in_array($value[0], $this->unEditable):
                    $editor = '';//Простой текстовый редактор
                    break;
                case in_array($value[0], $this->modalFields):
                    $editor = 'editor:"richtext",'; //TinyMCE
                    break;
                case (in_array($value[0], $this->chboxFields) || $tvCaption['type']=='checkbox'):
                    $editor = 'template:"{common.checkbox()}", options:{
    "true":"1","false":"0","undefined":"0"},';//Checkbox
                    break;
                case ($tvCaption['type'] == 'image'):
                    $editor = 'template: "<input type=text value=/#images#><img src=/#images#>", editor:"imageField",';//image
                    break;
                case ($tvCaption['type'] == 'listbox')://listbox и radio
                case ($tvCaption['type'] == 'option'):
                    $tmp = explode('||',$tvCaption['elements']);
                    foreach ($tmp as $key => $item) {
                        list($name, $opt_value) = explode('==', $item);
                        $options[$opt_value] = $name;
                    }
                    $editor = 'editor:"select",  options:'.json_encode($options).',';//radio
                    break;
                default:
                    $editor = 'editor:"text",';
                    $sort = 'string_strict';
            }
            unset($tvCaption);

    //         //Простой текстовый редактор
    //         $editor = in_array($value[0], $this->unEditable) ? '' :'editor:"text",';
    //         //TinyMCE
    //         $editor = !in_array($value[0], $this->modalFields) ? $editor :'editor:"richtext",';
    //         //Checkbox
    //         $editor = in_array($value[0], $this->chboxFields) || $tvCaption['type']=='checkbox' ? 'template:"{common.checkbox()}", options:{
    // "true":"1","false":"0","undefined":"0"},' : $editor;
    //         //image
    //         $editor = $tvCaption['type'] == 'image' ? 'template: "<input type=text value=/#images#><img src=/#images#>", editor:"imageField",' : $editor;

            if ($value[0] =='pagetitle') $header = 'header:["'.$this->_lang[$value[0]].'", {content:"textFilter"}]';
            $this->tableConfig .= '{id:"'.$value[0].'",'.$editor.' '. $header.', fillspace:'.$value[1].',sort:"'.$sort.'"},';
        }
        return $this;
    }


    /**
     * Конфиг экспорта/импорта
     *
     * @return string
     */
    private function expImpConfig(){
        $conf = explode(",",$this->params['ExpImpConfig']);
        foreach ($conf as $key => $value) {
            $config .= '"'.$value.'":{header:"'.$value.'"},';
        }
        return $config;
    }


    /**
     * Формируем из параметра конфига многомерный массив
     *
     * @param arr массив с данными
     * @param string $sepCol разделитель ключей первого уровня
     * @param string $sepRow разделитель ключей второго уровня
     * @return array массив
     */
    private function getConfigArray($arr, $sepCol=',' , $sepRow=':'){
        $res= array();
        $col= explode($sepCol, $arr);
        foreach($col as $key =>$value){
             $res[] = explode($sepRow,$value);
        }
        return $res;
    }

    //для сопоставления имён полей и языковых переменных
    private function langExtend()
        {

            $this->_lang['longtitle'] = $this->_lang["long_title"];
            $this->_lang['longtitle'] = $this->_lang["long_title"];
            $this->_lang['description'] = $this->_lang["resource_description"];
            $this->_lang['published']  =  $this->_lang['resource_opt_is_published'];
            $this->_lang['pub_date'] = $this->_lang["page_data_publishdate"];
            $this->_lang['introtext'] = $this->_lang["resource_description"];
            $this->_lang['content'] = $this->_lang["resource_content"];
            $this->_lang['menutitle'] = $this->_lang["resource_opt_menu_title"];

            return $this->_lang;
        }

    /**
     * Получаем имя и тип поля
     *
     * @param string имя поля TV
     * @return array caption,type TV
     */
    public function getTVCaption($tvName){
        $tvCaption='';
        if($tvName){
            $query = "SELECT caption,type,elements FROM $this->tvTable as tvs LEFT JOIN $this->tv_tmplts as tvt ON (tvs.id = tvt.tmplvarid) WHERE  tvs.name='".$tvName."' AND tvt.templateid IN (".$this->params['templatesItems'].")";
            $res = $this->modx->db->query($query);
            $tvCaption = $this->modx->db->getRow($res);
            if($tvCaption) return $tvCaption;
            return false;
        }
        return true;
    }
}
