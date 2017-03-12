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
import Alamofire

extension NewTaskController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func handleSelectAttachImageView() {
        let pickerController = DKImagePickerController()

        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            for each in assets {
                each.fetchOriginalImage(false) {
                    (image: UIImage?, info: [AnyHashable: Any]?) in
                    
                    if let selectedImage = image {
                        self.attachImageView.image = selectedImage
                        self.attachCounter = self.attachCounter + 1
                        self.attachImageView.isHidden = false
                    }
                }
            }
        }
        
        self.present(pickerController, animated: true, completion: nil)
    }
    
    
    func addNewTask() {
        guard let userId = Digits.sharedInstance().session()?.userID else {
            return
        }
        
        guard let taskText = taskTextField.text, !taskText.isEmpty else {
            return
        }

        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        let phone = Digits.sharedInstance().session()?.phoneNumber
        
        let parameters: Parameters = [
            "userId": userId,
            "text": taskText
        ]
        
        Alamofire.request("\(Server.serverUrl)/tasks/create",
            method: .post,
            parameters: parameters).responseJSON { response in

                if let result = response.result.value as? [String: Any] {
                    let taskId = result["taskId"]
                    
                    if( self.attachImageView.image != nil) {
                        self.sendImagesToStorage(userId, taskId: taskId! as! String)
                    }
                    
                    self.view.endEditing(true)
                    self.dismiss(animated: true, completion: nil)
                    
                }
        }
        
        
    }
    

    func sendImagesToStorage(_ fromId: String, taskId: String) {
//        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        let image = attachImageView.image
        let imageName = UUID().uuidString
        let imageref = FIRStorage.storage().reference().child("tasks").child(taskId).child(imageName)
        
        if image != UIImage(named: "attach") {
            if let uploadData = UIImageJPEGRepresentation(image!, 0.8) {
                imageref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print("Faild upload image:", error!)
                        return
                    }
                    if let imageUrl = metadata?.downloadURL()?.absoluteString {
                        self.saveDataToFirebase(imageUrl: imageUrl, taskId: taskId)
                    }
                })
            }
            
        }
    }
    

    
    fileprivate func saveDataToFirebase(imageUrl: String, taskId: String) {
        
        let taskRef = FIRDatabase.database().reference().child("tasks").child(taskId).child("attach")
        let childRef = taskRef.childByAutoId().key
        
        taskRef.updateChildValues([childRef:imageUrl]) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
        }

    }
    
   
    func handleAboutPrice() {
        let pricesViewController = PricesViewController()
        navigationController?.present(pricesViewController, animated: true, completion: nil)
    }
    
    func handleAboutTasks() {
        let howTaskingViewController = HowTaskingViewController()
        navigationController?.pushViewController(howTaskingViewController, animated: true)
    }
    
    
 
}
