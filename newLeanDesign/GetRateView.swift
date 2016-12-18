//
//  WaitingAlertView.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 12/1/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints
import Cosmos

class GetRateView: UIView {
    
    lazy var closeButton: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.image = UIImage(named: "close")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeView)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var blurEffectView: UIVisualEffectView = {
        let ev = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
        ev.translatesAutoresizingMaskIntoConstraints = false
        ev.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeView)))
        return ev
    }()
    
    let alertView: UIView = {
        let uv = UIView()
        uv.backgroundColor = .white
        uv.translatesAutoresizingMaskIntoConstraints = false
        return uv
    }()
    
    lazy var titleView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.text = "Мы подбираем дизайнера для вашей задачи"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .white
        tv.textAlignment = .center
        tv.font = UIFont.systemFont(ofSize: 32.0)
        tv.isEditable = false
        tv.isSelectable = false
        tv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeView)))
        return tv
    }()
    
    lazy var textView: CosmosView = {
        let tv = CosmosView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv as! CosmosView
    }()
    
    lazy var cancelButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.setTitleColor( .white, for: .normal)
        btn.setTitle("Отменить заказ", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        //        btn.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return btn
    }()
    
    lazy var cancelLabel: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.text = "До того, как мы назначили дизайнера, отмена задачи бесплатна."
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .white
        tv.textAlignment = .center
        tv.font = UIFont.systemFont(ofSize: 12.0)
        tv.isEditable = false
        tv.isSelectable = false
        tv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeView)))
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(blurEffectView)
        addConstraints("H:|[\(blurEffectView)]|")
        addConstraints("V:|[\(blurEffectView)]|")
        
        addSubview(textView)
        addSubview(titleView)
        addConstraints("V:|-110-[\(titleView)]-20-[\(textView)]")
        addConstraints("H:|-20-[\(titleView)]-20-|", "H:|-20-[\(textView)]-20-|")
        addConstraints(textView.heightAnchor == 120, titleView.heightAnchor == 140)
        
        addSubview(cancelButton)
        addSubview(cancelLabel)
        addConstraints("H:|-20-[\(cancelButton)]-20-|", "H:|-20-[\(cancelLabel)]-20-|")
        addConstraints("V:[\(cancelButton)]-10-[\(cancelLabel)]-10-|")
        addConstraints(cancelButton.heightAnchor == 50, cancelLabel.heightAnchor == 80)
        
        addSubview(closeButton)
        addConstraints("H:|-20-[\(closeButton)]")
        addConstraints("V:|-20-[\(closeButton)]")
        addConstraints(closeButton.heightAnchor == 30, closeButton.widthAnchor == 30)
        
    }
    
    func closeView() {
        self.alpha = 0
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
