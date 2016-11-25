//
//  SendMessageController.swift
//  newLeanDesign
//
//  Created by Sladkikh Alexey on 10/24/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Firebase
import DigitsKit

class SendMessageController: UIViewController {
    
    
    
    func sendMessageWithProperties(_ properties: [String: AnyObject], taskId: String) {
        let ref = FIRDatabase.database().reference().child("messages")
        let fromId = Digits.sharedInstance().session()?.userID as String!
        let childRef = ref.childByAutoId()
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        
        let taskRef = FIRDatabase.database().reference().child("tasks").child(taskId)
        
        
        
        taskRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let toId = (snapshot.value as? NSDictionary)?["toId"] as? String else {
                return
            }
            
            let userRef = FIRDatabase.database().reference().child("clients").child(fromId!)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                var photoUrl: String?
                var name: String?
                
                if snapshot.hasChild("photoUrl") {
                    photoUrl = (snapshot.value as? NSDictionary)!["photoUrl"] as? String
                } else {
                    photoUrl = "/img/profile_placeholder.png"
                }
                
                if snapshot.hasChild("name") {
                    name = (snapshot.value as? NSDictionary)!["name"] as? String
                } else {
                    name = "none"
                }
                
                var values: [String: AnyObject] = ["taskId": taskId as AnyObject, "timestamp": timestamp, "fromId": fromId as AnyObject, "status": toId as AnyObject, "photoUrl": photoUrl! as AnyObject, "name": name! as AnyObject]
                
                properties.forEach({values[$0] = $1})
                
                childRef.updateChildValues(values) { (error, ref) in
                    if error != nil {
                        print(error)
                        return
                    }
                    
                    
                    let userMessagesRef = FIRDatabase.database().reference().child("task-messages").child(taskId)
                    let messageID = childRef.key
                    userMessagesRef.updateChildValues([messageID: 1])

                    let notificationRef = FIRDatabase.database().reference().child("notifications").child(toId).childByAutoId()
                    notificationRef.updateChildValues(["taskId": taskId])
                    
                    
                    let tokenRef = FIRDatabase.database().reference().child("user-token").child(toId)
                    tokenRef.observe(.childAdded, with: { (snapshot) in
                        
                        let token = snapshot.key
                        print(token)
                        let pushRef = FIRDatabase.database().reference().child("push").childByAutoId()
                        let pushValues: [String: AnyObject] = ["token": token as AnyObject, "designerId": toId as AnyObject, "taskId": taskId as AnyObject]
                        pushRef.updateChildValues(pushValues) { (error, ref) in
                            if error != nil {
                                print(error)
                                return
                            }
                        }
                        
                        
                    }, withCancel: nil)
                    
                    
                    
                    
                    
                   
                }
                
                }, withCancel: nil)
            
            }, withCancel: nil)
        
        
    }
    
    
    
}
