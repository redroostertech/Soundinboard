import Foundation
import UIKit
import SVProgressHUD
import ChameleonFramework
import APESuperHUD
import Parse
import AVFoundation

extension UIViewController {
    
    func hideNavigationBarHairline() {
        if let navController = self.navigationController {
            navController.hidesNavigationBarHairline = true
        }
    }
    
    func hideNavigationBar() {
        if let navController = self.navigationController {
            navController.navigationBar.isHidden = true
        }
    }
    
    func unHideNavigationBar() {
        if let navController = self.navigationController {
            navController.navigationBar.isHidden = false
        }
    }
    
    func showNavigationBar() {
        if let navController = self.navigationController {
            navController.navigationBar.isHidden = false
        }
    }
    
    func clearNavigationBackButtonText() {
        if (self.navigationController != nil) {
            self.navigationItem.title = ""
        }
    }
    
    func updateNavigationBar(withBackgroundColor bgColor: UIColor?,
                             tintColor: UIColor?,
                             andText text: String?) {
        if let navigationcontroller = self.navigationController {
            navigationcontroller.navigationBar.isTranslucent = false
            if let bgcolor = bgColor {
                navigationcontroller.navigationBar.barTintColor = bgcolor
            }
            if let tintcolor = tintColor {
                navigationcontroller.navigationBar.tintColor = tintcolor
              navigationcontroller.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: tintcolor]
            }
            if text != nil {
                updateNavigationBar(title: text!)
            } else {
                clearNavigationBackButtonText()
            }
        }
    }
    
    func updateNavigationBar(title: String) {
        if (self.navigationController != nil) {
            self.navigationItem.title = title
        }
    }
    
    func updateNavigationBar(withButton button: UIButton) {
        if (self.navigationController != nil) {
            let button = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem = button
        }
    }
    
    func updateNavigationBar(withButton buttons: [UIButton]) {
        if (self.navigationController != nil) {
            var btns = [UIBarButtonItem]()
            for button in buttons {
                let btn = UIBarButtonItem(customView: button)
                btns.append(btn)
            }
            self.navigationItem.rightBarButtonItems = btns
        }
    }
    
    func navigateToView(withID vid: String, fromStoryboard sid: String = "Main") {
        let storyboard = UIStoryboard(name: sid, bundle: nil)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: vid)
        UIApplication.shared.keyWindow?.rootViewController = viewcontroller
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }
    
    func pushToView(withID vid: String, fromStoryboard sid: String = "Main") {
        let storyboard = UIStoryboard(name: sid, bundle: nil)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: vid)
        if (self.navigationController != nil) {
            self.navigationController!.pushViewController(viewcontroller, animated: true)
        } else {
            self.present(viewcontroller, animated: true, completion: nil)
        }
    }
    
    func pushToView(withViewController viewcontroller: UIViewController) {
        if (self.navigationController != nil) {
            self.navigationController!.pushViewController(viewcontroller, animated: true)
        } else {
            self.present(viewcontroller, animated: true, completion: nil)
        }
    }
    
    func popViewController(to vid: String? = nil, fromStoryboard sid: String? = nil){
        guard let idForViewController = vid, let idForStoryboard = sid else {
            if (self.navigationController != nil) {
                self.navigationController!.popViewController(animated: true)
            }
            return
        }
        let storyboard = UIStoryboard(name: idForStoryboard, bundle: nil)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: idForViewController)
        if (self.navigationController != nil) {
            self.navigationController!.popToViewController(viewcontroller,
                                                           animated: true)
        }
    }
    
    func popViewController(withViewController viewcontroller: UIViewController){
        if (self.navigationController != nil) {
            self.navigationController!.popToViewController(viewcontroller,
                                                           animated: true)
        } else {
            self.present(viewcontroller, animated: true, completion: nil)
        }
    }
    
    func dismissViewController() {
        self.dismiss(animated: true,
                     completion: nil)
    }
    
