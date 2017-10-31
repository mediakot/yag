<div id="yag" class="tab-page">
    <h2 class="tab" id="yag_tab">[+tabname+]</h2>
    <div id="yag_container" style="width:100%; margin:10px; border:1px solid #ccc"></div>
</div>
<div class="pagerB"></div>
<style type="text/css">
.webix_view button {
    padding: 0!important;
}

.webix_message_area {
    top: 35px !important;
    right: 10px;
}

.deletedRow {
    background-color: #EEAAAA;
}

.unPub{
    opacity: 0.5;
}

</style>
<script type="text/javascript" charset="utf-8">
var idEdited = ''; //Чтобы запомнить какая ячейка редактируется TinyMCE
var lastImageCtrl = ''; //Для файл-баузера
var thisNode = '';
var historyUndo = []; //Стек для undo
var X = XLSX; //Для импорта
var $$$ = webix.$$; //Алиас, потому что псевдоним $$ занят mootools
var itemUpdate = []; //для апдейта ячейки, чтобы коректно работало Undo
var deletedAction = "[+deletedAction+]"; //Действие с удаленными документами
var deletedItems = []; //Для сохранения удаленных доков
//Custom разбор данных для дерева документов
webix.DataDriver.custom = webix.extend({
    arr2hash: function(data) {
        var hash = {};
        for (var i = 0; i < data.length; i++) {
            var pid = data[i].parent;
            if (!hash[pid]) hash[pid] = [];
            hash[pid].push(data[i]);
        }
        return hash;
    },
    hash2tree: function(hash, level) {
        var top = hash[level];
        for (var i = 0; i < top.length; i++) {
            var branch = top[i].id;
            if (hash[branch])
                top[i].data = this.hash2tree(hash, branch);
        }
        return top;
    },
    minParent: function(data) {
        var parentsId = [];
        for (var key in data)
            if (data.hasOwnProperty(key)) {
                if (+data[key].parent || +data[key].parent === 0) parentsId.push(data[key].parent);
            }
        return Math.min.apply(Math, parentsId);
    },
    getRecords: function(data, id) {
        var minParent = this.minParent(data);
        var hash = this.arr2hash(data);
        return this.hash2tree(hash, minParent);
    }
}, webix.DataDriver.json);
if (deletedAction == "show") {
    showDeleted = true;
    showButton = "Скрыть";
    hideButton = "Показать";
} else {
    showDeleted = false;
    showButton = "Показать";
    hideButton = "Скрыть";
}
//Добавляем тип tinyMCE
webix.editors.richtext = {
    focus: function() {
        this.getInputNode(this.node).focus();
        this.getInputNode(this.node).select();
    },
    getValue: function() {
        if (rtEditor == "modal") return this.getInputNode(this.node).value;
        return tinymce.activeEditor.getContent({ format: 'raw' });
    },
    setValue: function(value) {
        this.getInputNode(this.node).value = value;
    },
    getInputNode: function() {
        return this.node.firstChild;
    },
    render: function() {
        if (rtEditor == "modal") return webix.html.create("div", {}, "<input type=text  hidden/>");
        return webix.html.create("div", {
            "class": "webix_dt_editor"
        }, "<textarea rows=15 class='tinyMCE'></textarea>");
    }
};
//Добавляем тип image
webix.editors.imageField = {
    focus: function() {
        this.getInputNode(this.node).focus();
        this.getInputNode(this.node).select();
        BrowseServer(this.node.firstChild, this);
    },
    getValue: function() {
        return this.getInputNode(this.node).value;
    },
    setValue: function(value) {
        this.getInputNode(this.node).value = value;
    },
    getInputNode: function() {
        return this.node.firstChild;
    },
    render: function() {
        return webix.html.create("div", {
            "class": ""
        }, "<input type=text  hidden/>");
    }
};

