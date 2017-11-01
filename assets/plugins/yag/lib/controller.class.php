<?php namespace yag;

require_once(MODX_BASE_PATH . 'assets/lib/SimpleTab/controller.abstract.php');
require_once(MODX_BASE_PATH . 'assets/plugins/yag/lib/table.class.php');
use \SimpleTab\AbstractController;
/**
 * Class yagController
 * @package yag
 */

//$this->modx->logEvent(123, 1, var_export($out,true) , 'Test yag controller');
class yagController extends AbstractController
{
    public $rfName = 'id';
    public $table = 'site_content';
    public $TVTable = 'site_tmplvars';
    public $params = array();

    public $dlParams = array(
            "controller"  => "site_content",
            "table"       => "site_content",
            'idField'     => "id",
            'api'         => 1,
            'tvPrefix'      => '',
            'depth'=>10,
            "idType"      => "parents",
            'ignoreEmpty' => 0,
            'JSONformat'  => "old",
            'display'     => 0,
            'offset'      => 0,
            'showNoPublish' => 1,
            'sortBy'      => "",
            'sortDir'     => "desc",
        );

    public function __construct(\DocumentParser $modx)
        {
            parent::__construct($modx);
            $this->data = new yagData($this->modx);
            $this->dlInit();
        }

    public function dlInit()
        {
            //parent::dlInit();
            $this->dlParams['tvList']= $this->tvList($this->params['tableConfig']);
            $this->dlParams['addWhereList'] = ' template IN ('.$this->params["templatesItems"].')';
        $this->dlParams['parents'] = $this->rid;
        $this->dlParams['sortBy'] = 'id';
        $this->dlParams['sortDir'] = 'asc';
        return $data;
        }

    //список TV
    public function tvList($string)
            {
                $tvList = preg_replace('\':\\d+\\.?\\d*\'','',$string);
                return $tvList;
            }

    //Запись одного поля
    public function setData(){
            $this->isExit = true;
            $data['id'] = $_POST['id'];
            $data[$_POST['field']] = $_POST['value'];
            if($this->data->update($data)) return "Обновлено";
            return "Ошибка";
    }

    // public function setData(){
    //      $this->isExit = true;
    //      if($this->data->update($_POST)) return "Обновлено";
    //      return "Ошибка";
    // }

    //Запись нескольких полей
    public function setMultiData(){
        $errIds = "";
        $items = json_decode($_POST['data'], true);
                foreach ($items as $k => $arr){
                    foreach($arr as $key => $val){
                        if ($key=='id'){
                            $item['id']=$val;
                            unset($value[$key]);
                            continue;
                        }
                        $item[$key] = $val;
                        $result = $this->data->update($item);
                        if(!$result)  $errIds .= $item['id']." ";
                    }
                }
                $this->isExit = true;
                if($errIds) return "Ошибка при обновлении ID:" .$errIds;
                else return "Обновлено";
    }

    //Публиковать
    public function publish(){
        $ids = implode(",",json_decode($_POST['ids']));
        $this->isExit = true;
        if ($ids && $this->data->updatePub($ids,1)) return "Опубликовано";
        return "Ничего не изменилось";
    }

    //Снять публикации
    public function unPublish(){
        $ids = implode(",",json_decode($_POST['ids']));
        $this->isExit = true;
        if ($ids && $this->data->updatePub($ids,0)) return "Снято с публикации";
        return "Ничего не изменилось";
    }
    //Пометить на удаление
    public function delete(){
        $ids = implode(",",json_decode($_POST['ids']));
        $this->isExit = true;
        if ($ids &&$this->data->markDeleted($ids)) return "Удалено в корзину";
        return "Ничего не изменилось";
    }

    public function getTreeData(){
        if ($_REQUEST['id']) $this->rid = $_REQUEST['id'];
        unset($this->dlParams['tvList']);
        $this->dlParams['addWhereList'] = ' (c.template IN ('.$this->params["templates"].') OR c.isfolder=1)';
        $this->dlParams['parents'] = $this->rid;
        $this->dlParams['selectFields'] = 'id,pagetitle,parent';
        $this->dlParams['showParent'] = '1';
        $this->modx->logEvent(123, 1, var_export($this->dlParams,true) , 'Test yag controller');
        return $this->listing();
    }

    public function saveNewDoc(){
        $this->isExit = true;
        return $this->data->newDoc($_POST);
    }

}
