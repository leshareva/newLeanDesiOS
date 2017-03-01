//
//  MyPromoView.swift
//  LinDesign
//
//  Created by Sladkikh Alexey on 2/23/17.
//  Copyright © 2017 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints

class MyPromoView: UIView {
    
    
    let titleView: UILabel = {
        let tv = UILabel()
        tv.text = "Зарабатывай с Лином"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.textColor = .black
        tv.textAlignment = .center
        return tv
    }()
    
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "Поделись промокодом с друзьями, и получай 10% с каждого заказа, сделанного им"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.backgroundColor = .clear
        tv.textColor = UIColor(r: 230, g: 230, b: 230)
        return tv
    }()
    
    let button: UIView = {
        let btn = UIView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.cornerRadius = 2.0
        btn.layer.masksToBounds = true
        btn.isUserInteractionEnabled = true
        return btn
    }()
    
    let buttonLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 24.0)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(r: 248, g: 248, b: 248)
        layer.cornerRadius = 6.0
        layer.masksToBounds = true
        
        
        
        addSubview(textView)
        addSubview(button)
    
        addConstraints("H:|-15-[\(textView)]-15-|", "H:|-15-[\(button)]-15-|")
        addConstraints("V:|-20-[\(textView)]-40-[\(button)]-20-|")
        addConstraints(button.heightAnchor == 50, textView.heightAnchor == 160)
        textView.attributedText = attributedText()

        addSubview(buttonLabel)
        addConstraints(buttonLabel.centerYAnchor == button.centerYAnchor,
                       buttonLabel.leftAnchor == button.leftAnchor + 10,
                       buttonLabel.widthAnchor == button.widthAnchor)
        
    }
    
    
    func attributedText()->NSAttributedString{
        let string = "Зарабатывай с Лином\n\nПоделись промокодом с друзьями, и получай 10% с каждого заказа, сделанного ими\n\n" as NSString
        
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        
        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 16.0), NSParagraphStyleAttributeName: style])
        
        let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 22.0), NSParagraphStyleAttributeName: style]
        
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: "Зарабатывай с Лином"))
        
        return attributedString
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
