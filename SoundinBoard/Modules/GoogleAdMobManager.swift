import Foundation
import GoogleMobileAds

class GoogleAdMobManager {
    static let shared = GoogleAdMobManager()
    private init() {
        print(" \(kAppName) | GoogleAdMobManager Handler Initialized")
        GADMobileAds.sharedInstance().start { (status) in
          print("GoogleAdMobManager Handler Initialized: \(status)")
        }
    }

  func showInterstitialAd(_ delegate: GADInterstitialDelegate, onViewController viewController: UIViewController) {
    let ad = generateInterstitialAd(delegate)
    DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
      if ad.isReady {
        ad.present(fromRootViewController: viewController)
        print("AdMob Interstitial!")
      }})
  }
   
    private func generateInterstitialAd(_ delegate: GADInterstitialDelegate) -> GADInterstitial {
        let ad = GADInterstitial(adUnitID: ADMOB_INTERSTITIAL_UNIT_ID)
        let adRequest = GADRequest()
        adRequest.testDevices = [kGADSimulatorID]
        ad.load(adRequest)
        ad.delegate = delegate
        return ad
    }
}

extension UIViewController {
  func showInterstitial() {
    if let viewcontroller = self as? GADInterstitialDelegate {
      GoogleAdMobManager.shared.showInterstitialAd(viewcontroller, onViewController: self)
    }
  }
}
