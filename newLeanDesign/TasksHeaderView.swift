//
//  TasksHeaderView.swift
//  LinDesign
//
//  Created by Sladkikh Alexey on 3/21/17.
//  Copyright © 2017 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints


class TasksHeaderView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    
    let imageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(named: "designers")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let logoView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "logo")
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Экономь время на дизайне"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 24.0)
        label.textColor = .white
        label.layer.shadowOpacity = 0.8;
        label.layer.shadowRadius = 0.2;
        label.layer.shadowColor = UIColor.black.cgColor;
        label.layer.shadowOffset = CGSize(width: 1, height: 2)
        return label
    }()
    
    func setupView() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(logoView)
        
        addConstraints("H:|[\(imageView)]|")
        addConstraints("V:|[\(imageView)]|")
        addConstraints("H:|-26-[\(titleLabel)]-26-|")
        addConstraints("V:[\(logoView)]-16-[\(titleLabel)]-16-|")
        addConstraints(titleLabel.heightAnchor == 40,
                       logoView.leftAnchor == titleLabel.leftAnchor,
                       logoView.widthAnchor == 50,
                       logoView.heightAnchor == 60)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
