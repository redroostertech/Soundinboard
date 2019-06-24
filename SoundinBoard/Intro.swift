import UIKit
import ParseFacebookUtilsV4
import Parse

class Intro: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var appnameLabel: UILabel!

    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      if PFUser.current() != nil {
        dismiss(animated: false, completion: nil)
      }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appnameLabel.text = "\(APP_NAME)"
        facebookButton.layer.cornerRadius = 22
        signUpButton.layer.cornerRadius = 22
        signUpButton.layer.borderColor = MAIN_COLOR.cgColor
        signUpButton.layer.borderWidth = 2
        loginButton.layer.cornerRadius = 22
        loginButton.layer.borderColor = MAIN_COLOR.cgColor
        loginButton.layer.borderWidth = 2
    }

    func getFacebookUserData() {
      let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, picture.type(large)"])
      let connection = FBSDKGraphRequestConnection()
      connection.add(graphRequest) { (connection, result, error) in
        if error == nil {
          let userData:[String:AnyObject] = result as! [String : AnyObject]

          let currUser = PFUser.current()!

          // Get data
          let facebookID = userData["id"] as! String
          let name = userData["name"] as! String
          var email = ""
          if userData["email"] != nil { email = userData["email"] as! String
          } else { email = "\(facebookID)@facebook.com" }

          // Get profile picture
          let pictureURL = URL(string: "https://graph.facebook.com/\(facebookID)/picture?type=large")
          let urlRequest = URLRequest(url: pictureURL!)
          let session = URLSession.shared
          let dataTask = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if error == nil && data != nil {
              let image = UIImage(data: data!)
              let imageData = image!.jpegData(compressionQuality: 1.0)
              let imageFile = PFFileObject(name:"avatar.jpg", data:imageData!)
              currUser[USER_AVATAR] = imageFile
              currUser.saveInBackground(block: { (succ, error) in
                print("...AVATAR SAVED!")

                self.hideHUD()
                mustReload = true
                self.dismiss(animated: true, completion: nil)
              })
              // error
            } else { self.hideHUD(); self.simpleAlert("\(error!.localizedDescription)")
            }})
          dataTask.resume()


          // Update user data
          let nameArr = name.components(separatedBy: " ")
          var username = String()
          for word in nameArr {
            username.append(word.lowercased())
          }
          currUser.username = username
          currUser.email = email
          currUser[USER_FULLNAME] = name
          currUser[USER_REPORTED_BY] = [String]()

          currUser.saveInBackground(block: { (succ, error) in
            if error == nil {
              print("USER'S DATA UPDATED...")
            }})

          // error
        } else { self.hideHUD(); self.simpleAlert("\(error!.localizedDescription))")
        }}
      connection.start()
    }


    @IBAction func facebookButt(_ sender: Any) {
        let alert = UIAlertController(title: APP_NAME,
            message: "Do you agree with our Terms of Service?",
            preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            // Set permissions required from the facebook user account
            let permissions = ["public_profile", "email"];
            self.showHUD()
            
            // LOGIN WITH FACEBOOK
            PFFacebookUtils.logInInBackground(withReadPermissions: permissions) { (user, error) in
                if user == nil {
                    self.simpleAlert("Facebook login cancelled")
                    self.hideHUD()
                    
                } else if (user!.isNew) {
                    print("NEW USER signed up or logged in with Facebook");
                    self.getFacebookUserData()
                    
                } else {
                    print("OLD USER logged in with Facebook!");
                    
                    // Go back to Home screen
                    let tbc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
                    tbc.selectedIndex = 0
                    self.present(tbc, animated: false, completion: nil)
                    
                    self.hideHUD()
                }
          }
        })
        alert.addAction(yes)

        
        // TERMS OF SERVICE
        let tos = UIAlertAction(title: "Read Terms of Service", style: .default, handler: { (action) -> Void in
            self.tosButt(self)
        })
        alert.addAction(tos)

        
        // CANCEL BUTTON
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }

    @IBAction func signUpButt(_ sender: Any) {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "SignUp") as! SignUp
        present(aVC, animated: true, completion: nil)
    }

    @IBAction func loginButt(_ sender: Any) {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
        present(aVC, animated: true, completion: nil)
    }

    @IBAction func tosButt(_ sender: Any) {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "TermsOfService") as! TermsOfService
        present(aVC, animated: true, completion: nil)
    }

    @IBAction func dismissButton(_ sender: Any) {
        // Go back to the Home screen
        let tbc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
        tbc.selectedIndex = 0
        self.present(tbc, animated: false, completion: nil)
    }
}
