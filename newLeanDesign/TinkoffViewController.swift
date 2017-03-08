//
//  tinkoffView.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 12/1/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash
import CryptoSwift
import DigitsKit
import Firebase

class TinkoffViewController: UIViewController, UIWebViewDelegate {
    
    var webV: UIWebView!
    var amount: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let clientId = Digits.sharedInstance().session()?.userID else {
            return
        }
     
            let orderId = NSNumber(value: Int(Date().timeIntervalSince1970)) 
            let orderRef = FIRDatabase.database().reference().child("orders").child(String(describing: orderId))
            let values: [String: AnyObject] = ["clientId": clientId as AnyObject, "amount": self.amount as AnyObject]
            
            orderRef.updateChildValues(values)
            
            webV = UIWebView(frame: UIScreen.main.bounds)
            webV.loadRequest(NSURLRequest(url: NSURL(string: "\(Server.serverUrl)/pay?amount=\(self.amount!)&orderId=\(orderId)") as! URL) as URLRequest)
            webV.delegate = self
            self.view.addSubview(webV)

//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        
        
        
//        attemptLoadInfo()
        

    }
    
//    var timer: Timer?
//    
//    private func attemptLoadInfo() {
//        self.timer?.invalidate()
//        
//        self.timer = Timer.scheduledTimer(timeInterval: 2.24, target: self, selector: #selector(self.handleLoadValue), userInfo: nil, repeats: false)
//    }
//    
//    func handleLoadValue() {
//        let html = webV.stringByEvaluatingJavaScript(from: "document.getElementById('pay-form-container').innerHTML")
//        print(html)
//    }
//    
    
    func handleDone() {
       self.dismiss(animated: true, completion: nil)
    }
    
}
