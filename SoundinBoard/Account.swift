/*==================================================
 Askk
 
 © XScoder 2019
 All Rights reserved
 
 /*
 RE-SELLING THIS SOURCE CODE TO ANY ONLINE MARKETPLACE IS A SERIOUS COPYRIGHT INFRINGEMENT.
 YOU WILL BE LEGALLY PROSECUTED
 */
======================================================*/

import UIKit
import Parse

class Account: UIViewController, UITableViewDataSource, UITableViewDelegate {

    /*--- VIEWS ---*/
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var educationLabel: UILabel!
    @IBOutlet weak var QATableView: UITableView!
    @IBOutlet weak var questionsButton: UIButton!
    @IBOutlet weak var answersButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    let refreshControl = UIRefreshControl()
    
    
    /*--- VARIABLES ---*/
    var isCurrentUser = true
    var showBackbutton = false
    var userObj = PFUser(className: USER_CLASS_NAME)
    var QAArray = [PFObject]()
    var skip = 0
    var isQuestions = true
    
    
    
    
    // ------------------------------------------------
    // MARK: - VIEW DID APPEAR
    // ------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        print("IS CURR USER: \(isCurrentUser)")
        
        // Show back button
        if showBackbutton { backButton.isHidden = false
        } else { backButton.isHidden = true }
        
        
        // USER NOT LOGGED IN...
        if PFUser.current() == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "Intro") as! Intro
            present(vc, animated: true, completion: nil)
            
        // USER IS LOGGED IN!
        } else {
            let currentUser = PFUser.current()!
            
            // Call function
            if isCurrentUser {
                showUserDetails(currentUser)
                editButton.isHidden = false
                reportButton.isHidden = true
            } else {
                showUserDetails(userObj)
                editButton.isHidden = true
                reportButton.isHidden = false
            }
            
            
            if mustReload {
                mustReload = false
                // Call query
                callQuery()
            }
            
        }// ./ If
    
    }
    
    
    
    
    // ------------------------------------------------
    // MARK: - VIEW DID LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        // Layout
        avatarImg.layer.cornerRadius = avatarImg.bounds.size.width/2
        avatarImg.layer.borderWidth = 2
        avatarImg.layer.borderColor = MAIN_COLOR.cgColor
        questionsButton.layer.cornerRadius = 20
        answersButton.layer.cornerRadius = 20
        
        // Refresh Control
        refreshControl.tintColor = UIColor.black
        refreshControl.addTarget(self, action: #selector(callQuery), for: .valueChanged)
        QATableView.addSubview(refreshControl)
        
        // Call query
        if PFUser.current() != nil { callQuery() }
    }
    

    
    // ------------------------------------------------
    // MARK: - SHOW USER DETAILS
    // ------------------------------------------------
    func showUserDetails(_ uObj:PFUser) {
        fullnameLabel.text = "\(uObj[USER_FULLNAME]!)"
        usernameLabel.text = "@\(uObj[USER_USERNAME]!)"
        getParseImage(object: uObj, colName: USER_AVATAR, imageView: avatarImg)
        if uObj[USER_LOCATION] != nil { locationLabel.text = "\(uObj[USER_LOCATION]!)"
        } else { locationLabel.text = "N/A" }
        if uObj[USER_EDUCATION] != nil { educationLabel.text = "\(uObj[USER_EDUCATION]!)"
        } else { educationLabel.text = "N/A" }
    }
    
    
    
    // ------------------------------------------------
    // MARK: - QUESTIONS BUTTON
    // ------------------------------------------------
    @IBAction func questionsButt(_ sender: UIButton) {
        isQuestions = true
        questionsButton.backgroundColor = MAIN_COLOR
        questionsButton.setTitleColor(.white, for: .normal)
        answersButton.backgroundColor = .white
        answersButton.setTitleColor(MAIN_COLOR, for: .normal)
        
        callQuery()
    }
    
    
    // ------------------------------------------------
    // MARK: - ANSWERS BUTTON
    // ------------------------------------------------
    @IBAction func answersButt(_ sender: UIButton) {
        isQuestions = false
        questionsButton.backgroundColor = .white
        questionsButton.setTitleColor(MAIN_COLOR, for: .normal)
        answersButton.backgroundColor = MAIN_COLOR
        answersButton.setTitleColor(.white, for: .normal)
        
        callQuery()
    }
    
    
    
    // ------------------------------------------------
    // MARK: - CALL QUERY
    // ------------------------------------------------
    @objc func callQuery() {
        showHUD()
        QAArray = [PFObject]()
        skip = 0
        QATableView.reloadData()
        
        // Call query
        if isQuestions { queryQuestions()
        } else { queryAnswers() }
        
        if refreshControl.isRefreshing { refreshControl.endRefreshing() }
    }
    
    
    
    // ------------------------------------------------
    // MARK: - QUERY QUESTIONS
    // ------------------------------------------------
    func queryQuestions() {
        let currentUser = PFUser.current()!
        
        let query = PFQuery(className: QUESTIONS_CLASS_NAME)
        
        if isCurrentUser {
            query.whereKey(QUESTIONS_USER_POINTER, equalTo: currentUser)
        } else {
            query.whereKey(QUESTIONS_USER_POINTER, equalTo: userObj)
            query.whereKey(QUESTIONS_IS_ANONYMOUS, equalTo: false)
        }
        
        query.skip = skip
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                // NO Questions...
                if objects!.count == 0 {
                    self.hideHUD()
                    self.QATableView.isHidden = true
                    
                // There are Questions!
                } else {
                    self.QATableView.isHidden = false
                    
                    for i in 0..<objects!.count { self.QAArray.append(objects![i]) }
                    if (objects!.count == 100) {
                        self.skip = self.skip + 100
                        self.queryQuestions()
                    } else {
                        self.hideHUD()
                        self.QATableView.reloadData()
                    }
                }// ./ If
          
            // error
            } else { self.hideHUD(); self.simpleAlert("\(error!.localizedDescription)")
        }}
    }
    
    
    
    // ------------------------------------------------
    // MARK: -  QUERY ANSWERS
    // ------------------------------------------------
    func queryAnswers() {
        let currentUser = PFUser.current()!
        
        let query = PFQuery(className: ANSWERS_CLASS_NAME)
        
        if isCurrentUser {
            query.whereKey(ANSWERS_USER_POINTER, equalTo: currentUser)
        } else {
            query.whereKey(ANSWERS_USER_POINTER, equalTo: userObj)
            query.whereKey(ANSWERS_IS_ANONYMOUS, equalTo: false)
        }
        
        query.skip = skip
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                // NO Answers...
                if objects!.count == 0 {
                    self.hideHUD()
                    self.QATableView.isHidden = true
                    
                // There are Answers!
                } else {
                    self.QATableView.isHidden = false
                    
                    for i in 0..<objects!.count { self.QAArray.append(objects![i]) }
                    if (objects!.count == 100) {
                        self.skip = self.skip + 100
                        self.queryAnswers()
                    } else {
                        self.hideHUD()
                        self.QATableView.reloadData()
                    }
                }// ./ If
                
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
        return QAArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath) as! QuestionCell
        
        // SHOW QUESTIONS
        if isQuestions {
            
            // Parse Obj
            var qObj = PFObject(className: QUESTIONS_CLASS_NAME)
            qObj = QAArray[indexPath.row]
            
            // User Pointer
            let userPointer = qObj[QUESTIONS_USER_POINTER] as! PFUser
            userPointer.fetchIfNeededInBackground(block: { (user, error) in
                if error == nil {
                    
                    // isAnonymous
                    let isAnonymuos = qObj[QUESTIONS_IS_ANONYMOUS] as! Bool
                    
                    // Color
                    cell.backgroundColor = UIColor(hexString: "\(qObj[QUESTIONS_COLOR]!)")
                    
                    // Category Image • Name
                    cell.categoryImg.isHidden = false
                    cell.categoryLabel.isHidden = false
                    cell.categoryImg.image = UIImage(named: "\(qObj[QUESTIONS_CATEGORY]!)")
                    cell.categoryLabel.text = "\(qObj[QUESTIONS_CATEGORY]!)".uppercased()
                    
                    // Fullname • Date
                    let date = qObj.createdAt!
                    let dateFormat = DateFormatter()
                    dateFormat.dateFormat = "MMM dd, yyyy"
                    if isAnonymuos {
                        cell.dateLabel.text = "(Anonymously) • " +  dateFormat.string(from: date)
                    } else {
                        cell.dateLabel.text = dateFormat.string(from: date)
                    }
                    
                    // Avatar
                    if isAnonymuos {
                        cell.avatarImg.image = UIImage(named: "anonymous_avatar")
                    } else {
                        self.getParseImage(object: userPointer, colName: USER_AVATAR, imageView: cell.avatarImg)
                    }
                    
                    // Question
                    cell.questionLabel.text = "\(qObj[QUESTIONS_QUESTION]!)"
                    
                    // Answers & Views
                    let answers = qObj[QUESTIONS_ANSWERS] as! Int
                    let views = qObj[QUESTIONS_VIEWS] as! Int
                    cell.answeredByLabel.text = answers.rounded + " answers • " + views.rounded + " views"
                    
                // error
                } else { self.simpleAlert("\(error!.localizedDescription)")
            }})// ./ userPointer
            
            
            
        // SHOW ANSWERS
        } else {
            // Parse Obj
            var aObj = PFObject(className: ANSWERS_CLASS_NAME)
            aObj = QAArray[indexPath.row]
            
            // User Pointer
            let userPointer = aObj[ANSWERS_USER_POINTER] as! PFUser
            userPointer.fetchIfNeededInBackground(block: { (user, error) in
                if error == nil {
                    
                    // isAnonymous
                    let isAnonymuos = aObj[ANSWERS_IS_ANONYMOUS] as! Bool
                    
                    // Color
                    cell.backgroundColor = MAIN_COLOR
                    
                    // Hide Category Image • Name
                    cell.categoryImg.isHidden = true
                    cell.categoryLabel.isHidden = true
                    
                    // Fullname • Date
                    let date = aObj.createdAt!
                    let dateFormat = DateFormatter()
                    dateFormat.dateFormat = "MMM dd, yyyy"
                    if isAnonymuos {
                        cell.dateLabel.text = "(Anonymously) • " +  dateFormat.string(from: date)
                    } else {
                        cell.dateLabel.text = dateFormat.string(from: date)
                    }
                    
                    // Avatar
                    if isAnonymuos {
                        cell.avatarImg.image = UIImage(named: "anonymous_avatar")
                    } else {
                        self.getParseImage(object: userPointer, colName: USER_AVATAR, imageView: cell.avatarImg)
                    }
                    
                    // Answer
                    cell.questionLabel.text = "\(aObj[ANSWERS_ANSWER]!)"
                    
                    // questionPointer
                    let questionPointer = aObj[ANSWERS_QUESTION_POINTER] as! PFObject
                    questionPointer.fetchIfNeededInBackground(block: { (object, error) in
                        if error == nil {
                            cell.answeredByLabel.text = "In: \(questionPointer[QUESTIONS_QUESTION]!)'"
                        // error
                        } else { self.simpleAlert("\(error!.localizedDescription)")
                    }})// ./ questionPointer
                    
                // error
                } else { self.simpleAlert("\(error!.localizedDescription)")
            }})// ./ userPointer

        }// ./ If
        
    return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 146
    }
    
    
    
    // ------------------------------------------------
    // MARK: - CELL TAPPED -> SEE QUESTION AND ANSWERS
    // ------------------------------------------------
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isQuestions {
            // Parse Obj
            var qObj = PFObject(className: QUESTIONS_CLASS_NAME)
            qObj = QAArray[indexPath.row]
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "QuestionScreen") as! QuestionScreen
            vc.qObj = qObj
            navigationController?.pushViewController(vc, animated: true)
            
        } else {
            // Parse Obj
            var aObj = PFObject(className: ANSWERS_CLASS_NAME)
            aObj = QAArray[indexPath.row]
            
            // questionPointer
            let questionPointer = aObj[ANSWERS_QUESTION_POINTER] as! PFObject
            questionPointer.fetchIfNeededInBackground(block: { (object, error) in
                if error == nil {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "QuestionScreen") as! QuestionScreen
                    vc.qObj = questionPointer
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                // error
                } else { self.simpleAlert("\(error!.localizedDescription)")
            }})// ./ questionPointer
            
        }// ./ If
        
    }
    
    
    
    // ------------------------------------------------
    // MARK: - REPORT USER BUTTON
    // ------------------------------------------------
    @IBAction func reportUserButt(_ sender: Any) {
        let currentUser = PFUser.current()!
        var reportedBy = userObj[USER_REPORTED_BY] as! [String]
        reportedBy.append(currentUser.objectId!)
        showHUD()
        
        let request = [
            "userId" : self.userObj.objectId!,
            "reportedBy" : reportedBy
        ] as [String : Any]
        
        PFCloud.callFunction(inBackground: "reportUser", withParameters: request as [String : Any], block: { (results, error) in
            if error == nil {
                self.hideHUD()
                mustReload = true
                
                // 1. Query all Questions of this user and report them (if any)
                let query = PFQuery(className: QUESTIONS_CLASS_NAME)
                query.whereKey(QUESTIONS_USER_POINTER, equalTo: self.userObj)
                query.findObjectsInBackground { (objects, error) in
                    if error == nil {
                        if objects!.count != 0 {
                            for i in 0..<objects!.count {
                                var qObj = PFObject(className: QUESTIONS_CLASS_NAME)
                                qObj = objects![i]
                                var qReportedBy = qObj[QUESTIONS_REPORTED_BY] as! [String]
                                qReportedBy.append(currentUser.objectId!)
                                qObj[QUESTIONS_REPORTED_BY] = qReportedBy
                                qObj.saveInBackground()
                            }
                        }
                        
                        // 2. Query all Answers of this user and report them (if any)
                        let query = PFQuery(className: ANSWERS_CLASS_NAME)
                        query.whereKey(ANSWERS_USER_POINTER, equalTo: self.userObj)
                        query.findObjectsInBackground { (objects2, error) in
                            if error == nil {
                                if objects2!.count != 0 {
                                    for i in 0..<objects2!.count {
                                        var aObj = PFObject(className: ANSWERS_CLASS_NAME)
                                        aObj = objects2![i]
                                        var aReportedBy = aObj[ANSWERS_REPORTED_BY] as! [String]
                                        aReportedBy.append(currentUser.objectId!)
                                        aObj[ANSWERS_REPORTED_BY] = aReportedBy
                                        aObj.saveInBackground()
                                    }
                                }
                                // error
                            } else { self.hideHUD(); self.simpleAlert("\(error!.localizedDescription)")
                        }}
                        
                    // error
                    } else { self.hideHUD(); self.simpleAlert("\(error!.localizedDescription)")
                }}
                
                
                
                // Fire alert
                let alert = UIAlertController(title: APP_NAME,
                    message: "Thanks for reporting @\(self.userObj[USER_USERNAME]!) to us. We'll take action for it withint 24h.",
                    preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    // Back to Home
                    let tbc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
                    tbc.selectedIndex = 0
                    self.present(tbc, animated: false, completion: nil)
                })
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                
            // error
            } else { self.hideHUD(); self.simpleAlert("\(error!.localizedDescription)") }
        })// ./ CloudCode
    }
    
    
    
    
    // ------------------------------------------------
    // MARK: - EDIT PROFILE BUTTON
    // ------------------------------------------------
    @IBAction func editProfileButt(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "EditProfile") as! EditProfile
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
    // ------------------------------------------------
    // MARK: - BACK BUTTON
    // ------------------------------------------------
    @IBAction func backButt(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    
    // ------------------------------------------------
    // MARK: - LOGOUT BUTTON
    // ------------------------------------------------
    @IBAction func logoutButt(_ sender: Any) {
        // Fire alert
        let alert = UIAlertController(title: APP_NAME,
            message: "Are you sure you want to logout?",
            preferredStyle: .alert)
        
        let logout = UIAlertAction(title: "Logout", style: .destructive, handler: { (action) -> Void in
            self.showHUD()
            PFUser.logOutInBackground(block: { (error) in
                if error == nil {
                    self.hideHUD()
                    
                    // Go back to Home
                    let tbc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
                    tbc.selectedIndex = 0
                    self.present(tbc, animated: false, completion: nil)
                    
                } else { self.hideHUD(); self.simpleAlert("\(error!.localizedDescription)")
                }})
        })
        alert.addAction(logout)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    
}// ./ end