//    func showHUD() {
//        SVProgressHUD.show()
//        SVProgressHUD.setBackgroundColor(UIColor.orange)
//        SVProgressHUD.setForegroundColor(UIColor.white)
//    }

    func showError(_ error: String, withDelay delay: TimeInterval = 3.0) {
        SVProgressHUD.showError(withStatus: error)
        SVProgressHUD.dismiss(withDelay: delay)
    }

    func scrollToTop(of tableView: UITableView, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            if tableView.visibleCells.count > 0 {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
            completion()
        }
    }
    
    func scrollToBottom(of tableView: UITableView, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            if tableView.numberOfRows(inSection: 0) > 0 {
                tableView.scrollToRow(at: IndexPath(row: tableView.numberOfRows(inSection: 0) - 1, section: 0), at: .bottom, animated: true)
            }
            completion()
        }
    }
    
    func setBackground(_ imageName: String, onView view: UIView) {
        if let view = self.view {
            let image = UIImage(named: imageName)
            let imageView = UIImageView(frame: view.frame)
            imageView.contentMode = .scaleAspectFill
            imageView.image = image
            view.addSubview(imageView)
            view.sendSubviewToBack(imageView)
        }
    }
    
    func setBackground(_ color: UIColor, onView view: UIView) {
        if let view = self.view {
            view.backgroundColor = color
        }
    }

    func EmptyMessage(tableView:UITableView, message:String, viewController:UIViewController) {
        print("Setting empty message")
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewController.view.bounds.size.width, height: viewController.view.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        tableView.backgroundView = messageLabel;
        tableView.separatorStyle = .none;
        print("message set")
    }
    
//    func setBackgroundWithPrimaryGradient() {
//        if let view = self.view {
//            view.addPrimaryGradientToBackground()
//        }
//    }
//    
//    func setBackgroundWithSecondaryGradient() {
//        if let view = self.view {
//            view.addSecondaryGradientToBackground()
//        }
//    }

    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: 16, y: self.view.frame.size.height-150, width: self.view.frame.size.width - 32, height: 70))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 2
        toastLabel.adjustsFontSizeToFitWidth = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    var emptyCell: UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = ""
        return cell
    }
    
}

extension UIViewController {
    func showErrorAlert(message: String?) {
        SVProgressHUD.showError(withStatus: message ?? "")
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.setMinimumDismissTimeInterval(1)
    }
    
    func showErrorAlert(_ error: DadHiveError) {
        SVProgressHUD.showError(withStatus: error.rawValue)
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.setMinimumDismissTimeInterval(1)
    }

    func showAlertErrorIfNeeded(error: Error?) {
        if let e = error {
            showErrorAlert(message: e.localizedDescription)
        } else {
            SVProgressHUD.dismiss()
        }
    }
    
//    func showHUD() {
//        SVProgressHUD.show()
//        UIApplication.shared.beginIgnoringInteractionEvents()
//        SVProgressHUD.setBackgroundColor(AppColors.darkGreen)
//        SVProgressHUD.setForegroundColor(UIColor.white)
//    }
//
//    func hideHUD() {
//        if SVProgressHUD.isVisible() {
//            SVProgressHUD.dismiss()
//        }
//        UIApplication.shared.endIgnoringInteractionEvents()
//    }
}

