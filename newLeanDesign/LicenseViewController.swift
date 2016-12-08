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
        webV.loadRequest(NSURLRequest(url: NSURL(string: "http://lean.mysmaxom.com/license/") as! URL) as URLRequest)
        webV.delegate = self
        self.view.addSubview(webV)
  
    }
}
