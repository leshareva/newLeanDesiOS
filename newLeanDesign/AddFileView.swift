//
//  AddFileView.swift
//  LinDesign
//
//  Created by Sladkikh Alexey on 1/29/17.
//  Copyright © 2017 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints

class AddFileView: UIView {
    
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.backgroundColor = .clear
        tv.textColor = .white
        return tv
    }()
    
    let button: ButtonView = {
       let btn = ButtonView()
       btn.buttonLabel.text = "Отправить ссылку"
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isUserInteractionEnabled = true
        btn.layer.borderWidth = 2.0
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.cornerRadius = 4.0
        btn.layer.masksToBounds = true
        btn.buttonLabel.font = UIFont.systemFont(ofSize: 20.0)
        
       return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = LeanColor.blueColor
        
        addSubview(textView)
        addSubview(button)
        addConstraints("H:|-10-[\(textView)]-10-|", "H:|-10-[\(button)]-10-|")
        addConstraints("V:|-10-[\(textView)]-10-[\(button)]-10-|")
        addConstraints(button.heightAnchor == 50)
        textView.attributedText = attributedText()
        textView.textColor = .white
    }
    
    
    func attributedText()->NSAttributedString{
        let string = "Ссылка для загрузки скопирована\n\nОткройте эту ссылку на компьютере, и загрузите файлы. Они попадут в ваш список файлов." as NSString
        
        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 16.0)])
        
        let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18.0)]
        
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: "Ссылка для загрузки скопирована"))
        
        return attributedString
    }

    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
