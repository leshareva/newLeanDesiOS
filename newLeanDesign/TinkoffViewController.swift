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
import ASDKUI

class TinkoffViewController: UIViewController, UIWebViewDelegate {
    
    var webV: UIWebView!
    var amount: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let userId = Digits.sharedInstance().session()?.userID else {
            return
        }
        
    
        webV = UIWebView(frame: UIScreen.main.bounds)
        webV.scalesPageToFit = true
        
        webV.loadRequest(NSURLRequest(url: NSURL(string: "\(Server.serverUrl)/bills?amount=\(String(self.amount))&userId=\(userId)") as! URL) as URLRequest)
        webV.delegate = self
        self.view.addSubview(webV)

        

    }
    
    
    
    func handleDone() {
       self.dismiss(animated: true, completion: nil)
    }
    
}
