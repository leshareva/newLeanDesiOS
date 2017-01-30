

import UIKit
import Swiftstraints
import SWXMLHash
import CryptoSwift
import DigitsKit
import Firebase

class WaitingAwarenessViewController: UIViewController {
    
    var task: Task?
    var userPhone: String?
    
    let userPic: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 50
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    lazy var titleView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.text = "Вашей задачей будет заниматься"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.textAlignment = .center
        tv.font = UIFont.systemFont(ofSize: 28.0)
        tv.isEditable = false
        tv.isSelectable = false
        return tv
    }()
    
    lazy var nameText: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.textAlignment = .center
        tv.font = UIFont.systemFont(ofSize: 24.0)
        tv.isEditable = false
        tv.isSelectable = false
        return tv
    }()
    
    let descriptionText: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.text = "Дизайнер позвонит вам, чтобы разобраться в задаче"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.textAlignment = .center
        tv.font = UIFont.systemFont(ofSize: 16.0)
        tv.isEditable = false
        tv.isSelectable = false
        return tv
    }()
    
    lazy var callButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .white
        btn.setTitleColor( .black, for: .normal)
        btn.setTitle("Написать дизайнеру", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.addTarget(self, action: #selector(handleCall), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserInfo(taskId: (task?.taskId)!)
    }
    
    
    func getUserInfo(taskId: String) {
 
        let ref = FIRDatabase.database().reference()
        
        ref.child("tasks").child(taskId).observeSingleEvent(of: .value, with: {(snapshot) in
            guard let designerId = (snapshot.value as? NSDictionary)!["toId"] as? String else {
                return
            }
            
            ref.child("designers").child(designerId ).observeSingleEvent(of: .value, with: { (snapshot)  in
                guard let name = (snapshot.value as? NSDictionary)!["firstName"] as? String,
                    let phone = (snapshot.value as? NSDictionary)!["phone"] as? String,
                    let photoUrl = (snapshot.value as! NSDictionary)["photoUrl"] as? String else {
                        return
                }
                
                self.userPhone = phone
              
                self.nameText.text = name
                self.userPic.loadImageUsingCashWithUrlString(photoUrl)

            }, withCancel: nil)
            
        }, withCancel: nil)
        
        
    }
    
    
    
    func setupView() {
        view.backgroundColor = .white
        view.addSubview(userPic)
        view.addSubview(titleView)
        view.addSubview(nameText)
        view.addSubview(descriptionText)
        view.addSubview(callButton)
        
        view.addConstraints("V:|-40-[\(titleView)]-10-[\(userPic)]-10-[\(nameText)]-20-[\(descriptionText)]", "V:[\(callButton)]-16-|")
        view.addConstraints("H:|-16-[\(titleView)]-16-|", "H:|-16-[\(nameText)]-16-|", "H:|-16-[\(descriptionText)]-16-|", "H:|-16-[\(callButton)]-16-|")
        view.addConstraints(userPic.widthAnchor == 100,
                            userPic.heightAnchor == 100,
                            userPic.centerXAnchor == view.centerXAnchor,
                            titleView.heightAnchor == 100,
                            nameText.heightAnchor == 40,
                            descriptionText.heightAnchor == 120,
                            callButton.heightAnchor == 50
                            )
    }
    
    
    func handleCall() {
        let chatController = ChatViewController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.task = task
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    
}
