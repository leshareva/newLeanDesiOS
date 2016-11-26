//
//  AmountViewController.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 11/26/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints

class AmountViewController: UIViewController, UITextViewDelegate {

    
 
    let amountLabel: UITextView = {
        let tv = UITextView()
        tv.text = "Введите сумму в рублях"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.font = UIFont.systemFont(ofSize: 20)
        tv.textAlignment = .left
        tv.isEditable = false
        return tv
    }()
    
    let amountField: UITextView = {
        let tf = UITextView()
        tf.textColor = .gray
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFont(ofSize: 32, weight: UIFontWeightThin)
        tf.isSelectable = true
        tf.backgroundColor = UIColor(r: 250, g: 250, b: 250)
        tf.keyboardType = UIKeyboardType.decimalPad
        return tf
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        amountField.delegate = self
        amountField.textColor = .lightGray
        amountField.text = "Введите сумму в рублях"
        amountField.becomeFirstResponder()
        
          navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Оплатить", style: .plain, target: self, action: #selector(handlePay));
        
       setupView()
    }


    
    func setupView() {
        view.addSubview(amountField)
        view.addSubview(amountLabel)
        
        view.addConstraints("V:|-10-[\(amountLabel)]-5-[\(amountField)]")
        view.addConstraints("H:|-10-[\(amountLabel)]-10-|", "H:|[\(amountField)]|")
        view.addConstraints(amountLabel.heightAnchor == 50, amountField.heightAnchor == 60)
        
    }
    
    
    func handlePay() {
        let payViewController = PayViewController()
        payViewController.amount = Int(amountField.text)
        navigationController?.pushViewController(payViewController, animated: true)
    }

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
        if !textView.text.isEmpty {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
          navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Введите сумму в рублях"
            textView.textColor = UIColor.lightGray
        }
    }
    
}
