import UIKit
import Firebase
import DigitsKit
import Swiftstraints
import DKImagePickerController

class NewClientViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var taskViewController: TaskViewController?
    
    let discriptionLabel: UILabel = {
        let tv = UILabel()
        tv.text = "Привет! Видимо мы еще не знакомы. Мы перезвоним вам, чтобы активировать аккаунт."
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = UIColor.whiteColor()
        tv.textAlignment = .Center
        tv.numberOfLines = 3
        return tv
    }()
    
    let profilePic: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "no-photo")
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .ScaleAspectFill
        return iv
    }()
    
    let inputForName: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }()
    
    let nameTextLabel: UITextView = {
        let tf = UITextView()
        tf.selectable = false
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "Промо-код"
        tf.font = UIFont.systemFontOfSize(16)
        return tf
    }()
    
    let nameTextField: UITextView = {
        let tf = UITextView()
        tf.selectable = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFontOfSize(16)
        return tf
    }()
    
    let labelComment: UILabel = {
        let tv = UILabel()
        tv.text = "Получить приглашение"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = UIColor.whiteColor()
        tv.textAlignment = .Center
        tv.numberOfLines = 3
        return tv
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 48, g: 140, b: 229)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .Plain, target: self, action: #selector(handleLogout))
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Готово", style: .Plain, target: self, action: #selector(checkPromo));
        
        
        
        setupInputsForLogin()
    }
    
    func handleLogout() {
        
        do {
            try Digits.sharedInstance().logOut()
            try FIRAuth.auth()?.signOut()
            
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.newClientViewController = self
        presentViewController(loginController, animated: true, completion: nil)
        
        
    }
    
    
    
    func setupInputsForLogin() {
        
        view.addSubview(discriptionLabel)
        
        view.addConstraints("V:|-80-[\(discriptionLabel)]|")
        view.addConstraints("H:|-10-[\(discriptionLabel)]-10-|")
        

        
    }
    
    
}
