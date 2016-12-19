

import UIKit
import Swiftstraints
import Firebase

class AwarenessViewController: UIViewController {
    
    var task: Task?
    
    lazy var titleView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.text = "Согласуйте понимание задачи"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.textAlignment = .center
        tv.font = UIFont.systemFont(ofSize: 28.0)
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
        btn.setTitle("Принимаю", for: .normal)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getAwarenessDetails()
    }
    
    
    func setupView() {
        view.backgroundColor = .white
        view.addSubview(titleView)
        view.addSubview(awarenessText)
        view.addSubview(acceptButton)
        view.addSubview(discussButton)
        
        view.addConstraints("V:|-40-[\(titleView)]-20-[\(awarenessText)]|", "V:[\(acceptButton)]-10-[\(discussButton)]-16-|")
        view.addConstraints("H:|-16-[\(titleView)]-16-|","H:|-16-[\(awarenessText)]-16-|", "H:|-16-[\(acceptButton)]-16-|", "H:|-16-[\(discussButton)]-16-|")
        view.addConstraints(titleView.heightAnchor == 100,
                            acceptButton.heightAnchor == 50,
                            discussButton.heightAnchor == 50)

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
    
    func handleAccept() {
        if let taskId = self.task?.taskId {
            let ref = FIRDatabase.database().reference()
            let values: [String: AnyObject] = ["status": "price" as AnyObject]
            ref.child("tasks").child(taskId).updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err)
                    return
                }
            })
        }
    }
    
    func handleDiscuss() {
        
    }
}
