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

class EditProfile: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    /*--- VIEWS ---*/
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var avatarImgButton: UIButton!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var locationTxt: UITextField!
    @IBOutlet weak var educationTxt: UITextField!
    
    
    
    
    // ------------------------------------------------
    // MARK: - VIEW DID LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        // Layout
        avatarImgButton.layer.cornerRadius = avatarImgButton.bounds.size.width/2
        avatarImgButton.imageView?.contentMode = .scaleAspectFill
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width,
                                                 height: 900)
        
        // Keyboard toolbar
        let toolbar = UIView(frame: CGRect(x: 0, y: view.frame.size.height+44, width: view.frame.size.width, height: 44))
        toolbar.backgroundColor = .white
        
        let doneButt = UIButton(frame: CGRect(x: toolbar.frame.size.width - 60, y: 0, width: 44, height: 44))
        doneButt.setBackgroundImage(UIImage(named: "dismiss_keyboard_butt"), for: .normal)
        doneButt.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
        toolbar.addSubview(doneButt)
        
        fullnameTxt.inputAccessoryView = toolbar
        usernameTxt.inputAccessoryView = toolbar
        emailTxt.inputAccessoryView = toolbar
        locationTxt.inputAccessoryView = toolbar
        educationTxt.inputAccessoryView = toolbar
        
        
        // Call function
        showUserDetails()
    }
    
    
    
    // ------------------------------------------------
    // MARK: - SHOW USER DETAILS
    // ------------------------------------------------
    func showUserDetails() {
        let currentUser = PFUser.current()!
        
        getParseImage(object: currentUser, colName: USER_AVATAR, button: avatarImgButton)
        fullnameTxt.text = "\(currentUser[USER_FULLNAME]!)"
        usernameTxt.text = "\(currentUser[USER_USERNAME]!)"
        emailTxt.text = "\(currentUser[USER_EMAIL]!)"
        if currentUser[USER_LOCATION] != nil { locationTxt.text = "\(currentUser[USER_LOCATION]!)" }
        if currentUser[USER_EDUCATION] != nil { educationTxt.text = "\(currentUser[USER_EDUCATION]!)" }
    }
    
    
    
    // ------------------------------------------------
    // MARK: - CHANGE AVATAR BUTTON
    // ------------------------------------------------
    @IBAction func avatarButt(_ sender: Any) {
        dismissKeyboard()
        let alert = UIAlertController(title: APP_NAME,
            message: "Select source",
            preferredStyle: .alert)
        
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
        
        present(alert, animated: true, completion: nil)
    }
    
    // ------------------------------------------------
    // MARK: - IMAGE PICKER DELEGATE
    // ------------------------------------------------
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            avatarImgButton.setImage(scaleImageToMaxWidth(image: image, newWidth: 300), for: .normal)
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // ------------------------------------------------
    // MARK: - TEXTFIELD DELEGATES
    // ------------------------------------------------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == fullnameTxt { usernameTxt.becomeFirstResponder() }
        if textField == usernameTxt { emailTxt.becomeFirstResponder() }
        if textField == emailTxt { locationTxt.becomeFirstResponder() }
        if textField == locationTxt { educationTxt.becomeFirstResponder() }
        if textField == educationTxt { dismissKeyboard() }
    return true
    }
    
    
    
    // ------------------------------------------------
    // MARK: - UPDATE PROFILE BUTTON
    // ------------------------------------------------
    @IBAction func updateProfileButt(_ sender: Any) {
        if fullnameTxt.text != "" || usernameTxt.text != "" || emailTxt.text != "" {
            dismissKeyboard()
            let currentUser = PFUser.current()!
            showHUD()
            
            // Prepare data
            currentUser[USER_FULLNAME] = fullnameTxt.text!
            currentUser[USER_USERNAME] = usernameTxt.text!
            currentUser[USER_EMAIL] = emailTxt.text!
            currentUser[USER_LOCATION] = locationTxt.text!
            currentUser[USER_EDUCATION] = educationTxt.text!

            // Avatar image
            let imageData = avatarImgButton.imageView!.image!.jpegData(compressionQuality: 1.0)
            let imageFile = PFFileObject(name:"avatar.jpg", data:imageData!)
            currentUser[USER_AVATAR] = imageFile
            
            // Save...
            currentUser.saveInBackground(block: { (succ, error) in
                if error == nil {
                    self.hideHUD()
                    self.simpleAlert("Your Profile has been updated.")
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                }})
            
        } else { simpleAlert("Full name, Username and Email address are mandatory.") }
    }
    
    
    
    
    // ------------------------------------------------
    // MARK: - DISMISS KEYBOARD
    // ------------------------------------------------
    @objc func dismissKeyboard() {
        fullnameTxt.resignFirstResponder()
        usernameTxt.resignFirstResponder()
        emailTxt.resignFirstResponder()
        locationTxt.resignFirstResponder()
        educationTxt.resignFirstResponder()
    }
    
    
    // ------------------------------------------------
    // MARK: - BACK BUTTON
    // ------------------------------------------------
    @IBAction func backButt(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    

}// ./ end
