import UIKit
import Firebase
import DigitsKit
import Swiftstraints
import DKImagePickerController




class MyProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let userView = UserView()
    
    lazy var closeButton: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "close")?.maskWithColor(color: .black)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handelCancel)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var saveButton: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "done")?.maskWithColor(color: .black)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(saveUserData)))
        imageView.isUserInteractionEnabled = true
        imageView.isHidden = true
        return imageView
    }()
    

    lazy var logoutButton: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLogout)))
        view.isUserInteractionEnabled = true
        
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "Выйти"
        view.addSubview(tv)
        
        view.addConstraints(tv.centerXAnchor == view.centerXAnchor,
                            tv.centerYAnchor == view.centerYAnchor)
        
        return view
    }()
    
 
    let inputForPhone = UIControls.TextField()
    let inputForCompany = UIControls.TextField()
    let inputForEmail = UIControls.TextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        userView.profilePic.isUserInteractionEnabled = true
        
        userView.profilePic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        setupView()
        loadUserInfo()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    
    func loadUserInfo() {

        guard let userId = Digits.sharedInstance().session()?.userID else {
            return
        }
        let ref = FIRDatabase.database().reference().child("clients").child(userId)
        ref.observe(.value, with: { (snapshot) in
            
            if let name = (snapshot.value as? NSDictionary)!["firstName"] as? String {
               self.userView.nameLabel.text = name
            }
            
            if let company = (snapshot.value as? NSDictionary)!["company"] as? String {
                self.inputForCompany.field.text = company
            }
            
            if let profileImageUrl = (snapshot.value as? NSDictionary)!["photoUrl"] as? String  {
                self.userView.profilePic.loadImageUsingCashWithUrlString(profileImageUrl)
            }
            
            if let phone = (snapshot.value as? NSDictionary)!["phone"] as? String  {
                self.inputForPhone.field.text = phone
            }
            
            if let email = (snapshot.value as? NSDictionary)!["email"] as? String {
                self.inputForEmail.field.text = email
            }
            
            }, withCancel: nil)
    }
    
    
    func handleLogout() {
        UserMethods.signOut()
        let loginController = LoginController()
        self.present(loginController, animated: true)
    }
    
    
    func handelCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func setupView() {
        userView.frame = CGRect(x: 0, y: 80, width: view.frame.size.width, height: 100)
        self.inputForPhone.label.text = "Телефон"
        self.inputForPhone.field.isUserInteractionEnabled = false
        self.inputForPhone.field.textColor = .lightGray
        
        self.inputForCompany.label.text = "Компания"
        self.inputForEmail.label.text = "Эл. почта"
        
        
        self.inputForCompany.field.addTarget(self, action: #selector(handleSave), for: UIControlEvents.touchDown)
        
        
        view.addSubview(inputForPhone)
        view.addSubview(inputForCompany)
        view.addSubview(inputForEmail)
        view.addSubview(closeButton)
        view.addSubview(saveButton)
        view.addSubview(logoutButton)
        view.addSubview(userView)
        logoutButton.isHidden = true
        
        
        view.addConstraints("V:|-35-[\(closeButton)]", "V:|-25-[\(saveButton)]")
        view.addConstraints("H:|-26-[\(closeButton)]", "H:[\(saveButton)]-16-|")
        

        view.addConstraints("V:[\(logoutButton)]|", "V:|-240-[\(inputForPhone)]-1-[\(inputForCompany)]-1-[\(inputForEmail)]")
        view.addConstraints("H:|[\(logoutButton)]|", "H:|[\(inputForPhone)]|", "H:|[\(inputForCompany)]|", "H:|[\(inputForEmail)]|")
        view.addConstraints(inputForPhone.heightAnchor == 50,
                            inputForCompany.heightAnchor == 50,
                            inputForEmail.heightAnchor == 50,
                            closeButton.widthAnchor == 30,
                            closeButton.heightAnchor == 30,
                            logoutButton.heightAnchor == 60,
                            saveButton.widthAnchor == 45,
                            saveButton.heightAnchor == 45
                            )
        
    }
    
    
    func handleSave() {
        saveButton.isHidden = false
    }
    
    
    func saveUserData() {
        let ref = FIRDatabase.database().reference().child("clients")
        guard let uid = Digits.sharedInstance().session()?.userID else {
            return
        }
        let company = self.inputForCompany.field.text
        let email = self.inputForEmail.field.text
        let values : [String: AnyObject] = ["company": company as AnyObject, "email" : email as AnyObject]
        ref.child(uid).updateChildValues(values)
        saveButton.isHidden = true
        view.endEditing(true)
    }
    
  
    
    var assets: [DKAsset]?
    
    
    internal func handleSelectProfileImageView() {
        let pickerController = DKImagePickerController()
        
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            
            for each in assets {
                each.fetchOriginalImage(false) {
                    (image: UIImage?, info: [AnyHashable: Any]?) in
                    self.userView.profilePic.image = image
//                    let imageData: NSData = UIImagePNGRepresentation(image!)!
                    self.uploadToFirebaseStorageUsingImage(image!)
                }
            }
            
        }
        
        self.present(pickerController, animated: true, completion: nil)
    }
    
    fileprivate func uploadToFirebaseStorageUsingImage(_ image: UIImage) {
        let imageName = UUID().uuidString
        print(imageName)
        let ref = FIRStorage.storage().reference().child("user-image").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Faild upload image:", error as! NSError)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    self.sendMessageWithImageUrl(imageUrl, image: image)
                }
            })
        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
    
    fileprivate func sendMessageWithImageUrl(_ imageUrl: String, image: UIImage) {
        let userId = Digits.sharedInstance().session()?.userID
        let ref = FIRDatabase.database().reference().child("clients").child(userId!)
        let values: [String: AnyObject] = ["photoUrl": imageUrl as AnyObject]
        
        ref.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error as! NSError)
                return
            }
            
        }
        
    }
    

    
}
