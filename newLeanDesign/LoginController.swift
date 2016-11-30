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
import Swiftstraints

class LoginController: UIViewController {
    
        var startViewController: StartViewController?
    
    var taskViewController: TaskViewController?
    var newClientViewController: NewClientViewController?
    var profileViewController: ProfileViewController?
    
    let logoView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(named: "logo")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // Set up your own button to call Digits
    let loginButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
       
        setupView()
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
    
    func setupView() {
        view.addSubview(loginButton)
        view.addSubview(logoView)
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = UIColor(r: 0, g: 127, b: 255)
        
        loginButton.setTitleColor(UIColor.white, for: UIControlState())
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.white.cgColor
 
        loginButton.setTitleColor(UIColor(r: 255, g: 255, b: 255), for: UIControlState())
        loginButton.setTitle("Войти", for: UIControlState())
        loginButton.addTarget(self, action: #selector(self.didTapLoginButton(_:)), for: .touchUpInside)
        loginButton.sizeToFit()
        loginButton.center = view.center
        
        view.addConstraints("V:[\(loginButton)]-20-|")
        view.addConstraints("H:|-20-[\(loginButton)]-20-|")
        view.addConstraints(logoView.centerXAnchor == view.centerXAnchor,
                            logoView.centerYAnchor == view.centerYAnchor - 60,
                            loginButton.heightAnchor == 60)
        
        
    }
    
    
}
