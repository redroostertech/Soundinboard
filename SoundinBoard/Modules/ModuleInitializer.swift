import Foundation
import IQKeyboardManagerSwift
import SDWebImage
import Parse

public typealias AppDelegateLaunchOptions = [UIApplication.LaunchOptionsKey: Any]
public typealias AppDelegateUserInfo = [AnyHashable : Any]
public typealias AppDelegateDeviceToken = Data
public typealias AppDelegateDidOpenUrl = (URL, String?, Any)

private var testDataGrabberModule: TestDataGrabberModule?
private var googleAdMobManager: GoogleAdMobManager?
private var notificationManager: NotificationsManagerModule?
private var parseModule: ParseModule?
private var parseFacebookModule: ParseFacebookModule?

class ModuleInitializer {
  var application: UIApplication?
  var launchOptions: AppDelegateLaunchOptions? {
    didSet {
      parseFacebookModule?.launchOptions = launchOptions
    }
  }

  var deviceToken: AppDelegateDeviceToken? {
    didSet {
      guard let devicetoken = self.deviceToken else { return }
      parseModule?.registerDeviceTokenForRemoteNotifications(devicetoken)
    }
  }

  var userInfo: AppDelegateUserInfo? {
    didSet {
      guard let userinfo = self.userInfo else { return }
      parseModule?.registerUserInfoForRemoteNotifications(userinfo)
    }
  }

  var didOpenUrl: AppDelegateDidOpenUrl? {
    didSet {
      guard let application = self.application, let didopenurl = self.didOpenUrl else { return }
      parseFacebookModule?.openUrlForFacebookLogin(application, object: didopenurl)
    }
  }

  func setupApps() {
    print(" \(APP_NAME) | Module Handler Initialized")
    IQKeyboardManager.shared.enable = true
    testDataGrabberModule = TestDataGrabberModule.shared
    googleAdMobManager = GoogleAdMobManager.shared
    notificationManager = NotificationsManagerModule.shared
    parseModule = ParseModule.shared
    parseFacebookModule = ParseFacebookModule.shared
  }

  func activateFacebookApp() {
    parseFacebookModule?.activateApp()
  }
}
