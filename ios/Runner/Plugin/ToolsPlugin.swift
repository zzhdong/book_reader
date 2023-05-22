
import Foundation
import SwiftSoup
import SVProgressHUD
import GoogleMobileAds

public class ToolsPlugin: NSObject, FlutterPlugin {
    
    let converterTraditionalChinese = try! ChineseConverter(option: [.traditionalize])
    let converterSimplifiedChinese = try! ChineseConverter(option: [.simplify])
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "tools_plugin", binaryMessenger: registrar.messenger())
        let instance = ToolsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
        case "showLoading":
            //内框宽度
            SVProgressHUD.setMinimumSize(CGSize(width: 80, height: 80))
            SVProgressHUD.setDefaultStyle(.custom)
            SVProgressHUD.setDefaultMaskType(.custom)
            SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.native)
            SVProgressHUD.setForegroundColor(UIColor.white)
            SVProgressHUD.setBackgroundColor(UIColor.black.withAlphaComponent(0.6))
            SVProgressHUD.setBackgroundLayerColor(UIColor.black.withAlphaComponent(0.2))
            SVProgressHUD.show();
        case "hideLoading":
            SVProgressHUD.dismiss();
        case "setAdMuted":
            //向admob报告静音，会导致广告减少
            //GADMobileAds.sharedInstance().applicationMuted = true;
            //设置广告音量为零
            GADMobileAds.sharedInstance().applicationVolume = 0;
            result("");
        case "setAdUnMuted":
            GADMobileAds.sharedInstance().applicationMuted = false;
            GADMobileAds.sharedInstance().applicationVolume = 1;
            result("");
        case "getAbsoluteURL":
            if let args = call.arguments as? Dictionary<String, String> {
                let paramsBaseURL = args["baseURL"] ?? ""
                let paramsRelativePath = args["relativePath"] ?? ""
                
                let baseUrlEncode = paramsBaseURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? ""
                let relativePathEncode = paramsRelativePath.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? ""
                let baseURL = URL(string: baseUrlEncode)!
                let url = NSURL(string: relativePathEncode, relativeTo: baseURL)!
                result(url.absoluteString?.removingPercentEncoding ?? "");
            } else {
                result(FlutterError.init(code: "getAbsoluteURL",message: "参数类型有误",details: nil))
            }
        case "formatHtml":
            if let args = call.arguments as? Dictionary<String, String> {
                DispatchQueue.global(qos: .userInteractive).async {
                    let paramsHtml = args["html"] ?? ""
                    do {
                        let doc: Document = try SwiftSoup.parse(paramsHtml)
                        result(try doc.outerHtml());
                    }catch{
                        result(paramsHtml);
                    }
                }
            } else {
                result(FlutterError.init(code: "formatHtml",message: "参数类型有误",details: nil))
            }
        case "toSimplifiedChinese":
            if let args = call.arguments as? Dictionary<String, String> {
                DispatchQueue.global(qos: .userInteractive).async {
                    let paramsContent = args["content"] ?? ""
                    result(self.converterSimplifiedChinese.convert(paramsContent));
                }
            } else {
                result(FlutterError.init(code: "toSimplifiedChinese",message: "参数类型有误",details: nil))
            }
        case "toTraditionalChinese":
            if let args = call.arguments as? Dictionary<String, String> {
                DispatchQueue.global(qos: .userInteractive).async {
                    let paramsContent = args["content"] ?? ""
                    result(self.converterTraditionalChinese.convert(paramsContent));
                }
            } else {
                result(FlutterError.init(code: "toTraditionalChinese",message: "参数类型有误",details: nil))
            }
        case "getIpAdress":
            result(getWiFiAddress(ipAddressType: "getIpAdress"))
        case "getIpV6Adress":
            result(getWiFiAddress(ipAddressType: "getIpV6Adress"))
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func getWiFiAddress(ipAddressType:String) -> String? {
        var address : String?
        var targetAddrFamily : UInt8?
        if ipAddressType == "getIpV6Adress" {
            targetAddrFamily = UInt8(AF_INET6)
        } else{
            targetAddrFamily = UInt8(AF_INET)
        }
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == targetAddrFamily {
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        return address
    }
}
