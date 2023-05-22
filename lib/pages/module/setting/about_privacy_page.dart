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

class AboutPrivacyPage extends StatefulWidget {
  const AboutPrivacyPage({super.key});

  @override
  _AboutPrivacyPageState createState() => _AboutPrivacyPageState();
}

class _AboutPrivacyPageState extends AppState<AboutPrivacyPage> {
  String _htmlData = '''
　　本应用尊重并保护所有使用服务用户的个人隐私权。为了给您提供更准确、更有个性化的服务，本应用会按照本隐私权政策的规定使用和披露您的个人信息。但本应用将以高度的勤勉、审慎义务对待这些信息。除本隐私权政策另有规定外，在未征得您事先许可的情况下，本应用不会将这些信息对外披露或向第三方提供。本应用会不时更新本隐私权政策。 您在同意本应用服务使用协议之时，即视为您已经同意本隐私权政策全部内容。本隐私权政策属于本应用服务使用协议不可分割的一部分。<br/>

　　<h2>1. 适用范围</h2><br/>

　　(a) 在您注册本应用帐号时，您根据本应用要求提供的个人注册信息；<br/>

　　(b) 在您使用本应用网络服务，或访问本应用平台网页时，本应用自动接收并记录的您的浏览器和计算机上的信息，包括但不限于您的IP地址、浏览器的类型、使用的语言、访问日期和时间、软硬件特征信息及您需求的网页记录等数据；<br/>

　　(c) 本应用通过合法途径从商业伙伴处取得的用户个人数据。<br/>

　　您了解并同意，以下信息不适用本隐私权政策：<br/>

　　(a) 您在使用本应用平台提供的搜索服务时输入的关键字信息；<br/>

　　(b) 本应用收集到的您在本应用发布的有关信息数据，包括但不限于参与活动、成交信息及评价详情；<br/>

　　(c) 违反法律规定或违反本应用规则行为及本应用已对您采取的措施。<br/>

　　<h2>2. 信息使用</h2><br/>

　　(a) 本应用不会向任何无关第三方提供、出售、出租、分享或交易您的个人信息，除非事先得到您的许可，或该第三方和本应用（含本应用关联公司）单独或共同为您提供服务，且在该服务结束后，其将被禁止访问包括其以前能够访问的所有这些资料。<br/>

　　(b) 本应用亦不允许任何第三方以任何手段收集、编辑、出售或者无偿传播您的个人信息。任何本应用平台用户如从事上述活动，一经发现，本应用有权立即终止与该用户的服务协议。<br/>

　　(c) 为服务用户的目的，本应用可能通过使用您的个人信息，向您提供您感兴趣的信息，包括但不限于向您发出产品和服务信息，或者与本应用合作伙伴共享信息以便他们向您发送有关其产品和服务的信息（后者需要您的事先同意）。<br/>

　　<h2>3. 信息披露</h2><br/>

　　在如下情况下，本应用将依据您的个人意愿或法律的规定全部或部分的披露您的个人信息：<br/>

　　(a) 经您事先同意，向第三方披露；<br/>

　　(b) 为提供您所要求的产品和服务，而必须和第三方分享您的个人信息；<br/>

　　(c) 根据法律的有关规定，或者行政或司法机构的要求，向第三方或者行政、司法机构披露；<br/>

　　(d) 如您出现违反中国有关法律、法规或者本应用服务协议或相关规则的情况，需要向第三方披露；<br/>

　　(e) 如您是适格的知识产权投诉人并已提起投诉，应被投诉人要求，向被投诉人披露，以便双方处理可能的权利纠纷；<br/>

　　(f) 在本应用平台上创建的某一交易中，如交易任何一方履行或部分履行了交易义务并提出信息披露请求的，本应用有权决定向该用户提供其交易对方的联络方式等必要信息，以促成交易的完成或纠纷的解决。<br/>

　　(g) 其它本应用根据法律、法规或者网站政策认为合适的披露。<br/>

　　<h2>4. 信息存储和交换</h2><br/>

　　(a) 本应用收集的有关您的信息和资料将保存在本应用及（或）其关联公司的服务器上，这些信息和资料可能传送至您所在国家、地区或本应用收集信息和资料所在地的境外并在境外被访问、存储和展示。<br/>

　　<h2>5. Cookie的使用</h2><br/>

　　(a) 在您未拒绝接受cookies的情况下，本应用会在您的计算机上设定或取用cookies ，以便您能登录或使用依赖于cookies的本应用平台服务或功能。本应用使用cookies可为您提供更加周到的个性化服务，包括推广服务。<br/>

　　(b) 您有权选择接受或拒绝接受cookies。您可以通过修改浏览器设置的方式拒绝接受cookies。但如果您选择拒绝接受cookies，则您可能无法登录或使用依赖于cookies的本应用网络服务或功能。<br/>

　　(c) 通过本应用所设cookies所取得的有关信息，将适用本政策。<br/>

　　<h2>6. 信息安全</h2><br/>

　　(a) 本应用帐号均有安全保护功能，请妥善保管您的用户名及密码信息。本应用将通过对用户密码进行加密等安全措施确保您的信息不丢失，不被滥用和变造。尽管有前述安全措施，但同时也请您注意在信息网络上不存在“完善的安全措施”。<br/>

　　(b) 在使用本应用网络服务进行网上交易时，您不可避免的要向交易对方或潜在的交易对方披露自己的个人信息，如联络方式或者邮政地址。请您妥善保护自己的个人信息，仅在必要的情形下向他人提供。如您发现自己的个人信息泄密，尤其是平台用户名及密码发生泄露，请您立即联络我们客服，以便我们采取相应措施。<br/>

　　<h2>7. 广告信息共享</h2><br/>

　　(a) 广告推送：我们可能与委托我们进行推广和广告投放的合作伙伴共享信息，但我们不会共享用于识别您个人身份的信息（姓名、身份证号），仅会向这些合作伙伴提供不能识别您个人身份的间接画像标签及去标识化或匿名化后的信息，以帮助其在不识别您个人身份的前提下提升广告有效触达率。<br/>

　　(b) 广告统计：我们可能与业务的服务商、供应商和其他合作伙伴共享分析去标识化的统计信息，这些信息难以与您的身份信息相关联，这些信息将帮助我们分析、衡量广告和相关服务的有效性。<br/>

　　<h2>8. 未成年人使用我们的服务</h2><br/>

　　(a) 若您是18周岁以下的未成年人，建议请您的监护人仔细阅读本隐私政策，并在征得您的监护人同意的前提下使用我们的产品或服务，或向我们提供相关信息。<br/>

　　<h2>9. 本隐私政策的更改</h2><br/>

　　(a) 如果决定更改隐私政策，我们会在本政策中、本公司网站中以及我们认为适当的位置发布这些更改，以便您了解我们如何收集、使用您的个人信息，哪些人可以访问这些信息，以及在什么情况下我们会透露这些信息。<br/>

　　(b) 本公司保留随时修改本政策的权利，因此请经常查看。如对本政策作出重大更改，本公司会通过网站通知的形式告知。<br/>

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
        appBar: WidgetUtils.getDefaultTitleBar(AppTitleBar(AppUtils.getLocale()?.aboutToPrivacy ?? "")),
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
