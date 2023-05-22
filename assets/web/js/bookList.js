let gblBookList = [];

$(document).ready(function () {
    //触发加载书籍列表点击按钮
    document.getElementById("loadBook").click();
});

function addBookItem(book){
    return `
            <li>
                <div class="book-img-box">
                    <a href="#" onclick="loadBookDetail('${book.bookUrl}')">
                        <img src="${book.coverUrl}">
                    </a>
                </div>
                <div class="book-mid-info">
                    <h4>
                        <a href="#" onclick="loadBookDetail('${book.bookUrl}')">${book.name}</a>
                    </h4>
                    <p class="author">
                        ${book.author}<em> | </em>${book.kinds}
                    </p>
                    <p class="intro">
                        书籍来源：${book.originName}
                    </p>
                    <p class="intro">
                        书籍简介：${book.intro}
                    </p>
                    <p class="last">
                        最后阅读：${book.durChapterTitle} 【${AppConfig.formatTime(book.durChapterTime)}】</span>
                    </p>
                    <p class="update">
                        最新章节：${book.latestChapterTitle} 【${AppConfig.formatTime(book.latestChapterTime)}】</span>
                    </p>
                </div>
            </li>
    `;
}

function loadBookDetail(bookUrl){
    for(let i = 0 ; i < gblBookList.length; i++){
        if(gblBookList[i].bookUrl === bookUrl){
            localStorage.setItem('bookInfo', JSON.stringify(gblBookList[i]));
            window.location.href = "bookDetail.html";
            break;
        }
    }
}

// 处理按钮点击事件
document.querySelector('.bookListManager').addEventListener('click', e => {
    let thisNode = e.target;
    if(thisNode.innerText === "Loading") return;
    let innerText = thisNode.innerText;
    thisNode.innerText = "Loading";
    thisNode.classList.add("button-busy");
    switch (thisNode.id) {
        case 'loadBook':
            (async () => {
                await $.ajax({
                    url: `/getBookshelf`,
                    method: 'get',
                    dataType: 'json',
                    success: function (data) {
                        if (!data.isSuccess) {
                            Swal.fire({
                                icon: 'info',
                                text: data.errorMsg,
                            });
                            return;
                        }
                        gblBookList = data.data.sort((book1, book2) => book1.serialNumber - book2.serialNumber);
                        let bookListArray = [];
                        gblBookList.forEach(book => {
                            bookListArray.push(addBookItem(book));
                        });
                        document.querySelector('#liBookList').innerHTML = bookListArray.join('');
                    },
                    error: function (err) {
                        Swal.fire({
                            icon: 'error',
                            text: `加载书籍列表失败,无法连接到「APP」!\r\n${err}`,
                        });
                    }
                });
                thisNode.classList.remove("button-busy");
                thisNode.innerText = innerText;
            })();
            return;
        default:
    }
    setTimeout(() => {thisNode.classList.remove("button-busy");thisNode.innerText = innerText; }, 500);
});
