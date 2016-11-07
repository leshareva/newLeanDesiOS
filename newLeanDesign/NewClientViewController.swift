import UIKit
import Firebase
import DigitsKit
import Swiftstraints
import DKImagePickerController

class NewClientViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var taskViewController: TaskViewController?
    
    let discriptionLabel: UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = UIColor.whiteColor()
        tv.textAlignment = .Left
        tv.numberOfLines = 3
        return tv
    }()
    
    let inputForName: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 0, g: 140, b: 255)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        
        let tf = UILabel()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "Имя"
        tf.font = UIFont.systemFontOfSize(16)
        tf.textColor = .whiteColor()
        view.addSubview(tf)
        view.addConstraints("H:|-16-[\(tf)]")
        view.addConstraints(tf.centerYAnchor == view.centerYAnchor)
        return view
    }()

    let nameField: UITextView = {
        let tf = UITextView()
        tf.backgroundColor = .clearColor()
        tf.textColor = .whiteColor()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFontOfSize(18, weight: UIFontWeightThin)
        tf.selectable = true
        tf.becomeFirstResponder()
        return tf
    }()
    
    
    let inputForEmail: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 0, g: 140, b: 255)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        
        let tf = UILabel()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "Эл. почта"
        tf.font = UIFont.systemFontOfSize(16)
        tf.textColor = .whiteColor()
        view.addSubview(tf)
        view.addConstraints("H:|-16-[\(tf)]")
        view.addConstraints(tf.centerYAnchor == view.centerYAnchor)
        return view
    }()
    
    let emailField: UITextView = {
        let tf = UITextView()
        tf.backgroundColor = .clearColor()
        tf.textColor = .whiteColor()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFontOfSize(18, weight: UIFontWeightThin)
        tf.selectable = true
        return tf
    }()
    
    let inputForCompany: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 0, g: 140, b: 255)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        
        let tf = UILabel()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "Компания"
        tf.font = UIFont.systemFontOfSize(16)
        tf.textColor = .whiteColor()
        view.addSubview(tf)
        view.addConstraints("H:|-16-[\(tf)]")
        view.addConstraints(tf.centerYAnchor == view.centerYAnchor)
        return view
    }()
    
    let companyField: UITextView = {
        let tf = UITextView()
        tf.backgroundColor = .clearColor()
        tf.textColor = .whiteColor()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFontOfSize(18, weight: UIFontWeightThin)
        tf.selectable = true
        return tf
    }()
    
    
    
    let alertView: UIView = {
        let view = UIView()
        view.backgroundColor = .redColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }()
    
    let alertLabel: UILabel = {
        let tf = UILabel()
        tf.backgroundColor = .clearColor()
        tf.textColor = .whiteColor()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFontOfSize(18, weight: UIFontWeightThin)
        return tf
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 0, g: 127, b: 255)

        checkUser()
        handleRefresh()
    }
    
    
    func handleRefresh() {
        guard let userId = Digits.sharedInstance().session()?.userID else {
            return
        }
        
        let ref = FIRDatabase.database().reference()
        let clientsReference = ref.child("clients")
        
        clientsReference.observeEventType(.Value, withBlock: { (snapshot) in
            if snapshot.hasChild(userId) {
                let taskViewController = TaskViewController()
                self.navigationController?.pushViewController(taskViewController, animated: true)
            }
        }, withCancelBlock: nil)
    }
    
    
    func checkUser() {
        
        let digits = Digits.sharedInstance()

        
        guard let userId = digits.session()?.userID else {
            return
        }
        
        let ref = FIRDatabase.database().reference()
        let clientsReference = ref.child("requests").child("clients")
        
        clientsReference.observeEventType(.Value, withBlock: { (snapshot) in
            
            if snapshot.hasChild(userId) {
                print("We have this request")
                self.setupWaitingView()
            } else {
                print("It's new user")
                self.setupInputsForLogin()
            }
            
            }, withCancelBlock: nil)
        
    }
    
    
    
    func dissmissController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handleSend() {
        let digits = Digits.sharedInstance()
        
        guard let userId = digits.session()?.userID else {
            return
        }
        guard let phone = digits.session()?.phoneNumber else {
            return
        }
        
        guard let name = nameField.text where !name.isEmpty else {
            alertView.hidden = false
            alertLabel.text = "Укажите имя"
            return
        }
        
        guard let email = emailField.text where !email.isEmpty else {
            alertView.hidden = false
            alertLabel.text = "Укажите почту"
            return
        }
        
        guard let company = companyField.text where !company.isEmpty else {
            alertView.hidden = false
            alertLabel.text = "Укажите компанию"
            return
        }
        
        let ref = FIRDatabase.database().reference()
        let requestReference = ref.child("requests").child("clients")
        let values: [String: AnyObject] = ["phone": phone, "id": userId, "email": email, "company": company, "name": name, "state": "none"]
        
        requestReference.child(userId).updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
        }
        
        let startViewController = StartViewController()
        startViewController.checkUserInBase()
        
//        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func setupWaitingView() {
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Обновить", style: .Plain, target: self, action: #selector(self.handleRefresh))
        view.addSubview(discriptionLabel)
        discriptionLabel.text = "Мы рассматриваем вашу заявку"
        view.addConstraints("V:|-80-[\(discriptionLabel)]")
        view.addConstraints("H:|-10-[\(discriptionLabel)]-10-|")
    }
    
    func setupInputsForLogin() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Отправить", style: .Plain, target: self, action: #selector(self.handleSend));
        view.addSubview(discriptionLabel)
        discriptionLabel.text = "Еще пару моментов, и сможем начать работать"
        view.addSubview(inputForName)
        view.addSubview(inputForEmail)
        view.addSubview(inputForCompany)
        view.addSubview(alertView)
        
        view.addConstraints("V:|-80-[\(discriptionLabel)]-10-[\(inputForName)]-1-[\(inputForEmail)]-1-[\(inputForCompany)]-1-[\(alertView)]")
        view.addConstraints("H:|-10-[\(discriptionLabel)]-10-|","H:|[\(inputForName)]|","H:|[\(inputForEmail)]|","H:|[\(inputForCompany)]|",
                            "H:|[\(alertView)]|")
        view.addConstraints(inputForName.heightAnchor == 40, inputForEmail.heightAnchor == 40, inputForCompany.heightAnchor == 40, alertView.heightAnchor == 40)
       
        inputForName.addSubview(nameField)
        inputForEmail.addSubview(emailField)
        inputForCompany.addSubview(companyField)
        
        inputForName.addConstraints(nameField.centerYAnchor == inputForName.centerYAnchor,
                                    nameField.heightAnchor == inputForName.heightAnchor,
                                    nameField.leftAnchor == inputForName.leftAnchor + 100,
                                    nameField.rightAnchor == inputForName.rightAnchor
                                    )
        
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
        alertView.hidden = true
    }
    
    
}
