
$(document).ready(function () {
    AppConfig.initCache();
    let ruleListArray = [];
    AppConfig.ruleSources.forEach(item => {
        ruleListArray.push(addRuleItem(item));
    });
    addRuleList(ruleListArray.join(''));
});

function addRuleItem(item){
    return `
            <tr>
                <td class="tc" id="` + item.bookSourceUrl + `">` + item.bookSourceName + `</td>
                <td class="tc">` + item.bookSourceUrl + `</td>
                <td class="tc">` + item.bookSourceGroup + `</td>
                <td class="tc">` + (item.enable === 1 ? `<span class="box-ok"></span>` : `<span class="box-cancel"></span>`) + `</td>
                <td class="tc">` + (item.searchForDetail === 1 ? `<span class="box-ok"></span>` : `<span class="box-cancel"></span>`) + `</td>
                <td class="tc">
                    <button class="btn-min btn-default" onclick="editAndDebug('` + item.bookSourceUrl.trim() + `')">编辑&调试</button>
                    <button class="btn-min btn-default" onclick="deleteItem('` + item.bookSourceUrl.trim() + `')">删除</button>
                </td>
            </tr>
    `;
}

function addRuleList(ruleListArray){
    let innerHTML = "";
    innerHTML += `
                <tr class="light_color">
                    <th class="tc w-100">书源名称</th>
                    <th class="tc w-100">书源地址</th>
                    <th class="tc w-100">书源分组</th>
                    <th class="tc w-200">是否启用</th>
                    <th class="tc w-200">用于详情搜索</th>
                    <th class="tc w-200">操作</th>
                </tr>
    `;
    innerHTML += ruleListArray;
    $('#tableRuleList').html(innerHTML);
}

function findItem(searchName, searchUrl){
    let ruleListArray = [];
    AppConfig.ruleSources.forEach(item => {
        let isExist = false;
        if(searchName === "") isExist = true;
        else {
            isExist = item.bookSourceName.indexOf(searchName) !== -1;
        }
        if(isExist){
            if(searchUrl === "") isExist = true;
            else {
                isExist = item.bookSourceUrl.indexOf(searchUrl) !== -1;
            }
        }
        if(isExist) ruleListArray.push(addRuleItem(item));
    });
    addRuleList(ruleListArray.join(''));
}

function editAndDebug(bookSourceUrl){
    let editBookSource = {};
    for(let i = 0; i < AppConfig.ruleSources.length; i++){
        if(AppConfig.ruleSources[i].bookSourceUrl === bookSourceUrl){
            editBookSource = AppConfig.ruleSources[i];
            break;
        }
    }
    localStorage.setItem('editBookSource', JSON.stringify(editBookSource));
    window.location.href = "/editBookSource.html";
}

function deleteItem(bookSourceUrl){
    Swal.fire({
        text: `确定要删除当前书源吗?\n(同时删除APP内书源)`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: '确定',
        cancelButtonText: '取消'
    }).then((result) => {
        if (result.value) {
            let deleteSources = AppConfig.ruleSources.filter(item => item.bookSourceUrl.trim() === bookSourceUrl.trim()); // 提取待删除的书源
            let resultSources = AppConfig.ruleSources.filter(item => !(item.bookSourceUrl.trim() === bookSourceUrl.trim()));  // 提取待留下的书源
            AppConfig.httpPost(`/deleteSources`, deleteSources).then(json => {
                if (json.isSuccess) {
                    localStorage.setItem('RuleSources', JSON.stringify(RuleSources = resultSources));
                    RuleSources = JSON.parse(localStorage.getItem('RuleSources'));
                    let ruleListArray = [];
                    RuleSources.forEach(item => {
                        ruleListArray.push(addRuleItem(item));
                    });
                    addRuleList(ruleListArray.join(''));
                }else{
                    Swal.fire({
                        icon: 'error',
                        text: `删除书源失败!`,
                    });
                }
            }).catch(err => {
                Swal.fire({
                    icon: 'error',
                    text: `删除书源失败，无法连接到「APP」!\r\n: ${err}`,
                });
            });
        }
    });
}

// 处理搜索事件
document.querySelector('#searchBtn').addEventListener('click', e => {
    if($('#searchName').val() === "" && $('#searchUrl').val() === "") return;
    findItem($('#searchName').val(), $('#searchUrl').val());
});
document.querySelector('#searchReset').addEventListener('click', e => {
    $('#searchName').val("");
    $('#searchUrl').val("");
    findItem($('#searchName').val(), $('#searchUrl').val());
});

