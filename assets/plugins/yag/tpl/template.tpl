<div id="yag" class="tab-page">
<h2 class="tab" id="yag_tab">[+tabName+]</h2>
<div id="yag_container" style="width:100%; margin:10px; border:1px solid #ccc"></div>
</div>

<script type="text/javascript" charset="utf-8">
var idEdited ='';  //Чтобы запомнить какая ячейка редактируется TinyMCE
var lastImageCtrl=''; //Для файл-баузера
var thisNode ='';
var historyUndo = []; //Стек для undo
var X = XLSX; //Для импорта
var $$$ = webix.$$; //Алиас, потому что псевдоним $$ занят mootools
var itemUpdate =[]; //для апдейта ячейки, чтобы коректно работало Undo

//Добавляем тип tinyMCE
webix.editors.richtext = {
    focus:function(){
        this.getInputNode(this.node).focus();
        this.getInputNode(this.node).select();
    },
    getValue:function(){
    	if(rtEditor=="modal") return this.getInputNode(this.node).value;
        return tinymce.activeEditor.getContent({format: 'raw'});
    },
    setValue:function(value){
        this.getInputNode(this.node).value = value;
    },
    getInputNode:function(){
        return this.node.firstChild;
    },
    render:function(){
    		if(rtEditor=="modal") return webix.html.create("div",{},"<input type=text  hidden/>");
        return webix.html.create("div", {
             "class":"webix_dt_editor"
         }, "<textarea rows=15 class='tinyMCE'></textarea>");
    }

};

//Добавляем тип image
webix.editors.imageField = {
    focus:function(){
        this.getInputNode(this.node).focus();
        this.getInputNode(this.node).select();
        BrowseServer(this.node.firstChild, this);
    },
    getValue:function(){
        return this.getInputNode(this.node).value;
    },
    setValue:function(value){
        this.getInputNode(this.node).value = value;
    },
    getInputNode:function(){
        return this.node.firstChild;
    },
    render:function(){
			return webix.html.create("div", {
            "class":""
        }, "<input type=text  hidden/>");
    }

};

function OpenServerBrowser(url, width, height )
		{
				var iLeft = (screen.width  - width) / 2 ;
				var iTop  = (screen.height - height) / 2 ;
				var sOptions = 'toolbar=no,status=no,resizable=yes,dependent=yes' ;
				sOptions += ',width=' + width ;
				sOptions += ',height=' + height ;
				sOptions += ',left=' + iLeft ;
				sOptions += ',top=' + iTop ;
				var oWindow = window.open( url, 'FCKBrowseWindow', sOptions );

		}

//Открываетм файл-менеджер
function BrowseServer(ctrl, node) {
		lastImageCtrl = ctrl;
		thisNode = node;
		var w = screen.width * 0.5;
		var h = screen.height * 0.5;
		OpenServerBrowser('[+site_manager_url+]/media/browser/mcpuk/browser.php?Type=images', w, h);
}

//Возвращаем значения из файл-менеджера
function SetUrl(url){
	lastImageCtrl.value = url;
	itemUpdate[idEdited.column] = url;
	//$$$('grid').updateItem(idEdited, itemUpdate);
	$$$('grid').editStop();
	$$$('grid').callEvent("onEditorChange", [idEdited,itemUpdate[idEdited.column]]);
	 // var item = $$$('grid').getItem(thisNode.row);
	 // item[thisNode.column] = url;
	 // $$$('grid').updateItem(thisNode.row, itemUpdate);
	//webix.ajax().post("[+url+]?mode=setData", {id:thisNode.row,field:thisNode.column,value:url});
}


//Сохранение из модального окна с richtext
function rtSave(webix,richtext,id){
					$$$('rtWindow').hide();
					itemUpdate[id.column] = richtext;
					$$$('grid').updateItem(id.row,itemUpdate);
					$$$('grid').editStop();
					$$$('grid').callEvent("onEditorChange", [id,itemUpdate[id.column]]);
					return;
				}


