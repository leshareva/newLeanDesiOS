//
//  NewTaskController+handlers.swift
//  leandesign
//
//  Created by Sladkikh Alexey on 8/11/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Firebase
import DigitsKit
import DKImagePickerController

extension NewTaskController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    func handleSelectAttachImageView() {
        let pickerController = DKImagePickerController()
        
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
            
            
            for each in assets {
                each.fetchOriginalImage(false) {
                    (image: UIImage?, info: [NSObject : AnyObject]?) in
                    
                    if let selectedImage = image {
                        self.attachImageView.image = selectedImage
                    }
                }
            }
            
        }
        
        self.presentViewController(pickerController, animated: true, completion: nil)
        
    }
    
    
    func addNewTask() {
        
        
        guard let fromId = Digits.sharedInstance().session()?.userID else {
            return
        }
        
        guard let taskText = taskTextField.text where !taskText.isEmpty else {
            return
        }
        
        
        let ref = FIRDatabase.database().reference().child("tasks")
        let postRef = ref.childByAutoId()
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        let taskId = postRef.key
        let toId = "designStudio"
        let phone = Digits.sharedInstance().session()?.phoneNumber
        
        let values : [String : AnyObject] = ["fromId": fromId, "text": taskText, "taskId": taskId, "status": "none", "toId": toId, "price": 0, "phone": phone!, "rate": 0.5]
        
        postRef.setValue(values)
        postRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            let userTaskRef = FIRDatabase.database().reference().child("user-tasks").child(fromId)
            let taskId = postRef.key
            userTaskRef.updateChildValues([taskId: 1])
            
            
        }
        
        
        let messageRef = FIRDatabase.database().reference().child("tasks").child(taskId).child("messages")
        let messageРostRef = messageRef.childByAutoId()
        let messageValues = ["text": taskText, "taskId": taskId, "fromId": fromId, "toId": toId]
        messageРostRef.updateChildValues(messageValues) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            
        }
        
        self.sendTaskImageToChat(fromId, taskId: taskId)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendTaskImageToChat(fromId: String, taskId: String) {
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        let image = attachImageView.image
        let imageName = NSUUID().UUIDString
        let imageref = FIRStorage.storage().reference().child("task_image").child(imageName)
        
        if image != UIImage(named: "attach") {
            if let uploadData = UIImageJPEGRepresentation(image!, 0.8) {
                imageref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print("Faild upload image:", error)
                        return
                    }
                    if let imageUrl = metadata?.downloadURL()?.absoluteString {
                        let messageRef = FIRDatabase.database().reference().child("tasks").child(taskId).child("messages")
                        let messageРostRef = messageRef.childByAutoId()
                        let messageValues = ["imageUrl": imageUrl, "taskId": taskId, "timestamp": timestamp, "fromId": fromId]
                        messageРostRef.updateChildValues(messageValues) { (error, ref) in
                            if error != nil {
                                print(error)
                                return
                            }
                            
                        }
                    }
                })
            }
            
        }
        
        
    }
 
}
