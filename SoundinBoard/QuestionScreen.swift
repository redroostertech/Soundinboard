import UIKit
import Parse

class QuestionScreen: UIViewController, UITableViewDataSource, UITableViewDelegate {

    /*--- VIEWS ---*/
    @IBOutlet weak var answersTableView: UITableView!
    @IBOutlet weak var questionTxt: UITextView!
    @IBOutlet weak var answersViewsLabel: UILabel!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var questionImgButton: UIButton!
    @IBOutlet weak var imagePreviewView: UIView!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var moreView: UIView!
    @IBOutlet weak var moreTextView: UITextView!
    @IBOutlet weak var moreAvatarImg: UIImageView!
    @IBOutlet weak var moreFullnameLabel: UILabel!
    @IBOutlet weak var moreAnsweredLabel: UILabel!
    @IBOutlet weak var editQuestionButton: UIButton!
    


    /*--- VARIABLES ---*/
    var qObj = PFObject(className: QUESTIONS_CLASS_NAME)
    var answersArray = [PFObject]()
    var skip = 0
    
    
    // ------------------------------------------------
    // MARK: - VIEW DID APPEAR
    // ------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        if mustReload {
            mustReload = false
            // Call function
            showQuestionDetails()
        }
    }
    
    
    
    // ------------------------------------------------
    // MARK: - VIEW DID LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Layout
        avatarImg.layer.cornerRadius = avatarImg.bounds.size.width/2
        questionImgButton.layer.cornerRadius = 6
        questionImgButton.imageView?.contentMode = .scaleAspectFill
        questionImgButton.imageView?.clipsToBounds = true

        imagePreviewView.frame.origin.y = view.frame.size.height
        moreView.frame.origin.y = view.frame.size.height

        
        // Call function
        showQuestionDetails()
        

        // Call AdMob Interstitial
        showInterstitial()
    }
    
    
    
    
    // ------------------------------------------------
    // MARK: - SHOW QUESTION DETAILS
    // ------------------------------------------------
    func showQuestionDetails() {
        
        // User Pointer
        let userPointer = qObj[QUESTIONS_USER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                
                // isAnonymous
                let isAnonymuos = self.qObj[QUESTIONS_IS_ANONYMOUS] as! Bool
                
                // Question Image
                let qImg = self.qObj[QUESTIONS_IMAGE] as? PFFileObject
                if qImg != nil {
                    self.questionImgButton.isHidden = false
                    self.getParseImage(object: self.qObj, colName: QUESTIONS_IMAGE, button: self.questionImgButton)
                    self.questionTxt.frame.size.width = (self.view.frame.size.width-30) - 80
                } else {
                    self.questionImgButton.isHidden = true
                    self.questionTxt.frame.size.width = self.view.frame.size.width-30
                }
                
                // Avatar • Fullname
                if isAnonymuos {
                    self.avatarImg.image = UIImage(named: "anonymous_avatar")
                    self.fullnameLabel.text = "Anonymous"
                } else {
                    self.getParseImage(object: userPointer, colName: USER_AVATAR, imageView: self.avatarImg)
                    self.fullnameLabel.text = "\(userPointer[USER_FULLNAME]!)"
                }
                
                // Question • Answers • Views
                self.questionTxt.text = "\(self.qObj[QUESTIONS_QUESTION]!)"
                let answers = self.qObj[QUESTIONS_ANSWERS] as! Int
                let views = self.qObj[QUESTIONS_VIEWS] as! Int
                self.answersViewsLabel.text = answers.rounded + " Answers • " + views.rounded + " Views"
                
                // Increase Views
                self.qObj.incrementKey(QUESTIONS_VIEWS, byAmount: 1)
                self.qObj.saveInBackground()
                
                
                // Edit Button
                if PFUser.current() != nil {
                    let currentUser = PFUser.current()!
                    if currentUser.objectId! == userPointer.objectId! {
                        self.editQuestionButton.isHidden = false
                    } else {
                        self.editQuestionButton.isHidden = true
                    }
                } else { self.editQuestionButton.isHidden = true }
                
                
                // Call query
                self.callQuery()
                
            // error
            } else { self.simpleAlert("\(error!.localizedDescription)")
        }})// ./ userPointer
    }
    
    
    
    
    // ------------------------------------------------
    // MARK: - CALL QUERY
    // ------------------------------------------------
    func callQuery() {
        showHUD()
        answersArray = [PFObject]()
        skip = 0
        queryAnswers()
    }
    
    
    // ------------------------------------------------
    // MARK: - QUERY ANSWERS
    // ------------------------------------------------
    func queryAnswers() {
        let query = PFQuery(className: ANSWERS_CLASS_NAME)
        query.whereKey(ANSWERS_QUESTION_POINTER, equalTo: qObj)
        if PFUser.current() != nil {
            let currentUser = PFUser.current()!
            query.whereKey(ANSWERS_REPORTED_BY, notContainedIn: [currentUser.objectId!])
        }
        query.order(byDescending: ANSWERS_CREATED_AT)
        query.skip = skip
        
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                if objects!.count == 0 {
                    self.hideHUD()
                    self.answersTableView.isHidden = true
                } else {
                    for i in 0..<objects!.count { self.answersArray.append(objects![i]) }
                    if (objects!.count == 100) {
                        self.skip = self.skip + 100
                        self.queryAnswers()
                    } else {
                        self.hideHUD()
                        self.answersTableView.isHidden = false
                        
                        // Check for BestAnswer
                        for i in 0..<self.answersArray.count {
                            var aObj = PFObject(className: ANSWERS_CLASS_NAME)
                            aObj = self.answersArray[i]
                            let isBestAnswer = aObj[ANSWERS_IS_BEST] as! Bool
                            if isBestAnswer {
                                self.answersArray.insert(aObj, at: 0)
                                self.answersArray.remove(at: i+1)
                                self.answersTableView.reloadData()
                            }
                            if i == self.answersArray.count-1 { self.answersTableView.reloadData() }
                        }// ./ For
                    }
                    
                }// ./ If
            // error
            } else { self.hideHUD(); self.simpleAlert("\(error!.localizedDescription)")
        }}
        
        let countQuery = PFQuery(className: ANSWERS_CLASS_NAME)
        countQuery.whereKey(ANSWERS_QUESTION_POINTER, equalTo: qObj)
        countQuery.countObjectsInBackground { (totalCount, error) in
            if let err = error {
                print(err.localizedDescription)
            } else {
                print("Count of answers \(totalCount)")
                let agreeCountQuery = PFQuery(className: ANSWERS_CLASS_NAME)
                agreeCountQuery.whereKey(ANSWERS_QUESTION_POINTER, equalTo: self.qObj)
                agreeCountQuery.whereKey(ANSWERS_IS_AGREE, equalTo: true)
                agreeCountQuery.countObjectsInBackground { (agreeCount, error) in
                    if let err = error {
                        print(err.localizedDescription)
                    } else {
                        let agreePercentage = (agreeCount / totalCount) * 100
                        let disagreePercentage = 100 - agreePercentage
                        print("Count of agreed answers \(agreeCount) - Agree percentage \(agreePercentage)% | Disagree percentage \(disagreePercentage)%")
                    }
                }
            }
        }
    }
    
    
    
    // ------------------------------------------------
    // MARK: - SHOW DATA IN TABLEVIEW
    // ------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answersArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath) as! AnswerCell
        
        // Parse Obj
        var aObj = PFObject(className: ANSWERS_CLASS_NAME)
        aObj = answersArray[indexPath.row]
        
        // User Pointer
        let userPointer = aObj[ANSWERS_USER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                
                // isAnonymous
                let isAnonymous = aObj[ANSWERS_IS_ANONYMOUS] as! Bool
                
                // Avatar • Fullname
                if isAnonymous {
                    cell.avatarImg.image = UIImage(named: "anonymous_avatar")
                    cell.fullnameLabel.text = "Anonymous"
                } else {
                    self.getParseImage(object: userPointer, colName: USER_AVATAR, imageView: cell.avatarImg)
                    cell.fullnameLabel.text = "\(userPointer[USER_FULLNAME]!)"
                }
                
                // Answer Text
                cell.answerTxt.text = "\(aObj[ANSWERS_ANSWER]!)"
              
                // Image (optional)
                let imageFile = aObj[ANSWERS_IMAGE] as? PFFileObject
                if imageFile != nil {
                    cell.answerImgButton.isHidden = false
                    cell.answerTxt.frame.size.width = (self.view.frame.size.width-30) - 74
                    self.getParseImage(object: aObj, colName: ANSWERS_IMAGE, button: cell.answerImgButton)
                } else {
                    cell.answerImgButton.isHidden = true
                    cell.answerImgButton.imageView?.image = nil
                    cell.answerTxt.frame.size.width = self.view.frame.size.width-30
                }

                
                // Date
                let date = aObj.createdAt!
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "MMM dd, yyyy"
                cell.answeredLabel.text = "Answered " + dateFormat.string(from: date)
                
                // Likes
                let likes = aObj[ANSWERS_LIKES] as! Int
                cell.likesLabel.text = likes.rounded
                if PFUser.current() != nil {
                    let currentUser = PFUser.current()!
                    let likedBy = aObj[ANSWERS_LIKED_BY] as! [String]
                    if likedBy.contains(currentUser.objectId!) {
                        cell.likeButton.setBackgroundImage(UIImage(named: "liked_butt"), for: .normal)
                    } else {
                        cell.likeButton.setBackgroundImage(UIImage(named: "like_butt"), for: .normal)
                    }
                }
                
                // Dislikes
                let dislikes = aObj[ANSWERS_DISLIKES] as! Int
                cell.dislikesLabel.text = dislikes.rounded
                if PFUser.current() != nil {
                    let currentUser = PFUser.current()!
                    let dislikedBy = aObj[ANSWERS_DISLIKED_BY] as! [String]
                    if dislikedBy.contains(currentUser.objectId!) {
                        cell.dislikeButton.setBackgroundImage(UIImage(named: "disliked_butt"), for: .normal)
                    } else {
                        cell.dislikeButton.setBackgroundImage(UIImage(named: "dislike_butt"), for: .normal)
                    }
                }
                
                // Edit Button
                if PFUser.current() != nil {
                    let currentUser = PFUser.current()!
                    if currentUser.objectId! == userPointer.objectId! {
                        cell.editButton.isHidden = false
                    } else {
                        cell.editButton.isHidden = true
                    }
                } else { cell.editButton.isHidden = true }
                
                // Best Answer
                let isBestAnswer = aObj[ANSWERS_IS_BEST] as! Bool
                if isBestAnswer { cell.bestAnswerLabel.isHidden = false
                } else { cell.bestAnswerLabel.isHidden = true }
                
               
                // More Button
                let chars = cell.answerTxt.text.count
                if chars >= 160 { cell.moreButton.isHidden = false
                } else { cell.moreButton.isHidden = true }
                
                
                // Hide/Show setBestButton
                let questionHasBestAnswer = self.qObj[QUESTIONS_HAS_BEST_ANSWER] as! Bool
                
                if PFUser.current() != nil {
                    let currentUser = PFUser.current()!
                    
                    // questionUserPointer
                    let questionUserPointer = self.qObj[QUESTIONS_USER_POINTER] as! PFUser
                    questionUserPointer.fetchIfNeededInBackground(block: { (user, error) in
                        if error == nil {
                            if currentUser.objectId! == questionUserPointer.objectId! {
                                if questionHasBestAnswer { cell.setBestAnswerButton.isHidden = true
                                } else { cell.setBestAnswerButton.isHidden = false }
                            } else {
                                cell.setBestAnswerButton.isHidden = true
                            }
                        // error
                        } else { self.simpleAlert("\(error!.localizedDescription)")
                    }})// ./ questionUserPointer
                    
                } else { cell.setBestAnswerButton.isHidden = true }
                
                // Tags for Buttons
                cell.moreButton.tag = indexPath.row
                cell.likeButton.tag = indexPath.row
                cell.dislikeButton.tag = indexPath.row
                cell.setBestAnswerButton.tag = indexPath.row
                cell.reportButton.tag = indexPath.row
                cell.answerUserButton.tag = indexPath.row
                cell.answerImgButton.tag = indexPath.row
                cell.editButton.tag = indexPath.row

            // error
            } else { self.simpleAlert("\(error!.localizedDescription)")
        }})// ./ userPointer

    return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230
    }
    

    
    
    
    // ------------------------------------------------
    // MARK: - QUESTION IMAGE BUTTON
    // ------------------------------------------------
    @IBAction func questionImgButt(_ sender: Any) {
        imagePreviewView.frame.origin.y = 0
        imagePreview.image = questionImgButton.imageView!.image
    }
    
    // ------------------------------------------------
    // MARK: - ANSWER IMAGE BUTTON
    // ------------------------------------------------
    @IBAction func answerImgButt(_ sender: UIButton) {
        // Get Cell
        let indexP = IndexPath(row: sender.tag, section: 0)
        let cell = answersTableView.cellForRow(at: indexP) as! AnswerCell
        
        imagePreviewView.frame.origin.y = 0
        imagePreview.image = cell.answerImgButton.imageView!.image
    }
    
    // ------------------------------------------------
    // MARK: - DISMISS IMAGE PREVIEW BUTTON
    // ------------------------------------------------
    @IBAction func dismissImagePreviewButt(_ sender: Any) {
        imagePreviewView.frame.origin.y = view.frame.size.height
    }
    
    
    
    // ------------------------------------------------
    // MARK: - SHARE QUESTION BUTTON
    // ------------------------------------------------
    @IBAction func shareQuestionButt(_ sender: UIButton) {
        let messageStr = "Check out this question on our app called #\(APP_NAME): " + questionTxt.text!
        
        var img = UIImage()
        if questionImgButton.imageView?.image != nil { img = questionImgButton.imageView!.image! }
        
        let shareItems = [messageStr, img] as [Any]
        
        let vc = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        vc.excludedActivityTypes = [.print, .postToWeibo, .copyToPasteboard, .addToReadingList, .postToVimeo]
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad
            vc.modalPresentationStyle = .popover
            vc.popoverPresentationController?.sourceView = view
            vc.popoverPresentationController!.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            vc.popoverPresentationController?.permittedArrowDirections = []
            present(vc, animated: true, completion: nil)
        } else {
            // iPhone
            present(vc, animated: true, completion: nil)
        }
    }
    
    
    
    // ------------------------------------------------
    // MARK: - MORE BUTTON
    // ------------------------------------------------
    @IBAction func moreButt(_ sender: UIButton) {
        // Get Cell
        let indexP = IndexPath(row: sender.tag, section: 0)
        let cell = answersTableView.cellForRow(at: indexP) as! AnswerCell
        
        // Show data
        moreView.frame.origin.y = 202
        moreTextView.text = cell.answerTxt.text
        moreFullnameLabel.text = cell.fullnameLabel.text
        moreAvatarImg.image = cell.avatarImg.image
        moreAnsweredLabel.text = cell.answeredLabel.text
    }
    
    
    // ------------------------------------------------
    // MARK: - DISMISS MORE VIEW BUTTON
    // ------------------------------------------------
    @IBAction func dismissMoreViewButt(_ sender: Any) {
        moreView.frame.origin.y = view.frame.size.height
    }
    
    
    
    // ------------------------------------------------
    // MARK: - QUESTION USER BUTTON
    // ------------------------------------------------
    @IBAction func questionUserButt(_ sender: Any) {
        if PFUser.current() == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "Intro") as! Intro
            present(vc, animated: true, completion: nil)
        } else {
            let currentUser = PFUser.current()!
            
            // User Pointer
            let userPointer = qObj[QUESTIONS_USER_POINTER] as! PFUser
            userPointer.fetchIfNeededInBackground(block: { (user, error) in
                if error == nil {
                    let isAnonymous = self.qObj[QUESTIONS_IS_ANONYMOUS] as! Bool
                    if isAnonymous {
                        self.simpleAlert("You're not allowed to view this User's Profile")
                        
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
    }
    
    
    
    
    // ------------------------------------------------
    // MARK: - ANSWER USER BUTTON
    // ------------------------------------------------
    @IBAction func answerUserButt(_ sender: UIButton) {
        // Parse Obj
        var aObj = PFObject(className: ANSWERS_CLASS_NAME)
        aObj = answersArray[sender.tag]
        
        // USER IS NOT LOGGED IN...
        if PFUser.current() == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "Intro") as! Intro
            present(vc, animated: true, completion: nil)
            
        // USER IS LOGGED IN!
        } else {
            let currentUser = PFUser.current()!
            
            let isAnonymous = aObj[ANSWERS_IS_ANONYMOUS] as! Bool
            if isAnonymous {
                self.simpleAlert("You're not allowed to view this User's Profile")
                
            } else {
                // User Pointer
                let userPointer = aObj[ANSWERS_USER_POINTER] as! PFUser
                userPointer.fetchIfNeededInBackground(block: { (user, error) in
                    if error == nil {
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Account") as! Account
                        if userPointer.objectId! == currentUser.objectId! {
                            vc.isCurrentUser = true
                        } else {
                            vc.isCurrentUser = false
                            vc.userObj = userPointer
                        }
                        vc.showBackbutton = true
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    // error
                    } else { self.simpleAlert("\(error!.localizedDescription)")
                }})// ./ userPointer
                
            }// ./ If
        
        }// ./ IF
        
    }
    
    
    
    
    
    
    
    // ------------------------------------------------
    // MARK: - LIKE BUTTON
    // ------------------------------------------------
    @IBAction func likeButt(_ sender: UIButton) {
        // Parse Obj
        var aObj = PFObject(className: ANSWERS_CLASS_NAME)
        aObj = answersArray[sender.tag]
        
        // Cell
        let indexP = IndexPath(row: sender.tag, section: 0)
        let cell = answersTableView.cellForRow(at: indexP) as! AnswerCell
    
        
        // USER IS NOT LOGGED IN...
        if PFUser.current() == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "Intro") as! Intro
            present(vc, animated: true, completion: nil)
            
        // USER IS LOGGED IN!
        } else {
            let currentUser = PFUser.current()!
            var likedBy = aObj[ANSWERS_LIKED_BY] as! [String]
            
            // UNLIKE
            if likedBy.contains(currentUser.objectId!) {
                likedBy = likedBy.filter{$0 != currentUser.objectId!}
                aObj[ANSWERS_LIKED_BY] = likedBy
                aObj.incrementKey(ANSWERS_LIKES, byAmount: -1)
                aObj.saveInBackground()
                
                let likes = aObj[ANSWERS_LIKES] as! Int
                cell.likesLabel.text = likes.rounded
                
                sender.setBackgroundImage(UIImage(named: "like_butt"), for: .normal)
                
            // LIKE
            } else {
                likedBy.append(currentUser.objectId!)
                aObj[ANSWERS_LIKED_BY] = likedBy
                aObj.incrementKey(ANSWERS_LIKES, byAmount: 1)
                aObj.saveInBackground()
                
                let likes = aObj[ANSWERS_LIKES] as! Int
                cell.likesLabel.text = likes.rounded
                
                sender.setBackgroundImage(UIImage(named: "liked_butt"), for: .normal)

                // Send Push Notification
                let pushMess = "\(currentUser[USER_FULLNAME]!) liked your answer: \(aObj[ANSWERS_ANSWER]!)"
                sendPushNotification(parseObj: aObj, columnName: ANSWERS_USER_POINTER, pushMessage: pushMess)
            }
        }// ./ If
    }
    
    
    
    // ------------------------------------------------
    // MARK: - DISLIKE BUTTON
    // ------------------------------------------------
    @IBAction func dislikeButt(_ sender: UIButton) {
        // Parse Obj
        var aObj = PFObject(className: ANSWERS_CLASS_NAME)
        aObj = answersArray[sender.tag]
        
        // Cell
        let indexP = IndexPath(row: sender.tag, section: 0)
        let cell = answersTableView.cellForRow(at: indexP) as! AnswerCell
        
        
        // USER IS NOT LOGGED IN...
        if PFUser.current() == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "Intro") as! Intro
            present(vc, animated: true, completion: nil)
            
            // USER IS LOGGED IN!
        } else {
            let currentUser = PFUser.current()!
            var dislikedBy = aObj[ANSWERS_DISLIKED_BY] as! [String]
            
            // UN-DISLIKE
            if dislikedBy.contains(currentUser.objectId!) {
                dislikedBy = dislikedBy.filter{$0 != currentUser.objectId!}
                aObj[ANSWERS_DISLIKED_BY] = dislikedBy
                aObj.incrementKey(ANSWERS_DISLIKES, byAmount: -1)
                aObj.saveInBackground()
                
                let dislikes = aObj[ANSWERS_DISLIKES] as! Int
                cell.dislikesLabel.text = dislikes.rounded
                
                sender.setBackgroundImage(UIImage(named: "dislike_butt"), for: .normal)
                
            // DISLIKE
            } else {
                dislikedBy.append(currentUser.objectId!)
                aObj[ANSWERS_DISLIKED_BY] = dislikedBy
                aObj.incrementKey(ANSWERS_DISLIKES, byAmount: 1)
                aObj.saveInBackground()
                
                let dislikes = aObj[ANSWERS_DISLIKES] as! Int
                cell.dislikesLabel.text = dislikes.rounded
                
                sender.setBackgroundImage(UIImage(named: "disliked_butt"), for: .normal)
            }
        }// ./ If
    }
    
    
    
    // ------------------------------------------------
    // MARK: - REPORT ANSWER BUTTON
    // ------------------------------------------------
    @IBAction func reportAnswerButt(_ sender: UIButton) {
        // Parse Obj
        var aObj = PFObject(className: ANSWERS_CLASS_NAME)
        aObj = answersArray[sender.tag]
        
        if PFUser.current() == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "Intro") as! Intro
            present(vc, animated: true, completion: nil)
        } else {
            let currentUser = PFUser.current()!
            var reportedBy = aObj[ANSWERS_REPORTED_BY] as! [String]
            
            // Fire alert
            let alert = UIAlertController(title: APP_NAME,
                message: "Do you want to report this Answer as inappropriate/abusive to the admin?",
                preferredStyle: .alert)
            
            // Report Answer
            let report = UIAlertAction(title: "Report Answer", style: .destructive, handler: { (action) -> Void in
                reportedBy.append(currentUser.objectId!)
                aObj[ANSWERS_REPORTED_BY] = reportedBy
                aObj.saveInBackground(block: { (succ, error) in
                    if error == nil {
                        
                        // Fire alert2
                        let alert2 = UIAlertController(title: APP_NAME,
                            message: "Thanks for reporting this Answer. We'll take action within 24h",
                            preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                            self.callQuery()
                        })
                        alert2.addAction(ok)
                        self.present(alert2, animated: true, completion: nil)
                        
                    // error
                    } else { self.simpleAlert("\(error!.localizedDescription)") }
                })
            })
            alert.addAction(report)
            
            // Cancel button
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }// ./ If
    }
    
    
    
    
    // ------------------------------------------------
    // MARK: - REPORT QUESTION BUTTON
    // ------------------------------------------------
    @IBAction func reportQuestionButt(_ sender: UIButton) {
        if PFUser.current() == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "Intro") as! Intro
            present(vc, animated: true, completion: nil)
        } else {
            let currentUser = PFUser.current()!
            var reportedBy = qObj[QUESTIONS_REPORTED_BY] as! [String]
            
            // Fire alert
            let alert3 = UIAlertController(title: APP_NAME,
                message: "What do you want to report to the Admin?",
                preferredStyle: .actionSheet)
            
            // REPORT QUESTION ------------------------------------------------------------------------
            let reportQuestion = UIAlertAction(title: "Report Question", style: .default, handler: { (action) -> Void in
                // Fire alert
                let alert = UIAlertController(title: APP_NAME,
                    message: "Do you want to report this Question as inappropriate/abusive to the admin?",
                    preferredStyle: .alert)
                
                // Report Question
                let report = UIAlertAction(title: "Report Question", style: .destructive, handler: { (action) -> Void in
                    reportedBy.append(currentUser.objectId!)
                    self.qObj[QUESTIONS_REPORTED_BY] = reportedBy
                    self.qObj.saveInBackground(block: { (succ, error) in
                        if error == nil {
                            
                            // Fire alert2
                            let alert2 = UIAlertController(title: APP_NAME,
                                                           message: "Thanks for reporting this Question. We'll take action within 24h",
                                                           preferredStyle: .alert)
                            let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                                mustReload = true
                                _ = self.navigationController?.popViewController(animated: true)
                            })
                            alert2.addAction(ok)
                            self.present(alert2, animated: true, completion: nil)
                            
                            // error
                        } else { self.simpleAlert("\(error!.localizedDescription)") }
                    })
                })
                alert.addAction(report)
                
                // Cancel button
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            })
            alert3.addAction(reportQuestion)
            
            
            
            
            
            // REPORT USER ------------------------------------------------------------------------
            let reportUser = UIAlertAction(title: "Report User", style: .default, handler: { (action) -> Void in
                
                // User Pointer
                let userPointer = self.qObj[QUESTIONS_USER_POINTER] as! PFUser
                userPointer.fetchIfNeededInBackground(block: { (user, error) in
                    if error == nil {
                        
                        var uReportedBy = userPointer[USER_REPORTED_BY] as! [String]
                        uReportedBy.append(currentUser.objectId!)
                        self.showHUD()
                
                        let request = [
                            "userId" : userPointer.objectId!,
                            "reportedBy" : uReportedBy
                        ] as [String : Any]
                        
                        PFCloud.callFunction(inBackground: "reportUser", withParameters: request as [String : Any], block: { (results, error) in
                            if error == nil {
                                self.hideHUD()
                                mustReload = true
                        
                                // 1. Query all Questions of this user and report them (if any)
                                let query = PFQuery(className: QUESTIONS_CLASS_NAME)
                                query.whereKey(QUESTIONS_USER_POINTER, equalTo: userPointer)
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
                                        query.whereKey(ANSWERS_USER_POINTER, equalTo: userPointer)
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
                                }}// ./ query
                        
                        
                                // Fire alert
                                let alert4 = UIAlertController(title: APP_NAME,
                                    message: "Thanks for reporting @\(userPointer[USER_USERNAME]!) to us. We'll take action for it withint 24h.",
                                    preferredStyle: .alert)
                                
                                let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                                    // Back to Home
                                    let tbc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
                                    tbc.selectedIndex = 0
                                    self.present(tbc, animated: false, completion: nil)
                                })
                                alert4.addAction(ok)
                                self.present(alert4, animated: true, completion: nil)
                                
                            // error
                            } else { self.hideHUD(); self.simpleAlert("\(error!.localizedDescription)") }
                        })// ./ CloudCode
                    
                    // error
                    } else { self.simpleAlert("\(error!.localizedDescription)")
                }})// ./ userPointer
            })
            alert3.addAction(reportUser)
            
        
            
            // Cancel button
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
            alert3.addAction(cancel)
            
            alert3.view.tintColor = MAIN_COLOR
            if UIDevice.current.userInterfaceIdiom == .pad {
                // iPad
                alert3.modalPresentationStyle = .popover
                alert3.popoverPresentationController?.sourceView = self.view
                alert3.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                alert3.popoverPresentationController?.permittedArrowDirections = []
                self.present(alert3, animated: true, completion: nil)
            } else {
                // iPhone
                self.present(alert3, animated: true, completion: nil)
            }
            
            
            
        }// ./ If
    }
    
    
    
    
    
    // ------------------------------------------------
    // MARK: - EDIT ANSWER BUTTON
    // ------------------------------------------------
    @IBAction func editAnswerButt(_ sender: UIButton) {
        // Parse Obj
        var aObj = PFObject(className: ANSWERS_CLASS_NAME)
        aObj = answersArray[sender.tag]
        
        let isAnonymous = aObj[ANSWERS_IS_ANONYMOUS] as! Bool
        
        // Fire alert
        let alert = UIAlertController(title: APP_NAME,
            message: "Select option",
            preferredStyle: .actionSheet)
        
        // Delete Answer
        let delete = UIAlertAction(title: "Delete Answer", style: .destructive, handler: { (action) -> Void in
            self.showHUD()
            aObj.deleteInBackground(block: { (succ, error) in
                if error == nil {
                    self.hideHUD()
                    self.qObj.incrementKey(QUESTIONS_ANSWERS, byAmount: -1)
                    self.qObj.saveInBackground()
                    mustReload = true
                    
                    // Recall query
                    self.showQuestionDetails()
                // error
                } else { self.hideHUD(); self.simpleAlert("\(error!.localizedDescription)") }
            })
        })
        alert.addAction(delete)
        
        
        // Edit Answer
        let edit = UIAlertAction(title: "Edit Answer", style: .default, handler: { (action) -> Void in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PostScreen") as! PostScreen
            vc.isAnonymous = isAnonymous
            vc.isQuestion = false
            vc.isEditingMode = true
            vc.qObj = self.qObj
            vc.aObj = aObj
            self.present(vc, animated: true, completion: nil)
        })
        alert.addAction(edit)
        
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
        alert.addAction(cancel)
        
        alert.view.tintColor = MAIN_COLOR
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad
            alert.modalPresentationStyle = .popover
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            alert.popoverPresentationController?.permittedArrowDirections = []
            self.present(alert, animated: true, completion: nil)
        } else {
            // iPhone
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    
    // ------------------------------------------------
    // MARK: - EDIT QUESTION BUTTON
    // ------------------------------------------------
    @IBAction func editQuestionButt(_ sender: UIButton) {
        let isAnonymous = qObj[QUESTIONS_IS_ANONYMOUS] as! Bool
        
        // Fire alert
        let alert = UIAlertController(title: APP_NAME,
            message: "Select option",
            preferredStyle: .actionSheet)
        
        // Delete Question
        let delete = UIAlertAction(title: "Delete Question", style: .default, handler: { (action) -> Void in
           self.showHUD()
            self.qObj.deleteInBackground(block: { (succ, error) in
                if error == nil {
                    self.hideHUD()
                    mustReload = true
                    
                    // Delete all related Answers in background
                    let query = PFQuery(className: ANSWERS_CLASS_NAME)
                    query.whereKey(ANSWERS_QUESTION_POINTER, equalTo: self.qObj)
                    query.findObjectsInBackground { (objects, error) in
                        if error == nil {
                            for i in 0..<objects!.count {
                                var aObj = PFObject(className: ANSWERS_CLASS_NAME)
                                aObj = objects![i]
                                aObj.deleteInBackground()
                            }
                        // error
                        } else { self.hideHUD(); self.simpleAlert("\(error!.localizedDescription)")
                    }}
                    
                    _ = self.navigationController?.popViewController(animated: true)
                // error
                } else { self.hideHUD(); self.simpleAlert("\(error!.localizedDescription)") }
            })
        })
        alert.addAction(delete)
        
        
        // Edit question
        let edit = UIAlertAction(title: "Edit Question", style: .default, handler: { (action) -> Void in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PostScreen") as! PostScreen
            vc.isAnonymous = isAnonymous
            vc.isQuestion = true
            vc.isEditingMode = true
            vc.qObj = self.qObj
            self.present(vc, animated: true, completion: nil)
        })
        alert.addAction(edit)
       
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
        alert.addAction(cancel)
        
        alert.view.tintColor = MAIN_COLOR
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad
            alert.modalPresentationStyle = .popover
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            alert.popoverPresentationController?.permittedArrowDirections = []
            self.present(alert, animated: true, completion: nil)
        } else {
            // iPhone
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    
    // ------------------------------------------------
    // MARK: - SET BEST ANSWER BUTTON
    // ------------------------------------------------
    @IBAction func setBestAnswerButt(_ sender: UIButton) {
        // Parse Obj
        var aObj = PFObject(className: ANSWERS_CLASS_NAME)
        aObj = answersArray[sender.tag]
        
        if PFUser.current() == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "Intro") as! Intro
            present(vc, animated: true, completion: nil)
        } else {
            let currentUser = PFUser.current()!
                                 
            // userPointer (Question)
            let userPointer = qObj[QUESTIONS_USER_POINTER] as! PFUser
            userPointer.fetchIfNeededInBackground(block: { (user, error) in
                if error == nil {

                    // CURRENT USER OWNS THIS QUESTION!
                    if userPointer.objectId! == currentUser.objectId! {
                        // Fire alert
                        let alert = UIAlertController(title: APP_NAME,
                        message: "Are you sure you want to set this answer as best? Once set, you can no longer change it.",
                        preferredStyle: .alert)
                        
                        // Yes
                        let yes = UIAlertAction(title: "Best Answer", style: .default, handler: { (action) -> Void in
                            aObj[ANSWERS_IS_BEST] = true
                            aObj.saveInBackground { (succ, error) in
                                self.qObj[QUESTIONS_HAS_BEST_ANSWER] = true
                                self.qObj.saveInBackground()
                                self.callQuery()
                            }
                        })
                        alert.addAction(yes)
                        
                        // Cancel button
                        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
                        alert.addAction(cancel)
                        self.present(alert, animated: true, completion: nil)
                        
                        
                    // CURRENT USER DOESN'T OWN THIS QUESTION...
                    } else { self.simpleAlert("Only the User who made this question is allowed to choose the best answer!") }
                   
                // error
                } else { self.simpleAlert("\(error!.localizedDescription)")
            }})// ./ userPointer
            
        }// ./ If
    }
    
    
    
    
    // ------------------------------------------------
    // MARK: - POST ANSWER BUTTON
    // ------------------------------------------------
    @IBAction func postAnswersButt(_ sender: Any) {
        // USER IS NOT LOGGED IN...
        if PFUser.current() == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "Intro") as! Intro
            present(vc, animated: true, completion: nil)
            
        // USER IS LOGGED IN!
        } else {
            
            // Fire alert
            let alert = UIAlertController(title: APP_NAME,
                message: "How do you want to answer to this question?",
                preferredStyle: .actionSheet)
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "PostScreen") as! PostScreen
            
            // Ask with name
            let ask = UIAlertAction(title: "Answer with name", style: .default, handler: { (action) -> Void in
                vc.isAnonymous = false
                vc.isQuestion = false
                vc.qObj = self.qObj
                self.present(vc, animated: true, completion: nil)
            })
            alert.addAction(ask)
            
            // Ask anonymously
            let askAnonymously = UIAlertAction(title: "Answer anonymously", style: .default, handler: { (action) -> Void in
                vc.isAnonymous = true
                vc.isQuestion = false
                vc.qObj = self.qObj
                self.present(vc, animated: true, completion: nil)
            })
            alert.addAction(askAnonymously)
            
            
            // Cancel button
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
            alert.addAction(cancel)
            
            alert.view.tintColor = MAIN_COLOR
            if UIDevice.current.userInterfaceIdiom == .pad {
                // iPad
                alert.modalPresentationStyle = .popover
                alert.popoverPresentationController?.sourceView = self.view
                alert.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                alert.popoverPresentationController?.permittedArrowDirections = []
                self.present(alert, animated: true, completion: nil)
            } else {
                // iPhone
                self.present(alert, animated: true, completion: nil)
            }
            
        }// ./ If
    }
    
    
    // ------------------------------------------------
    // MARK: - BACK BUTTON
    // ------------------------------------------------
    @IBAction func backButt(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    

}// /. end
