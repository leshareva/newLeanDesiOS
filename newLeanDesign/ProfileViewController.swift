import UIKit
import Firebase
import DigitsKit
import Swiftstraints
import DKImagePickerController




class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let discriptionLabel: UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = UIColor.blackColor()
        tv.textAlignment = .Center
        return tv
    }()
    
    lazy var closeButton: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "close")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .ScaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handelCancel)))
        imageView.userInteractionEnabled = true
        return imageView
    }()
    
    lazy var profilePic: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.gifWithName("spinner-duo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .ScaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.userInteractionEnabled = true
        imageView.layer.cornerRadius = 38
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    
    let inputForName: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        
        let tf = UILabel()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "Компания"
        tf.font = UIFont.systemFontOfSize(16)
        tf.textColor = UIColor(r: 180, g: 180, b: 180)
        view.addSubview(tf)
        view.addConstraints("H:|-16-[\(tf)]")
        view.addConstraints(tf.centerYAnchor == view.centerYAnchor)
        
        return view
    }()
 
    
    let firstField: UILabel = {
        let tf = UILabel()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFontOfSize(16)
        return tf
    }()
    
    
    let inputForPhone: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        
        let tf = UILabel()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "Телефон"
        tf.font = UIFont.systemFontOfSize(16)
        tf.textColor = UIColor(r: 180, g: 180, b: 180)
        view.addSubview(tf)
        
        view.addConstraints("H:|-16-[\(tf)]")
        view.addConstraints(tf.centerYAnchor == view.centerYAnchor)
        
        return view
    }()
    
    let phoneField: UILabel = {
        let tf = UILabel()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFontOfSize(16)
        return tf
    }()

    
    lazy var logoutButton: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLogout)))
        view.userInteractionEnabled = true
        
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "Выйти"
        view.addSubview(tv)
        
        view.addConstraints(tv.centerXAnchor == view.centerXAnchor,
                            tv.centerYAnchor == view.centerYAnchor)
        
        return view
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
        setupView()
        loadUserInfo()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
    }
    
    
    
    func loadUserInfo() {

        guard let userId = Digits.sharedInstance().session()?.userID else {
            return
        }
        let ref = FIRDatabase.database().reference().child("clients").child(userId)
        ref.observeEventType(.Value, withBlock: { (snapshot) in
            
            if let name = snapshot.value!["name"] as? String {
               self.discriptionLabel.text = name
            }
            if let company = snapshot.value!["company"] as? String {
                self.firstField.text = company
            }
            
            if let profileImageUrl = snapshot.value!["photoUrl"] as? String  {
                self.profilePic.loadImageUsingCashWithUrlString(profileImageUrl)
            }
            
            if let phone = snapshot.value!["phone"] as? String  {
                self.phoneField.text = phone
            }
            
            }, withCancelBlock: nil)
    }
    
    func handleLogout() {
        Digits.sharedInstance().logOut()
        
       do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }

        let loginController = LoginController()
        presentViewController(loginController, animated: true, completion: nil)
        
        
        
    }
    
    func handelCancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func setupView() {
        
        view.addSubview(discriptionLabel)
        view.addSubview(profilePic)
        view.addSubview(inputForName)
        view.addSubview(inputForPhone)
        view.addSubview(closeButton)
        view.addSubview(logoutButton)
       
        
        view.addConstraints("V:|-20-[\(closeButton)]")
        view.addConstraints("H:|-8-[\(closeButton)]")
        
        view.addConstraints("V:|-60-[\(profilePic)][\(discriptionLabel)]-20-[\(inputForName)]-1-[\(inputForPhone)]")
        view.addConstraints("V:[\(logoutButton)]|")
        view.addConstraints("H:|[\(inputForName)]|", "H:|[\(logoutButton)]|", "H:|[\(inputForPhone)]|")
        view.addConstraints(discriptionLabel.widthAnchor == view.widthAnchor,
                            discriptionLabel.heightAnchor == 40,
                            inputForName.heightAnchor == 40,
                            inputForPhone.heightAnchor == 40,
                            profilePic.centerXAnchor == view.centerXAnchor,
                            profilePic.heightAnchor == 76,
                            profilePic.widthAnchor == 76,
                            closeButton.widthAnchor == 30,
                            closeButton.heightAnchor == 30,
                            logoutButton.heightAnchor == 40
                            )
        
    
        inputForName.addSubview(firstField)
        inputForName.addConstraints("H:|-100-[\(firstField)]|")
        inputForName.addConstraints( firstField.centerYAnchor == inputForName.centerYAnchor)
        inputForPhone.addSubview(phoneField)
        inputForPhone.addConstraints("H:|-100-[\(phoneField)]|")
        inputForPhone.addConstraints( phoneField.centerYAnchor == inputForPhone.centerYAnchor)
        
        
        
    }
    
    var assets: [DKAsset]?
    
    
    internal func handleSelectProfileImageView() {
        let pickerController = DKImagePickerController()
        
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            
            for each in assets {
                each.fetchOriginalImage(false) {
                    (image: UIImage?, info: [NSObject : AnyObject]?) in
                    self.profilePic.image = image
//                    let imageData: NSData = UIImagePNGRepresentation(image!)!
                    self.uploadToFirebaseStorageUsingImage(image!)
                }
            }
            
        }
        
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage) {
        let imageName = NSUUID().UUIDString
        print(imageName)
        let ref = FIRStorage.storage().reference().child("user-image").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Faild upload image:", error)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    self.sendMessageWithImageUrl(imageUrl, image: image)
                }
                
                
            })
        }
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        let userId = Digits.sharedInstance().session()?.userID
        let ref = FIRDatabase.database().reference().child("clients").child(userId!)
        let values: [String: AnyObject] = ["photoUrl": imageUrl]
        
        ref.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            
        }
        
    }
    

    
}