//
//  LoginController.swift
//  leandesign
//
//  Created by Sladkikh Alexey on 8/10/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import DigitsKit
import Firebase

class LoginController: UIViewController {
    
    //    var tasksListController: TasksListController?
    var taskViewController: TaskViewController?
    var newClientViewController: NewClientViewController?
    var profileViewController: ProfileViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up your own button to call Digits
        let loginButton = UIButton()
        loginButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        loginButton.setTitle("Войти", forState: .Normal)
        loginButton.addTarget(self, action: #selector(self.didTapLoginButton(_:)), forControlEvents: .TouchUpInside)
        loginButton.sizeToFit()
        loginButton.center = view.center
        view.addSubview(loginButton)
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.backgroundColor = UIColor(r: 48, g: 140, b: 229)
        
        loginButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.whiteColor().CGColor
        loginButton.leftAnchor.constraintEqualToAnchor(view.leftAnchor, constant: 15).active = true
        loginButton.rightAnchor.constraintEqualToAnchor(view.rightAnchor, constant: -15).active = true
        loginButton.heightAnchor.constraintEqualToConstant(50).active = true
        loginButton.bottomAnchor.constraintEqualToAnchor(view.topAnchor, constant: 350).active = true
        
    }
    
    
    
    func didTapLoginButton(sender: UIButton) {
        //        let configuration = DGTAuthenticationConfiguration(accountFields: .Email)
        let configuration = DGTAuthenticationConfiguration(accountFields: .DefaultOptionMask)
        configuration.appearance = DGTAppearance()
        
        configuration.appearance.logoImage = UIImage(named: "logo")
        
        configuration.appearance.labelFont = UIFont(name: "HelveticaNeue-Bold", size: 16)
        configuration.appearance.bodyFont = UIFont(name: "HelveticaNeue-Italic", size: 16)
        
        configuration.appearance.accentColor = UIColor.whiteColor()
        configuration.appearance.backgroundColor = UIColor(r: 48, g: 140, b: 229)
        
        // Change color properties to customize the look:
        
        Digits.sharedInstance().authenticateWithViewController(nil, configuration: configuration) { session, error in
            if session != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    FIRAuth.auth()?.signInAnonymouslyWithCompletion() { (user, error) in
                        if error != nil {
                            print(error)
                            return
                        }
                        
                        
                        
                        
                        self.taskViewController?.checkUserInBase()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                }
            } else {
                NSLog("Authentication error: %@", error!.localizedDescription)
            }
        }
    }
    
    
    
    
}
