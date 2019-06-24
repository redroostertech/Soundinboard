import UIKit
import Parse

class SignUp: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet private weak var usernameTxt: UITextField!
    @IBOutlet private weak var passwordTxt: UITextField!
    @IBOutlet private weak var emailTxt: UITextField!
    @IBOutlet private weak var fullnameTxt: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    @IBOutlet private weak var tosButton: UIButton!
    @IBOutlet private weak var logoImg: UIImageView!
    @IBOutlet private weak var checkboxButton: UIButton!

    var tosAccepted = false

    override func viewDidLoad() {
        super.viewDidLoad()
        logoImg.layer.cornerRadius = logoImg.bounds.size.width/2
        signUpButton.layer.cornerRadius = 22
        tableView.reloadData()
    }

    func dismissKeyboard() {
        usernameTxt.resignFirstResponder()
        passwordTxt.resignFirstResponder()
        emailTxt.resignFirstResponder()
        fullnameTxt.resignFirstResponder()
    }

    @IBAction func signupButt(_ sender: AnyObject) {
        dismissKeyboard()
        
        // YOU ACCEPTED THE TERMS OF SERVICE
        if tosAccepted {
            if usernameTxt.text == "" || passwordTxt.text == "" || emailTxt.text == "" || fullnameTxt.text == "" {
                simpleAlert("You must fill all fields to sign up on \(APP_NAME)")
                self.hideHUD()
                
            } else {
                showHUD()

                let currentUser = PFUser()
                currentUser.username = usernameTxt.text!.lowercased()
                currentUser.password = passwordTxt.text
                currentUser.email = emailTxt.text
                currentUser[USER_FULLNAME] = fullnameTxt.text
                currentUser[USER_REPORTED_BY] = [String]()
                
                // Save Avatar
                let imageData = UIImage(named: "default_avatar")!.jpegData(compressionQuality: 1.0)
                let imageFile = PFFileObject(name:"avatar.jpg", data:imageData!)
                currentUser[USER_AVATAR] = imageFile
            
                currentUser.signUpInBackground { (succeeded, error) -> Void in
                    if error == nil {
                        self.hideHUD()
                
                        let alert = UIAlertController(title: APP_NAME,
                            message: "We have sent you an email that contains a verification link.\nVerified users get more consideration from buyers and sellers!",
                            preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                            mustReload = true
                            self.dismiss(animated: false, completion: nil)
                        })
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                        
                    // error
                    } else { self.hideHUD(); self.simpleAlert("\(error!.localizedDescription)")
                }}
            }

        } else { simpleAlert("You must agree with our Terms of Service to Sign Up.") }
    }

    @IBAction func checkboxButt(_ sender: UIButton) {
        tosAccepted = true
        sender.setBackgroundImage(UIImage(named: "checkbox_on"), for: .normal)
    }

    @IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }

    @IBAction func dismissButt(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func tosButt(_ sender: AnyObject) {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "TermsOfService") as! TermsOfService
        present(aVC, animated: true, completion: nil)
    }

}

// MARK: - UITextFieldDelegate
extension SignUp: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == usernameTxt {  passwordTxt.becomeFirstResponder()  }
    if textField == passwordTxt {  emailTxt.becomeFirstResponder()     }
    if textField == emailTxt {  fullnameTxt.becomeFirstResponder()     }
    if textField == fullnameTxt {  dismissKeyboard()  }
    return true
  }
}
