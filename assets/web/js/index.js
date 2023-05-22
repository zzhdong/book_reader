$(document).ready(function () {
    getLocalBookList();
});

function getLocalBookList(){
    $.ajax({
        url: `/getLocalBookList`,
        method: 'get',
        dataType: 'json',
        success: function (json) {
            if (json.isSuccess) {
                let listArray = [];
                json.data.forEach(item => {
                    listArray.push(addBookItem(item));
                });
                addBookList(listArray.join(''));
            }
            else {
                Swal.fire({
                    icon: 'error',
                    text: `获取书籍列表失败!\r\n: ${json.errorMsg}`,
                });
            }
        },
        error: function (err) {
            Swal.fire({
                icon: 'error',
                text: `获取书籍列表失败,无法连接到「APP」!\r\n${err}`,
            });
        }
    });
}

function addBookItem(item){
    return `
            <tr>
                <td class="tc" id="` + item.name + `">` + item.name + `</td>
                <td class="tc">` + item.size + `</td>
                <td class="tc">
                    <button class="btn-min btn-default mr10" onclick="downloadItem('` + item.name.trim() + `')">下载书籍</button>
                    <button class="btn-min btn-default" onclick="deleteItem('` + item.name.trim() + `')">删除书籍</button>
                </td>
            </tr>
    `;
}

function addBookList(ruleListArray){
    let innerHTML = "";
    innerHTML += `
                <tr class="light_color">
                    <th class="tc w-100">书籍名称</th>
                    <th class="tc w-100">书籍大小</th>
                    <th class="tc w-200">操作</th>
                </tr>
    `;
    innerHTML += ruleListArray;
    $('#tableBookList').html(innerHTML);
}

function downloadItem(bookName){
    $.ajax({
        url: `/downloadFile`,
        type: 'post',
        data: bookName,
        success: function (data, status, xhr) {
            let dataContent = new Blob([data],{type:"text/plain;charset=UTF-8"});
            let downloadUrl = window.URL.createObjectURL(dataContent);
            let anchor = document.createElement("a");
            anchor.href = downloadUrl;
            anchor.download = bookName;
            anchor.click();
            window.URL.revokeObjectURL(data);
        }
    });
}

function deleteItem(bookName){
    Swal.fire({
        text: `确定要删除当前书籍吗?`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: '确定',
        cancelButtonText: '取消'
    }).then((result) => {
        if (result.value) {
            AppConfig.httpPost(`/deleteFile`, {"bookName" : bookName}).then(json => {
                getLocalBookList();
            }).catch(err => {
                Swal.fire({
                    icon: 'error',
                    text: `删除书籍失败，无法连接到「APP」!\r\n: ${err}`,
                });
            });
        }
    });
}

// 处理按钮点击事件
document.querySelector('.bookSourceManager').addEventListener('click', e => {
    let thisNode = e.target;
    if(thisNode.innerText === "Loading") return;
    let innerText = thisNode.innerText;
    thisNode.innerText = "Loading";
    thisNode.classList.add("button-busy");
    switch (thisNode.id) {
        case 'uploadBook':
            let fileImport = document.createElement('input');
            fileImport.type = 'file';
            fileImport.accept = '.txt';
            fileImport.setAttribute("multiple","");
            fileImport.addEventListener('change', () => {
                for(let i = 0; i < fileImport.files.length; i++){
                    let file = fileImport.files[i];
                    let reader = new FileReader();
                    reader.onloadend = function (evt) {
                        if (evt.target.readyState === FileReader.DONE) {
                            let fileText = evt.target.result;
                            try {
                                (async () => {
                                    await AppConfig.httpPost(`/uploadFiles`, {"fileName": file.name, "fileData": fileText}).then(json => {
                                        getLocalBookList();
                                    }).catch(err => {
                                        Swal.fire({
                                            icon: 'error',
                                            text: `导入书籍失败,无法连接到「APP」!\r\n${err}`,
                                        });
                                    });
                                })();
                            }
                            catch (err) {
                                Swal.fire({
                                    icon: 'error',
                                    text: `导入书籍失败!\r\n${err}`,
                                });
                            }
                        }
                    };
                    reader.readAsText(file);
                }
            }, false);
            fileImport.click();
            break;
        default:
    }
    setTimeout(() => {thisNode.classList.remove("button-busy");thisNode.innerText = innerText; }, 500);
});