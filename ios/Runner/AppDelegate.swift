import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  var configuration = NEHotspotConfiguration.init(ssid: "wifi name", passphrase: "wifi password", isWEP: false)
  configuration.joinOnce = true

  NEHotspotConfigurationManager.shared.apply(configuration) { (error) in
      if error != nil {
          //an error occurred
          print(error?.localizedDescription)
      }
      else {
          //success
      }
  }
}
