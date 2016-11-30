//
//  UserView.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 12/1/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints

class UserView: UIView {
    
    lazy var profilePic: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.gifWithName("spinner-duo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
//        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 38
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Имя"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    
   
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profilePic)
        addSubview(nameLabel)
        
        
        addConstraints("V:|[\(profilePic)]-10-[\(nameLabel)]")
        addConstraints(profilePic.widthAnchor == 76,
                       profilePic.heightAnchor == 76,
                       profilePic.centerXAnchor == centerXAnchor,
                       nameLabel.centerXAnchor == centerXAnchor,
                       nameLabel.heightAnchor == 20
        )
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
