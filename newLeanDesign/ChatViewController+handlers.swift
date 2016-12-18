//
//  ChatViewController+handlers.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 12/14/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Firebase
import DigitsKit
import DKImagePickerController
import Alamofire
import Cosmos

extension ChatViewController {

    func rateUser(designerId: String) {
        let database = FIRDatabase.database().reference()
        let ref = database.child("designers").child(designerId)
 
    }
    
    
    
}
