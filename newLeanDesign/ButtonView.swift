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
    
    let alertButton: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(r: 109, g: 199, b: 82)
        view.userInteractionEnabled = true
        return view
    }()
    
    let alertTextView: UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "Согласуйте результаты этапа"
        tv.font = UIFont.systemFontOfSize(14.0)
        tv.textColor = UIColor.whiteColor()
        return tv
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
        
        self.addSubview(alertButton)
        alertButton.addSubview(alertTextView)
        self.addConstraints("H:|[\(alertButton)]|")
        self.addConstraints("V:|[\(alertButton)]")
        self.addConstraints(alertButton.heightAnchor == self.heightAnchor)
        
        alertButton.addConstraints(alertTextView.centerXAnchor == alertButton.centerXAnchor,
                                 alertTextView.centerYAnchor == alertButton.centerYAnchor)
        
        self.alertButton.hidden = true

        let options : UIViewAnimationOptions =  [UIViewAnimationOptions.Autoreverse, UIViewAnimationOptions.Repeat, UIViewAnimationOptions.CurveEaseOut, UIViewAnimationOptions.AllowUserInteraction]
        UIView.animateWithDuration(1.0, delay: 0.0, options: options, animations: {
            self.alertButton.backgroundColor = UIColor(r: 139, g: 224, b: 112)
            }, completion: nil)
        

        
        
    }
}