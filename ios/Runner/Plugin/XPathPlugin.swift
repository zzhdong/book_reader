
import Foundation
import Fuzi

public class XPathPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "xpath_plugin", binaryMessenger: registrar.messenger())
        let instance = XPathPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "selectNodesXml":
            if let args = call.arguments as? Dictionary<String, String> {
                DispatchQueue.global(qos: .userInteractive).async {
                    var paramsRule = args["rule"] ?? ""
                    let paramsHtml = args["html"] ?? ""
                    //去除content()后面的括号
                    if(paramsRule.count > 9 && paramsRule.suffix(9) == "content()"){
                        paramsRule = String(paramsRule.prefix(paramsRule.count - 2));
                    }
                    do {
                        let doc = try HTMLDocument(string: paramsHtml)
                        let nodeList = doc.xpath(paramsRule)
                        var resultElement: [String] = [];
                        for e in nodeList {
                            resultElement.append(e.rawXML)
                        }
                        result(resultElement);
                    }catch{
                        result(FlutterError.init(code: "selectNodesXml", message: "Error",details: nil))
                    }
                }
            } else {
                result(FlutterError.init(code: "selectNodesXml",message: "参数类型有误",details: nil))
            }
        case "selectNodesValue":
            if let args = call.arguments as? Dictionary<String, String> {
                DispatchQueue.global(qos: .userInteractive).async {
                    var paramsRule = args["rule"] ?? ""
                    let paramsHtml = args["html"] ?? ""
                    var isHtml = true;
                    //去除content()后面的括号
                    if(paramsRule.count > 9 && paramsRule.suffix(9) == "content()"){
                        paramsRule = String(paramsRule.prefix(paramsRule.count - 2));
                    }
                    if((paramsRule.count > 7 && paramsRule.suffix(7) == "content") ||
                        (paramsRule.count > 6 && paramsRule.suffix(6) == "text()") ||
                        (paramsRule.count > 5 && paramsRule.suffix(5) == "value") ||
                        (paramsRule.count > 4 && paramsRule.suffix(4) == "text") ||
                        (paramsRule.count > 4 && paramsRule.suffix(4) == "href") ||
                        (paramsRule.count > 3 && paramsRule.suffix(3) == "src")){
                        isHtml = false;
                    }
                    do {
                        let doc = try HTMLDocument(string: paramsHtml)
                        let nodeList = doc.xpath(paramsRule)
                        var resultElement: [String] = [];
                        for e in nodeList {
                            if(isHtml){
                                resultElement.append(e.rawXML)
                            }
                            else{
                                resultElement.append(e.stringValue)
                            }
                        }
                        result(resultElement);
                    }catch{
                        result(FlutterError.init(code: "selectNodesValue", message: "Error",details: nil))
                    }
                }
            } else {
                result(FlutterError.init(code: "selectNodesValue",message: "参数类型有误",details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
