
import Foundation
import SwiftSoup

public class SoupPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "soup_plugin", binaryMessenger: registrar.messenger())
        let instance = SoupPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "selectElement":
            if let args = call.arguments as? Dictionary<String, String> {
                let elementText = args["elementText"] ?? ""
                var rule = args["rule"] ?? ""
                if(elementText == "" || rule == ""){
                    result(FlutterError.init(code: "selectElement",message: "参数值不能为空",details: nil))
                }else{
                    DispatchQueue.global(qos: .userInteractive).async {
                        do {
                            // 存在~这个符号，会导致doc.select(rule)一直卡住
                            rule = rule.replacingOccurrences(of: "~", with: "")
                            let doc: Document = try SwiftSoup.parse(elementText)
                            let els: Elements = try doc.select(rule)
                            var resultElement: [String] = [];
                            for e in els {
                                resultElement.append(try e.outerHtml())
                            }
                            result(resultElement);
                        } catch Exception.Error(let type, let message)  {
                            result(FlutterError.init(code: "selectElement",
                                                     message: "错误信息：" + message, details: nil))
                        } catch{
                            result(FlutterError.init(code: "selectElement", message: "Error",details: nil))
                        }
                    }
                }
            } else {
                result(FlutterError.init(code: "selectElement",message: "参数类型有误",details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
