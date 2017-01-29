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
import Alamofire

class SendMessageController: UIViewController {
    
    
    func sendMessageToSupport(_ properties: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference().child("messages")
        
        guard let fromId = Digits.sharedInstance().session()?.userID as String! else {
            return
        }
        
        let childRef = ref.childByAutoId()
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        
        FIRDatabase.database().reference().child("admin").observeSingleEvent(of: .childAdded, with: {(snapshot) in
            let toId = snapshot.key
            
            var values: [String: AnyObject] = ["timestamp": timestamp, "fromId": fromId as AnyObject]
            
            properties.forEach({values[$0] = $1})
            
            childRef.updateChildValues(values) { (error, ref) in
                if error != nil {
                    print(error as! NSError)
                    return
                }
            }
            
            let userMessagesRef = FIRDatabase.database().reference().child("support-messages").child(fromId).child(toId)
            let messageID = childRef.key
            userMessagesRef.updateChildValues([messageID: 1])
            
            let recipientUserMessagesRef = FIRDatabase.database().reference().child("support-messages").child(toId).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageID: 1])
            
            var message = "";
            if (properties["text"] != nil) {
                message = properties["text"] as! String
            } else {
                message = "Новое сообщение"
            }
            
            let notificationRef = FIRDatabase.database().reference().child("admin").child(toId).child("unread").child(fromId)
            notificationRef.updateChildValues([messageID: 1])
            
            //send Push notification
            TaskMethods.sendPush(message: message, toId: String(toId), taskId: nil)
            
            
        }, withCancel: nil)
        
        
        
        
        
    }
    
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
                }
                
                if snapshot.hasChild("firstName") {
                    name = (snapshot.value as? NSDictionary)!["firstName"] as? String
                }
                
                var values: [String: AnyObject] = ["taskId": taskId as AnyObject, "timestamp": timestamp, "fromId": fromId as AnyObject, "status": toId as AnyObject, "photoUrl": photoUrl! as AnyObject, "name": name! as AnyObject]
                
                properties.forEach({values[$0] = $1})
                
                childRef.updateChildValues(values) { (error, ref) in
                    if error != nil {
                        print(error as! NSError)
                        return
                    }
                    
                    
                    let userMessagesRef = FIRDatabase.database().reference().child("task-messages").child(taskId)
                    let messageID = childRef.key
                    userMessagesRef.updateChildValues([messageID: 1])

                    let notificationRef = FIRDatabase.database().reference().child("designers").child(toId).child("unread").child(taskId)
                    notificationRef.updateChildValues([messageID: 1])
                    
                    
                    var message = "";
                    if (properties["text"] != nil) {
                        message = properties["text"] as! String
                    } else {
                        message = "Новое сообщение"
                    }
                    
                    //send Push notification
                   TaskMethods.sendPush(message: message, toId: toId, taskId: taskId)
  
                   
                }
                
                }, withCancel: nil)
            
            }, withCancel: nil)
        
        
    }
    
    
 
    
}

