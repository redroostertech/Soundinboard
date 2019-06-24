import Foundation
import Parse
import ParseFacebookUtilsV4

private let serverURL = "https://parseapi.back4app.com"

class ParseModule {
    static let shared = ParseModule()
    
    private init() {
        print(" \(APP_NAME) | ParseModule Handler Initialized")
        // INITIALIZE PARSE SERVER
        let configuration = ParseClientConfiguration {
            $0.applicationId = PARSE_APP_ID
            $0.clientKey = PARSE_CLIENT_KEY
            $0.server = serverURL
        }
        Parse.initialize(with: configuration)
    }
    
    func registerDeviceTokenForRemoteNotifications(_ deviceToken: Data) {
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        installation?.saveInBackground(block: { (succ, error) in
            if error == nil {
                print("DEVICE TOKEN REGISTERED!")
                // error
            } else {
                print("\(error!.localizedDescription)")
            }
        })
    }
    
    func registerUserInfoForRemoteNotifications(_ userInfo: AppDelegateUserInfo) {
        PFPush.handle(userInfo)
        if UIApplication.shared.applicationState == .inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(inBackground: userInfo, block: nil)
        }
    }

  func register(username: String, userID: String) {
    let installation = PFInstallation.current()
    installation?["username"] = username
    installation?["userID"] = userID
    installation?.saveInBackground(block: { (succ, error) in
      if error == nil {
        print("PUSH REGISTERED FOR: \(username)")
      }
    })
  }
}

class ParseFacebookModule {
    static let shared = ParseFacebookModule()
    
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]? {
        didSet {
            PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        }
    }
    
    private init() {
        print(" \(APP_NAME) | ParseFacebookModule Handler Initialized")
    }
    
    func openUrlForFacebookLogin(_ application: UIApplication, object: AppDelegateDidOpenUrl) {
        FBSDKApplicationDelegate.sharedInstance().application(application, open: object.0, sourceApplication: object.1, annotation: object.2)
    }
    
    func activateApp() {
        FBSDKAppEvents.activateApp()
        let installation = PFInstallation.current()
        print("BADGE: \(installation!.badge)")
        if installation?.badge != 0 {
            installation?.badge = 0
            installation?.saveInBackground(block: { (succ, error) in
                if error == nil {
                    print("Badge reset to 0")
                    // error
                } else { print("\(error!.localizedDescription)")
                }})
        }
    }
}
