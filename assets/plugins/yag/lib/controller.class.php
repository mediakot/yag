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
	        'tvPrefix'		=> '',
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
	        $this->data->setParams($this->params);
	        $this->dlInit();
	    }

	public function dlInit()
	    {
	        //parent::dlInit();
	    	$this->dlParams['tvList']= $this->tvList($this->params['tableConfig']);
	    	$this->dlParams['addWhereList'] = ' template = '.$this->params["templatesItems"] ;
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
			return $this->data->update($_POST);
	}

	//Запись нескольких полей
	public function setMultiData(){
		$items = json_decode($_POST['data'], true);
				foreach ($items as $k => $arr){
					foreach($arr as $key => $val){
						if ($key=='id'){
							$item['id']=$val;
							unset($value[$key]);
							continue;
						}
						$item['field'] = $key;
						$item['value'] = $val;
						$this->data->update($item);
					}
				}
		return true;
	}

}
