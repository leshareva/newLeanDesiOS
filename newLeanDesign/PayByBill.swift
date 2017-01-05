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
import Firebase

class PayByBillController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    
    let amountField = UIControls.TextField()
    let innField = UIControls.TextField()
    var timer: Timer?
    
    let commentLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 248, g: 248, b: 248)
        innField.label.text = "ИНН"
        amountField.label.text = "Сумма в руб"
        amountField.field.becomeFirstResponder()
        amountField.field.keyboardType = UIKeyboardType.decimalPad
        innField.field.keyboardType = UIKeyboardType.decimalPad
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Отправить", style: .plain, target: self, action: #selector(handleRequestBill));
        
        guard let uid = Digits.sharedInstance().session()?.userID else {
            print("no Digits ID")
            return
        }
        
        let ref = FIRDatabase.database().reference()
        ref.child("clients").child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
            if let inn = (snapshot.value as! NSDictionary)["inn"] as? String {
                self.innField.field.text = inn
                
                if let company = (snapshot.value as! NSDictionary)["fullCompany"] as? String {
                    self.commentLabel.text = "Счет выставим для \(company)"
                }
                
                if self.innField.field.text == inn {
                    self.commentLabel.isHidden = false
                } else {
                    self.commentLabel.isHidden = true
                }
            }
            
            
            
            
        }, withCancel: nil)
        
        
        setupView()
    }

    
    func setupView() {
        view.addSubview(innField)
        view.addSubview(amountField)
        view.addSubview(commentLabel)
        commentLabel.isHidden = true
        view.addConstraints("H:|[\(innField)]|", "H:|[\(amountField)]|", "H:|-16-[\(commentLabel)]-16-|")
        view.addConstraints("V:|-10-[\(amountField)]-10-[\(innField)]-10-[\(commentLabel)]")
        view.addConstraints(innField.heightAnchor == 50, amountField.heightAnchor == 50, commentLabel.heightAnchor == 20)
        
    }
    
    func handleRequestBill() {
        

        
        guard let inn = innField.field.text, !inn.isEmpty  else {
            return
        }
        
        
        let parameters: Parameters = [
            "query": "544300960537"
        ]
        
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Token 40196e2e46624942c5a1d3cdcf7792083f7d1c83",
            "Accept": "application/json"
        ]
        
        
        let url = "https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/party"
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let result = response.result.value as? AnyObject {
                    let obj = result["suggestions"] as? [AnyObject]
                   let company = obj?[0]["value"] as! String
                    self.sendToServer(company: company, inn: inn)
                }
                
        }
        
    }
    
    
    
    func sendToServer(company: String, inn: String) {
        
        guard let clientId = Digits.sharedInstance().session()?.userID, let amount = amountField.field.text, !amount.isEmpty  else {
            return
        }

                let parameters: Parameters = [
                    "clientId": clientId,
                    "amount": amount,
                    "inn": inn,
                    "company": company
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
        
                                    }
                                }
                }
    }
    
    func dismissView() {
       self.navigationController?.popViewController(animated: true)
    }
    
}
