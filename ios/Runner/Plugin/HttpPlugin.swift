
import Foundation
import Alamofire

public class HttpPlugin: NSObject, FlutterPlugin {
    // 网络请求数组
    static fileprivate var requestCacheArr = [DataRequest]();
    static let GB2312 = CFStringConvertEncodingToNSStringEncoding(0x0632)
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "http_plugin", binaryMessenger: registrar.messenger())
        let instance = HttpPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "post":
            if let args = call.arguments as? Dictionary<String, Any> {
                let postUrl = args["postUrl"] as? String ?? ""
                let postParams = args["postParams"] as? Dictionary<String, String> ?? [:]
                let postHeader = args["postHeader"] as? Dictionary<String, String> ?? [:]
                self.AlamofireSessionManager.request(postUrl, method: .post, parameters: postParams, headers: postHeader).responseData{ response in
                    let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8) ?? String.init(data: response.data!, encoding: String.Encoding(rawValue:HttpPlugin.GB2312))
                    print("Url: \(String(describing: response.response?.url?.absoluteString))")
                    print("Content: \(String(describing: responseStr))")
                    if response.error != nil {
                        print("Request Error: \(String(describing: response.error))")
                    }
                    result(["url":response.response?.url?.absoluteString, "content":responseStr]);
                }
            } else {
                result(FlutterError.init(code: "post",message: "参数类型有误",details: nil))
            }
        case "postWithGBK":
            if let args = call.arguments as? Dictionary<String, Any> {
                let postUrl = args["postUrl"] as? String ?? ""
                let postParams = args["postParams"] as? Dictionary<String, String> ?? [:]
                let postHeader = args["postHeader"] as? Dictionary<String, String> ?? [:]
                self.AlamofireSessionManager.request(postUrl, method: .post, parameters: postParams, encoding: GBKParameterEncoding.default , headers: postHeader).responseString(encoding: String.Encoding(rawValue:HttpPlugin.GB2312)) { response in
                    result(["url":response.response?.url?.absoluteString, "content":response.result.value]);
                }
            } else {
                result(FlutterError.init(code: "postWithGBK",message: "参数类型有误",details: nil))
            }
        case "get":
            if let args = call.arguments as? Dictionary<String, Any> {
                let getUrl = args["getUrl"] as? String ?? ""
                let getHeader = args["getHeader"] as? Dictionary<String, String> ?? [:]
                self.AlamofireSessionManager.request(GetUrlEncoding(url: getUrl), method: .get, headers: getHeader).responseData{ response in
                    let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8) ?? String.init(data: response.data!, encoding: String.Encoding(rawValue:HttpPlugin.GB2312))
                    print("Url: \(String(describing: response.response?.url?.absoluteString))")
                    print("Content: \(String(describing: responseStr))")
                    if response.error != nil {
                        print("Request Error: \(String(describing: response.error))")
                    }
                    result(["url":response.response?.url?.absoluteString, "content":responseStr]);
                }
            } else {
                result(FlutterError.init(code: "get",message: "参数类型有误",details: nil))
            }
        case "getWithGBK":
            if let args = call.arguments as? Dictionary<String, Any> {
                let getUrl = args["getUrl"] as? String ?? ""
                let getHeader = args["getHeader"] as? Dictionary<String, String> ?? [:]
                self.AlamofireSessionManager.request(getUrl, method: .get, encoding: GBKParameterEncoding.default , headers: getHeader).responseString(encoding: String.Encoding(rawValue:HttpPlugin.GB2312)) { response in
                    result(["url":response.response?.url?.absoluteString, "content":response.result.value]);
                }
            } else {
                result(FlutterError.init(code: "getWithGBK",message: "参数类型有误",details: nil))
            }
        case "cancel":
            if let args = call.arguments as? Dictionary<String, Any> {
                let cancelUrl = args["cancelUrl"] as? String ?? ""
                AlamofireSessionManager.session.getTasksWithCompletionHandler {
                    (sessionDataTask, uploadData, downloadData) in
                    sessionDataTask.forEach {
                        //只取消指定url的请求
                        if ($0.originalRequest?.url?.absoluteString == cancelUrl) {
                            $0.cancel()
                        }
                    }
                }
            } else {
                result(FlutterError.init(code: "cancel",message: "参数类型有误",details: nil))
            }
        case "cancelAll":
            AlamofireSessionManager.session.getTasksWithCompletionHandler {
                (sessionDataTask, uploadData, downloadData) in
                sessionDataTask.forEach { $0.cancel() }
                uploadData.forEach { $0.cancel() }
                downloadData.forEach { $0.cancel() }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    struct GBKParameterEncoding: ParameterEncoding {
        
        public static var `default`: GBKParameterEncoding { return GBKParameterEncoding() }
        
        func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
            //设置请求
            var request = try urlRequest.asURLRequest()
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            //添加发送参数
            let uploadData = NSMutableData()
            for (key,value) in parameters ?? [:] {
                uploadData.append("\(key)=\(value)&".data(using: String.Encoding(rawValue: HttpPlugin.GB2312))!)
            }
            request.httpBody = uploadData as Data
            return request
        }
    }
    
    let AlamofireSessionManager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        //设置20秒超时时间
        configuration.timeoutIntervalForRequest = 20
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    // 进行URL Encoding
    func GetUrlEncoding (url: String) -> String {
        let urlStr = url.removingPercentEncoding!
        if(urlStr == url){
            return url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? ""
        }else{
            return url
        }
    }
    
}
