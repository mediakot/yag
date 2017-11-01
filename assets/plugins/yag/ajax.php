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
 $modx->invokeEvent('OnManagerPageInit',array('invokedBy'=>'yag'));
 if (isset($modx->pluginCache['yagProps'])) {
 	$modx->event->params = $modx->parseProperties($modx->pluginCache['yagProps'],'yag','plugin');
 } else {
 	die();
 }
 $params = $modx->event->params;

 $roles = isset($params['role']) ? explode(',',$params['role']) : false;
 if ($roles && !in_array($_SESSION['mgrRole'], $roles)) die();

 $mode = (isset($_REQUEST['mode']) && is_scalar($_REQUEST['mode'])) ? $_REQUEST['mode'] : null;
   $out = null;
 if (empty($controllerClass) || !class_exists($controllerClass)) {
     require_once (MODX_BASE_PATH . 'assets/plugins/yag/lib/controller.class.php');
     $controllerClass = '\yag\yagController';
 }

 $controller = new $controllerClass($modx);
if($controller instanceof \SimpleTab\AbstractController){
	if (!empty($mode) && method_exists($controller, $mode)) {
		$controller->output = call_user_func_array(array($controller, $mode), array());
		$out = $controller->output;
		$controller->callExit();
	}else{
		$out = call_user_func_array(array($controller, 'listing'), array());
	}

}

//$modx->logEvent(1, 1, var_export($out,true) , 'Test yag ajax');
$out = array_merge(json_decode($out, true));

echo ($out = is_array($out) ? json_encode($out, JSON_UNESCAPED_UNICODE) : $out);