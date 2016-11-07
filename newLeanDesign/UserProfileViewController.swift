//
//  userProfileViewController.swift
//  leandesign
//
//  Created by Sladkikh Alexey on 9/12/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Firebase
import Swiftstraints

class UserProfileViewController: UIViewController {
    
    var task: Task? {
        didSet {
            obserUserInfo()
        }
    }
    
    
    let taskImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage.gifWithName("spinner-duo")
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .ScaleAspectFill
        iv.layer.cornerRadius = 40
        iv.clipsToBounds = true
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFontOfSize(16)
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Center
        return label
    }()
    
    lazy var phoneLabel: UITextView = {
        let label = UITextView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFontOfSize(16)
        label.textColor = UIColor.blackColor()
        label.backgroundColor = UIColor.clearColor()
        label.textAlignment = .Left
        label.userInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleCall)))
        label.editable = false
        return label
    }()
    
    let emailLabel: UITextView = {
        let label = UITextView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFontOfSize(16)
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Left
        label.editable = false
        return label
    }()
    
    
    func handleCall() {
        if let url = NSURL(string: "tel://\(self.phoneLabel.text)") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(taskImageView)
        view.addSubview(nameLabel)
        view.addSubview(phoneLabel)
        view.addSubview(emailLabel)
        
        view.addConstraints("V:|-20-[\(taskImageView)]-8-[\(nameLabel)]-20-[\(phoneLabel)]-8-[\(emailLabel)]")
        view.addConstraints(taskImageView.heightAnchor == 80, taskImageView.widthAnchor == 80, taskImageView.centerXAnchor == view.centerXAnchor,
                            nameLabel.centerXAnchor == view.centerXAnchor,
                            phoneLabel.leftAnchor == view.leftAnchor + 16,
                            phoneLabel.heightAnchor == 40,
                            emailLabel.heightAnchor == 40,
                            emailLabel.leftAnchor == view.leftAnchor + 16,
                            emailLabel.rightAnchor == view.rightAnchor - 16,
                            phoneLabel.rightAnchor == view.rightAnchor - 16
        )
    }
    
    func obserUserInfo() {
        
        guard let taskId = self.task?.taskId else {
            return
        }
        
        let ref = FIRDatabase.database().reference()
        ref.child("tasks").child(taskId).observeEventType(.Value, withBlock: { (snapshot) in
            if let designerId = snapshot.value!["toId"] as? String {
                ref.child("designers").child(designerId).observeEventType(.Value, withBlock: { (snap) in
                    if let imageUrl = snap.value!["photoUrl"] as? String {
                        self.taskImageView.loadImageUsingCashWithUrlString(imageUrl)
                    }
                    if let name = snap.value!["name"] as? String {
                        self.nameLabel.text = name
                    }
                    
                    if let email = snap.value!["email"] as? String {
                        self.emailLabel.text = email
                        
                    }
                    
                    if let phone = snap.value!["phone"] as? String {
                        self.phoneLabel.text = phone
                    }
                    
                    }, withCancelBlock: nil)
            }

            }, withCancelBlock: nil)
    }
    
}
