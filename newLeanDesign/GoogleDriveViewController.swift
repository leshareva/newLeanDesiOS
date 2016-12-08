import UIKit
import Alamofire
import SWXMLHash
import CryptoSwift


class GoogleDriveViewController: UIViewController, UIWebViewDelegate {
    
    var folderUrl: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webV:UIWebView = UIWebView(frame: UIScreen.main.bounds)
        webV.loadRequest(NSURLRequest(url: NSURL(string: folderUrl) as! URL) as URLRequest)
        webV.delegate = self
        self.view.addSubview(webV)
        
    }
}
