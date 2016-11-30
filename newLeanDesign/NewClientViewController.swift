import UIKit
import Firebase
import DigitsKit
import Swiftstraints
import DKImagePickerController
import Alamofire

class NewClientViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var taskViewController: TaskViewController?
    
    let discriptionLabel: UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .lightGray
        tv.textAlignment = .left
        tv.numberOfLines = 3
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    let waitingLabel: UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.textAlignment = .center
        tv.numberOfLines = 3
        return tv
    }()
    
    let inputForName: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 245, g: 245, b: 245)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        
        let tf = UILabel()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "Имя"
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .black
        view.addSubview(tf)
        view.addConstraints("H:|-16-[\(tf)]")
        view.addConstraints(tf.centerYAnchor == view.centerYAnchor)
        return view
    }()

    let nameField: UITextView = {
        let tf = UITextView()
        tf.backgroundColor = .clear
        tf.textColor = .black
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightThin)
        tf.isSelectable = true
        tf.becomeFirstResponder()
        return tf
    }()
    
    let inputForSecondName: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 245, g: 245, b: 245)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        
        let tf = UILabel()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "Фамилия"
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .black
        view.addSubview(tf)
        view.addConstraints("H:|-16-[\(tf)]")
        view.addConstraints(tf.centerYAnchor == view.centerYAnchor)
        return view
    }()
    
    let secondNameField: UITextView = {
        let tf = UITextView()
        tf.backgroundColor = .clear
        tf.textColor = .black
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightThin)
        tf.isSelectable = true
        return tf
    }()
    
    
    let inputForEmail: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 245, g: 245, b: 245)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        
        let tf = UILabel()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "Эл. почта"
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .black
        view.addSubview(tf)
        view.addConstraints("H:|-16-[\(tf)]")
        view.addConstraints(tf.centerYAnchor == view.centerYAnchor)
        return view
    }()
    
    let emailField: UITextView = {
        let tf = UITextView()
        tf.backgroundColor = .clear
        tf.textColor = .black
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightThin)
        tf.isSelectable = true
        return tf
    }()
    
    let inputForCompany: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 245, g: 245, b: 245)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        
        let tf = UILabel()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "Компания"
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .black
        view.addSubview(tf)
        view.addConstraints("H:|-16-[\(tf)]")
        view.addConstraints(tf.centerYAnchor == view.centerYAnchor)
        return view
    }()
    
    let companyField: UITextView = {
        let tf = UITextView()
        tf.backgroundColor = .clear
        tf.textColor = .black
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightThin)
        tf.isSelectable = true
        return tf
    }()
    
    
    
    let alertView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }()
    
    let alertLabel: UILabel = {
        let tf = UILabel()
        tf.backgroundColor = .clear
        tf.textColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightThin)
        return tf
    }()
    
    let licenseText: UITextView = {
        let tf = UITextView()
        tf.backgroundColor = .clear
        tf.textColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin)
        return tf
    }()
    
    var myString:NSString = "Продолжая, вы подтверждаете, что прочитали и принимаете Условия предоставления услуг и Политику конфиденциальности"
    var myMutableString = NSMutableAttributedString()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        UINavigationBar.appearance().barTintColor = UIColor(r: 0, g: 127, b: 255)
        navigationController?.navigationBar.isTranslucent = false
        
        licenseText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLicense)))
        licenseText.textColor = .white
        
        myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 12.0)!])
        
        
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor(r: 0, g: 127, b: 255), range: NSRange(location:56,length:28))
        
        
        // set label Attribute
        
        licenseText.attributedText = myMutableString
  
        setupInputsForLogin()
      
    }
    
    func handleLicense() {
        let licenseViewController = LicenseViewController()
        navigationController?.pushViewController(licenseViewController, animated: true)
    }
    
    
    
    func dissmissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleSend() {
        let digits = Digits.sharedInstance()
        
        guard let userId = digits.session()?.userID else {
            return
        }
        guard let phone = digits.session()?.phoneNumber else {
            return
        }
        
        guard let name = nameField.text, !name.isEmpty else {
            alertView.isHidden = false
            alertLabel.text = "Укажите имя"
            return
        }
        
        guard let sename = secondNameField.text, !sename.isEmpty else {
            alertView.isHidden = false
            alertLabel.text = "Укажите Фамилию"
            return
        }
        
        guard let email = emailField.text, !email.isEmpty else {
            alertView.isHidden = false
            alertLabel.text = "Укажите почту"
            return
        }
        
        guard let company = companyField.text, !company.isEmpty else {
            alertView.isHidden = false
            alertLabel.text = "Укажите компанию"
            return
        }
        
        let ref = FIRDatabase.database().reference()
        let requestReference = ref.child("clients")
        
        let parameters: Parameters = [
            "toEmail": email,
            "subject": "Добро пожаловать в Лин",
            "mailKind": "welcome",
            "name": name,
            "clientId": userId,
            "company": company
        ]
        
        Alamofire.request("\(Server.serverUrl)/createFolder",
                          method: .post,
                          parameters: parameters)
        

        
        let values: [String: AnyObject] = ["phone": phone as AnyObject, "lastName": sename as AnyObject, "id": userId as AnyObject, "email": email as AnyObject, "company": company as AnyObject, "firstName": name as AnyObject, "rate": 0.6 as AnyObject, "sum": 0 as AnyObject]
        
        requestReference.child(userId).updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error as! NSError)
                return
            }
        }
        
        inputForCompany.isHidden = true
        inputForName.isHidden = true
        inputForEmail.isHidden = true
        inputForSecondName.isHidden = true
        alertView.isHidden = true

        view.endEditing(true)
        let taskViewController = TaskViewController()
        navigationController?.pushViewController(taskViewController, animated: true)

    }
    
    
   
    
    func setupInputsForLogin() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Отправить", style: .plain, target: self, action: #selector(self.handleSend));
        view.addSubview(discriptionLabel)
        discriptionLabel.text = "Расскажите о себе"
        view.addSubview(inputForName)
        view.addSubview(inputForEmail)
        view.addSubview(inputForCompany)
        view.addSubview(inputForSecondName)
        view.addSubview(alertView)
        view.addSubview(licenseText)
        
        view.addConstraints("V:|-10-[\(discriptionLabel)]-10-[\(inputForName)]-1-[\(inputForSecondName)]-1-[\(inputForEmail)]-1-[\(inputForCompany)]-1-[\(licenseText)]")
        view.addConstraints("H:|-10-[\(discriptionLabel)]-10-|","H:|[\(inputForName)]|","H:|-10-[\(licenseText)]-10-|","H:|[\(inputForCompany)]|","H:|[\(inputForEmail)]|",
                            "H:|[\(alertView)]|", "H:|[\(inputForSecondName)]|")
        view.addConstraints(inputForName.heightAnchor == 40, inputForEmail.heightAnchor == 40, inputForCompany.heightAnchor == 40, alertView.heightAnchor == 40, inputForSecondName.heightAnchor == 40, licenseText.heightAnchor == 80)
       
        inputForName.addSubview(nameField)
        inputForEmail.addSubview(emailField)
        inputForCompany.addSubview(companyField)
        inputForSecondName.addSubview(secondNameField)
        
        inputForName.addConstraints(nameField.centerYAnchor == inputForName.centerYAnchor,
                                    nameField.heightAnchor == inputForName.heightAnchor,
                                    nameField.leftAnchor == inputForName.leftAnchor + 100,
                                    nameField.rightAnchor == inputForName.rightAnchor
                                    )
        
        inputForSecondName.addConstraints(secondNameField.centerYAnchor == inputForSecondName.centerYAnchor,
                                       secondNameField.heightAnchor == inputForSecondName.heightAnchor,
                                       secondNameField.leftAnchor == inputForSecondName.leftAnchor + 100,
                                       secondNameField.rightAnchor == inputForSecondName.rightAnchor)
        
        inputForEmail.addConstraints(emailField.centerYAnchor == inputForEmail.centerYAnchor,
                                     emailField.heightAnchor == inputForEmail.heightAnchor,
                                     emailField.leftAnchor == inputForEmail.leftAnchor + 100,
                                     emailField.rightAnchor == inputForEmail.rightAnchor)
        
        inputForCompany.addConstraints(companyField.centerYAnchor == inputForCompany.centerYAnchor,
                                     companyField.heightAnchor == inputForCompany.heightAnchor,
                                     companyField.leftAnchor == inputForCompany.leftAnchor + 100,
                                     companyField.rightAnchor == inputForCompany.rightAnchor)
        
        alertView.addSubview(alertLabel)
        alertView.addConstraints(alertLabel.centerYAnchor == alertView.centerYAnchor,
                                 alertLabel.heightAnchor == alertView.heightAnchor,
                                 alertLabel.centerXAnchor == alertView.centerXAnchor)
        alertView.isHidden = true
    }
    
    
}
