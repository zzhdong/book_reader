import 'package:flutter/material.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:book_reader/widget/qrcode_reader_view.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

//扫描二维码
class AppScanView extends StatefulWidget {
  const AppScanView({super.key});

  @override
  _AppScanViewState createState() => _AppScanViewState();
}

class _AppScanViewState extends State<AppScanView> {

  @override
  void initState() {
    super.initState();
    //检查相机权限
    checkPermission();
  }

  void checkPermission() async{
    PermissionStatus permission = await Permission.camera.status;
    if(permission != PermissionStatus.granted){
      if (await Permission.camera.request().isGranted) {
        //重载界面
      }else{
        ToastUtils.showToast("获取授权失败！");
        NavigatorUtils.goBack(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QrcodeReaderView(
        // key: _key,
        onScan: onScan,
        headerWidget: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
      ),
    );
  }

  Future onScan(String data) async {
    print("扫码结果：$data");
    //延迟一秒后返回结果
    Future.delayed(const Duration(milliseconds: 500), (){
      //返回扫码参数
      NavigatorUtils.goBackWithParams(context, data);
    });
  }
}
