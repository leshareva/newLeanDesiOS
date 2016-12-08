import UIKit
import Swiftstraints
import Firebase
import DigitsKit

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
        let ref = FIRDatabase.database().reference()
        
        guard let code = textField.field.text, !code.isEmpty, let uid = Digits.sharedInstance().session()?.userID else {
            return
        }

        ref.child("promocodes").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(code) {
                let codeAmount = (snapshot.value as! NSDictionary)[code] as! Int
                
                let userRef = ref.child("clients").child(uid)
                    
                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    let oldAmount = (snapshot.value as! NSDictionary)["sum"] as! Int
                    let newAmount = oldAmount + codeAmount
                    let values : [String: AnyObject] = ["sum": newAmount as AnyObject]
                    userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print(error!)
                            return
                        }
                    })
                    
                    ref.child("promocodes").child(code).removeValue()
                    self.dismiss(animated: true, completion: nil)
                    
                }, withCancel: nil)
  
            } else {
                print("wrong code")
            }
        }, withCancel: nil)
    }
    
    
}
