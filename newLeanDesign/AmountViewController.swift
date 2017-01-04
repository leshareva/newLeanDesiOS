//
//  AmountViewController.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 11/26/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints
import SafariServices
import Alamofire

class AmountViewController: UIViewController, UITextViewDelegate, SFSafariViewControllerDelegate, UITextFieldDelegate {

    
 
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
    
    
    let amountField: UITextField = {
        let tf = UITextField()
        tf.textColor = .gray
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFont(ofSize: 32, weight: UIFontWeightThin)
        tf.backgroundColor = UIColor(r: 250, g: 250, b: 250)
        tf.keyboardType = UIKeyboardType.decimalPad
        tf.placeholder = "0,0"
        return tf
    }()
    
    let tinkoffLogo: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "tinkoff")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    
    let promoLink = UIControls.SectionCell()
    let billLink = UIControls.SectionCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        amountField.delegate = self
        amountField.textColor = .lightGray
        
        amountField.becomeFirstResponder()
     
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Оплатить", style: .plain, target: self, action: #selector(handlePay));
        
        promoLink.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePromoLink)))
        billLink.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBillLink)))
        
       setupView()
    }


    
    func setupView() {
        view.addSubview(amountField)
        view.addSubview(amountLabel)
        view.addSubview(promoLink)
        view.addSubview(tinkoffLogo)
        view.addSubview(billLink)
        
        view.addConstraints("V:|-10-[\(amountLabel)]-5-[\(amountField)]-20-[\(promoLink)]")
        view.addConstraints("H:|-10-[\(amountLabel)]-10-|", "H:|[\(amountField)]|" , "H:|[\(promoLink)]-6-[\(billLink)]")
        view.addConstraints(amountLabel.heightAnchor == 50, amountField.heightAnchor == 60, promoLink.heightAnchor == 50, billLink.heightAnchor == 50)
        promoLink.label.text = "Ввести промо-код"
        billLink.label.text = "Выставить счет"
        view.addConstraints(tinkoffLogo.centerYAnchor == amountField.centerYAnchor, tinkoffLogo.rightAnchor == amountField.rightAnchor - 20, tinkoffLogo.heightAnchor == amountField.heightAnchor - 30, tinkoffLogo.widthAnchor == 85,
                            billLink.topAnchor == promoLink.topAnchor,
                            billLink.widthAnchor == (view.widthAnchor / 2) - 2,
                            promoLink.widthAnchor == (view.widthAnchor / 2) - 4)
    }
    
    func handlePromoLink() {
        let promoCodeViewController = PromoCodeViewController()
        navigationController?.pushViewController(promoCodeViewController, animated: true)
    }
    
    func handlePay() {
        guard let amount = amountField.text, !amount.isEmpty  else {
            return
        }
        
        let tinkoffViewController = TinkoffViewController()
        tinkoffViewController.amount = Int(amountField.text!)
        self.navigationController?.pushViewController(tinkoffViewController, animated: true)
    }

    
    func handleBillLink() {
        let payByBillController = PayByBillController()
        self.navigationController?.pushViewController(payByBillController, animated: true)
        
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
    
    func handleCancel() {
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
}
