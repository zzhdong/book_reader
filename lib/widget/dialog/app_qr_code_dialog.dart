import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AppQrCodeDialog extends Dialog {
  final String qrCodeData;

  const AppQrCodeDialog({
    super.key,
    required this.qrCodeData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Container(
          padding: const EdgeInsets.all(3.0),
          decoration: const ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(0.0),
              ))),
          margin: const EdgeInsets.all(12.0),
          child: Column(children: <Widget>[
            QrImageView(
              data: qrCodeData,
              version: QrVersions.auto,
              size: 250,
            )
          ]))
    ]);
  }
}
