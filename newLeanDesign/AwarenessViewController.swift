

import UIKit
import Swiftstraints
import Firebase
import Alamofire
import DigitsKit

class AwarenessViewController: UIViewController, UIWebViewDelegate {
    
    var task: Task?
    var webV: UIWebView!
    
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
    
    var awarenessText: UITextView = {
        let tv = UITextView()
        
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.textAlignment = .left
        tv.font = UIFont.systemFont(ofSize: 16.0)
        tv.isEditable = false
        tv.isSelectable = false
        tv.isScrollEnabled = false
        tv.sizeToFit()
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
        getAwarenessDetails()
//        setReadStatus()
        setupView()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Свернуть", style: .plain, target: self, action: #selector(handleDismiss))
    }
    
    
    func setupView() {
        view.backgroundColor = .white
        view.addSubview(acceptButton)
        view.addSubview(discussButton)
        
        
        webV = UIWebView(frame: CGRect(x: 0, y: 60, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 160))
        
        if let taskId = self.task?.taskId {
            webV.loadRequest(NSURLRequest(url: NSURL(string: "\(Server.serverUrl)/awareness?taskId=\(taskId)") as! URL) as URLRequest)
            webV.delegate = self
            self.view.addSubview(webV)
        }
        view.addConstraints("H:|[\(acceptButton)]|", "H:|[\(discussButton)]|")
        view.addConstraints(acceptButton.heightAnchor == 50, discussButton.topAnchor == webV.bottomAnchor,
                            discussButton.heightAnchor == 50, acceptButton.topAnchor == discussButton.bottomAnchor)
    }
    

    
    
    func getAwarenessDetails() {
        if let taskId = self.task?.taskId {
            let ref = FIRDatabase.database().reference()
            
            ref.child("tasks").child(taskId).child("awareness").observeSingleEvent(of: .value, with: { (snapshot) in
                guard let awareness = (snapshot.value as! NSDictionary)["text"] as? String else {
                    return
                }
                
                var height: CGFloat = 80
                let font = UIFont.systemFont(ofSize: 16)
                do {
                    let attrStr = try NSMutableAttributedString(HTMLString: awareness, font: nil)
                    var attrs = attrStr?.attributes(at: 0, effectiveRange: nil)
                    attrs?[NSFontAttributeName] as? UIFont
                    
                    height = (attrStr?.boundingRect(with: CGSize(width: 200, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin), context: nil).height)!
                    
                    self.awarenessText.attributedText = attrStr
                    
                    self.awarenessText.frame = CGRect(x: 0, y: 60, width: self.view.window!.frame.size.width, height: height)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                

            }, withCancel: nil)
                
            
                
            
           
        }
    }
    
    
    func setupTextView(text: String) {
        
        
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
            
            let parameters2: Parameters = [
                "taskId": taskId,
                "status": "price"
            ]
            
            Alamofire.request("\(Server.serverUrl)/tasks/update",
                method: .post,
                parameters: parameters2).responseJSON { response in
                    
                    if (response.result.value as? [String: Any]) != nil {}
            }
            
            
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
        
        let priceWaitingViewController = PriceWaitingViewController()
        
        priceWaitingViewController.task = task
        priceWaitingViewController.titleView.text = "Ждем согласования понимания задачи"
        priceWaitingViewController.descriptionText.text = " "
//        dismiss(animated: true, completion: nil)
        navigationController?.pushViewController(priceWaitingViewController, animated: true)
        
        
        
//        guard let taskId = self.task?.taskId, let designerId = task?.toId else {
//            return
//        }
//        
//        let ref = FIRDatabase.database().reference()
//        let values: [String: AnyObject] = ["status": "discuss" as AnyObject]
//        ref.child("tasks").child(taskId).child("awareness").updateChildValues(values, withCompletionBlock: { (err, ref) in
//            if err != nil {
//                print(err!)
//                return
//            }
//        })
//
//        
//        //send push notification
//        let parameters: Parameters = [
//            "userId": designerId,
//            "message": "Клиент хочет обсудить понимание задачи",
//            "taskId": taskId
//        ]
//        
//        Alamofire.request("\(Server.serverUrl)/push",
//            method: .post,
//            parameters: parameters).responseJSON { response in
//                if (response.result.value as? [String: Any]) != nil {}
//        }
//
//        
//        
//            let chatController = ChatViewController(collectionViewLayout: UICollectionViewFlowLayout())
//            chatController.task = task
//            dismiss(animated: true, completion: nil)
//            navigationController?.pushViewController(chatController, animated: true)
        
        
    }
    
    
    func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
   
    
}
