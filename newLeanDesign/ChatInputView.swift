//
//  NotificationView.swift
//  newLeanDesign
//
//  Created by Sladkikh Alexey on 10/31/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints

class ChatInputView: UIView, UITextFieldDelegate {
    
    var chatViewController: ChatViewController? {
        didSet {
            sendButton.addTarget(chatViewController, action: #selector(ChatViewController.handleSend), for: .touchUpInside)
            
             uploadImage.addGestureRecognizer(UITapGestureRecognizer(target: chatViewController, action: #selector(ChatViewController.handleUploadTap)))
        }
    }
    
    let sendButton: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.black, for: .normal)
        btn.setTitle("Отпр.", for: UIControlState())
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let uploadImage: UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        iv.image = UIImage(named: "addimage")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    lazy var messageField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    let separator:UIView = {
        let iv = UIView()
        iv.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white

        addSubview(uploadImage)
        addSubview(messageField)
        addSubview(sendButton)
        addSubview(separator)
        addConstraints("H:|-8-[\(uploadImage)]-8-[\(messageField)]-8-[\(sendButton)]|", "H:|[\(separator)]|")
        addConstraints("V:|[\(separator)]-4-[\(messageField)]-5-|")
        addConstraints(uploadImage.centerYAnchor == centerYAnchor,
                       uploadImage.heightAnchor == 32,
                       uploadImage.widthAnchor == 32,
                       sendButton.centerYAnchor == centerYAnchor,
                       sendButton.widthAnchor == 80,
                       separator.heightAnchor == 0.5
                       )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
