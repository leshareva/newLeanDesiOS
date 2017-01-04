//
//  TitleNavBarView.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 1/3/17.
//  Copyright © 2017 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints

class TitleNavBarView: UIView {
    
    let userPic: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 18
        iv.layer.masksToBounds = true
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(userPic)
        addSubview(nameLabel)

        addConstraints("H:[\(nameLabel)]-8-[\(userPic)]|")
        addConstraints("V:|[\(nameLabel)]|","V:|[\(userPic)]|")
        addConstraints(userPic.widthAnchor == 36, nameLabel.widthAnchor == 96)
    }
}
