let isLoadChapter = false;
$(document).ready(function () {
    AppConfig.initTheme();
    AppConfig.initCache();
    //初始化缓存内容
    let errorMessage = "";
    if(AppConfig.bookInfo == null) errorMessage = "获取书籍信息失败，请刷新页面后重试！";
    if(AppConfig.openChapter == null) errorMessage = "获取书籍章节失败，请刷新页面后重试！";
    if(AppConfig.chapterList == null) errorMessage = "获取书籍章节目录失败，请刷新页面后重试！";
    if(errorMessage !== ""){
        Swal.fire({
            icon: 'error',
            text: errorMessage,
        }).then(() => {
            window.close();
        });
    }
    initView();
    loadChapterHtml();
    initClickEvent();
    //获取内容
    getChapterContent(-1, "");
    //滚动到顶部
    $('html, body').animate({scrollTop: 0}, 'slow');
});

function initView(){
    //设置标题
    document.title = AppConfig.bookInfo.name + " - " + AppConfig.bookInfo.durChapterTitle;
    //设置内容
    $('#bookName').text(AppConfig.bookInfo.name);
    $('#chapterName').text(AppConfig.bookInfo.durChapterTitle);
    if (!$('body').hasClass(AppConfig.theme)) {
        $('body').addClass(AppConfig.theme);
    }
    $('.md-setting-font-size-view').text(AppConfig.fontSize);
    $('.reader-content').css('font-size', AppConfig.fontSize + 'px');
    $('.md-setting-line-height-view').text(AppConfig.lineHeight);
    $('.reader-content').css('line-height', AppConfig.lineHeight);
    $('.reader-content').css('font-family', AppConfig.fontFamily);
    if (AppConfig.pageSize < 100) {
        $('.content').css('width', AppConfig.pageSize + '%');
        $('.catalog-control').css('width', AppConfig.pageSize + '%');
    }
    $('.md-setting-page-size-view').text(AppConfig.pageSize + '%');

    if ($(window).width() <= 736) {
        $('.layui-container').css('padding', '0');

        $('.reader-content').click(function (e) {
            if ($('#ui_setting').is(':hidden')) {
                $('#ui_setting').show(200);
            } else {
                $('#ui_setting').hide(100);
            }
        });
        //提示弹窗
        let isShowTip = localStorage.getItem('isShowTip');
        if (!isShowTip) {
            layui.layer.alert("手机阅读模式下点击屏幕可切换工具栏显示和隐藏状态！");
            localStorage.setItem('isShowTip', true);
        }
    }else{
        $('#ui_setting').show(200);
    }

    let width = $('.layui-container').width();
    if (width < 736) {
        let ulWidth = $("#ui_setting").width();
        $('.reader-setting-md').width(width - ulWidth - 42);
        $('.reader-catalogs-md').width(width - ulWidth - 42);
        $('.reader-content').css('margin', '40px 10px 10px 10px');
    } else {
        $('.reader-setting-md').width(width / 5 * 2);
        $('.reader-catalogs-md').width(width / 5 * 3);
        $('.reader-content').css('margin', '40px 50px 30px 50px');
    }
}

