//
//  HowMuchViewController.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 12/29/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Firebase
import DigitsKit
import Swiftstraints

class HowMuchViewController: UIViewController {

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
        UserDefaults.standard.set(true, forKey: "HowMuchReaded")
    }
    
    func attributedText()->NSAttributedString{
            let string = "Сколько стоит?\nСредняя стоимость задач в лине от 500 до 7000₽. Точную стоимость мы назовем после того как разберемся в задаче. Дизайнер свяжется с вами, составит понимание и в системе отобразится стоимость. Понимание задачи - бесплатный этап.\n\nКогда снимают деньги?\nМы снимаем деньги только если вы нажали кнопку согласовать этап." as NSString
            
            let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 15.0)])
            
            let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15.0)]

            attributedString.addAttributes(boldFontAttribute, range: string.range(of: "Сколько стоит?"))
            attributedString.addAttributes(boldFontAttribute, range: string.range(of: "Когда снимают деньги?"))
        
            return attributedString
    }
    
    
    
    

}
