let AppConfig = {
    theme: "",
    fontSize: 16,
    lineHeight: 1.8,
    fontFamily: "'Microsoft YaHei', PingFangSC-Regular, HelveticaNeue-Light, 'Helvetica Neue Light', sans-serif",
    pageSize: 100,
    ruleSources: [],
    editBookSource: null,
    editCourse: { "old": [], "now": {}, "new": [] },
    bookInfo: null,
    openChapter: "",
    chapterList: null,

    initTheme: () => {
        //加载主题
        AppConfig.theme = localStorage.getItem('theme');
        if (AppConfig.theme == null || AppConfig.theme === '') {
            AppConfig.theme = 'theme-0';
        }

        //加载字体大小
        AppConfig.fontSize = localStorage.getItem("fontSize");
        if (AppConfig.fontSize == null || AppConfig.fontSize === '') {
            if ($(window).width() < 600) {
                AppConfig.fontSize = 14;
            } else {
                AppConfig.fontSize = 16;
            }
        }
        AppConfig.fontSize = parseInt(AppConfig.fontSize);

        //加载行间距
        AppConfig.lineHeight = localStorage.getItem("lineHeight");
        if (AppConfig.lineHeight == null || AppConfig.lineHeight === '') {
            AppConfig.lineHeight = 1.8;
        }
        AppConfig.lineHeight = parseFloat(AppConfig.lineHeight);

        //加载字体
        AppConfig.fontFamily = localStorage.getItem('fontFamily');
        if (AppConfig.fontFamily == null || AppConfig.fontFamily === '') {
            AppConfig.fontFamily = "'Microsoft YaHei', PingFangSC-Regular, HelveticaNeue-Light, 'Helvetica Neue Light', sans-serif";
        }

        //加载页面大小
        AppConfig.pageSize = localStorage.getItem('pageSize');
        if (AppConfig.pageSize == null || AppConfig.pageSize === '') {
            AppConfig.pageSize = 100;
        }
        AppConfig.pageSize = parseInt(AppConfig.pageSize);
    },

    initCache: () => {
        try{
            //读取缓存中的相关信息
            AppConfig.ruleSources = JSON.parse(localStorage.getItem('ruleSources'));
            if(AppConfig.ruleSources == null || AppConfig.ruleSources === '') AppConfig.ruleSources = [];
            AppConfig.editCourse = JSON.parse(localStorage.getItem('editCourse'));
            AppConfig.editBookSource = JSON.parse(localStorage.getItem('editBookSource'));
            AppConfig.bookInfo = JSON.parse(localStorage.getItem('bookInfo'));
            AppConfig.openChapter = localStorage.getItem('openChapter');
            AppConfig.chapterList = JSON.parse(localStorage.getItem('chapterList'));
        }catch (e) {
            if(AppConfig.ruleSources == null || AppConfig.ruleSources.length === 0) AppConfig.ruleSources = [];
        }
    },


    // 读写Hash值(val未赋值时为读取)
    hashParam: (key, val) => {
        let hashStr = decodeURIComponent(window.location.hash);
        let regKey = new RegExp(`${key}=([^&]*)`);
        let getVal = regKey.test(hashStr) ? hashStr.match(regKey)[1] : null;
        if (val === undefined) return getVal;
        if (hashStr === '' || hashStr === '#') {
            window.location.hash = `#${key}=${val}`;
        }
        else {
            if (getVal) window.location.hash = hashStr.replace(getVal, val);
            else {
                window.location.hash = hashStr.indexOf(key) > -1 ? hashStr.replace(regKey, `${key}=${val}`) : `${hashStr}&${key}=${val}`;
            }
        }
    },

    formatTime: value => {
        return new Date(value).toLocaleString('zh-CN', {
            hour12: false, year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit", second: "2-digit"
        }).replace(/\//g, "-");
    },


    httpPost: (url, data) => {
        return fetch(AppConfig.hashParam('domain') ? AppConfig.hashParam('domain') + url : url, {
            body: JSON.stringify(data),
            method: 'POST',
            mode: "cors",
            headers: new Headers({
                'Content-Type': 'application/json;charset=utf-8'
            })
        }).then(res => res.json()).catch(err => console.error('Error:', err));
    },
};
