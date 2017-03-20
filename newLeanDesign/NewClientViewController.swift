import UIKit
import Firebase
import DigitsKit
import Swiftstraints
import DKImagePickerController
import Alamofire
import Toast_Swift

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
 
    lazy var nameField:  UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.autocorrectionType = UITextAutocorrectionType.no
        tf.keyboardType = UIKeyboardType.default
        tf.returnKeyType = UIReturnKeyType.done
        tf.clearButtonMode = UITextFieldViewMode.whileEditing;
        tf.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        tf.translatesAutoresizingMaskIntoConstraints = false
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
    
    let secondNameField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.autocorrectionType = UITextAutocorrectionType.no
        tf.keyboardType = UIKeyboardType.default
        tf.returnKeyType = UIReturnKeyType.done
        tf.clearButtonMode = UITextFieldViewMode.whileEditing;
        tf.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.becomeFirstResponder()
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
    
    let emailField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.autocorrectionType = UITextAutocorrectionType.no
        tf.keyboardType = UIKeyboardType.emailAddress
        tf.returnKeyType = UIReturnKeyType.done
        tf.clearButtonMode = UITextFieldViewMode.whileEditing;
        tf.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.becomeFirstResponder()
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
    
    let companyField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.autocorrectionType = UITextAutocorrectionType.no
        tf.keyboardType = UIKeyboardType.default
        tf.returnKeyType = UIReturnKeyType.done
        tf.clearButtonMode = UITextFieldViewMode.whileEditing;
        tf.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.becomeFirstResponder()
        return tf
    }()
    
    
    let inputForPromo: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 245, g: 245, b: 245)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        
        let tf = UILabel()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "Промо-код"
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .black
        view.addSubview(tf)
        view.addConstraints("H:|-16-[\(tf)]")
        view.addConstraints(tf.centerYAnchor == view.centerYAnchor)
        return view
    }()
    
    let promoField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Необязательно"
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.autocorrectionType = UITextAutocorrectionType.no
        tf.keyboardType = UIKeyboardType.default
        tf.returnKeyType = UIReturnKeyType.done
        tf.clearButtonMode = UITextFieldViewMode.whileEditing;
        tf.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.becomeFirstResponder()
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
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightThin)
        return label
    }()
    
    let licenseText: UITextView = {
        let tf = UITextView()
        tf.backgroundColor = .clear
        tf.textColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin)
        tf.isEditable = false
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
        
        var style = ToastStyle()
        style.messageColor = .white
        style.backgroundColor = UIColor.red
        
        
        let digits = Digits.sharedInstance()
        
        guard let userId = digits.session()?.userID else {
            return
        }
        guard let phone = digits.session()?.phoneNumber else {
            return
        }
        
        guard let name = nameField.text, !name.isEmpty else {
            self.view.makeToast("Укажите имя", duration: 3.0, position: .top, style: style)
            return
        }
        
        guard let sename = secondNameField.text, !sename.isEmpty else {
           self.view.makeToast("Укажите фамилию", duration: 3.0, position: .top, style: style)
            return
        }
        
        
        guard let email = emailField.text, isValidEmail(testStr: email) else {
            self.view.makeToast("Что-то не так с почтой", duration: 3.0, position: .top, style: style)
            return
        }
        
        
        
        guard let company = companyField.text, !company.isEmpty else {
            return
        }
        
        guard var promofield = promoField.text else {
            return
        }
        
        var code = "none"
        
        if !promofield.isEmpty {
            code = promofield
        }
        
        let ref = FIRDatabase.database().reference()
        let clientReference = ref.child("clients")
        
        var parameters: Parameters = [
            "firstName": name,
            "id": userId,
            "code": code,
            "company": company,
            "phone": phone,
            "lastName": sename,
            "email": email,
            "rate": 0.6,
            "sum": 0
        ]
        
        
        
        
        Alamofire.request("\(Server.serverUrl)/users/create",
            method: .post,
            parameters: parameters).responseJSON { response in
                
                
                guard let statusCode = (response.response?.statusCode)! as? Int else{
                    return
                }
                if let result = response.result.value as? [String: Any] {
                    print(result)
                    
                    switch statusCode {
                    case 404:
                        print("404 error")
                        self.view.makeToast("Что-то пошло не так", duration: 3.0, position: .top)
                    case 200:
                        print("200 answer")
                        self.goToNexStep()
                    case 403:
                        print("wrong code")
                        self.view.makeToast("Промокод не действителен", duration: 3.0, position: .top)
                    default:
                        print("default")
                    }
                    
                    
                }
        }
        
    }
    
    
    func goToNexStep() {
                inputForCompany.isHidden = true
                inputForName.isHidden = true
                inputForEmail.isHidden = true
                inputForSecondName.isHidden = true
                inputForPromo.isHidden = true
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
        view.addSubview(inputForPromo)
        view.addSubview(alertView)
        view.addSubview(licenseText)
        
        
        
        view.addConstraints("V:|-10-[\(discriptionLabel)]-10-[\(inputForName)]-1-[\(inputForSecondName)]-1-[\(inputForEmail)]-1-[\(inputForCompany)]-1-[\(inputForPromo)]-1-[\(licenseText)]")
        view.addConstraints("H:|-10-[\(discriptionLabel)]-10-|","H:|[\(inputForName)]|","H:|-10-[\(licenseText)]-10-|","H:|[\(inputForCompany)]|","H:|[\(inputForEmail)]|", "H:|[\(inputForPromo)]|",
                            "H:|[\(alertView)]|", "H:|[\(inputForSecondName)]|")
        view.addConstraints(inputForName.heightAnchor == 40, inputForEmail.heightAnchor == 40, inputForCompany.heightAnchor == 40, alertView.heightAnchor == 40, inputForSecondName.heightAnchor == 40, inputForPromo.heightAnchor == 40, licenseText.heightAnchor == 80)
       
        inputForName.addSubview(nameField)
        inputForEmail.addSubview(emailField)
        inputForCompany.addSubview(companyField)
        inputForSecondName.addSubview(secondNameField)
        inputForPromo.addSubview(promoField)
        
        
        inputForName.addConstraints(nameField.centerYAnchor == inputForName.centerYAnchor,
                                    nameField.heightAnchor == inputForName.heightAnchor,
                                    nameField.leftAnchor == inputForName.leftAnchor + 110,
                                    nameField.rightAnchor == inputForName.rightAnchor
                                    )
        
        inputForSecondName.addConstraints(secondNameField.centerYAnchor == inputForSecondName.centerYAnchor,
                                       secondNameField.heightAnchor == inputForSecondName.heightAnchor,
                                       secondNameField.leftAnchor == inputForSecondName.leftAnchor + 110,
                                       secondNameField.rightAnchor == inputForSecondName.rightAnchor)
        
        inputForEmail.addConstraints(emailField.centerYAnchor == inputForEmail.centerYAnchor,
                                     emailField.heightAnchor == inputForEmail.heightAnchor,
                                     emailField.leftAnchor == inputForEmail.leftAnchor + 110,
                                     emailField.rightAnchor == inputForEmail.rightAnchor)
        
        inputForCompany.addConstraints(companyField.centerYAnchor == inputForCompany.centerYAnchor,
                                     companyField.heightAnchor == inputForCompany.heightAnchor,
                                     companyField.leftAnchor == inputForCompany.leftAnchor + 110,
                                     companyField.rightAnchor == inputForCompany.rightAnchor)
        
        inputForPromo.addConstraints(promoField.centerYAnchor == inputForPromo.centerYAnchor,
                                       promoField.heightAnchor == inputForPromo.heightAnchor,
                                       promoField.leftAnchor == inputForPromo.leftAnchor + 110,
                                       promoField.rightAnchor == inputForPromo.rightAnchor)
        
        
        alertView.addSubview(alertLabel)
        alertView.addConstraints(alertLabel.centerYAnchor == alertView.centerYAnchor,
                                 alertLabel.heightAnchor == alertView.heightAnchor,
                                 alertLabel.centerXAnchor == alertView.centerXAnchor)
        alertView.isHidden = true
    }
    
    func isValidEmail(testStr:String) -> Bool {
        print("validate emilId: \(testStr)")
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    
    
    
}
