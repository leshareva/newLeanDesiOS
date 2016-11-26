//
//  PayViewController.swift
//  Lean Design
//
//  Created by Sladkikh Alexey on 11/15/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import DigitsKit
import Swiftstraints
import Caishen
import SnapKit
import Firebase

class PayViewController: UIViewController, CardTextFieldDelegate, CardIOPaymentViewControllerDelegate {

    
 
    let size = UIScreen.main.bounds

    
    let cardNumberTextField = CardTextField(frame:CGRect(x: 20, y: 0, width: 300, height: 400 ))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        
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
//      UIButtonon?.isEnabled = validationResult == .Valid
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
//        let orderId = "3D21022602304402246475170161136321512"
        
        let database = FIRDatabase.database().reference()
        
        let orderId = database.child("payture").childByAutoId()
        
        let payInfo = "PAN%3D\(pan)%3BEMonth%3D\(month)%3BEYear%3D\(year)%3BCardHolder%3D\(cardHolder)%3BSecureCode%3D\(cvc)%3BOrderId%3D\(orderId)"

        
        var request = URLRequest(url: URL(string: "https://sandbox2.payture.com/api/Pay")!)
        request.httpMethod = "POST"
        let postString = "Key=\(Merchant)&Amount=\(amount)&OrderId=\(orderId)&PayInfo=\(payInfo)"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
        
        
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


