//
//  chatBannerView.swift
//  Lean Design
//
//  Created by Sladkikh Alexey on 11/13/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

//
//import UIKit
//import Swiftstraints
//
//class ChatBannerView: UIView {
//
//    
//    let line: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor(r: 222, g: 222, b: 222)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    
//    let titleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Дизайнер готовит понимание задачи"
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = UIFont.boldSystemFont(ofSize: 14.0)
//        return label
//    }()
//    
//    let textView: UITextView = {
//        let td = UITextView()
//        td.text = "В ближайшее время мы свяжемся с вами, чтобы задать вопросы"
//        td.translatesAutoresizingMaskIntoConstraints = false
//        td.backgroundColor = UIColor.clear
//        td.font = UIFont.systemFont(ofSize: 14)
//        td.textColor = UIColor(r: 125, g: 125, b: 125)
//        td.isUserInteractionEnabled = false
//        td.isEditable = false
//        return td
//    }()
//    
//    lazy var startChatButton: UIButton = {
//        let btn = UIButton()
//        btn.backgroundColor = .white
//        btn.setTitleColor( .black, for: .normal)
//        btn.setTitle("Написать дизайнеру", for: .normal)
//        btn.translatesAutoresizingMaskIntoConstraints = false
//        btn.layer.borderWidth = 1
//        btn.layer.borderColor = UIColor.lightGray.cgColor
//        return btn
//    }()
//    
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = .white
//        addSubview(line)
//        addSubview(titleLabel)
//        addSubview(textView)
//        addSubview(startChatButton)
//        addConstraints("H:|[\(line)]|", "H:|-20-[\(titleLabel)]-20-|", "H:|-16-[\(textView)]-16-|", "H:|-16-[\(startChatButton)]-16-|")
//        addConstraints("V:|[\(line)]-14-[\(titleLabel)][\(textView)]-2-[\(startChatButton)]-10-|")
//        addConstraints(line.heightAnchor == 1, titleLabel.heightAnchor == 14, startChatButton.heightAnchor == 40)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
