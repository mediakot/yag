<?php namespace evoWGrid;



require_once(MODX_BASE_PATH . 'assets/lib/SimpleTab/table.abstract.php');

use SimpleTab\dataTable;


//$this->modx->logEvent(0,1, var_export($SQL, TRUE), 'test EvoWGrid table.class');
/**

 * Class eWGData

 * @package evoWGrid

 */

class eWGData extends dataTable{
		protected $table = 'site_content';
    protected $TVTable = 'site_tmplvars';
    protected $rfName = 'id';
    protected $tvList = array();
    protected $tvListIDs = array();
    private $chboxFields =array('published','hidemenu');

    //Получаем массив с именами всех TV и их ID в переменную $this->tvList и $this->tvListIDs соотв.
    public function getTVList(){
				$SQL =	$this->modx->db->select('id,name', $this->makeTable($this->TVTable));
				while ($row = $this->modx->db->getRow($SQL)){
					$this->tvList[] = $row['name'];
					$this->tvListIDs[$row['name']] = $row['id'];
				}
				return $this;
		}

		//Обновляем значение одной строки
		public function update($item){
				$table = $this->table;
				$id = $this->rfName;

			  //Б - Безопасность
				foreach ($item as $key => $value) {
					$itemVal[$key] = $this->escape($value);
				}
				if (in_array($itemVal['field'], $this->chboxFields)){
					 $itemVal['value'] = ($itemVal['value']=="true") ? 1:0;
				}
				$this->getTVList();
				if (in_array($itemVal['field'], $this->tvList)){
					$table = 'site_tmplvar_contentvalues';
					$id  = 'contentid';
					$andTmplvarid = " AND tmplvarid =".$this->tvListIDs[$itemVal['field']];
					$tmplvarid = $itemVal['field'];
					$itemVal['field'] = 'value';
				}

				$SQL = "UPDATE {$this->makeTable($table)} SET {$itemVal['field']} ='{$itemVal['value']}' WHERE `{$id}` = {$itemVal['id']}". $andTmplvarid;
				$this->query($SQL);
				///Если нет строки в таблице, то вставляем
				$rows = $this->modx->db->getAffectedRows();
				if (!$rows){

					$SQL = "INSERT INTO {$this->makeTable($table)} (tmplvarid,contentid,value) VALUES ({$this->tvListIDs[$tmplvarid]},{$itemVal['id']}, {$itemVal['value']})";
					$this->modx->logEvent(0,1, var_export($SQL, TRUE), 'test EvoWGrid table.class');
						$this->query($SQL);
				}
				else return false;
				return true;
			}


}