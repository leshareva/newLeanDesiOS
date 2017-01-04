//
//  HowTaskingController.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 12/29/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//


import UIKit
import Firebase
import DigitsKit
import Swiftstraints

class HowTaskingViewController: UIViewController {
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        
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
        UserDefaults.standard.set(true, forKey: "HowTaskingReaded")
    }
    
    func attributedText()->NSAttributedString{
        let string = "В каком формате ставить задачу?\nДостаточно очень коротко описать суть задачи. После дизайнер разберется в задаче и сам опишет задание на работу.\n\nНапример:\n«Нужно сделать визитку» или «Нужно разработать логотип для магазина одежды" as NSString
        
        var attributedString = NSMutableAttributedString(string: string as String, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 15.0)])
        
        let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15.0)]
        
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: "В каком формате ставить задачу?"))
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: "Например:"))
        
        return attributedString
    }
    
    
    
    
    
}
