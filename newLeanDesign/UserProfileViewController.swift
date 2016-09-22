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
    
    let phoneLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFontOfSize(16)
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Left
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFontOfSize(16)
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Left
        return label
    }()
    
    
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
                            emailLabel.leftAnchor == view.leftAnchor + 16
        )
    }
    
    func obserUserInfo() {
        guard let userId = self.task?.toId else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("designers").child(userId)
        ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            guard let imageUrl = snapshot.value!["photoUrl"] as? String, let name = snapshot.value!["name"] as? String, let email = snapshot.value!["email"] as? String, let phone = snapshot.value!["phone"] as? String  else {
                return
            }
            
            self.taskImageView.loadImageUsingCashWithUrlString(imageUrl)
            self.nameLabel.text = name
            self.phoneLabel.text = phone
            self.emailLabel.text = email
            
            
            
            
            }, withCancelBlock: nil)
    }
    
}
