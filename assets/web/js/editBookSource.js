// 创建书源规则容器对象
const RuleJSON = (() => {
    let ruleJson = {};
    document.querySelectorAll('.rules input').forEach(item => ruleJson[item.id] = '');
    ruleJson.serialNumber = 0;
    ruleJson.weight = 0;
    ruleJson.enable = 1;
    ruleJson.searchForDetail = 0;
    return ruleJson;
})();


$(document).ready(function () {
    AppConfig.initCache();
    if(AppConfig.editCourse == null){
        AppConfig.editCourse = { "old": [], "now": {}, "new": [] };
        AppConfig.editCourse.now = rule2json();
        window.localStorage.setItem('editCourse', JSON.stringify(AppConfig.editCourse));
    }else{
        json2rule(AppConfig.editCourse.now);
    }

    if(AppConfig.editBookSource == null){
        document.querySelectorAll('.rules input').forEach(item => { item.value = '' });
        formatCheckBox();
        todo();
    }else{
        AppConfig.editBookSource.enable === 1 ? document.querySelector("#enable").checked = true : document.querySelector("#enable").checked = false;
        AppConfig.editBookSource.searchForDetail === 1 ? document.querySelector("#searchForDetail").checked = true : document.querySelector("#searchForDetail").checked = false;
        document.querySelector('#ruleFindUrl').value = AppConfig.editBookSource.ruleFindUrl;
        formatCheckBox();
        //编辑
        json2rule(AppConfig.editBookSource);
        todo();
    }

    document.querySelectorAll('input').forEach((item) => { item.addEventListener('change', () => { todo() }) });
    document.querySelectorAll('textarea').forEach((item) => { item.addEventListener('change', () => { todo() }) });
});


//初始化按钮
function formatCheckBox(){
    let checkBoxList = Array.prototype.slice.call(document.querySelectorAll('.js-switch'));
    checkBoxList.forEach(function(html) {
        new Switchery(html, { size: 'small'});
    });
}

function setRule(editRule) {
    let checkRule = AppConfig.ruleSources.find(x => x.bookSourceUrl === editRule.bookSourceUrl);
    if (checkRule) {
        Object.keys(checkRule).forEach(key => { checkRule[key] = editRule[key]; });
    } else {
        AppConfig.ruleSources.unshift(editRule);
    }
    localStorage.setItem('ruleSources', JSON.stringify(AppConfig.ruleSources));
}

// 将书源表单转化为书源对象
function rule2json() {
    Object.keys(RuleJSON).forEach((key) => {
        RuleJSON[key] = document.querySelector('#' + key).value;
        RuleJSON.enable = document.querySelector("#enable").checked ? 1 : 0;
        RuleJSON.searchForDetail = document.querySelector("#searchForDetail").checked ? 1 : 0;
        RuleJSON.ruleFindUrl = document.querySelector('#ruleFindUrl').value;
    });
    RuleJSON.bookSourceType = RuleJSON.bookSourceType.toUpperCase();
    RuleJSON.serialNumber = RuleJSON.serialNumber === '' ? 0 : parseInt(RuleJSON.serialNumber);
    RuleJSON.weight = RuleJSON.weight === '' ? 0 : parseInt(RuleJSON.weight);
    let TempRules = AppConfig.ruleSources.filter(item => (item['bookSourceUrl'] === RuleJSON['bookSourceUrl'] ? item : null));
    if (TempRules.length > 0) {
        Object.keys(RuleJSON).forEach(key => TempRules[0][key] = RuleJSON[key]);
        return TempRules[0];
    }
    return RuleJSON;
}

// 将书源对象填充到书源表单
function json2rule(RuleEditor) {
    Object.keys(RuleJSON).forEach((key) => document.querySelector("#" + key).value = RuleEditor[key] ? RuleEditor[key] : '');
}

function todo() {
    AppConfig.editCourse.old.push(Object.assign({}, AppConfig.editCourse.now));
    AppConfig.editCourse.now = rule2json();
    AppConfig.editCourse.new = [];
    if (AppConfig.editCourse.old.length > 50) AppConfig.editCourse.old.shift(); // 限制历史记录堆栈大小
    localStorage.setItem('editCourse', JSON.stringify(AppConfig.editCourse));
}

function undo() {
    AppConfig.editCourse = JSON.parse(localStorage.getItem('editCourse'));
    if (AppConfig.editCourse.old.length > 0) {
        AppConfig.editCourse.new.push(AppConfig.editCourse.now);
        AppConfig.editCourse.now = AppConfig.editCourse.old.pop();
        localStorage.setItem('editCourse', JSON.stringify(AppConfig.editCourse));
        json2rule(AppConfig.editCourse.now);
    }
}

function redo() {
    AppConfig.editCourse = JSON.parse(localStorage.getItem('editCourse'));
    if (AppConfig.editCourse.new.length > 0) {
        AppConfig.editCourse.old.push(AppConfig.editCourse.now);
        AppConfig.editCourse.now = AppConfig.editCourse.new.pop();
        localStorage.setItem('editCourse', JSON.stringify(AppConfig.editCourse));
        json2rule(AppConfig.editCourse.now);
    }
}

