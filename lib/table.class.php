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


				// $table = $this->table;
				// $id = $this->pkName;

			 //  //Б - Безопасность?
				// foreach ($item as $key => $value) {
				// 	$itemVal[$key] = $this->escape($value);
				// }
				// if (in_array($itemVal['field'], $this->chboxFields)){
				// 	 $itemVal['value'] = ($itemVal['value']=="true") ? 1:0;
				// }
				// if (in_array($itemVal['field'], $this->tvList)){
				// 	$table = 'site_tmplvar_contentvalues';
				// 	$id  = 'contentid';
				// 	$andTmplvarid = " AND tmplvarid =".$this->tvListIDs[$itemVal['field']];
				// 	$tmplvarid = $itemVal['field'];
				// 	$itemVal['field'] = 'value';
				// }

				// $SQL = "UPDATE {$this->makeTable($table)} SET {$itemVal['field']} ='{$itemVal['value']}' WHERE `{$id}` = {$itemVal['id']}". $andTmplvarid;
				// $this->query($SQL);
				// ///Если нет строки в таблице, то вставляем

				// if (!$this->modx->db->getAffectedRows()){
				// 	$SQL = "INSERT INTO {$this->makeTable($table)} (tmplvarid,contentid,value) VALUES ({$this->tvListIDs[$tmplvarid]},{$itemVal['id']}, {$itemVal['value']})";
				// 		$this->query($SQL);
				// }

			}

		//Обновленяем статус публикации
		public function updatePub($ids, $pub){
			$SQL= "UPDATE {$this->makeTable($this->table)} SET published ='".$pub."' WHERE  `{$this->pkName}` IN (".$ids.")";
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

	  public function newDoc($item){
	  	$this->create($item);

	  	foreach ($item as $key => $value) {
					$this->set($key, $value);
				}

	  	return $this->save(true,false);
	  }
}