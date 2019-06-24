/*==================================================
 Askk
 
 © XScoder 2019
 All Rights reserved
 
 /*
 RE-SELLING THIS SOURCE CODE TO ANY ONLINE MARKETPLACE IS A SERIOUS COPYRIGHT INFRINGEMENT.
 YOU WILL BE LEGALLY PROSECUTED
 */
=====================================================*/

import UIKit
import Parse

class PostScreen: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    /*--- VIEWS ---*/
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postTxt: UITextView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var attachmentImg: UIImageView!
    @IBOutlet weak var addimageButton: UIButton!
    @IBOutlet weak var removePictureButton: UIButton!
    
    

    /*-- VARIABLES ---*/
    var qObj = PFObject(className: QUESTIONS_CLASS_NAME)
    var aObj = PFObject(className: ANSWERS_CLASS_NAME)
    var isAnonymous = false
    var isQuestion = false
    var isEditingMode = false
    
    
    
    // ------------------------------------------------
    // MARK: - VIEW DID LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("IS EDITING MODE: \(isEditingMode)")
        
        // Layout
        removePictureButton.isHidden = true
        
        
        // IT'S A QUESTION
        if isQuestion {
            if isAnonymous { titleLabel.text = "Ask something (anonymous)"
            } else { titleLabel.text = "Ask something" }
           
            
        // IT'S AN ANSWER
        } else {
            if isAnonymous { titleLabel.text = "Give an answer (anonymous)"
            } else { titleLabel.text = "Give an answer" }
            postTitleLabel.text = "\(qObj[QUESTIONS_QUESTION]!)"
        }
        
        
        // IS EDITING MODE
        if isEditingMode {
            postTxt.backgroundColor = .white
            
            if isQuestion {
                postTxt.text = "\(qObj[QUESTIONS_QUESTION]!)"
                let imageFile = qObj[QUESTIONS_IMAGE] as? PFFileObject
                if imageFile != nil {
                    removePictureButton.isHidden = false
                    getParseImage(object: qObj, colName: QUESTIONS_IMAGE, imageView: attachmentImg)
                }
            } else {
                postTxt.text = "\(aObj[ANSWERS_ANSWER]!)"
                let imageFile = aObj[ANSWERS_IMAGE] as? PFFileObject
                if imageFile != nil {
                    removePictureButton.isHidden = false
                    getParseImage(object: aObj, colName: ANSWERS_IMAGE, imageView: attachmentImg)
                }
            }
        }
        
        // Show keyboard
        postTxt.becomeFirstResponder()
        
        
        // Keyboard toolbar
        let toolbar = UIView(frame: CGRect(x: 0, y: view.frame.size.height+44, width: view.frame.size.width, height: 44))
        toolbar.backgroundColor = .white
        
        let doneButt = UIButton(frame: CGRect(x: toolbar.frame.size.width - 60, y: 0, width: 44, height: 44))
        doneButt.setBackgroundImage(UIImage(named: "dismiss_keyboard_butt"), for: .normal)
        doneButt.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
        toolbar.addSubview(doneButt)
        
        postTxt.inputAccessoryView = toolbar
        postTxt.delegate = self
    }
    
    
    
    
    // ------------------------------------------------
    // MARK: - POST QUESTION/ANSWER BUTTON
    // ------------------------------------------------
    @IBAction func postButt(_ sender: Any) {
        if postTxt.text != "" {
            let currentUser = PFUser.current()!
            
            // POST A QUESTION
            if isQuestion {
                
                // Fire alert
                let alert = UIAlertController(title: APP_NAME,
                    message: "Select a Category",
                    preferredStyle: .actionSheet)
                
                var tempCatArr = categoriesArray
                for _ in 0..<3 { tempCatArr.remove(at: 0) }
                var tempColorsArr = colorsArray
                for _ in 0..<3 { tempColorsArr.remove(at: 0) }
                
                for i in 0..<tempCatArr.count {
                    let category = UIAlertAction(title: tempCatArr[i].uppercased(), style: .default, handler: { (action) -> Void in
                        
                        self.showHUD()
                        self.dismissKeyboard()
                        
                        // Parse Obj (New)
                        if !self.isEditingMode {
                            self.qObj = PFObject(className: QUESTIONS_CLASS_NAME)
                            self.qObj[QUESTIONS_ANSWERS] = 0
                            self.qObj[QUESTIONS_VIEWS] = 0
                            self.qObj[QUESTIONS_REPORTED_BY] = [String]()
                            self.qObj[QUESTIONS_HAS_BEST_ANSWER] = false
                        }
                        
                        // Prepare data...
                        self.qObj[QUESTIONS_QUESTION] = self.postTxt.text!
                        self.qObj[QUESTIONS_COLOR] = tempColorsArr[i]
                        self.qObj[QUESTIONS_CATEGORY] = tempCatArr[i]
                        
                        if self.attachmentImg.image != nil {
                            self.saveParseImage(object: self.qObj, colName: QUESTIONS_IMAGE, imageView: self.attachmentImg)
                        } else {
                            self.qObj.remove(forKey: QUESTIONS_IMAGE)
                        }
                        
                        let noCommas = self.postTxt.text!.replacingOccurrences(of: ",", with: "")
                        let noDots = noCommas.replacingOccurrences(of: ".", with: "")
                        let noQuestMark = noDots.lowercased().replacingOccurrences(of: "?", with: "")
                        let keywords = noQuestMark.components(separatedBy: " ")
                        self.qObj[QUESTIONS_KEYWORDS] = keywords
                        
                        self.qObj[QUESTIONS_IS_ANONYMOUS] = self.isAnonymous
                        self.qObj[QUESTIONS_USER_POINTER] = currentUser
                        
                        // Save...
                        self.qObj.saveInBackground(block: { (succ, error) in
                            if error == nil {
                                self.hideHUD()
                                mustReload = true
                                self.dismiss(animated: true, completion: nil)
                                
                            // error
                            } else { self.hideHUD(); self.simpleAlert("\(error!.localizedDescription)") }
                        })
                        
                    })
                    alert.addAction(category)
                    
                }// ./ For
                
                
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
                
                
                
            // POST AN ANSWER
            } else {
                showHUD()
                dismissKeyboard()
                
                // Parse Obj (New)
                if !isEditingMode {
                    aObj = PFObject(className: ANSWERS_CLASS_NAME)
                    aObj[ANSWERS_LIKES] = 0
                    aObj[ANSWERS_DISLIKES] = 0
                    aObj[ANSWERS_IS_BEST] = false
                    aObj[ANSWERS_LIKED_BY] = [String]()
                    aObj[ANSWERS_DISLIKED_BY] = [String]()
                    aObj[ANSWERS_REPORTED_BY] = [String]()
                }
                
                // Prepare data...
                aObj[ANSWERS_ANSWER] = self.postTxt.text!
                aObj[ANSWERS_QUESTION_POINTER] = qObj
                aObj[ANSWERS_USER_POINTER] = currentUser
                aObj[ANSWERS_IS_ANONYMOUS] = isAnonymous
                if self.attachmentImg.image != nil {
                    self.saveParseImage(object: aObj, colName: ANSWERS_IMAGE, imageView: self.attachmentImg)
                } else {
                    aObj.remove(forKey: ANSWERS_IMAGE)
                }
                
                // Save...
                aObj.saveInBackground(block: { (succ, error) in
                    if error == nil {
                        
                        // Send Push Notification
                        var userFullname = ""
                        if !self.isAnonymous { userFullname = "\(currentUser[USER_FULLNAME]!)"
                        } else { userFullname = "(Anonymous)" }
                        let pushMess = userFullname + " answered to your question: \(self.qObj[QUESTIONS_QUESTION]!)"
                        self.sendPushNotification(parseObj: self.qObj, columnName: QUESTIONS_USER_POINTER, pushMessage: pushMess)
                        
                        // increment Question's answers
                        if !self.isEditingMode {
                            self.qObj.incrementKey(QUESTIONS_ANSWERS, byAmount: 1)
                            self.qObj.saveInBackground()
                        }
                        
                        self.hideHUD()
                        mustReload = true
                        self.dismiss(animated: true, completion: nil)
                        
                    // error
                    } else { self.hideHUD(); self.simpleAlert("\(error!.localizedDescription)") }
                })
                
                
            }// ./ If
          
            
        // postTxt is empty!
        } else { simpleAlert("Please type something!") }// ./ If
    }
    
    
    
    // ------------------------------------------------
    // MARK: - ADD IMAGE BUTTON
    // ------------------------------------------------
    @IBAction func addImageButt(_ sender: Any) {
        dismissKeyboard()
        
        // Fire alert
        let alert = UIAlertController(title: APP_NAME,
            message: "Select source",
            preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Take a picture", style: .default, handler: { (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        alert.addAction(camera)
        
        let library = UIAlertAction(title: "Pick from Library", style: .default, handler: { (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        alert.addAction(library)
        
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
    // MARK: - IMAGE PICKER DELEGATE
    // ------------------------------------------------
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            attachmentImg.image = scaleImageToMaxWidth(image: image, newWidth: 600)
        }
        removePictureButton.isHidden = false
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    // ------------------------------------------------
    // MARK: - REMOVE PICTURE BUTTON
    // ------------------------------------------------
    @IBAction func removePictureButt(_ sender: Any) {
        if attachmentImg.image != nil {
            attachmentImg.image = nil
            removePictureButton.isHidden = true
        }
    }
    
    
    
    
    // ------------------------------------------------
    // MARK: - TEXTVIEW DELEGATES
    // ------------------------------------------------
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let chars = newText.count
        if chars != 0 { textView.backgroundColor = .white
        } else { textView.backgroundColor = .clear }
        
    return true
    }
    
    
    
    // ------------------------------------------------
    // MARK: - DISMISS KEYBOARD
    // ------------------------------------------------
    @objc func dismissKeyboard() {
        postTxt.resignFirstResponder()
    }
    
    
    // ------------------------------------------------
    // MARK: - DISMISS BUTTON
    // ------------------------------------------------
    @IBAction func dismissButt(_ sender: Any) {
        dismissKeyboard()
        dismiss(animated: true, completion: nil)
    }
    
}// ./ end