function initClickEvent(){
    //返回顶部点击
    $(".layui-fixbar-top").click(function () {
        $('html, body').animate({scrollTop: 0}, 'slow');
    });
    $(window).scroll(function () {
        checkLayout();
    });

    //返回书架详情
    $('.md-go-detail').click(function () {
        $('.book-detail-catalogs')[0].click();
    });

    //设置按钮
    $('.md-setting-open').click(function () {
        $('.md-catalogs-close').click();
        if ($(this).hasClass('panel-wrap')) {
            $('.md-setting-close').click();
        } else {
            $('.reader-theme .act').addClass('default').removeClass('act');
            $('.reader-theme .' + AppConfig.theme).removeClass('default').addClass('act');
            if (AppConfig.fontFamily == "'Microsoft YaHei', PingFangSC-Regular, HelveticaNeue-Light, 'Helvetica Neue Light', sans-serif") {
                $('.md-setting-font-family .act').addClass('default').removeClass('act');
                $('.md-setting-font-family-yahei').removeClass('default').addClass('act');
            } else if (AppConfig.fontFamily == "PingFangSC-Regular,'-apple-system',Simsun") {
                $('.md-setting-font-family .act').addClass('default').removeClass('act');
                $('.md-setting-font-family-song').removeClass('default').addClass('act');
            } else if (AppConfig.fontFamily == "Kaiti") {
                $('.md-setting-font-family .act').addClass('default').removeClass('act');
                $('.md-setting-font-family-kai').removeClass('default').addClass('act');
            }
            $('.reader-setting-md').show(100);
            $('.md-setting-open').addClass('panel-wrap');
            $('.md-setting-open').removeClass('setting-wrap');
        }
    });
    $('.md-setting-close').click(function () {
        $('.reader-setting-md').hide(100);
        $('.md-setting-open').addClass('setting-wrap');
        $('.md-setting-open').removeClass('panel-wrap');
    });

    //打开目录
    $('.md-catalogs-open').click(function () {
        $('.md-setting-close').click();
        if ($(this).hasClass('panel-wrap')) {
            $('.md-catalogs-close').click();
        } else {
            $('.reader-catalogs-md').show(100, function () {
                loadChapterList();
            });
            $('.md-catalogs-open').addClass('panel-wrap');
            $('.md-catalogs-open').removeClass('setting-wrap');
        }
    });
    $('.md-catalogs-close').click(function () {
        $('.reader-catalogs-md').hide(100);
        $('.md-catalogs-open').addClass('setting-wrap');
        $('.md-catalogs-open').removeClass('panel-wrap');
    });

    bindingThemeBtn();
    bindingFontFamilyBtn();
    bindingFontSizeBtn();
    bindingLineHeightBtn();
    bindingPageSizeBtn();
}

function checkLayout() {
    //为了保证兼容性，这里取两个值，哪个有值取哪一个
    //scrollTop就是触发滚轮事件时滚轮的高度
    let scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
    if (scrollTop === 0) {
        $('.layui-fixbar-top').hide();
    } else {
        $('.layui-fixbar-top').show();
    }

    let top = $('#container').offset().top - scrollTop + 80;
    if (top < 0) {
        top = 0;
    }
    $('.layui-fixset').css('top', top + 'px');

    let left = $('#book-content').offset().left;
    if (left < 100) {
        $('.layui-fixbar').css('right', '15px');
    } else {
        left = left - 62;
        if (left < 15) {
            left = 15;
        }
        $('.layui-fixset').css('left', left + 'px');

        left = left + $('#book-content').width() + 75;
        $('.layui-fixbar').css('left', left + 'px');
    }
}

