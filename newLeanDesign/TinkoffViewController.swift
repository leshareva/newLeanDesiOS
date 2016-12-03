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
    
    
    var amount: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let clientId = Digits.sharedInstance().session()?.userID else {
            return
        }
     

            let orderRef = FIRDatabase.database().reference().child("orders")
            let childRef = orderRef.childByAutoId()
            let orderId = childRef.key

            
            let values: [String: AnyObject] = ["clientId": clientId as AnyObject, "amount": self.amount as AnyObject]
            
            childRef.updateChildValues(values)
            
            let webV:UIWebView = UIWebView(frame: UIScreen.main.bounds)
            webV.loadRequest(NSURLRequest(url: NSURL(string: "\(Server.serverUrl)/pay?amount=\(self.amount!)&orderId=\(orderId)") as! URL) as URLRequest)
            webV.delegate = self
            self.view.addSubview(webV)

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        
        
        
        
//        let parameters: Parameters = [
//            "clientId": clientId
//        ]
        
        
//        Alamofire.request("\(Server.serverUrl)/pay",
//            method: .get,
//            parameters: parameters)
        

    }
    
    func handleDone() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
