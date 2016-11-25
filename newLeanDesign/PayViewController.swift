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


class PayViewController: UIViewController {

    
    let discriptionLabel: UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = UIColor.white
        tv.textAlignment = .left
        tv.numberOfLines = 3
        return tv
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
//        let webV:UIWebView = UIWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
//        
//        var request = URLRequest(url: URL(string: "http://www.leandesign.pro:8000")!)
//        request.httpMethod = "POST"
//        
//        if let uid = Digits.sharedInstance().session()?.userID {
//         
//            let postString = "clientId=\(uid)"
//            request.httpBody = postString.data(using: .utf8)
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                guard let data = data, error == nil else {                                                 // check for fundamental networking error
//                    print("error=\(error)")
//                    return
//                }
//                
//                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
//                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
//                    print("response = \(response)")
//                }
//                
//                let responseString = String(data: data, encoding: .utf8)
//                print("responseString = \(responseString)")
//            }
//            task.resume()
//         
//            
//        }
        
    }
    
    func setupView() {
    
        
    
    }

}