//Из XLSX в JSON
function to_json(workbook) {
		var result = {};
		workbook.SheetNames.forEach(function(sheetName) {
			var roa = X.utils.sheet_to_json(workbook.Sheets[sheetName]);
			if(roa.length) result[sheetName] = roa;
		});
		return JSON.stringify(result["Data"]);
	};


		(function($){
			var loaded = false;
		    $('#documentPane').on('click','#yag_tab',function(){
		        if(!loaded){

		        	//https://webix.com/snippet/66c69730
		        	// Активируем Webix
		        	webix.ready(function(){

		        		rtEditor = "[+rtEditor+]";
     						webix.ui({
   									container:"yag_container",
										rows:[
									    { type:"header", template:"[+tabName+]" },
									    {
									    	view:"form",
									    	padding: 7,
									    	cols:[
									    	{view:"pager",
									    	id:"pager",
									    	template:"{common.prev()} {common.pages()} {common.next()}",
												animate:true,
												size:5,
												group:5,},
											{ view:"uploader", type:"icon", label:"Import", icon:"download", on:{
												onBeforeFileAdd: function(upload){
													var output='';
													(FileReader.prototype).readAsBinaryString;
													var reader = new FileReader();
													reader.onload = function(e) {
														var data = e.target.result;
														output = to_json(X.read(data, {type:'binary'}));
														webix.ajax().post("[+url+]?mode=setMultiData", {data:output});
														$$$("grid").parse(output,"json");
													}
													reader.readAsBinaryString(upload.file);
													return false;
											}}, width:80},
											{view:"button", type:"icon", icon:"upload", label:"Export", click: function(){
												webix.toExcel($$$("grid"),
												{
													filename: "[+tabName+]",
													filterHTML:true,
													heights:false,
													columns:{[+expImpConfig+]}
												});
											}, width:80 },
											{ view:"button", type:"icon", icon:"undo", label:"Undo", click: function(){
												id = historyUndo.pop();
												if(!id) return;
												$$$('grid').undo(id);
												row = $$$('grid').getItem(id);
												$$$('grid').callEvent("onEditorChange", [id,row[id.column]]);
											}, width:80 }
											]},
									    { cols:[
										    {
														view:"datatable",
														url: "post->[+url+]?id=[+id+]",
														id:"grid",
														columns:[
															[+tableConfig+]
														],
														pager:"pager",
														fixedRowHeight:false,
														rowLineHeight:25,
														rowHeight:180,
														editable:true,
														editaction: "[+editaction+]",
														autoheight:true,
														checkboxRefresh:true,
														scrollY:true,
														scrollAlignY:true,
														undo:true,
														on:{
																"onAfterLoad":webix.once(function(){
																	this.adjustRowHeight("content");
																}),
																"onEditorChange":function(id, value){
																	//if (!value) return false;
									      					webix.ajax().post("[+url+]?mode=setData", {id:id.row,field:id.column,value:value});
									     					},
									     					"onCheck":function(row, column, state){
									     						state = state ? true :false;
									     						webix.ajax().post("[+url+]?mode=setData", {id:row,field:column,value:state});
									     					},
									     					//Активируем TinyMCE для заданных ячеек
									     					"onAfterEditStart":function(id){
									     						idEdited = id;
									     						if($$$('grid').getEditor().config.editor=="richtext"){
										     						switch(rtEditor){
										     							case "inline":
											     							tinymce.init({
																					  selector: 'textarea.tinyMCE',
																					  toolbar: 'undo redo | styleselect | bold italic | link image',
																				});
										     							break;
										     							case "modal":
										     								$$$("rtWindow").show();
										     								$$$("rtWindow").enable();
										     								tinymce.init({
																					  selector: 'textarea.tinyMCE',
																					  toolbar: 'undo redo | styleselect | bold italic | link image',
																				})
										     								break;
										     						}
										     					}

										     					historyUndo.push(id);
																},
																//Вставляем данные из TinyMce в таблицу
																"onAfterEditStop":function(state, editor, ignoreUpdate){
																	if ($$$("rtWindow").isVisible()) return;
																		switch(true){
																			case state.value != state.old && editor.config.editor=='richtext':
																				itemUpdate[idEdited.column] = tinymce.activeEditor.getContent({format: 'raw'});
																				$$$('grid').callEvent("onEditorChange", [idEdited,itemUpdate[idEdited.column]]);
																			break;

																			case editor.config.editor=='combo':
																			webix.ajax().post("[+url+]?mode=setData", {id:idEdited.row,field:idEdited.column,value:state.value});
																				break;
																		}
																},
															},
													}
									    ]},

									  ]
				     						});

				//richtext в модальном окне
					webix.ui({
				            view:"window",
				            id:"rtWindow",
				            width:800,
				            //height:600,
				            resize:true,
				            position:"center",
				            modal:true,
				            head:{view:"toolbar", cols:[
													{view:"label", label: "Редактор" },
													{ view:"button", label: 'Сохранить', width: 100, align: 'right', click:"rtSave(webix,tinymce.activeEditor.getContent({format:'raw'}),idEdited);"},
													{ view:"button", label: 'Закрыть', width: 100, align: 'right', click:"webix.$$('rtWindow').hide();"}
										]},
										body: "",
				            on:{
				            	"onShow": function(){
				            		var cellValue = "<textarea rows=15 class='tinyMCE'>" + $$$('grid').getText(idEdited.row, idEdited.column) + "</textarea>";
				            		 viewId = $$$('rtWindow').config.body.id;
				            		 $('[view_id="'+viewId+'"]').html(cellValue);
				            	}
				            },
				        });
				});


		        	loaded= true; //Таблица загружена
		        }

		      })
		    $(window).on('load', function(){
		        if ($('#yag_tab')) {
		            $('#yag_tab.selected').trigger('click');
		        }
		    });

		})(jQuery)

</script>