function OpenServerBrowser(url, width, height) {
    var iLeft = (screen.width - width) / 2;
    var iTop = (screen.height - height) / 2;
    var sOptions = 'toolbar=no,status=no,resizable=yes,dependent=yes';
    sOptions += ',width=' + width;
    sOptions += ',height=' + height;
    sOptions += ',left=' + iLeft;
    sOptions += ',top=' + iTop;
    var oWindow = window.open(url, 'FCKBrowseWindow', sOptions);
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
function SetUrl(url) {
    lastImageCtrl.value = url;
    itemUpdate[idEdited.column] = url;
    //$$$('grid').updateItem(idEdited, itemUpdate);
    $$$('grid').editStop();
    $$$('grid').callEvent("onEditorChange", [idEdited, itemUpdate[idEdited.column]]);
    // var item = $$$('grid').getItem(thisNode.row);
    // item[thisNode.column] = url;
    // $$$('grid').updateItem(thisNode.row, itemUpdate);
    //webix.ajax().post("[+url+]?mode=setData", {id:thisNode.row,field:thisNode.column,value:url});
}
//Сохранение из модального окна с richtext
function rtSave(webix, richtext, id) {
    $$$('rtWindow').hide();
    itemUpdate[id.column] = richtext;
    $$$('grid').updateItem(id.row, itemUpdate);
    $$$('grid').editStop();
    $$$('grid').callEvent("onEditorChange", [id, itemUpdate[id.column]]);
    return;
}
//Сохранение нового документа
function newDocSave(id, data) {
    if (typeof $$$('treeDocs').getSelectedItem() === "undefined") {
        webix.message("Не выбрано куда добавлять документ", "error");
        return;
    }
    var idNewDoc = '';
    var parentId = $$$('treeDocs').getSelectedItem().id;
    var pagetitle = $$$('newDocForm').getValues().pagetitle;
    webix.ajax().post("[+url+]?mode=saveNewDoc", { parent: parentId, pagetitle: pagetitle, template: '[+templatesItems+]', published: 0 },
        function(id) {
            $$$('grid').add({
                id: id,
                parent: parentId,
                pagetitle: $$$('newDocForm').getValues().pagetitle,
                published: 0
            })
        });
    $$$('newDoc').hide();
}
//Из XLSX в JSON
function to_json(workbook) {
    var result = {};
    workbook.SheetNames.forEach(function(sheetName) {
        var roa = X.utils.sheet_to_json(workbook.Sheets[sheetName]);
        if (roa.length) result[sheetName] = roa;
    });
    return JSON.stringify(result["Data"]);
};
(function($) {
    var loaded = false;
    $('#documentPane').on('click', '#yag_tab', function() {
        if (!loaded) {
            // Активируем Webix
            webix.ready(function() {
                rtEditor = "[+rtEditor+]";
                webix.ui({
                    container: "yag_container",
                    type:"clean",
                    rows: [
                        { view: "toolbar",
                            elements: [
                                //Кнопка показать/скрыть удаленные
                                {
                                    view: "toggle",
                                    type: "iconButton",
                                    tooltip: "Отображение удаленных документов",
                                    offLabel: showButton,
                                    onLabel: hideButton,
                                    icon: "trash-o",
                                    width: 110,
                                    click: function() {
                                        if (!showDeleted) {
                                            deletedItems.each(function(obj) {
                                                $$$('grid').add(obj);
                                                $$$("grid").addRowCss(obj.id, "deletedRow");
                                            })
                                            showDeleted = true;
                                            deletedItems = [];
                                        } else {
                                            $$$("grid").data.each(function(obj) {
                                                if (obj.deleted == "1") {
                                                    deletedItems.push(obj);
                                                }
                                            })
                                            deletedItems.each(function(obj) { $$$("grid").remove(obj.id) })
                                            showDeleted = false;
                                        }
                                    }
                                },
                                //Селект действия с отмеченными
                                {
                                    view: "select",
                                    id: "ops",
                                    label: "Действие:",
                                    labelAlign: "right",
                                    value: 1,
                                    options: [{ id: 1, value: "Публиковать" },
                                        { id: 2, value: "Не публиковать" },
                                        { id: 3, value: "Удалить" }
                                    ],
                                    width: 200
                                },
                                //Кнопка выполнить выбранное действие
                                {
                                    view: "button",
                                    type: "iconButton",
                                    label: "Применить",
                                    tooltip: "Применить выбранное действие",
                                    icon: "cog",
                                    width: 125,
                                    click: function() {
                                        var chIds = [];
                                        $$$("grid").data.each(function(obj) {
                                            if (obj.ch) {
                                                deletedItems.push(obj);
                                                chIds.push(obj.id)
                                            }
                                        })
                                        switch ($$$("ops").getValue()) {
                                            case "1":
                                                webix.ajax().post("[+url+]?mode=publish", { ids: chIds },
                                                    function(text) {
                                                        webix.message(text, "info");
                                                    });
                                                break;
                                            case "2":
                                                webix.ajax().post("[+url+]?mode=unPublish", { ids: chIds }, function(text) {
                                                    webix.message(text, "info");
                                                });
                                                break;
                                            case "3":
                                                webix.ajax().post("[+url+]?mode=delete", { ids: chIds },
                                                    function(text) {
                                                        webix.message(text, "info");
                                                        showDeleted ? $$$("grid").addRowCss(chIds, "deletedRow") : $$$('grid').remove(chIds);
                                                    });
                                                break;
                                        }
                                    }
                                },
                                //Кнопка Импорт
                                {
                                    view: "uploader",
                                    type: "iconButton",
                                    label: "Импорт",
                                    icon: "download",
                                    autowidth: true,
                                    on: {
                                        onBeforeFileAdd: function(upload) {
                                            var output = '';
                                            (FileReader.prototype).readAsBinaryString;
                                            var reader = new FileReader();
                                            reader.onload = function(e) {
                                                var data = e.target.result;
                                                output = to_json(X.read(data, { type: 'binary' }));
                                                webix.ajax().post("[+url+]?mode=setMultiData", { data: output },
                                                    function(text) {
                                                        var message = webix.message(text, "info");
                                                    });
                                                $$$("grid").parse(output, "json");
                                            }
                                            reader.readAsBinaryString(upload.file);
                                            return false;
                                        }
                                    },
                                    width: 80
                                },
                                //Кнопка Экспорт
                                {
                                    view: "button",
                                    type: "iconButton",
                                    icon: "upload",
                                    label: "Экспорт",
                                    autowidth: true,
                                    click: function() {
                                        webix.toExcel($$$("grid"), {
                                            filename: "[+tabName+]",
                                            filterHTML: true,
                                            heights: false,
                                            columns: {
                                                [+expImpConfig+]}
                                        });
                                    },
                                    width: 80
                                },
                                //Кнопка Отменить действие
                                {
                                    view: "button",
                                    type: "iconButton",
                                    icon: "undo",
                                    label: "Undo",
                                    autowidth: true,
                                    click: function() {
                                        id = historyUndo.pop();
                                        if (!id) return;
                                        $$$('grid').undo(id);
                                        row = $$$('grid').getItem(id);
                                        $$$('grid').callEvent("onEditorChange", [id, row[id.column]]);
                                    },
                                    width: 80
                                },
                                {
                                    view: "button",
                                    type: "iconButton",
                                    label: "Добавить",
                                    tooltip: "Добавить новый документ",
                                    icon: "plus-square-o",
                                    width: 110,
                                    click: function() {
                                        $$$("newDoc").show();
                                    }
                                }
                            ]
                        },
                        {
                            view: "form",
                            padding: 7,
                            cols: [{
                                view: "pager",
                                id: "pagerA",
                                template: "{common.first()} {common.prev()} {common.pages()} {common.next()} {common.last()}",
                                animate: true,
                                size: [+sizePager+],
                                group: 5,
                            }]
                        },
                        {
                            cols: [{
                                view: "datatable",
                                url: "post->[+url+]?id=[+id+]",
                                id: "grid",
                                columns: [
                                    [+tableConfig+]
                                ],
                                pager: "pagerA",
                                fixedRowHeight: false,
                                rowLineHeight: 25,
                                rowHeight: 180,
                                editable: true,
                                resizeColumn: [+resizeColumns+],
                                editaction: "[+editaction+]",
                                autoheight: true,
                                checkboxRefresh: true,
                                scrollY: true,
                                scrollAlignY: true,
                                undo: true,
                                on: {
                                      "onBeforeLoad":function(){
                                                                this.showOverlay("Loading...");
                                                          },
                                    "onAfterLoad": function() {
                                        this.adjustRowHeight("content");
                                        //Действия с помеченными на удаление документами
                                        if (showDeleted) {
                                            $$$("grid").data.each(function(obj) {
                                                //console.log(obj.published)
                                                if (obj.deleted == "1")  $$$("grid").addRowCss(obj.id, "deletedRow");

                                                if (obj.published == "0") $$$('grid').addRowCss(obj.id, "unPub");
                                            })
                                        } else {
                                            $$$("grid").data.each(function(obj) {
                                                if (obj.deleted == "1")  deletedItems.push(obj);

                                                if (obj.published == "0") $$$('grid').addRowCss(obj.id, "unPub");
                                            })
                                            deletedItems.each(function(obj) { $$$('grid').remove(obj.id) })
                                        }


                                        this.hideOverlay()
                                    },
                                    "onBeforeRender":function(data) {
                                        //Для правильного отображения картинок, вставленных в контент
                                        for(var key in data.pull){
                                            if (data.pull.hasOwnProperty(key)) {
                                            var content = data.pull[key].content;

                                            content = content.replace(new RegExp('src="assets','mg'),'src="\/assets');
                                            data.pull[key].content = content;
                                            }
                                        }
                                    },
                                    "onEditorChange": function(id, value) {
                                        //if (!value) return false;
                                        webix.ajax().post("[+url+]?mode=setData", { id: id.row, field: id.column, value: value }, function(text) {
                                            webix.message(text, "info");
                                        });
                                    },
                                    "onCheck": function(row, column, state) {
                                        if (column == "ch") return;
                                        state = state ? true : false;
                                        webix.ajax().post("[+url+]?mode=setData", { id: row, field: column, value: state }, function(text) {
                                            webix.message(text, "info");
                                        });
                                    },
                                    //Активируем TinyMCE для заданных ячеек
                                    "onAfterEditStart": function(id) {
                                        idEdited = id;
                                        if ($$$('grid').getEditor().config.editor == "richtext") {
                                            switch (rtEditor) {
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
                                    "onAfterEditStop": function(state, editor, ignoreUpdate) {
                                        if ($$$("rtWindow").isVisible()) return;
                                        switch (true) {
                                            case state.value != state.old && editor.config.editor == 'richtext':
                                                itemUpdate[idEdited.column] = tinymce.activeEditor.getContent({ format: 'raw' });
                                                $$$('grid').callEvent("onEditorChange", [idEdited, itemUpdate[idEdited.column]]);
                                                break;
                                            case editor.config.editor == 'combo':
                                                webix.ajax().post("[+url+]?mode=setData", { id: idEdited.row, field: idEdited.column, value: state.value });
                                                break;
                                        }
                                    }
                                }
                            }]
                        },
                        {
                            view: "form",
                            padding: 7,
                            cols: [{ id: "pagerB", view: "pager", template: "{common.first()} {common.prev()} {common.pages()} {common.next()} {common.last()}" }],
                            size: [+sizePager+],
                            group: 5,
                        }
                    ]
                });
                //Pager под таблицей
                $$$("pagerA").clone($$$("pagerB"));
                //richtext в модальном окне
                webix.ui({
                    view: "window",
                    id: "rtWindow",
                    width: 800,
                    //height:600,
                    resize: true,
                    position: "center",
                    modal: true,
                    head: {
                        view: "toolbar",
                        cols: [
                            { view: "label", label: "Редактор" },
                            { view: "button", label: 'Сохранить', width: 100, align: 'right', click: "rtSave(webix,tinymce.activeEditor.getContent({format:'raw'}),idEdited);" },
                            { view: "button", label: 'Закрыть', width: 100, align: 'right', click: "webix.$$('rtWindow').hide();" }
                        ]
                    },
                    body: "",
                    on: {
                        "onShow": function() {
                            var cellValue = "<textarea rows=15 class='tinyMCE'>" + $$$('grid').getText(idEdited.row, idEdited.column) + "</textarea>";
                            viewId = $$$('rtWindow').config.body.id;
                            $('[view_id="' + viewId + '"]').html(cellValue);
                        }
                    },
                })
                webix.ui({
                    view: "window",
                    id: "newDoc",
                    move: true,
                    width: $(window).width() - 10,
                    height: $(window).height() / 1.5,
                    resize: true,
                    position: "center",
                    modal: true,
                    head: {
                        view: "toolbar",
                        cols: [
                            { view: "label", label: "Редактор" },
                            { view: "button", label: 'Сохранить', width: 100, align: 'right', click: "newDocSave()" },
                            { view: "button", label: 'Закрыть', width: 100, align: 'right', click: "webix.$$('newDoc').hide();" }
                        ]
                    },
                    body: {
                        cols: [{
                                //Дерево документов для выбора куда добовлять новый документ.
                                view: "tree",
                                width: 250,
                                id: "treeDocs",
                                select: true,
                                datatype: "custom",
                                template: function(obj, common) {
                                    return common.icon(obj, common) + common.folder(obj, common) + "<span>" + obj.title + " (" + obj.id + ")</span>"
                                },
                                url: "[+url+]?mode=getTree&id=[+id+]",
                            },
                            {
                                //Добавление нового документа
                                view: "form",
                                id: "newDocForm",
                                height: 600,
                                elements: [{ view: "text", label: "Pagetitle", name: "pagetitle" }, ]
                            }
                        ]
                    },
                    on: {
                        "onShow": function() {
                            $$$('treeDocs').openAll();
                        }
                    }
                })
            });
            loaded = true; //Таблица загружена
        }
    })
    $(window).on('load', function() {
        if ($('#yag_tab')) {
            $('#yag_tab.selected').trigger('click');
        }
    });
})(jQuery)
</script>