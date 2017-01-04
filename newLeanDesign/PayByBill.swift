//
//  PayByBill.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 12/28/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import Foundation
import Swiftstraints
import Alamofire
import DigitsKit
import Toast_Swift

class PayByBillController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    
    let amountField = UIControls.TextField()
    let innField = UIControls.TextField()
    var timer: Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 248, g: 248, b: 248)
        innField.label.text = "ИНН"
        amountField.label.text = "Сумма в руб"
        amountField.field.becomeFirstResponder()
        amountField.field.keyboardType = UIKeyboardType.decimalPad
        innField.field.keyboardType = UIKeyboardType.decimalPad
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Отправить", style: .plain, target: self, action: #selector(handleRequestBill));
        
        setupView()
    }

    
    func setupView() {
        view.addSubview(innField)
        view.addSubview(amountField)
        view.addConstraints("H:|[\(innField)]|", "H:|[\(amountField)]|")
        view.addConstraints("V:|-10-[\(amountField)]-10-[\(innField)]")
        view.addConstraints(innField.heightAnchor == 50, amountField.heightAnchor == 50)
        
    }
    
    func handleRequestBill() {
        
        guard let amount = amountField.field.text, !amount.isEmpty  else {
            return
        }
        
        guard let inn = innField.field.text, !inn.isEmpty  else {
            return
        }
        
        guard let clientId = Digits.sharedInstance().session()?.userID else {
            return
        }
        
        let parameters: Parameters = [
            "clientId": clientId,
            "amount": amount,
            "inn": inn
        ]
        
        Alamofire.request("\(Server.serverUrl)/requestBill",
                    method: .post,
                    parameters: parameters).responseJSON { response in
                        if let result = response.result.value as? [String: Any] {
                            self.view.endEditing(true)
                            if result["status"] as! String == "success" {
                                
                                self.view.makeToast("Заявка отправлена! Мы отправим вам счет на электронную почту в ближайшее время", duration: 2.0, position: .center, style:nil)
                                
                                self.timer?.invalidate()
                                self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.dismissView), userInfo: nil, repeats: false)
//
                            }
                        }
        }
        
    }
    
    func dismissView() {
       self.navigationController?.popViewController(animated: true)
    }
    
}
