//
//  acceptView.swift
//  leandesign
//
//  Created by Sladkikh Alexey on 9/15/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints

class ButtonView: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let blueColor = UIColor(r: 48, g: 140, b: 229)

    lazy var acceptTaskButtonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = blueColor
        view.userInteractionEnabled = true
        return view
    }()

    let buttonLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.whiteColor()
        return label
    }()
    
    
    func setupViews() {
        self.addSubview(acceptTaskButtonView)
        self.addSubview(buttonLabel)
        
        acceptTaskButtonView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        acceptTaskButtonView.heightAnchor.constraintEqualToConstant(50).active = true
        acceptTaskButtonView.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
        acceptTaskButtonView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        
        self.addConstraints(buttonLabel.centerXAnchor == acceptTaskButtonView.centerXAnchor,
                            buttonLabel.centerYAnchor == acceptTaskButtonView.centerYAnchor)
        
    }
}