//
//  AwarenessViewController.swift
//  leandesign
//
//  Created by Sladkikh Alexey on 9/13/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints
import Firebase


class AwarenessViewController: UIViewController {
    
    static let blueColor = UIColor(r: 48, g: 140, b: 229)
    var task: Task?
    var message: Message?
    
    let ref = FIRDatabase.database().reference()
    let acceptView = AcceptView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    let awarenessView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFontOfSize(16)
        tv.backgroundColor = UIColor.clearColor()
        tv.textColor = UIColor.blackColor()
        tv.editable = false
        return tv
    }()
    
    let priceLabel: UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFontOfSize(26)
        return tv
    }()
    
    
    func setupView(message: Message) {
        self.view.addSubview(acceptView)
        self.view.addSubview(awarenessView)
        self.view.addSubview(priceLabel)
        self.view.addConstraints("H:|-8-[\(awarenessView)]-8-|", "H:|-8-[\(priceLabel)]-8-|")
        self.view.addConstraints("V:|[\(awarenessView)][\(priceLabel)]")
        self.view.addConstraints(awarenessView.heightAnchor == self.view.heightAnchor - 90)
        
        acceptView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraints(acceptView.widthAnchor == self.view.widthAnchor,
                                 acceptView.bottomAnchor == self.view.bottomAnchor,
                                 acceptView.heightAnchor == 50)
    }
    
    
    func acceptAwareness() {
        
        let values : [String: AnyObject] = ["status": "concept"]
        if let taskId = task!.taskId {
            ref.child("tasks").child(taskId).updateChildValues(values) { (error, ref) in
                if error != nil {
                    print(error)
                    return
                }
                self.acceptView.acceptedLabel.text = "Согласовано"
                self.acceptView.acceptTaskButtonView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
                
            }
            
            let awStatus : [String: AnyObject] = ["status": "accept"]
            ref.child("tasks").child(taskId).child("awareness").updateChildValues(awStatus, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err)
                    return
                }
            })
            
        }
        
        
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        let acceptView = AcceptView(frame: CGRectMake(0, 0, view.frame.size.width, 60))
        
        if let taskId = task?.taskId {
            let taskRef = ref.child("tasks").child(taskId)
            taskRef.child("awareness").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                guard let status = snapshot.value!["status"] as? String else {
                    return
                }
                
                if status != "accept" {
                    self.acceptView.acceptedLabel.hidden = false
                    self.acceptView.acceptedLabel.text = "Согласовать"
                    self.acceptView.acceptTaskButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.acceptAwareness)))
                } else {
                    self.acceptView.acceptedLabel.hidden = false
                    self.acceptView.acceptTaskButtonView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
                }
                
                if let text = snapshot.value!["text"] as? String {
                    self.awarenessView.text = text
                }
                guard let price = snapshot.value!["price"] as? NSNumber else {
                    return
                }
                
                self.priceLabel.text = String(price) + "₽"
                
                }, withCancelBlock: nil)
            
            
        }
        
    }
    
}
