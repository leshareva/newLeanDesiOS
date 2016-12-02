//
//  LicenseViewController.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 11/27/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash
import CryptoSwift


class LicenseViewController: UIViewController, UIWebViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webV:UIWebView = UIWebView(frame: UIScreen.main.bounds)
        webV.loadRequest(NSURLRequest(url: NSURL(string: "\(Server.serverUrl)/pay") as! URL) as URLRequest)
        webV.delegate = self
        self.view.addSubview(webV)
        
        
//        let email = "leshareva.box%40gmail.com"
//        
//        let terminalKey = "1480564341918DEMO"
//        let description = "Тестовый платеж"
//        
//        let data = "Email=\(email)"
//        let password = "1f272aw4aqe9lwm2"
//        
//        
//        
//        let parameters: [String : Any] = [
//            "TerminalKey": terminalKey,
//            "Amount": 2,
//            "OrderId": "234234asdf234",
//            "Description": description,
//            "DATA": data,
//            "Password": password
//        ]
//        
//        let sortedKeysAndValues = parameters.sorted(by: { $0.0 < $1.0 })
//        print(sortedKeysAndValues)
//        
//        let cookieHeader = (sortedKeysAndValues.flatMap({ (key, value) -> String in
//            return "\(key)=\(value)"
//        }) as Array).joined(separator: "")
//        print(cookieHeader)
//        
//        let hash = cookieHeader.sha256()
//        print("shaHex: \(hash)")
//        
//        Alamofire.request("https://securepay.tinkoff.ru/rest",
//                                    method: .post,
//                                  parameters: hash)
//            .responseData { response in
//                switch response.result {
//                case .success:
//                    print("Validation Successful")
//                case .failure(let error):
//                    print(error)
//                }
//        }
    }

    


  
}
