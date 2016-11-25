
//
//  ViewController.swift
//  newLeanDesign
//
//  Created by Sladkikh Alexey on 11/6/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Firebase
import DigitsKit
import Swiftstraints

class StartViewController: UIViewController {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "launch")
       return iv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        
        view.addConstraints("H:|[\(imageView)]|")
        view.addConstraints("V:|[\(imageView)]|")
        
        view.backgroundColor = UIColor(r: 0, g: 127, b: 255)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        checkIfUserIsLoggedIn()
    }
    
    func checkIfUserIsLoggedIn() {
        let digits = Digits.sharedInstance()
        let digitsUid = digits.session()?.userID
        
        if digitsUid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            checkUserInBase()
        }
    }
    
    
    func checkUserInBase() {
        guard let userId = Digits.sharedInstance().session()?.userID else {
            return
        }
        
        let ref = FIRDatabase.database().reference()
        let clientsReference = ref.child("clients")
        
        clientsReference.observe(.value, with: { (snapshot) in
            if snapshot.hasChild(userId) {
                print("it's our client!")
                let taskViewController = TaskViewController()
                self.navigationController?.pushViewController(taskViewController, animated: true)
                
            } else {
                print("itsn't our client!")
                let newClientViewController = NewClientViewController()
                let navController = UINavigationController(rootViewController: newClientViewController)
                self.present(navController, animated: true, completion: nil) 
            }
            
        
            }, withCancel: nil)
    }
    
    
    
    
    func handleLogout() {
        Digits.sharedInstance().logOut()
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.startViewController = self
        present(loginController, animated: true, completion: nil)
    }
    
}
