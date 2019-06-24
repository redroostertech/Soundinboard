import UIKit
import Parse
import CoreLocation
import GoogleMobileAds
import AudioToolbox

class Home: UIViewController,
  GADInterstitialDelegate {

    @IBOutlet private weak var noResultsView: UIView!
    @IBOutlet private weak var questionsTableView: UITableView!
    @IBOutlet private weak var categoriesScrollView: UIScrollView!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var searchTextField: UITextField!

    var searchTxt = ""
    var skip = 0
    var questionsArray = [PFObject]()
    var selectedCategory = categoriesArray[0]

    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.addLeftPadding(withWidth: 28)
        searchTextField.addRightPadding(withWidth: 28)
        searchTextField.layer.cornerRadius = 18
        
        // Keyboard toolbar
        let toolbar = UIView(frame: CGRect(x: 0, y: view.frame.size.height + 44, width: view.frame.size.width, height: 44))
        toolbar.backgroundColor = .white
        
        let doneButt = UIButton(frame: CGRect(x: toolbar.frame.size.width - 60, y: 0, width: 44, height: 44))
        doneButt.setBackgroundImage(UIImage(named: "dismiss_keyboard_butt"), for: .normal)
        doneButt.addTarget(self, action: #selector(dismisskeyboard), for: .touchUpInside)
        toolbar.addSubview(doneButt)
        
        searchTextField.inputAccessoryView = toolbar
        searchTextField.delegate = self

        categoryLabel.text = categoriesArray[0].uppercased()
        
        setupCategoriesScrollView()
        
        callQuery()
    }

    override func viewDidAppear(_ animated: Bool) {
      if let user = PFUser.current(), let username = user.username, let userid = user.objectId {
        ParseModule.shared.register(username: username, userID: userid)
      }
      if mustReload {
        mustReload = false
        callQuery()
      }
    }

    @objc func categoryButt(_ sender:UIButton) {
        categoryLabel.text = categoriesArray[sender.tag].uppercased()
        selectedCategory = categoriesArray[sender.tag]
        
        if selectedCategory == categoriesArray[0] ||
            selectedCategory == categoriesArray[1] ||
            selectedCategory == categoriesArray[2] {
            categoryLabel.textColor = .black
        } else {
          categoryLabel.textColor = UIColor.hexValue(hex: colorsArray[sender.tag])
        }
        searchTxt = ""
        searchTextField.text = ""

        callQuery()
    }

    func callQuery() {
        showHUD()
        skip = 0
        questionsArray = [PFObject]()
        questionsTableView.reloadData()
        queryQuestions()
    }

    func queryQuestions() {
        if searchTxt != "" { selectedCategory = "" }
        
        let query = PFQuery(className: QUESTIONS_CLASS_NAME)
        
        if PFUser.current() != nil {
            let currentUser = PFUser.current()!
            query.whereKey(QUESTIONS_REPORTED_BY, notContainedIn: [currentUser.objectId!])
        }

        if selectedCategory == categoriesArray[0] {
            query.order(byDescending: QUESTIONS_CREATED_AT)
            query.limit = 100

        } else if selectedCategory == categoriesArray[1] {
            query.order(byDescending: QUESTIONS_ANSWERS)
            query.whereKey(QUESTIONS_ANSWERS, greaterThanOrEqualTo: 2)
            query.limit = 100

        } else if selectedCategory == categoriesArray[2] {
            query.order(byDescending: QUESTIONS_ANSWERS)
            query.whereKey(QUESTIONS_ANSWERS, equalTo: 0)

        } else {
            if selectedCategory != "" { 
                query.whereKey(QUESTIONS_CATEGORY, equalTo: selectedCategory)
                query.order(byDescending: QUESTIONS_CREATED_AT)
            }
        }

        if searchTxt != "" {
            let keywords = searchTxt.lowercased().components(separatedBy: " ")
            query.whereKey(QUESTIONS_KEYWORDS, containedIn: keywords)
            query.order(byDescending: QUESTIONS_CREATED_AT)
        }
        
        query.skip = skip
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                // NO Questions...
                if objects!.count == 0 {
                    self.hideHUD()
                    self.questionsTableView.isHidden = true
                    
                // There are Questions!
                } else {
                    self.questionsTableView.isHidden = false
                    
                    for i in 0..<objects!.count { self.questionsArray.append(objects![i]) }
                    if (objects!.count == 100) {
                        self.skip = self.skip + 100
                        self.queryQuestions()
                    } else {
                        self.hideHUD()
                        self.questionsTableView.reloadData()
                        
                        if self.searchTxt != "" {
                            self.categoryLabel.text = "FOUND " + self.questionsArray.count.rounded + " ANSWERS"
                            self.categoryLabel.textColor = .black
                        }
                    }
                }// ./ If
            // error
            } else { self.hideHUD(); self.simpleAlert("\(error!.localizedDescription)")
        }}
    }

  @IBAction func postQuestionButt(_ sender: Any) {
    // USER IS NOT LOGGED IN...
    if PFUser.current() == nil {
      let vc = storyboard?.instantiateViewController(withIdentifier: "Intro") as! Intro
      present(vc, animated: true, completion: nil)

      // USER IS LOGGED IN!
    } else {

      // Fire alert
      let alert = UIAlertController(title: APP_NAME,
                                    message: "How do you want to ask a question?",
                                    preferredStyle: .actionSheet)

      let vc = storyboard?.instantiateViewController(withIdentifier: "PostScreen") as! PostScreen

      // Ask with name
      let ask = UIAlertAction(title: "Ask with name", style: .default, handler: { (action) -> Void in
        vc.isAnonymous = false
        vc.isQuestion = true
        self.present(vc, animated: true, completion: nil)
      })
      alert.addAction(ask)

      // Ask anonymously
      let askAnonymously = UIAlertAction(title: "Ask anonymously", style: .default, handler: { (action) -> Void in
        vc.isAnonymous = true
        vc.isQuestion = true
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

  @objc func dismisskeyboard() {
    searchTextField.resignFirstResponder()
  }
}

// MARK: -
extension Home {
  func setupCategoriesScrollView() {
    var X: CGFloat = 0
    let Y: CGFloat = 0
    let W: CGFloat = 80
    let H: CGFloat = 72
    let G: CGFloat = 10
    var counter = 0

    for i in 0..<categoriesArray.count {
      counter = i

      // Background View
      let aView = UIView(frame: CGRect(x: X, y: Y, width: W, height: H))

      // Button
      let aButt = UIButton(type: .custom)
      aButt.frame = CGRect(x: 18, y: 8, width: 44, height: 44)
      aButt.tag = i
      aButt.setBackgroundImage(UIImage(named: "\(categoriesArray[i])"), for: .normal)
      aButt.addTarget(self, action: #selector(categoryButt), for: .touchUpInside)
      aButt.clipsToBounds = true
      aButt.layer.cornerRadius = aButt.bounds.size.width/2
      aButt.backgroundColor = UIColor(hexString: colorsArray[i])
      aView.addSubview(aButt)

      // Label
      let aLabel = UILabel(frame: CGRect(x: 0, y: 52, width: W, height: 16))
      aLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 10)
      aLabel.textColor = UIColor.hexValue(hex: colorsArray[i])
      aLabel.textAlignment = .center
      aLabel.adjustsFontSizeToFitWidth = true
      aLabel.text = "\(categoriesArray[i])".uppercased()
      aView.addSubview(aLabel)

      // Add Views based on X
      X += W + G
      categoriesScrollView.addSubview(aView)
    }

    // Place Views into the ScrollView
    categoriesScrollView.contentSize = CGSize(width: W * CGFloat(counter+3), height: H)
  }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension Home: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath) as! QuestionCell
        
        // Parse Obj
        var qObj = PFObject(className: QUESTIONS_CLASS_NAME)
        qObj = questionsArray[indexPath.row]
        
        // User Pointer
        let userPointer = qObj[QUESTIONS_USER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                
                // isAnonymous
                let isAnonymuos = qObj[QUESTIONS_IS_ANONYMOUS] as! Bool
                
                // Color
                cell.backgroundColor = UIColor.hexValue(hex: "\(qObj[QUESTIONS_COLOR]!)")
                
                // Category Image • Name
                cell.categoryImg.image = UIImage(named: "\(qObj[QUESTIONS_CATEGORY]!)")
                cell.categoryLabel.text = "\(qObj[QUESTIONS_CATEGORY]!)".uppercased()
                
                // Fullname • Date
                let date = qObj.createdAt!
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "MMM dd, yyyy"
                if isAnonymuos {
                    cell.dateLabel.text = "By Anonymous • " +  dateFormat.string(from: date)
                } else {
                    cell.dateLabel.text = "By \(userPointer[USER_FULLNAME]!) • " +  dateFormat.string(from: date)
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
                var answersStr = ""
                if answers == 0 { answersStr = "No answer yet • "
                } else { answersStr = answers.rounded + " answers • " }
                cell.answeredByLabel.text = answersStr  + views.rounded + " views"
                
            // error
            } else { self.simpleAlert("\(error!.localizedDescription)")
        }})// ./ userPointer
        
    return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 146
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Parse Obj
        var qObj = PFObject(className: QUESTIONS_CLASS_NAME)
        qObj = questionsArray[indexPath.row]

        let vc = storyboard?.instantiateViewController(withIdentifier: "QuestionScreen") as! QuestionScreen
        vc.qObj = qObj
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - UITextFieldDelegate
extension Home: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField.text != "" {
      searchTxt = textField.text!
      callQuery()
      dismisskeyboard()
    } else { simpleAlert("Please type something!") }

    return true
  }
}
