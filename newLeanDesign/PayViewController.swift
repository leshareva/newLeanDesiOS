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

    let cardNumberTextField = CardTextField(frame:CGRect(x: 20, y: 0, width: 300, height: 400 ))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setUpCardTextField()
        cardNumberTextField.cardTextFieldDelegate = self
    }

    func setUpCardTextField() {
        
        cardNumberTextField.cardTextFieldDelegate = self
        cardNumberTextField.placeholder = "0000000000000000"
        self.view.addSubview(cardNumberTextField)
        self.view.addConstraints(cardNumberTextField.widthAnchor == self.view.widthAnchor,
                                cardNumberTextField.heightAnchor == self.view.heightAnchor,
                                cardNumberTextField.centerXAnchor == self.view.centerXAnchor,
                                cardNumberTextField.topAnchor == self.view.topAnchor
                               )
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
        let amount = "100"
        
        let database = FIRDatabase.database().reference()
        
        let crateId = database.child("payture").childByAutoId()
        let orderId = crateId.key
        
        let payInfo = "PAN%3D\(pan)%3BEMonth%3D\(month)%3BEYear%3D\(year)%3BCardHolder%3D\(cardHolder)%3BSecureCode%3D\(cvc)%3BOrderId%3D\(orderId)"
        
        let parameters: Parameters = [
            "Key": Merchant,
            "Amount": amount,
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
                        print(utf8Text)
                        if let uid = Digits.sharedInstance().session()?.userID {
                        let userRef = database.child("clients").child(uid)
                            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                let oldAmount = (snapshot.value as? NSDictionary)!["sum"] as? Int
                                let newAmount = Int(oldAmount!) + Int(amount)!
                                print(newAmount)
                                let values: [String : AnyObject] = ["sum": newAmount as AnyObject]
                                userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                                    if error != nil {
                                        print(error!)
                                        return
                                    }
                                })
                            }, withCancel: nil)
                        }
                       
                        let payViewController = PayViewController()
                        payViewController.dismiss(animated: true, completion: nil)
                        
                    } else {
                        let error = xml["Pay"].element?.attribute(by: "ErrCode")?.text
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

