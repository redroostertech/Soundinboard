import UIKit
import Parse
import GoogleMobileAds
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var moduleInitializer: ModuleInitializer!

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    moduleInitializer = ModuleInitializer()
    moduleInitializer.setupApps()
    moduleInitializer.application = application
    moduleInitializer.launchOptions = launchOptions
    return true
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    moduleInitializer.deviceToken = deviceToken
  }

  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
  }

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    moduleInitializer.userInfo = userInfo
  }

  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    moduleInitializer.didOpenUrl = (url, sourceApplication, annotation)
    return true
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    moduleInitializer.activateFacebookApp()
  }
}
