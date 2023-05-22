import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
      //注册自定义插件Object-C
      ProjectPluginRegistrant.register(with: self)
      //注册自定义插件Swift
      SoupPlugin.register(with: self.registrar(forPlugin: "SoupPlugin")!)
      XPathPlugin.register(with: self.registrar(forPlugin: "XPathPlugin")!)
      ToolsPlugin.register(with: self.registrar(forPlugin: "ToolsPlugin")!)
      HttpPlugin.register(with: self.registrar(forPlugin: "HttpPlugin")!)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
