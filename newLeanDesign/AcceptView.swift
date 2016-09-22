//
//  acceptView.swift
//  leandesign
//
//  Created by Sladkikh Alexey on 9/15/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints

class AcceptView: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    lazy var acceptTaskButtonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(r: 172, g: 223, b: 61)
        view.userInteractionEnabled = true
        return view
    }()
    
    
    
    let acceptedLabel: UILabel = {
        let label = UILabel()
        label.text = "Согласовано"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.whiteColor()
        return label
    }()
    
    
    func setupViews() {
        self.addSubview(acceptTaskButtonView)
        self.addSubview(acceptedLabel)
        
        acceptTaskButtonView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        acceptTaskButtonView.heightAnchor.constraintEqualToConstant(50).active = true
        acceptTaskButtonView.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
        acceptTaskButtonView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        
        self.addConstraints(acceptedLabel.centerXAnchor == acceptTaskButtonView.centerXAnchor,
                            acceptedLabel.centerYAnchor == acceptTaskButtonView.centerYAnchor)
        
    }
}