import UIKit
import Swiftstraints
import Firebase
import DigitsKit
import Alamofire

class PromoCodeViewController: UIViewController {

    let textField = UIControls.TextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textField)
        view.addConstraints("H:|[\(textField)]|")
        view.addConstraints("V:|[\(textField)]")
        view.addConstraints(textField.heightAnchor == 50)
        view.backgroundColor = .white
        textField.label.text = "Промо-код"
        textField.field.becomeFirstResponder()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Отправить", style: .plain, target: self, action: #selector(handleSend))
    }
    
    
    func handleSend() {
        
        guard let code = textField.field.text, !code.isEmpty, let uid = Digits.sharedInstance().session()?.userID else {
            return
        }
        
        let parameters: Parameters = [
            "userId": uid,
            "code": code
        ]
        
        
        Alamofire.request("\(Server.serverUrl)/users/promo/check",
            method: .post,
            parameters: parameters).responseJSON { response in
                
                let statusCode = (response.response?.statusCode)! as Int
                
                if let result = response.result.value as? [String: Any] {
                    print(result)
                    
                    switch statusCode {
                    case 404:
                        print("404 error")
                        self.view.makeToast("Промокод не действителен", duration: 3.0, position: .top)
                    case 200:
                        print("200 answer")
                        let tasksViewController = TaskViewController()
                        self.navigationController?.pushViewController(tasksViewController, animated: true)
                    case 403:
                        print("wrong code")
                        self.view.makeToast("Промокод не действителен", duration: 3.0, position: .top)
                    default:
                        print("default")
                    }
                    
                    
                }
        }
        
        
    }
    
    
    
}
