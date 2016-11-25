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
    
    static let blueColor = UIColor(r: 0, g: 127, b: 255)

    lazy var acceptTaskButtonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = blueColor
        view.isUserInteractionEnabled = true
        return view
    }()

    let buttonLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        return label
    }()
    
    let alertButton: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(r: 109, g: 199, b: 82)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let alertTextView: UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "Согласуйте результаты этапа"
        tv.font = UIFont.systemFont(ofSize: 14.0)
        tv.textColor = UIColor.white
        return tv
    }()
    
    
    func setupViews() {
        self.addSubview(acceptTaskButtonView)
        self.addSubview(buttonLabel)
        
        acceptTaskButtonView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        acceptTaskButtonView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        acceptTaskButtonView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        acceptTaskButtonView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        self.addConstraints(buttonLabel.centerXAnchor == acceptTaskButtonView.centerXAnchor,
                            buttonLabel.centerYAnchor == acceptTaskButtonView.centerYAnchor)
        
        self.addSubview(alertButton)
        alertButton.addSubview(alertTextView)
        self.addConstraints("H:|[\(alertButton)]|")
        self.addConstraints("V:|[\(alertButton)]")
        self.addConstraints(alertButton.heightAnchor == self.heightAnchor)
        
        alertButton.addConstraints(alertTextView.centerXAnchor == alertButton.centerXAnchor,
                                 alertTextView.centerYAnchor == alertButton.centerYAnchor)
        
        self.alertButton.isHidden = true

        let options : UIViewAnimationOptions =  [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat, UIViewAnimationOptions.curveEaseOut, UIViewAnimationOptions.allowUserInteraction]
        UIView.animate(withDuration: 1.0, delay: 0.0, options: options, animations: {
            self.alertButton.backgroundColor = UIColor(r: 139, g: 224, b: 112)
            }, completion: nil)
    }
    
    func greenButton() {
        self.backgroundColor = UIColor(r: 0, g: 0, b: 0)
    }
    
}