function bindingThemeBtn() {
    //阅读主题按钮
    $('.reader-theme .theme-0').click(function () {
        if (!$(this).hasClass('act')) {
            $('.reader-theme .act').addClass('default').removeClass('act');
            $(this).addClass('act');
            $('body').removeClass('theme-1');
            $('body').removeClass('theme-2');
            $('body').removeClass('theme-3');
            $('body').removeClass('theme-4');
            if (!$('body').hasClass('theme-0')) {
                $('body').addClass('theme-0');
            }
            localStorage.setItem('theme', 'theme-0');
            AppConfig.theme = 'theme-0';
        }
    });
    $('div.theme-1').click(function () {
        if (!$(this).hasClass('act')) {
            $('.reader-theme .act').addClass('default').removeClass('act');
            $(this).addClass('act');
            $('body').removeClass('theme-0');
            $('body').removeClass('theme-2');
            $('body').removeClass('theme-3');
            $('body').removeClass('theme-4');
            if (!$('body').hasClass('theme-1')) {
                $('body').addClass('theme-1');
            }
            localStorage.setItem('theme', 'theme-1');
            AppConfig.theme = 'theme-1';
        }
    });
    $('div.theme-2').click(function () {
        if (!$(this).hasClass('act')) {
            $('.reader-theme .act').addClass('default').removeClass('act');
            $(this).addClass('act');
            $('body').removeClass('theme-0');
            $('body').removeClass('theme-1');
            $('body').removeClass('theme-3');
            $('body').removeClass('theme-4');
            if (!$('body').hasClass('theme-2')) {
                $('body').addClass('theme-2');
            }
            localStorage.setItem('theme', 'theme-2');
            AppConfig.theme = 'theme-2';
        }
    });
    $('div.theme-3').click(function () {
        if (!$(this).hasClass('act')) {
            $('.reader-theme .act').addClass('default').removeClass('act');
            $(this).addClass('act');
            $('body').removeClass('theme-0');
            $('body').removeClass('theme-1');
            $('body').removeClass('theme-2');
            $('body').removeClass('theme-4');
            if (!$('body').hasClass('theme-3')) {
                $('body').addClass('theme-3');
            }
            localStorage.setItem('theme', 'theme-3');
            AppConfig.theme = 'theme-3';
        }
    });
    $('div.theme-4').click(function () {
        if (!$(this).hasClass('act')) {
            $('.reader-theme .act').addClass('default').removeClass('act');
            $(this).addClass('act');
            $('body').removeClass('theme-0');
            $('body').removeClass('theme-1');
            $('body').removeClass('theme-2');
            $('body').removeClass('theme-3');
            if (!$('body').hasClass('theme-4')) {
                $('body').addClass('theme-4');
            }
            localStorage.setItem('theme', 'theme-4');
            AppConfig.theme = 'theme-4';
        }
    });
}

function bindingFontFamilyBtn() {
    $('.md-setting-font-family-yahei').click(function () {
        if (!$(this).hasClass('act')) {
            $('.md-setting-font-family .act').addClass('default').removeClass('act');
            $(this).removeClass('default').addClass('act');
            AppConfig.fontFamily = "'Microsoft YaHei', PingFangSC-Regular, HelveticaNeue-Light, 'Helvetica Neue Light', sans-serif";
            $('.reader-content').css('font-family', AppConfig.fontFamily);
            localStorage.setItem('fontFamily', AppConfig.fontFamily);
        }
    });
    $('.md-setting-font-family-song').click(function () {
        if (!$(this).hasClass('act')) {
            $('.md-setting-font-family .act').addClass('default').removeClass('act');
            $(this).removeClass('default').addClass('act');
            AppConfig.fontFamily = "PingFangSC-Regular,'-apple-system',Simsun";
            $('.reader-content').css('font-family', AppConfig.fontFamily);
            localStorage.setItem('fontFamily', AppConfig.fontFamily);
        }
    });
    $('.md-setting-font-family-kai').click(function () {
        if (!$(this).hasClass('act')) {
            $('.md-setting-font-family .act').addClass('default').removeClass('act');
            $(this).removeClass('default').addClass('act');
            AppConfig.fontFamily = "Kaiti";
            $('.reader-content').css('font-family', AppConfig.fontFamily);
            localStorage.setItem('fontFamily', AppConfig.fontFamily);
        }
    });
}

function bindingFontSizeBtn() {
    $('.md-setting-font-size-smaller').click(function () {
        if (AppConfig.fontSize > 12) {
            AppConfig.fontSize = AppConfig.fontSize - 1;
            $('.md-setting-font-size-view').text(AppConfig.fontSize);
            localStorage.setItem('fontSize', AppConfig.fontSize);
            $('.reader-content').css('font-size', AppConfig.fontSize + 'px');
        }
    });
    $('.md-setting-font-size-bigger').click(function () {
        if (AppConfig.fontSize < 36) {
            AppConfig.fontSize = AppConfig.fontSize + 1;
            $('.md-setting-font-size-view').text(AppConfig.fontSize);
            localStorage.setItem('fontSize', AppConfig.fontSize);
            $('.reader-content').css('font-size', AppConfig.fontSize + 'px');
        }
    });
}

