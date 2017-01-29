//
//  WhoViewController.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 1/3/17.
//  Copyright © 2017 LeshaReva. All rights reserved.
//

import UIKit
import Firebase
import DigitsKit
import Swiftstraints

class WhoViewController: UIViewController {
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(textView)
        view.addConstraints("H:|-10-[\(textView)]-10-|")
        view.addConstraints("V:|-10-[\(textView)]-10-|")
        textView.attributedText = attributedText()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UserDefaults.standard.set(true, forKey: "WhoReaded")
    }
    
    func attributedText()->NSAttributedString{
        let string = "Что за дизайнеры?\nВ системе работают дизайнеры команды Мысмаксом. Это не фрилансеры, а отобранные дизайнеры. Уровень наших работ можно посмотреть на нашем сайте.\n\nКому попадет моя задача?\nВаша задача автоматически попадает свободному дизайнеру." as NSString
        
        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 15.0)])
        
        let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15.0)]
        
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: "Что за дизайнеры?"))
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: "Кому попадет моя задача?"))
        
        return attributedString
    }
    
    
}
