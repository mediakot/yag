<?php namespace yag;

require_once(MODX_BASE_PATH . 'assets/lib/MODxAPI/modResource.php');

use modResource;


//$this->modx->logEvent(0,1, var_export($SQL, TRUE), 'test EvoWGrid table.class');
/**

 * Class yagData

 * @package yag

 */

class yagData extends modResource{
		protected $table = 'site_content';
    protected $TVTable = 'site_tmplvars';
    protected $tvListNames = array();
    protected $tvListNamesIDs = array();
    private $chboxFields =array('published','hidemenu');

    public function __construct($modx, $debug = false)
    {
        parent::__construct($modx, $debug);
        //Получаем массив с именами всех TV и их ID в переменную $this->tvList и $this->tvListIDs соотв.
        $SQL =	$this->modx->db->select('id,name', $this->makeTable($this->TVTable));
				while ($row = $this->modx->db->getRow($SQL)){
					$this->tvList[] = $row['name'];
					$this->tvListIDs[$row['name']] = $row['id'];
				}
				$this->table = $this->makeTable($this->table);
				$this->TVTable = $this->makeTable($this->TVTable);
    }

		//Обновляем значение одной строки
		public function update($item){

				$this->edit($item['id']);
				unset($item['id']);

				foreach ($item as $key => $value) {
					$this->set($key, $value);
				}
				$this->save(true,false);
				return ($this->modx->db->getAffectedRows()>0);
			}

		//Обновленяем статус публикации
		public function updatePub($ids, $pub){
			$SQL= "UPDATE {$this->table} SET published ='".$pub."' WHERE  `{$this->pkName}` IN (".$ids.")";
			$this->query($SQL);
			if($this->modx->db->getAffectedRows()) return true;
			return false;
		}

		//Удаление документов
		public function markDeleted($ids){
			parent::toTrash($ids);
			if($this->modx->db->getAffectedRows()) return true;
			return false;
		}

		//Добавление нового документа
	  public function newDoc($item){
	  	$this->create($item);
	  	$neighborTpl = $this->modx->db->makeArray($this->modx->db->select('template', $this->table, "parent = {$this->field['parent']}"));
	  	$item['template'] = $neighborTpl[0]['template'];
	  	foreach ($item as $key => $value) {
					$this->set($key, $value);
				}

	  	return $this->save(true,false);
	  }
}