// 处理按钮点击事件
document.querySelector('.bookSourceManager').addEventListener('click', e => {
    let thisNode = e.target;
    if(thisNode.innerText === "Loading") return;
    let innerText = thisNode.innerText;
    thisNode.innerText = "Loading";
    thisNode.classList.add("button-busy");
    switch (thisNode.id) {
        case 'getSource':
            $.ajax({
                url: `/getSources`,
                method: 'get',
                dataType: 'json',
                success: function (json) {
                    if (json.isSuccess) {
                        localStorage.setItem('ruleSources', JSON.stringify(AppConfig.ruleSources = json.data));
                        let ruleListArray = [];
                        AppConfig.ruleSources.forEach(item => {
                            ruleListArray.push(addRuleItem(item));
                        });
                        addRuleList(ruleListArray.join(''));
                        Swal.fire({
                            icon: 'success',
                            text: `刷新书源列表，共 ${AppConfig.ruleSources.length} 条书源`,
                        });
                    }
                    else {
                        Swal.fire({
                            icon: 'error',
                            text: `刷新书源列表失败!\r\n: ${json.errorMsg}`,
                        });
                    }
                    thisNode.classList.remove("button-busy");
                    thisNode.innerText = innerText;
                },
                error: function (err) {
                    Swal.fire({
                        icon: 'error',
                        text: `刷新书源列表失败,无法连接到「APP」!\r\n${err}`,
                    });
                    thisNode.classList.remove("button-busy");
                    thisNode.innerText = innerText;
                }
            });
            return;
        case 'addSource':
            localStorage.setItem('editBookSource', "");
            window.location.href = "/editBookSource.html";
            break;
        case 'importSource':
            let fileImport = document.createElement('input');
            fileImport.type = 'file';
            fileImport.accept = '.json';
            fileImport.addEventListener('change', () => {
                let file = fileImport.files[0];
                let reader = new FileReader();
                reader.onloadend = function (evt) {
                    if (evt.target.readyState === FileReader.DONE) {
                        let fileText = evt.target.result;
                        try {
                            let fileJson = JSON.parse(fileText);
                            let newSources = [];
                            newSources.push(...fileJson);
                            //直接写入APP
                            (async () => {
                                await AppConfig.httpPost(`/saveSources`, newSources).then(json => {
                                    if (json.isSuccess) {
                                        let okData = json.data;
                                        if (Array.isArray(okData)) {
                                            Swal.fire({
                                                icon: 'success',
                                                text: `导入书源到「APP」\r\n共计: ${newSources.length} 条\r\n成功: ${okData.length} 条\r\n失败: ${newSources.length - okData.length} 条`,
                                            }).then((result) => {
                                                //触发刷新
                                                document.getElementById("getSource").click();
                                            });
                                        }
                                        else {
                                            Swal.fire({
                                                icon: 'success',
                                                text: `导入书源到「APP」成功!\r\n共计: ${newSources.length} 条`,
                                            }).then((result) => {
                                                //触发刷新
                                                document.getElementById("getSource").click();
                                            });
                                        }
                                    }
                                    else {
                                        Swal.fire({
                                            icon: 'error',
                                            text: `导入书源失败!\r\n: ${json.errorMsg}`,
                                        });
                                    }
                                }).catch(err => {
                                    Swal.fire({
                                        icon: 'error',
                                        text: `导入书源失败,无法连接到「APP」!\r\n${err}`,
                                    });
                                });
                            })();
                        }
                        catch (err) {
                            Swal.fire({
                                icon: 'error',
                                text: `导入书源文件失败!\r\n${err}`,
                            });
                        }
                    }
                };
                reader.readAsText(file);
            }, false);
            fileImport.click();
            break;
        case 'exportSource':
            let fileExport = document.createElement('a');
            fileExport.download = `Rules${Date().replace(/.*?\s(\d+)\s(\d+)\s(\d+:\d+:\d+).*/, '$2$1$3').replace(/:/g, '')}.json`;
            let myBlob = new Blob([JSON.stringify(AppConfig.ruleSources, null, 4)], { type: "application/json" });
            fileExport.href = window.URL.createObjectURL(myBlob);
            fileExport.click();
            break;
        case 'clearSource':
            Swal.fire({
                text: `确定要清空当前书源列表吗?\r\n(不会删除APP内书源)`,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: '确定',
                cancelButtonText: '取消'
            }).then((result) => {
                if (result.value) {
                    localStorage.setItem('ruleSources', JSON.stringify(AppConfig.ruleSources = []));
                    addRuleList("");
                }
            });
            break;
        default:
    }
    setTimeout(() => {thisNode.classList.remove("button-busy");thisNode.innerText = innerText; }, 500);
});