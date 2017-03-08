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
    
    var userId: String? {
        didSet {
            obserUserInfo()
        }
    }

    let taskImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage.gifWithName("spinner-duo")
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 40
        iv.clipsToBounds = true
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.textAlignment = .center
        return label
    }()
    
    lazy var phoneLabel: UITextView = {
        let label = UITextView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.backgroundColor = UIColor.clear
        label.textAlignment = .left
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleCall)))
        label.isEditable = false
        return label
    }()
    
    let emailLabel: UITextView = {
        let label = UITextView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.textAlignment = .left
        label.isEditable = false
        return label
    }()
    
    
    func handleCall() {
        if let url = URL(string: "tel://\(self.phoneLabel.text)") {
            UIApplication.shared.openURL(url)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
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

        let ref = FIRDatabase.database().reference()
                ref.child("designers").child(userId!).observe(.value, with: { (snap) in
                    if let imageUrl = (snap.value as? NSDictionary)!["photoUrl"] as? String {
                        self.taskImageView.loadImageUsingCashWithUrlString(imageUrl)
                    }
                    if let name = (snap.value as? NSDictionary)!["firstName"] as? String {
                        self.nameLabel.text = name
                    }
                    
                    if let email = (snap.value as? NSDictionary)!["email"] as? String {
                        self.emailLabel.text = email
                        
                    }
                    
                    if let phone = (snap.value as? NSDictionary)!["phone"] as? String {
                        self.phoneLabel.text = phone
                    }
                    
                    }, withCancel: nil)  
    }
    
}