extension UIViewController {
  // ------------------------------------------------
  // MARK: - SHOW TOAST MESSAGE
  // ------------------------------------------------
  func showToast(_ message:String) {
    toast = UILabel(frame: CGRect(x: view.frame.size.width/2 - 100,
                                  y: view.frame.size.height-100,
                                  width: 200,
                                  height: 32))
    toast.font = UIFont(name: "OpenSans-Bold", size: 14)
    toast.textColor = UIColor.white
    toast.textAlignment = .center
    toast.adjustsFontSizeToFitWidth = true
    toast.text = message
    toast.layer.cornerRadius = 14
    toast.clipsToBounds = true
    toast.backgroundColor = MAIN_COLOR
    view.addSubview(toast)
    Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(hideToast), userInfo: nil, repeats: false)
  }
  @objc func hideToast() {
    toast.removeFromSuperview()
  }

  // ------------------------------------------------
  // MARK: - SHOW/HIDE LOADING HUD
  // ------------------------------------------------
  func showHUD() {
    hud.frame = CGRect(x:0, y:0,
                       width:view.frame.size.width,
                       height: view.frame.size.height)
    hud.backgroundColor = UIColor.white
    hud.alpha = 0.7
    view.addSubview(hud)

    loadingCircle.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
    loadingCircle.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
    loadingCircle.image = UIImage(named: "spinner")
    loadingCircle.contentMode = .scaleAspectFill
    loadingCircle.clipsToBounds = true
    animateLoadingCircle(imageView: loadingCircle, time: 0.8)
    view.addSubview(loadingCircle)
  }

  func animateLoadingCircle(imageView: UIImageView, time: Double) {
    let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
    rotationAnimation.fromValue = 0.0
    rotationAnimation.toValue = -Double.pi * 2
    rotationAnimation.duration = time
    rotationAnimation.repeatCount = .infinity
    imageView.layer.add(rotationAnimation, forKey: nil)
  }

  func hideHUD() {
    hud.removeFromSuperview()
    loadingCircle.removeFromSuperview()
  }

  // ------------------------------------------------
  // MARK: - SHOW LOGIN ALERT
  // ------------------------------------------------
  func showLoginAlert(_ mess:String) {
    let alert = UIAlertController(title: APP_NAME,
                                  message: mess,
                                  preferredStyle: .alert)

    let ok = UIAlertAction(title: "Sign in", style: .default, handler: { (action) -> Void in
      let aVC = self.storyboard?.instantiateViewController(withIdentifier: "Intro") as! Intro
      self.present(aVC, animated: true, completion: nil)
    })
    alert.addAction(ok)

    let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
  }


  // ------------------------------------------------
  // MARK: - FIRE A SIMPLE ALERT
  // ------------------------------------------------
  func simpleAlert(_ mess:String) {
    let alert = UIAlertController(title: APP_NAME,
                                  message: mess, preferredStyle: .alert)
    let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in })
    alert.addAction(ok)
    present(alert, animated: true, completion: nil)
  }

  // ------------------------------------------------
  // MARK: - GET PARSE IMAGE - IMAGEVIEW
  // ------------------------------------------------
  func getParseImage(object:PFObject, colName:String, imageView:UIImageView) {
    let imageFile = object[colName] as? PFFileObject
    imageFile?.getDataInBackground(block: { (imageData, error) in
      if error == nil {
        if let imageData = imageData {
          imageView.image = UIImage(data:imageData)
        }}})
  }

  // ------------------------------------------------
  // MARK: - GET PARSE IMAGE - BUTTON
  // ------------------------------------------------
  func getParseImage(object:PFObject, colName:String, button:UIButton) {
    let imageFile = object[colName] as? PFFileObject
    imageFile?.getDataInBackground(block: { (imageData, error) in
      if error == nil {
        if let imageData = imageData {
          button.setImage(UIImage(data:imageData), for: .normal)
        }}})
  }


  // ------------------------------------------------
  // MARK: - SAVE PARSE IMAGE
  // ------------------------------------------------
  func saveParseImage(object:PFObject, colName:String, imageView:UIImageView) {
    let imageData = imageView.image!.jpegData(compressionQuality: 1.0)
    let imageFile = PFFileObject(name:"image.jpg", data:imageData!)
    object[colName] = imageFile
  }

  // ------------------------------------------------
  // MARK: - PROPORTIONALLY SCALE AN IMAGE TO MAX WIDTH
  // ------------------------------------------------
  func scaleImageToMaxWidth(image: UIImage, newWidth: CGFloat) -> UIImage {
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
  }

  // ------------------------------------------------
  // MARK: - CREATE A THUMBNAIL IMAGE OF A VIDEO
  // ------------------------------------------------
  func createVideoThumbnail(_ url:URL) -> UIImage? {
    let asset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    var time = asset.duration
    time.value = min(time.value, 2)
    do {
      let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
      return UIImage(cgImage: imageRef)
    } catch let error as NSError {
      print("Image generation failed with error \(error)")
      return nil
    }
  }

  // ------------------------------------------------
  // MARK: - SEND A PUSH NOTIFICATION
  // ------------------------------------------------
  func sendPushNotification(parseObj:PFObject, columnName:String, pushMessage:String) {
    let currentUser = PFUser.current()!

    // userPointer
    let userPointer = parseObj[columnName] as! PFUser
    userPointer.fetchIfNeededInBackground(block: { (user, error) in
      if error == nil {

        let data = [
          "badge" : "Increment",
          "alert" : pushMessage,
          "sound" : "bingbong.aiff"
        ]
        let request = [
          "userObjectID" : userPointer.objectId!,
          "data" : data
          ] as [String : Any]

        PFCloud.callFunction(inBackground: "pushiOS", withParameters: request as [String : Any], block: { (results, error) in
          if error == nil { print ("\nPUSH NOTIFICATION SENT TO: \(userPointer[USER_USERNAME]!)\nMESSAGE: \(pushMessage)")
            // error
          } else { self.simpleAlert("\(error!.localizedDescription)")
          }})// ./ PFCloud


        // ------------------------------------------------
        // MARK: - SAVE NOTIFICATION IN THE DATABASE
        // ------------------------------------------------
        let nObj = PFObject(className: NOTIFICATIONS_CLASS_NAME)
        nObj[NOTIFICATIONS_TEXT] = pushMessage
        nObj[NOTIFICATIONS_CURRENT_USER] = currentUser
        nObj[NOTIFICATIONS_OTHER_USER] = userPointer
        nObj.saveInBackground(block: { (succ, error) in
          if error == nil {
            print("NOTIFICATION SAVED IN THE DATABASE!\n")
          } else { self.simpleAlert("\(error!.localizedDescription)")
          }})

        // error
      } else { self.simpleAlert("\(error!.localizedDescription)")
      }})// ./ userPointer
  }


  // ------------------------------------------------
  // MARK: - FORMAT DATE BY TIME AGO SINCE DATE
  // ------------------------------------------------
  func timeAgoSinceDate(_ date:Date, currentDate:Date, numericDates:Bool) -> String {
    let calendar = Calendar.current
    let now = currentDate
    let earliest = (now as NSDate).earlierDate(date)
    let latest = (earliest == now) ? date : now
    let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())

    if (components.year! >= 2) {
      return "\(components.year!) years ago"
    } else if (components.year! >= 1){
      if (numericDates){ return "1 year ago"
      } else { return "Last year" }
    } else if (components.month! >= 2) {
      return "\(components.month!) months ago"
    } else if (components.month! >= 1){
      if (numericDates){ return "1 month ago"
      } else { return "Last month" }
    } else if (components.weekOfYear! >= 2) {
      return "\(components.weekOfYear!) weeks ago"
    } else if (components.weekOfYear! >= 1){
      if (numericDates){ return "1 week ago"
      } else { return "Last week" }
    } else if (components.day! >= 2) {
      return "\(components.day!) days ago"
    } else if (components.day! >= 1){
      if (numericDates){ return "1 day ago"
      } else { return "Yesterday" }
    } else if (components.hour! >= 2) {
      return "\(components.hour!) hours ago"
    } else if (components.hour! >= 1){
      if (numericDates){ return "1 hour ago"
      } else { return "An hour ago" }
    } else if (components.minute! >= 2) {
      return "\(components.minute!) minutes ago"
    } else if (components.minute! >= 1){
      if (numericDates){ return "1 minute ago"
      } else { return "A minute ago" }
    } else if (components.second! >= 3) {
      return "\(components.second!) seconds ago"
    } else { return "Just now" }
  }

}
