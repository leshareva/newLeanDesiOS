//
//  UserMethods.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 1/3/17.
//  Copyright © 2017 LeshaReva. All rights reserved.
//


import Alamofire
import Firebase
import DigitsKit

class UserMethods {
    
    class func signOut() {
        Digits.sharedInstance().logOut()
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        

    }
    
}
