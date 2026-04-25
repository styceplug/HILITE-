import Flutter
import UIKit
import Firebase
import UserNotifications


@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
  FirebaseApp.configure()
  if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
      }

    GeneratedPluginRegistrant.register(with: self)

 if let registrar = registrar(forPlugin: "VideoTrimmer") {
     VideoTrimmer.register(with: registrar)
 }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
