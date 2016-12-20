import UIKit
import Swiftstraints
import Firebase
import DigitsKit

class PromoCodeViewController: UIViewController {

    let textField = UIControls.TextField()
    let errorText: UILabel = {
       let uil = UILabel()
        uil.text = "Ошибка"
        uil.translatesAutoresizingMaskIntoConstraints = false
        uil.textColor = .red
        return uil
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textField)
        view.addSubview(errorText)
        view.addConstraints("H:|[\(textField)]|", "H:|-10-[\(errorText)]-10-|")
        view.addConstraints("V:|[\(textField)]-10-[\(errorText)]")
        view.addConstraints(textField.heightAnchor == 50, errorText.heightAnchor == 40)
        view.backgroundColor = .white
        textField.label.text = "Промо-код"
        textField.field.becomeFirstResponder()
        errorText.isHidden = true
        
        
        
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
                self.errorText.text = "Код не действителен"
                self.errorText.isHidden = false
            }
        }, withCancel: nil)
    }
    
    
}
