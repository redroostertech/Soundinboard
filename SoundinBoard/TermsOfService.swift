import UIKit

class TermsOfService: UIViewController {

    @IBOutlet var webView: UIWebView!

    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show tou.html
        let url = Bundle.main.url(forResource: "tou", withExtension: "html")
        webView.loadRequest(URLRequest(url: url!))
    }

    @IBAction func dismissButt(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

  override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
          // Dispose of any resources that can be recreated.
      }
  }