function bindingLineHeightBtn() {
    $('.md-setting-line-height-smaller').click(function () {
        if (AppConfig.lineHeight > 0) {
            AppConfig.lineHeight -= 0.1;
            $('.md-setting-line-height-view').text(AppConfig.lineHeight.toPrecision(2));
            localStorage.setItem('lineHeight', AppConfig.lineHeight.toPrecision(2));
            $('.reader-content').css('line-height', AppConfig.lineHeight.toPrecision(2));
        }
    });
    $('.md-setting-line-height-bigger').click(function () {
        AppConfig.lineHeight += 0.1;
        $('.md-setting-line-height-view').text(AppConfig.lineHeight.toPrecision(2));
        localStorage.setItem('lineHeight', AppConfig.lineHeight.toPrecision(2));
        $('.reader-content').css('line-height', AppConfig.lineHeight.toPrecision(2));
    });
}

function bindingPageSizeBtn() {
    $('.md-setting-page-size-smaller').click(function () {
        if (AppConfig.pageSize > 65) {
            AppConfig.pageSize -= 5;
            $('.md-setting-page-size-view').text(AppConfig.pageSize + '%');
            $('.content').css('width', AppConfig.pageSize + '%');
            $('.catalog-control').css('width', AppConfig.pageSize + '%');
            localStorage.setItem('pageSize', AppConfig.pageSize);
        }
        checkLayout();
    });
    $('.md-setting-page-size-bigger').click(function () {
        if (AppConfig.pageSize < 100) {
            AppConfig.pageSize += 5;
            $('.md-setting-page-size-view').text(AppConfig.pageSize + '%');
            $('.content').css('width', AppConfig.pageSize + '%');
            $('.catalog-control').css('width', AppConfig.pageSize + '%');
            localStorage.setItem('pageSize', AppConfig.pageSize);
        }
        checkLayout();
    });
}

function loadChapterHtml(){
    let html = "";
    if(AppConfig.bookInfo.durChapterIndex === 0){
        html = `
            <span class="layui-col-xs4 layui-col-md4 bottom-disabled">上一章</span>
            <a target="_blank" href="../../bookDetail.html" class="layui-col-xs4 layui-col-md4 book-detail-catalogs">目录</a>
            <a href="#" onclick="loadNextChapter()" class="layui-col-xs4 layui-col-md4">下一章</a>
        `;
    }else if(AppConfig.bookInfo.durChapterIndex === AppConfig.chapterList.length - 1){
        html = `            
            <a href="#" onclick="loadPreChapter()" class="layui-col-xs4 layui-col-md4">上一章</a>
            <a target="_blank" href="../../bookDetail.html" class="layui-col-xs4 layui-col-md4 book-detail-catalogs">目录</a>
            <span class="layui-col-xs4 layui-col-md4 bottom-disabled">下一章</span>
        `;
    }else{
        html = `
            <a href="#" onclick="loadPreChapter()" class="layui-col-xs4 layui-col-md4">上一章</a>
            <a target="_blank" href="../../bookDetail.html" class="layui-col-xs4 layui-col-md4 book-detail-catalogs">目录</a>
            <a href="#" onclick="loadNextChapter()" class="layui-col-xs4 layui-col-md4">下一章</a>
        `;
    }
    $('#chapterNextPre').html(html);
}

function getChapterContent(chapterIndex, chapterName){
    $.ajax({
        url: `/getBookContent?url=${encodeURIComponent(AppConfig.openChapter)}`,
        method: 'get',
        dataType: 'json',
        success: function (data) {
            if (data.isSuccess) {
                let content = data.data.trim().split("\n\n");
                if (content.length === 2) {
                    $("#chapterInfo").html("作者：" + AppConfig.bookInfo.author +  "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;字数：" + content[1].length);
                    $("#chapterContent").html('<br>　　' + content[1].trim().replace(/\n/g, "<br><br>"));
                } else {
                    $("#chapterInfo").html("作者：" + AppConfig.bookInfo.author +  "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;字数：" + data.data.length);
                    $("#chapterContent").html('<br>　　' + data.data.trim().replace(/\n/g, "<br><br>"));
                }
                //加载成功，保存对象
                if(chapterName !== ""){
                    saveBook(chapterIndex, chapterName);
                }
            }else{
                Swal.fire({
                    icon: 'error',
                    text: `章节内容加载失败！`,
                });
            }
            checkLayout();
        },
        error: function (err) {
            Swal.fire({
                icon: 'error',
                text: `章节内容加载失败,无法连接到「APP」!\r\n${err}`,
            });
            checkLayout();
        }
    });
}

