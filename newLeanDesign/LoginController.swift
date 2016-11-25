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
    
        var startViewController: StartViewController?
    
    var taskViewController: TaskViewController?
    var newClientViewController: NewClientViewController?
    var profileViewController: ProfileViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up your own button to call Digits
        let loginButton = UIButton()
        loginButton.setTitleColor(UIColor(r: 0, g: 127, b: 255), for: UIControlState())
        loginButton.setTitle("Войти", for: UIControlState())
        loginButton.addTarget(self, action: #selector(self.didTapLoginButton(_:)), for: .touchUpInside)
        loginButton.sizeToFit()
        loginButton.center = view.center
        view.addSubview(loginButton)
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.backgroundColor = UIColor(r: 0, g: 127, b: 255)
        
        loginButton.setTitleColor(UIColor.white, for: UIControlState())
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        loginButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loginButton.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 350).isActive = true
        
    }
    
    
    
    func didTapLoginButton(_ sender: UIButton) {
        //        let configuration = DGTAuthenticationConfiguration(accountFields: .Email)
        let configuration = DGTAuthenticationConfiguration(accountFields: .defaultOptionMask)
        configuration?.appearance = DGTAppearance()
        
        configuration?.appearance.logoImage = UIImage(named: "logo")
        
        configuration?.appearance.labelFont = UIFont(name: "HelveticaNeue-Bold", size: 16)
        configuration?.appearance.bodyFont = UIFont(name: "HelveticaNeue-Italic", size: 16)
        
        configuration?.appearance.accentColor = UIColor.white
        configuration?.appearance.backgroundColor = UIColor(r: 0, g: 127, b: 255)
        
        // Change color properties to customize the look:
        
        Digits.sharedInstance().authenticate(with: nil, configuration: configuration!) { session, error in
            if session != nil {
                DispatchQueue.main.async {
                    FIRAuth.auth()?.signInAnonymously() { (user, error) in
                        if error != nil {
                            print(error)
                            return
                        }
                        self.startViewController?.checkUserInBase()
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                }
            } else {
                NSLog("Authentication error: %@", error!.localizedDescription)
            }
        }
    }
    
    
    
    
}
