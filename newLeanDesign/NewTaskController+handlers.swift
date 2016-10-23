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
            
            let taskId = postRef.key
            
            let activeTaskRef = FIRDatabase.database().reference().child("active-tasks").child(fromId)
            activeTaskRef.updateChildValues([taskId: 1])
            
        }
        
        
        let messageRef = FIRDatabase.database().reference().child("messages")
        let messageРostRef = messageRef.childByAutoId()
        let messageValues = ["text": taskText, "taskId": taskId, "fromId": fromId, "toId": toId]
        messageРostRef.updateChildValues(messageValues) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            
        }
        
        let userMessagesRef = FIRDatabase.database().reference().child("task-messages").child(taskId)
        let messageID = messageРostRef.key
        userMessagesRef.updateChildValues([messageID: 1])
        
        view.endEditing(true)
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
                        self.sendMessageWithImageUrl(imageUrl, image: image!, taskId: taskId)
                    }
                })
            }
            
        }
        
        
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage, taskId: String) {
        let properties: [String: AnyObject] = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height]
        
        sendMessageWithProperties(properties, taskId: taskId)
    }
    
    private func sendMessageWithProperties(properties: [String: AnyObject], taskId: String) {
//        let taskId = task?.taskId as String!
        let ref = FIRDatabase.database().reference().child("messages")
        let fromId = Digits.sharedInstance().session()?.userID as String!
        let childRef = ref.childByAutoId()
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        
        
        var values: [String: AnyObject] = ["taskId": taskId, "timestamp": timestamp, "fromId": fromId, "status": "toDesigner"]
        
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            
        }
        
        let userMessagesRef = FIRDatabase.database().reference().child("task-messages").child(taskId)
        let messageID = childRef.key
        userMessagesRef.updateChildValues([messageID: 1])
        
    }
 
}