// 处理按钮点击事件
document.querySelector('.bookSourceManager').addEventListener('click', e => {
    let thisNode = e.target;
    if(thisNode.innerText === "Loading") return;
    let innerText = thisNode.innerText;
    thisNode.innerText = "Loading";
    thisNode.classList.add("button-busy");
    switch (thisNode.id) {
        case 'exportBookSource':
            document.querySelector('#textareaExportBookSource').value = JSON.stringify(rule2json(), null, 4);
            layx.open({
                id: "layoutExportBookSource",
                content: {
                    type: 'html',
                    value: document.getElementById("layout-bookSource")
                },toolBar: {
                    titleBar: {
                        title: "生成JSON书源"
                    }
                },
            });
            break;
        case 'importBookSource':
            layx.open({
                id: "layoutExportBookSourceImport",
                content: {
                    type: 'html',
                    value: document.getElementById("layout-bookSource-import")
                },toolBar: {
                    titleBar: {
                        title: "导入JSON书源"
                    }
                }
            });
            document.querySelector('#layx-layoutExportBookSourceImport #btnExportBookSourceImport').addEventListener('click', e => {
                if (document.querySelector('#layx-layoutExportBookSourceImport #textareaExportBookSourceImport').value === ""){
                    Swal.fire({
                        icon: 'info',
                        text: `JSON内容不能为空!`,
                    });
                }else{
                    try {
                        json2rule(JSON.parse(document.querySelector('#layx-layoutExportBookSourceImport #textareaExportBookSourceImport').value));
                        todo();
                    } catch (error) {
                        Swal.fire({
                            icon: 'error',
                            text: `导入JSON失败!\n${error}`,
                        });
                    }
                }
            });
            break;
        case 'clearBookSource':
            document.querySelectorAll('.rules input').forEach(item => { item.value = '' });
            document.querySelectorAll('.rules textarea').forEach(item => { item.value = '' });
            todo();
            break;
        case 'undoOpera':
            undo();
            break;
        case 'todoOpera':
            redo();
            break;
        case 'debugBookSource':
            layx.open({
                id: "layoutDebugger",
                content: {
                    type: 'html',
                    value: document.getElementById("layout-debugger")
                },toolBar: {
                    titleBar: {
                        title: "调试书源"
                    }
                }
            });
            document.querySelector('#layx-layoutDebugger #btnDebugger').addEventListener('click', e => {
                if (document.querySelector('#layx-layoutDebugger #debugKey').value === ""){
                    Swal.fire({
                        icon: 'info',
                        text: `搜索内容不能为空!`,
                    });
                }else{
                    let wsOrigin = (AppConfig.hashParam('domain') || location.origin).replace(/^.*?:/, 'ws:').replace(/\d+$/, (port) => (parseInt(port) + 1));
                    let DebugInfos = document.querySelector('#layx-layoutDebugger #textareaDebugger');
                    function DebugPrint(msg) { DebugInfos.value += `\n${msg}`; DebugInfos.scrollTop = DebugInfos.scrollHeight; }
                    let saveRule = [rule2json()];
                    AppConfig.httpPost(`/saveSources`, saveRule).then(sResult => {
                        if (sResult.isSuccess) {
                            let sKey = document.querySelector('#layx-layoutDebugger #debugKey').value ? document.querySelector('#layx-layoutDebugger #debugKey').value : '至尊';
                            document.querySelector('#layx-layoutDebugger #textareaDebugger').value = `书源《${saveRule[0].bookSourceName}》保存成功！使用搜索关键字“${sKey}”开始调试...`;
                            let ws = new WebSocket(`${wsOrigin}/sourceDebug`);
                            ws.onopen = () => {
                                ws.send(`{"tag":"${saveRule[0].bookSourceUrl}", "key":"${sKey}"}`);
                            };
                            ws.onmessage = (msg) => {
                                DebugPrint(msg.data === 'finish' ? `\n[${Date().split(' ')[4]}] 调试任务已完成!` : msg.data);
                                if (msg.data === 'finish') setRule(saveRule[0]);
                            };
                            ws.onerror = (err) => {
                                throw `${err.data}`;
                            };
                            ws.onclose = () => {
                                thisNode.classList.remove("button-busy");
                                thisNode.innerText = innerText;
                                DebugPrint(`[${Date().split(' ')[4]}] 调试服务已关闭!`);
                            };
                        } else throw `${sResult.errorMsg}`;
                    }).catch(err => {
                        DebugPrint(`调试过程意外中止，以下是详细错误信息:\n${err}`);
                        thisNode.classList.remove("button-busy");
                        thisNode.innerText = innerText;
                    });
                }
            });
            break;
        case 'saveBookSource':
            if(document.querySelector("#bookSourceName").value === "" || document.querySelector("#bookSourceUrl").value === ""){
                Swal.fire({
                    icon: 'info',
                    text: `书源名称和书源地址不能为空！`,
                });
            }else{
                (async () => {
                    let saveRule = [rule2json()];
                    await AppConfig.httpPost(`/saveSources`, saveRule).then(json => {
                        Swal.fire({
                            icon: 'success',
                            text: json.isSuccess ? `书源《${saveRule[0].bookSourceName}》已成功保存到「APP」` : `书源《${saveRule[0].bookSourceName}》保存失败!\nErrorMsg: ${json.errorMsg}`,
                        });
                        setRule(saveRule[0]);
                    }).catch(err => {
                        Swal.fire({
                            icon: 'error',
                            text: `保存书源失败,无法连接到「APP」!\n${err}`,
                        });
                    });
                    thisNode.classList.remove("button-busy");
                    thisNode.innerText = innerText;
                })();
            }
            break;
        default:
    }
    setTimeout(() => { thisNode.classList.remove("button-busy");thisNode.innerText = innerText;}, 500);
});