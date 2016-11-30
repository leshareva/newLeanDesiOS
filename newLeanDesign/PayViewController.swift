//
//  PayViewController.swift
//  Lean Design
//
//  Created by Sladkikh Alexey on 11/15/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import Foundation
import UIKit
import DigitsKit
import Swiftstraints
import Caishen
import Firebase
import Alamofire
import SWXMLHash

class PayViewController: UIViewController, CardTextFieldDelegate, CardIOPaymentViewControllerDelegate, XMLParserDelegate {
    
    var amount: Int!
    
    let cardNumberTextField = CardTextField(frame:CGRect(x: 10, y: 60, width: 300, height: 40 ))
    
    let discriptionLabel: UITextView = {
        let tv = UITextView()
        tv.text = "Данные вашей карты будут в безопасности: мы используем технологии шифрования, соответствующие требованиям Visa и MasterCard."
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .lightGray
        tv.font = UIFont.systemFont(ofSize: 12)
        tv.textAlignment = .center
        tv.isEditable = false
        return tv
    }()
    
    let titleLabel: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.font = UIFont.systemFont(ofSize: 20)
        tv.textAlignment = .center
        tv.backgroundColor = .clear
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpCardTextField()
        cardNumberTextField.cardTextFieldDelegate = self
    }
    
    let errorView: UIView = {
       let uv = UIView()
        uv.backgroundColor = .red
        uv.translatesAutoresizingMaskIntoConstraints = false
        return uv
    }()
    
    let errorLabel: UITextView = {
        let tv = UITextView()
        tv.text = "Произошла ошибка"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .white
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.textAlignment = .center
        tv.backgroundColor = .clear
        tv.isEditable = false
        return tv
    }()
    
    
    func setUpCardTextField() {
        
        cardNumberTextField.cardTextFieldDelegate = self
        cardNumberTextField.placeholder = "0000000000000000"
        cardNumberTextField.becomeFirstResponder()
        
        self.view.addSubview(cardNumberTextField)
        self.view.addSubview(discriptionLabel)
        self.view.addSubview(titleLabel)
        self.view.addSubview(errorView)
        
        self.view.addConstraints(titleLabel.topAnchor == self.view.topAnchor,
                                 titleLabel.leftAnchor == self.view.leftAnchor,
                                 titleLabel.rightAnchor == self.view.rightAnchor,
                                 titleLabel.heightAnchor == 40,
                                 cardNumberTextField.widthAnchor == self.view.widthAnchor,
                                cardNumberTextField.heightAnchor == self.view.heightAnchor,
                                cardNumberTextField.centerXAnchor == self.view.centerXAnchor,
                                cardNumberTextField.topAnchor == titleLabel.topAnchor + 20,
                                discriptionLabel.topAnchor == cardNumberTextField.bottomAnchor,
                                discriptionLabel.centerXAnchor == self.view.centerXAnchor,
                                discriptionLabel.heightAnchor == 80,
                                discriptionLabel.widthAnchor == self.view.widthAnchor - 40,
                                errorView.widthAnchor == self.view.widthAnchor,
                                errorView.heightAnchor == 40,
                                errorView.topAnchor == self.view.topAnchor,
                                errorView.leftAnchor == self.view.leftAnchor
                               )
        errorView.isHidden = true
        errorView.addSubview(errorLabel)
        errorView.addConstraints("H:|-10-[\(errorLabel)]-10-|")
        errorView.addConstraints(errorLabel.heightAnchor == 24, errorLabel.centerYAnchor == errorView.centerYAnchor)
        
        titleLabel.text = "К оплате \(amount!) рублей"
        
    }
    
   
    
    func cardTextField(_ cardTextField: CardTextField, didEnterCardInformation information: Card, withValidationResult validationResult: CardValidationResult) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Оплатить", style: .plain, target: self, action: #selector(handlePay));
    }
    
    func cardTextFieldShouldShowAccessoryImage(_ cardTextField: CardTextField) -> UIImage? {
        return UIImage(named: "cards")
    }
    
    func cardTextFieldShouldProvideAccessoryAction(_ cardTextField: CardTextField) -> (() -> ())? {
        return { [weak self] _ in
            let cardIOViewController = CardIOPaymentViewController(paymentDelegate: self as! CardIOPaymentViewControllerDelegate!)
            self?.present(cardIOViewController!, animated: true, completion: nil)
        }
    }
    
   
    
    
    func handlePay() {
        
        let pan = cardNumberTextField.card.bankCardNumber
        let expiryDate = String(describing: cardNumberTextField.card.expiryDate)
        let year = expiryDate.substring(from:expiryDate.index(expiryDate.startIndex, offsetBy: 3))

        let tldEndIndex = expiryDate.index(expiryDate.startIndex, offsetBy: 2)
        let tldStartIndex = expiryDate.index(expiryDate.startIndex, offsetBy: 0)
        let range = Range(uncheckedBounds: (lower: tldStartIndex, upper: tldEndIndex))
        let month = expiryDate[range]    // "com"
        
        let cvc = cardNumberTextField.card.cardVerificationCode
        let cardHolder = "Ivan Ivanov"
        let Merchant = "VWMerchantleanmysmaxomPay"
        
        
        let database = FIRDatabase.database().reference()
        
        let crateId = database.child("payture").childByAutoId()
        let orderId = crateId.key
        
        let payInfo = "PAN%3D\(pan)%3BEMonth%3D\(month)%3BEYear%3D\(year)%3BCardHolder%3D\(cardHolder)%3BSecureCode%3D\(cvc)%3BOrderId%3D\(orderId)"
        
        let parameters: Parameters = [
            "Key": Merchant,
            "Amount": self.amount,
            "OrderId": orderId,
            "PayInfo": payInfo
        ]
        
        
        Alamofire.request("https://sandbox2.payture.com/api/Pay",
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding(destination: .methodDependent))
            .responseData { response in
            switch response.result {
                
            case .success:
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                     let xml = SWXMLHash.parse(utf8Text)
                    let success = xml["Pay"].element?.attribute(by: "Success")?.text
                    if success! == "3DS" {
                        
                        let PaReq = xml["Pay"].element?.attribute(by: "PaReq")?.text
                        let newParametres: Parameters = [
                            "Key": Merchant,
                            "OrderId": orderId,
                            "PaRes": PaReq!
                        ]

                        Alamofire.request("https://sandbox2.payture.com/api/Pay3DS",
                                          method: .post,
                                          parameters: newParametres,
                                          encoding: URLEncoding(destination: .methodDependent))
                            .responseData { response in
                                switch response.result {
                                case .success:
                                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                                        print(utf8Text)
                                    }
                                case .failure(let error):
                                    print(error)
                                }
                        }
                    } else if success! == "True" {
                        
                        if let uid = Digits.sharedInstance().session()?.userID {
                        let userRef = database.child("clients").child(uid)
                            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                let oldAmount = (snapshot.value as? NSDictionary)!["sum"] as? Int
                                let newAmount = Int(oldAmount!) + Int(self.amount!)
                                let clientEmail = (snapshot.value as? NSDictionary)!["email"] as? String
                                
                                let values: [String : AnyObject] = ["sum": newAmount as AnyObject]
                                userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                                    if error != nil {
                                        print(error!)
                                        return
                                    }
                                })
                                
                                
                                
                            }, withCancel: nil)
                        }
                       
                       
                        self.dismiss(animated: true, completion: nil)
                        
                    } else {
                        let error = xml["Pay"].element?.attribute(by: "ErrCode")?.text
                        self.errorView.isHidden = false
                        self.errorLabel.text = "Платеж не прошел. Попробуйте еще раз"
                        print("False:", error!)
                       
                    }
                }
                
            case .failure(let error):
                print(error)
                }
        }
        
    }
    
    
    /// This method will be called when there is a successful scan (or manual entry). You MUST dismiss paymentViewController.
    /// @param cardInfo The results of the scan.
    /// @param paymentViewController The active CardIOPaymentViewController.
    public func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        cardNumberTextField.prefill(cardInfo.cardNumber,
                                    month: Int(cardInfo.expiryMonth),
                                    year: Int(cardInfo.expiryYear),
                                    cvc: cardInfo.cvv)
        
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    
    
    /// This method will be called if the user cancels the scan. You MUST dismiss paymentViewController.
    /// @param paymentViewController The active CardIOPaymentViewController.
    public func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismiss(animated: true, completion: nil)
    }


    
}

struct Book: XMLIndexerDeserializable {
    let pay: String
    let success: String
    
    static func deserialize(_ node: XMLIndexer) throws -> Book {
        return try Book(
            pay: node["Pay"].value(),
            success: node.value(ofAttribute: "Success")
        )
    }
}

