//
//  MyFilesViewController+handlers.swift
//  Лин
//
//  Created by Sladkikh Alexey on 1/28/17.
//  Copyright © 2017 LeshaReva. All rights reserved.
//

import UIKit
import DigitsKit
import Firebase
import DKImagePickerController

extension MyFilesViewController {
    
    func observeUserFiles() {
        guard let uid = Digits.sharedInstance().session()?.userID else {
            print("No Digits Id")
            return
        }
        
        let ref = FIRDatabase.database().reference()
        ref.child("userFiles").child(uid).observe(.childAdded, with: { (snapshot) in
            
            let fileId = snapshot.key
            
            ref.child("files").child(fileId).observe(.value, with: {(snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let file = File(dictionary: dictionary)
                    self.filesDictionary[fileId] = file
                }
                self.attemptReloadTable()
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        
    }
    
    
    private func attemptReloadTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.08, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    
    func handleReloadTable() {
        self.files = Array(self.filesDictionary.values)
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
    
    func handleAddFile() {
        self.addFileView = AddFileView(frame: CGRect(x: 0, y: -230, width: self.view.window!.frame.size.width, height: 230))
        self.addFileView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShareLink)))
        self.view.addSubview(self.addFileView)
        
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.addFileView.addGestureRecognizer(swipeUp)
        
        
        
        
        let alert = UIAlertController(title: "Загрузить файл", message: "Какой файл загрузим?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Фото", style: .default , handler:{ (UIAlertAction)in
            self.handleSelectAttachImageView()
        }))
        
        alert.addAction(UIAlertAction(title: "Другой файл", style: .default , handler:{ (UIAlertAction)in
            
            guard let uid = Digits.sharedInstance().session()?.userID else {
                print("No Digits")
                return
            }
            
            let site = "http://leandesign.pro/#"
            let myWebsite = NSURL(string:"\(site)/upload-files/?=\(uid)")
            
            guard let url = myWebsite else {
                print("nothing found")
                return
            }
            
            UIPasteboard.general.string = String(describing: url)
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.addFileView.frame = CGRect(x: 0, y: 0, width: (self.view.window?.frame.size.width)!, height: 230)
            }, completion: nil)
            
        }))
        
        
        alert.addAction(UIAlertAction(title: "Отмена", style: UIAlertActionStyle.cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        
        self.present(alert, animated: true, completion: {
            
        })
        
    }
    
    
    
    func handleShareLink() {
        guard let uid = Digits.sharedInstance().session()?.userID else {
            print("No Digits")
            return
        }
        
        let site = Server.desktopWeb
        let myWebsite = NSURL(string:"\(site)/upload-file;userId=\(uid)")
        
        guard let url = myWebsite else {
            print("nothing found")
            return
        }
        
        let shareItems:Array = [url]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
        self.present(activityViewController, animated: true, completion: {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.addFileView.frame = CGRect(x: 0, y: -230, width: (self.view.window?.frame.size.width)!, height: 230)
            }, completion: nil)
        })
    }
    
    
    
    
    
    func handleSelectAttachImageView() {
        let pickerController = DKImagePickerController()
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            for each in assets {
                each.fetchOriginalImage(false) {
                    (image: UIImage?, info: [AnyHashable: Any]?) in
                    
                    if let selectedImage = image {
                        self.sendImagesToStorage(image: selectedImage)
                    }
                }
            }
        }
        
        self.present(pickerController, animated: true, completion: nil)
    }
    
    
    func sendImagesToStorage(image: UIImage) {
        guard let uid = Digits.sharedInstance().session()?.userID else {
            print("No Digits")
            return
        }
        let imageName = UUID().uuidString
        let imageref = FIRStorage.storage().reference().child("userFiles").child(uid).child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 1) {
            imageref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Faild upload image:", error!)
                    return
                }
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    self.sendImageToDB(imageUrl: imageUrl, image: image, imageName: imageName)
                }
            })
        }
        
    }
    
    
    func sendImageToDB(imageUrl: String, image: UIImage, imageName: String) {
        print(imageUrl)
        guard let uid = Digits.sharedInstance().session()?.userID else {
            print("No Digits")
            return
        }
        let filesRef = FIRDatabase.database().reference().child("userFiles").child(uid)
        let childRef = filesRef.childByAutoId()
        
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        
        
        let values: [String: AnyObject] = ["timestamp": timestamp, "extension": "jpg" as AnyObject, "name": imageName as AnyObject, "imageUrl": imageUrl as AnyObject, "thumbnailLink": imageUrl as AnyObject]
        
        childRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
        })
    }
    
    
}
