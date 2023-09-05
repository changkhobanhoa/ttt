import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    [GMSServices provideAPIKey:@"AIzaSyDHK00QTsRbXgFx4pTK2ErSuS5sVbUjNvE"];
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
