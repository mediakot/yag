<?php
define('MODX_API_MODE', true);
define('IN_MANAGER_MODE', 'true');

include_once(__DIR__."/../../../index.php");
$modx->db->connect();
if (empty ($modx->config)) {
    $modx->getSettings();
}
if(!isset($_SESSION['mgrValidated'])){
    die();
}
 $modx->invokeEvent('OnManagerPageInit',array('invokedBy'=>'evoWGrid'));
 if (isset($modx->pluginCache['SimpleGalleryProps'])) {
 	$modx->event->params = $modx->parseProperties($modx->pluginCache['evoWGridProps'],'evoWGrid','plugin');
 } else {
 	die();
 }
 $params = $modx->event->params;

 $roles = isset($params['role']) ? explode(',',$params['role']) : false;
 if ($roles && !in_array($_SESSION['mgrRole'], $roles)) die();

 $mode = (isset($_REQUEST['mode']) && is_scalar($_REQUEST['mode'])) ? $_REQUEST['mode'] : null;
   $out = null;
// $controllerClass = isset($modx->event->params['controller']) ? $modx->event->params['controller'] : '';
 if (empty($controllerClass) || !class_exists($controllerClass)) {
     require_once (MODX_BASE_PATH . 'assets/plugins/evoWGrid/lib/controller.class.php');
     $controllerClass = '\evoWGrid\evoWGController';
 }
 $controller = new $controllerClass($modx);
if($controller instanceof \SimpleTab\AbstractController){
	if (!empty($mode) && method_exists($controller, $mode)) {
		$out = call_user_func_array(array($controller, $mode), array());
	}else{
		$out = call_user_func_array(array($controller, 'listing'), array());
	}
	$controller->callExit();
}

//  [
// 	{ "id":1, "title":"The Shawshank Redemption"},
// 	{ "id":2, "title":"The Godfather"}
// ]
 //$out = call_user_func_array(array($controller, 'listing'), array());

$out = array_merge(json_decode($out, true));
$out = json_encode($out, JSON_UNESCAPED_UNICODE);

//$modx->logEvent(123, 1, $out , 'Test evoWGrid ajax');



echo ($out = is_array($out) ? json_encode($out) : $out);