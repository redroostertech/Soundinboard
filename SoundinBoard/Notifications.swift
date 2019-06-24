/*==================================================
 Askk
 
 © XScoder 2019
 All Rights reserved
 
 /*
 RE-SELLING THIS SOURCE CODE TO ANY ONLINE MARKETPLACE IS A SERIOUS COPYRIGHT INFRINGEMENT.
 YOU WILL BE LEGALLY PROSECUTED
 */
=======================================================*/

import UIKit
import Parse

class Notifications: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /*--- VIEWS ---*/
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var notificationsTableView: UITableView!
    
    
    /*--- VARIABLES ---*/
    var notificationsArray = [PFObject]()
    var skip = 0
    
    
    
    // ------------------------------------------------
    // MARK: - VIEW DID APPEAR
    // ------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "Intro") as! Intro
            present(vc, animated: true, completion: nil)
        } else {
            // Call query
            refreshData()
        }
    }
    
    
    
    // ------------------------------------------------
    // MARK: - VIEW DID LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Refresh Control
        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        notificationsTableView.addSubview(refreshControl)
        
    }
    
    
    
    // ------------------------------------------------
    // MARK: - QUERY NOTIFICATIONS
    // ------------------------------------------------
    func queryNotifications() {
        let currentUser = PFUser.current()!
        
        let query = PFQuery(className: NOTIFICATIONS_CLASS_NAME)
        query.whereKey(NOTIFICATIONS_OTHER_USER, equalTo: currentUser)
        query.order(byDescending: NOTIFICATIONS_CREATED_AT)
        query.skip = skip
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.hideHUD()
                
                if objects!.count == 0 {
                    self.notificationsTableView.isHidden = true
                } else {
                    for i in 0..<objects!.count { self.notificationsArray.append(objects![i]) }
                    if (objects!.count == 100) {
                        self.skip = self.skip + 100
                        self.queryNotifications()
                    } else {
                        self.hideHUD()
                        self.notificationsTableView.isHidden = false
                        self.notificationsTableView.reloadData()
                    }
                }
            // error
            } else { self.hideHUD(); self.simpleAlert("\(error!.localizedDescription)")
        }}
    }
    
    
    
    // ------------------------------------------------
    // MARK: - SHOW DATA IN TABLEVIEW
    // ------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        
        // Parse Obj
        var nObj = PFObject(className: NOTIFICATIONS_CLASS_NAME)
        nObj = notificationsArray[indexPath.row]
        
        // userPointer
        let userPointer = nObj[NOTIFICATIONS_CURRENT_USER] as! PFUser
        userPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                
                // User is anonymous!
                let notifText = "\(nObj[NOTIFICATIONS_TEXT]!)"
                if notifText.contains("(Anonymous)") {
                    cell.fullnameLabel.text = "(Anonymous)"
                    cell.avatarImg.image = UIImage(named: "anonymous_avatar")
                
                // User is not anonymous
                } else {
                    cell.fullnameLabel.text = "\(userPointer[USER_FULLNAME]!)"
                    self.getParseImage(object: userPointer, colName: USER_AVATAR, imageView: cell.avatarImg)
                }
                cell.notificationLabel.text = notifText
                
            // error
            } else { self.simpleAlert("\(error!.localizedDescription)")
        }})// ./ userPointer
        
    return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    // ------------------------------------------------
    // MARK: - NOTIFICATION SELECTED
    // ------------------------------------------------
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Parse Obj
        var nObj = PFObject(className: NOTIFICATIONS_CLASS_NAME)
        nObj = notificationsArray[indexPath.row]
        let currentUser = PFUser.current()!
        
        // userPointer
        let userPointer = nObj[NOTIFICATIONS_CURRENT_USER] as! PFUser
        userPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                
                // User is Anonymous!
                let notifText = "\(nObj[NOTIFICATIONS_TEXT]!)"
                if notifText.contains("(Anonymous)") {
                   self.simpleAlert("You are not allowed to see this Profile")
                    
                // User is not anonymous
                } else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Account") as! Account
                    if userPointer.objectId! == currentUser.objectId! {
                        vc.isCurrentUser = true
                    } else {
                        vc.isCurrentUser = false
                        vc.userObj = userPointer
                    }
                    vc.showBackbutton = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            // error
            } else { self.simpleAlert("\(error!.localizedDescription)")
        }})// ./ userPointer
    }
    
    
    
    // ------------------------------------------------
    // MARK: - DELETE CELL
    // ------------------------------------------------
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Parse Obj
            var nObj = PFObject(className: NOTIFICATIONS_CLASS_NAME)
            nObj = notificationsArray[indexPath.row]
            nObj.deleteInBackground { (succ, error) in
                if error == nil {
                    self.notificationsArray.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
            }}
        }// ./ If
    }
    
    
    
    // ------------------------------------------------
    // MARK: - REFRESH DATA
    // ------------------------------------------------
    @objc func refreshData () {
        showHUD()
        skip = 0
        notificationsArray = [PFObject]()
        notificationsTableView.reloadData()
        
        // Recall query
        queryNotifications()
        
        if refreshControl.isRefreshing { refreshControl.endRefreshing() }
    }
    
    
}// ./ end
