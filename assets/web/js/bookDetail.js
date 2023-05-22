$(document).ready(function () {
    AppConfig.initCache();
    if(AppConfig.bookInfo == null){
        window.location.href = "bookList.html";
        return;
    }
    AppConfig.chapterList = [];

    document.title = AppConfig.bookInfo.name;
    addBookInfo();
    addBookChapter();
});


function addBookInfo(){
    document.querySelector('#bookInfo').innerHTML = `
        <div class="book-img-box">
            <a href="#">
                <img src="${AppConfig.bookInfo.coverUrl}">
            </a>
        </div>
        <div class="book-mid-info">
            <h4>
                <a href="#">${AppConfig.bookInfo.name}</a>
            </h4>
            <p class="author">
                ${AppConfig.bookInfo.author}<em> | </em>${AppConfig.bookInfo.kinds}
            </p>
            <p class="intro">
                书籍来源：${AppConfig.bookInfo.originName}
            </p>
            <p class="intro">
                书籍简介：${AppConfig.bookInfo.intro}
            </p>
            <p class="last">
                最后阅读：${AppConfig.bookInfo.durChapterTitle} 【${AppConfig.formatTime(AppConfig.bookInfo.durChapterTime)}】</span>
            </p>
            <p class="update">
                最新章节：${AppConfig.bookInfo.latestChapterTitle} 【${AppConfig.formatTime(AppConfig.bookInfo.latestChapterTime)}】</span>
            </p>
        </div>
        <div style="float: right">
            <button onclick="getContent('-1')" class="btn btn-default">
                继续阅读
            </button>
        </div>
    `;
}

function addChapterInfo(chapter){
    return `
        <li>
            <a href="#" onclick="getContent('${chapter.chapterUrl}')" title="${chapter.chapterTitle}">${chapter.chapterTitle}</a>
        </li>
    `;
}

function addBookChapter(){
    (async () => {
        await $.ajax({
            url: `/getChapterList?url=${encodeURIComponent(AppConfig.bookInfo.bookUrl)}`,
            method: 'get',
            dataType: 'json',
            success: function (data) {
                if (!data.isSuccess) {
                    Swal.fire({
                        icon: 'error',
                        text: `章节列表加载失败！`,
                    });
                    return;
                }
                AppConfig.chapterList = data.data;
                if(data.data.length === 0){
                    Swal.fire({
                        icon: 'error',
                        text: `章节列表为空，请在APP内刷新章节列表！`,
                    });
                }
                localStorage.setItem('chapterList', JSON.stringify(data.data));
                let divList = [];
                AppConfig.chapterList.forEach(chapter => {
                    divList.push(addChapterInfo(chapter));
                });
                document.querySelector('#chapterList').innerHTML = divList.join('');
            },
            error: function (err) {
                Swal.fire({
                    icon: 'error',
                    text: `章节列表加载失败,无法连接到「APP」!\r\n${err}`,
                });
            }
        });
    })();
}

function getContent(chapterUrl){
    if(chapterUrl === '-1'){
        if(AppConfig.chapterList.length === 0){
            Swal.fire({
                icon: 'error',
                text: `章节列表为空，请在APP内刷新章节列表！`,
            });
            return;
        }
        for(let i = 0 ; i < AppConfig.chapterList.length; i++){
            if(i === AppConfig.bookInfo.durChapterIndex){
                chapterUrl = AppConfig.chapterList[i].chapterUrl;
                break;
            }
        }
        localStorage.setItem('openChapter', chapterUrl);
        //跳转到章节内容页
        window.open("read/bookContent.html");
    }else{
        for(let i = 0 ; i < AppConfig.chapterList.length; i++){
            if(chapterUrl === AppConfig.chapterList[i].chapterUrl){
                AppConfig.bookInfo.durChapterIndex = i;
                AppConfig.bookInfo.durChapterTitle = AppConfig.chapterList[i].chapterTitle;
                break;
            }
        }
            localStorage.setItem('bookInfo', JSON.stringify(AppConfig.bookInfo));
            localStorage.setItem('openChapter', chapterUrl);
            AppConfig.httpPost(`/saveBook`, {
                "bookUrl": AppConfig.bookInfo.bookUrl,
                "chapterIndex": AppConfig.bookInfo.durChapterIndex,
                "chapterTitle": AppConfig.bookInfo.durChapterTitle
            }).then(data => {
                //跳转到章节内容页
                window.open("read/bookContent.html");
                window.location.reload();
        }).catch(err => {});
    }
}
