

import UIKit
import Swiftstraints
import Firebase
import Alamofire
import DigitsKit

class AwarenessViewController: UIViewController {
    
    var task: Task?
    
    
    
    
    lazy var titleView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.text = "Согласуйте понимание задачи"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.textAlignment = .center
        tv.font = UIFont.systemFont(ofSize: 24.0)
        tv.isEditable = false
        tv.isSelectable = false
        return tv
    }()
    
    let awarenessText: UITextView = {
        let tv = UITextView()
        
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.textAlignment = .left
        tv.font = UIFont.systemFont(ofSize: 16.0)
        tv.isEditable = false
        tv.isSelectable = false
        return tv
    }()
    
    lazy var acceptButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor(r: 0, g: 127, b: 255)
        btn.setTitle("Все верно", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
        return btn
    }()
    
    lazy var discussButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .white
        btn.setTitleColor( .black, for: .normal)
        btn.setTitle("Обсудить", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.addTarget(self, action: #selector(handleDiscuss), for: .touchUpInside)
        return btn
    }()
    
    let textlabel: UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "Следующим шагом мы назовем стоимость"
        tv.font = UIFont.systemFont(ofSize: 12.0)
        tv.textAlignment = .center
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getAwarenessDetails()
        setReadStatus()
    }
    
    
    func setupView() {
        view.backgroundColor = .white
        view.addSubview(titleView)
        view.addSubview(awarenessText)
        view.addSubview(acceptButton)
        view.addSubview(discussButton)
        view.addSubview(textlabel)
        
        view.addConstraints("V:|-40-[\(titleView)]-20-[\(awarenessText)]|", "V:[\(textlabel)]-10-[\(acceptButton)]-10-[\(discussButton)]-16-|")
        view.addConstraints("H:|-16-[\(titleView)]-16-|","H:|-16-[\(awarenessText)]-16-|", "H:|-16-[\(acceptButton)]-16-|", "H:|-16-[\(discussButton)]-16-|", "H:|-16-[\(textlabel)]-16-|")
        
        view.addConstraints(titleView.heightAnchor == 150,
                            acceptButton.heightAnchor == 50,
                            discussButton.heightAnchor == 50,
                            textlabel.heightAnchor == 20)

    }
    
    func getAwarenessDetails() {
        if let taskId = self.task?.taskId {
            let ref = FIRDatabase.database().reference()
            ref.child("tasks").child(taskId).child("awareness").observeSingleEvent(of: .value, with: {(snapshot) in
                guard let awareness = (snapshot.value as! NSDictionary)["text"] as? String else {
                    return
                }
                
                self.awarenessText.text = awareness
                
            }, withCancel: nil)
        }
    }
    
    
    func setReadStatus() {
        if let taskId = self.task?.taskId {
            let ref = FIRDatabase.database().reference()
            let values: [String: AnyObject] = ["status": "read" as AnyObject]
            ref.child("tasks").child(taskId).child("awareness").updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err!)
                    return
                }
            })
        }
    }
    
    
    func handleAccept() {
        if let taskId = self.task?.taskId {
            
            guard let designerId = task?.toId else {
                return
            }
            
            let ref = FIRDatabase.database().reference()
            let values: [String: AnyObject] = ["status": "price" as AnyObject]
            ref.child("tasks").child(taskId).updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err!)
                    return
                }
            })
            
            
            //send push to server
            let parameters: Parameters = [
                "userId": designerId,
                "message": "Клиент утвердил понимание задачи",
                "taskId": taskId
            ]
            
            Alamofire.request("\(Server.serverUrl)/push",
                method: .post,
                parameters: parameters).responseJSON { response in
                    
                    if (response.result.value as? [String: Any]) != nil {}
            }
            
            dismiss(animated: true, completion: nil)
            
        }
    }
    
    
    
    
    func handleDiscuss() {
        
        guard let taskId = self.task?.taskId, let designerId = task?.toId else {
            return
        }
        
        let ref = FIRDatabase.database().reference()
        let values: [String: AnyObject] = ["status": "discuss" as AnyObject]
        ref.child("tasks").child(taskId).child("awareness").updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err!)
                return
            }
        })

        
        //send push notification
        let parameters: Parameters = [
            "userId": designerId,
            "message": "Клиент хочет обсудить понимание задачи",
            "taskId": taskId
        ]
        
        Alamofire.request("\(Server.serverUrl)/push",
            method: .post,
            parameters: parameters).responseJSON { response in
                if (response.result.value as? [String: Any]) != nil {}
        }

        
        
            let chatController = ChatViewController(collectionViewLayout: UICollectionViewFlowLayout())
            chatController.task = task
            dismiss(animated: true, completion: nil)
            navigationController?.pushViewController(chatController, animated: true)
        
        
    }
}
