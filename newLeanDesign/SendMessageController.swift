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
    
    
    
    func sendMessageWithProperties(properties: [String: AnyObject], taskId: String) {
        let ref = FIRDatabase.database().reference().child("messages")
        let fromId = Digits.sharedInstance().session()?.userID as String!
        let childRef = ref.childByAutoId()
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        
        let taskRef = FIRDatabase.database().reference().child("tasks").child(taskId)
        
        
        
        taskRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            guard let toId = snapshot.value!["toId"] as? String else {
                return
            }
            
            let userRef = FIRDatabase.database().reference().child("clients").child(fromId)
            userRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                var photoUrl: String?
                var name: String?
                
                if snapshot.hasChild("photoUrl") {
                    photoUrl = snapshot.value!["photoUrl"] as? String
                } else {
                    photoUrl = "/img/profile_placeholder.png"
                }
                
                if snapshot.hasChild("name") {
                    name = snapshot.value!["name"] as? String
                } else {
                    name = "none"
                }
                
                var values: [String: AnyObject] = ["taskId": taskId, "timestamp": timestamp, "fromId": fromId, "status": toId, "photoUrl": photoUrl!, "name": name!]
                
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
                    
                }
                
                }, withCancelBlock: nil)
            
            }, withCancelBlock: nil)
        
        
    }
    
    
    
}
