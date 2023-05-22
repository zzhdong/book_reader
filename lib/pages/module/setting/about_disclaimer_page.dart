
import 'package:flutter_html/flutter_html.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_scroll_view.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class AboutDisclaimerPage extends StatefulWidget {
  const AboutDisclaimerPage({super.key});

  @override
  _AboutDisclaimerPageState createState() => _AboutDisclaimerPageState();
}

class _AboutDisclaimerPageState extends AppState<AboutDisclaimerPage> {
  String _htmlData = '''
　　BookReader提醒您：在使用BookReader(以下简称本应用)前，请您务必仔细阅读并透彻理解本声明。您可以选择不使用本应用，但如果您使用本应用，您的使用行为将被视为对本声明全部内容的认可。<br/>

　　1. 本应用是一款提供网络小说即时更新的工具，为广大小说爱好者提供一种方便、快捷、舒适的试读体验。本应用致力于最大程度的减少网络小说阅读者在自行搜寻过程中毫无意义的时间浪费，通过专业搜索展示不同网站中网络小说的最新章节。本应用为广大小说爱好者提供方便、快捷、舒适的试读体验的同时，也使优秀网络小说得以更迅捷、更广泛的传播，从而达到了在一定程度促进网络文学充分繁荣发展之目的。<br/>

　　2. 当您点击搜索一本书时，本应用会将该书的书名以关键词的形式提交到第三方网站或搜索引擎(如百度、宜搜、贴吧等)。第三方网站返回的内容与本应用无关，本应用对其概不负责，亦不承担任何法律责任。<br/>

　　3. 任何通过使用本应用而链接到的第三方网页均系他人制作或提供，您可能从该第三方网页上获得其他服务，本应用对其合法性概不负责，亦不承担任何法律责任。<br/>

　　4. 第三方搜索引擎结果根据你提交的书名自动搜索获得并提供试读，不代表本应用赞成被搜索链接到的第三方网页上的内容或立场。您应该对使用搜索引擎的结果自行承担风险。本应用不做任何形式的保证：不保证第三方搜索引擎的搜索结果满足您的要求，不保证搜索服务不中断，不保证搜索结果的安全性、正确性、及时性、合法性。<br/>

　　5. 因网络状况、通讯线路、第三方网站等任何原因而导致您不能正常使用本应用，本应用不承担任何法律责任。<br/>

　　6. 本应用尊重并保护所有使用本应用用户的个人隐私权，您注册的用户名、电子邮件地址等个人资料，非经您亲自许可或根据相关法律、法规的强制性规定，本应用不会主动地泄露给第三方。<br/>

　　7. 本应用鼓励广大小说爱好者通过本应用发现优秀网络小说及其提供商，并建议阅读正版图书。任何单位或个人认为通过本应用搜索链接到的第三方网页内容可能涉嫌侵犯其信息网络传播权，应该及时向本应用提出书面权利通知，并提供身份证明、权属证明及详细侵权情况证明。本应用在收到上述法律文件后，将会依法尽快断开相关链接内容。<br/>
  ''';

  @override
  void initState() {
    super.initState();
    if(AppParams.getInstance().getLocaleLanguage() == 2){
      ToolsPlugin.toTraditionalChinese(_htmlData).then((value) => setState(() {_htmlData = value;}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: WidgetUtils.getDefaultTitleBar(AppTitleBar(AppUtils.getLocale()?.aboutToDisclaimer ?? "")),
        backgroundColor: AppParams.getInstance().getAppTheme() == 1 ? Colors.white : store.state.theme.body.background,
        body: AppScrollView(
            showBar: true,
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
              child: Html(data: _htmlData, style: {
                "html": Style(
                  fontSize: FontSize(16.0),
                  fontFamily: "PingFangMedium",
                  color: store.state.theme.body.fontColor,
                  letterSpacing: 1,
                )
              }),
            )),
      );
    });
  }
}