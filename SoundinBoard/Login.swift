import UIKit
import Parse
import ParseFacebookUtilsV4

class Login: UITableViewController {
    
    @IBOutlet private weak var usernameTxt: UITextField!
    @IBOutlet private weak var passwordTxt: UITextField!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private var loginButtons: [UIButton]!
    @IBOutlet private weak var logoImg: UIImageView!
    @IBOutlet private weak var loginLabel: UILabel!

    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil { dismiss(animated: false, completion: nil) }
    }

    override func viewDidLoad() {
            super.viewDidLoad()
        loginLabel.text = "Log in to \(APP_NAME)"
        loginButton.layer.cornerRadius = 22
        logoImg.layer.cornerRadius = logoImg.bounds.size.width/2
    }

    func dismissKeyboard() {
        usernameTxt.resignFirstResponder()
        passwordTxt.resignFirstResponder()
    }

    @IBAction func loginButt(_ sender: AnyObject) {
        dismissKeyboard()
        showHUD()
        
        PFUser.logInWithUsername(inBackground: usernameTxt.text!, password:passwordTxt.text!) { (user, error) -> Void in
            if error == nil {
                self.hideHUD()
                mustReload = true
                self.dismiss(animated: true, completion: nil)
            // error
            } else { self.hideHUD(); self.simpleAlert("\(error!.localizedDescription)")
        }}
    }

    @IBAction func signupButt(_ sender: AnyObject) {
        let signupVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUp") as! SignUp
        signupVC.modalTransitionStyle = .crossDissolve
        present(signupVC, animated: true, completion: nil)
    }

    @IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }

    @IBAction func forgotPasswButt(_ sender: AnyObject) {
        let alert = UIAlertController(title: APP_NAME,
            message: "Type your email address you used to register.",
            preferredStyle: .alert)
        
        // RESET PASSWORD
        let reset = UIAlertAction(title: "Reset Password", style: .default, handler: { (action) -> Void in
            let textField = alert.textFields!.first!
            let txtStr = textField.text!
            PFUser.requestPasswordResetForEmail(inBackground: txtStr, block: { (succ, error) in
                if error == nil {
                    self.simpleAlert("You will receive an email shortly with a link to reset your password")
            }})
        })
        alert.addAction(reset)
        
        
        // CANCEL BUTTON
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        alert.addAction(cancel)
        
        // TextField
        alert.addTextField { (textField: UITextField) in
            textField.keyboardType = .emailAddress
        }
        
        present(alert, animated: true, completion: nil)
    }

    @IBAction func dismissButt(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension Login: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == usernameTxt  {  passwordTxt.becomeFirstResponder() }
    if textField == passwordTxt  {
      passwordTxt.resignFirstResponder()
      loginButt(self)
    }
    return true
  }
}