function loadChapterList() {
    if (!isLoadChapter) {
        isLoadChapter = true;
        let length = AppConfig.chapterList.length;
        let html = '';
        for (let index = 0; index < length; index++) {
            let isActive = index === AppConfig.bookInfo.durChapterIndex ? ' active' : '';
            html += `
            <a href="#" onclick="loadChapter(${index})" title="${AppConfig.chapterList[index].chapterTitle}" class="layui-col-xs12 layui-col-md5 layui-col-lg4 layui-col-md-offset1${isActive}">${AppConfig.chapterList[index].chapterTitle}</a>
        `;
        }
        $('#catalogTips').hide();
        $('.catalog-list').html(html);
        $('.catalog-list').scrollTop($('a.active:first').offset().top - $('.catalog-list').offset().top + $('.catalog-list').scrollTop());
    }else{
        $('.catalog-list').scrollTop($('a.active:first').offset().top - $('.catalog-list').offset().top + $('.catalog-list').scrollTop());
    }
}

function loadNextChapter(){
    let chapterIndex = 0, chapterName = "";
    for(let i = 0 ; i < AppConfig.chapterList.length; i++){
        if(i === (AppConfig.bookInfo.durChapterIndex + 1)){
            chapterIndex = i;
            chapterName = AppConfig.chapterList[i].chapterTitle;
            AppConfig.openChapter = AppConfig.chapterList[i].chapterUrl;
            break;
        }
    }
    getChapterContent(chapterIndex, chapterName);
}

function loadPreChapter(){
    let chapterIndex = 0, chapterName = "";
    for(let i = 0 ; i < AppConfig.chapterList.length; i++){
        if(i === (AppConfig.bookInfo.durChapterIndex - 1)){
            chapterIndex = i;
            chapterName = AppConfig.chapterList[i].chapterTitle;
            AppConfig.openChapter = AppConfig.chapterList[i].chapterUrl;
            break;
        }
    }
    getChapterContent(chapterIndex, chapterName);
}

function loadChapter(index){
    $('.md-catalogs-close').click();
    let chapterIndex = 0, chapterName = "";
    for(let i = 0 ; i < AppConfig.chapterList.length; i++){
        if(i === index){
            chapterIndex = i;
            chapterName = AppConfig.chapterList[i].chapterTitle;
            AppConfig.openChapter = AppConfig.chapterList[i].chapterUrl;
            break;
        }
    }
    getChapterContent(chapterIndex, chapterName);
}

function saveBook(chapterIndex, chapterName){
    AppConfig.bookInfo.durChapterIndex = chapterIndex;
    AppConfig.bookInfo.durChapterTitle = chapterName;

    //设置标题
    document.title = AppConfig.bookInfo.name + " - " + AppConfig.bookInfo.durChapterTitle;
    //设置内容
    $('#bookName').text(AppConfig.bookInfo.name);
    $('#chapterName').text(AppConfig.bookInfo.durChapterTitle);

    localStorage.setItem('openChapter', AppConfig.openChapter);
    localStorage.setItem('bookInfo', JSON.stringify(AppConfig.bookInfo));

    AppConfig.httpPost(`/saveBook`, {
            "bookUrl": AppConfig.bookInfo.bookUrl,
            "chapterIndex": chapterIndex,
            "chapterTitle": chapterName
        }).then(data => {
            isLoadChapter = false;
            loadChapterList();
        }).catch(err => {});

}