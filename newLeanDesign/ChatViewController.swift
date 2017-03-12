//
//  ChatViewController.swift
//  leandesign
//
//  Created by Sladkikh Alexey on 8/17/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Firebase
import DigitsKit
import DKImagePickerController
import Swiftstraints
import Cosmos

class ChatViewController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    let cashe = NSCache<AnyObject, AnyObject>()
    var designerPic: String?
    
    var task: Task? {
        didSet {
            observeMessages()
        }
    }
    
    var user: User?
    
    var messages = [Message]()
    var sentMessages = [String]()
    var defaults = UserDefaults.standard
    let cellId = "cellId"
    
    lazy var inputContainerView: ChatInputView = {
        let chatInputView = ChatInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputView.chatViewController = self
        return chatInputView
    }()
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        collectionView?.contentInset = UIEdgeInsets(top: 54, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        
        setupNavbarWithUser()
        setupStepsView()
        setupKeyboardObservers()
        deleteUnread()
    }
    

    func deleteUnread() {
        guard let taskId = self.task?.taskId, let userId = Digits.sharedInstance().session()?.userID else {
            return
        }
        
        let unreadRef = FIRDatabase.database().reference().child("clients").child(userId).child("unread").child(taskId)
        unreadRef.removeValue()
        
    }
    
    func observeMessages() {
        guard let taskId = self.task?.taskId else {
            return
        }
        
        let userMessagesRef = FIRDatabase.database().reference().child("task-messages").child(taskId)
        userMessagesRef.queryLimited(toLast: 20).observe(.childAdded, with: { (snapshot) in
            
            let taskMessagesRef = FIRDatabase.database().reference().child("messages").child(snapshot.key)
            taskMessagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let status = (snapshot.value as? NSDictionary)!["status"] as? String
                if status == self.task!.fromId {
                    
                    let values : [String: AnyObject] = ["status": "read" as AnyObject]
                    taskMessagesRef.updateChildValues(values) { (error, ref) in
                        if error != nil {
                            print(error!)
                            return
                        }
                    }
                }
                
                guard var dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                if let text = dictionary["text"] as? String {
                    if self.sentMessages.contains(text){
                    } else {
                        self.messages.append(Message(dictionary: dictionary))
                    }
                }
                
                if let imageUrl = dictionary["imageUrl"] as? String {
                    if self.sentMessages.contains(imageUrl){
                    } else {
                        self.messages.append(Message(dictionary: dictionary))
                    }
                }
                
                
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    //scroll to the last index
                    let indexPath = IndexPath(item: self.messages.count-1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                })
            }, withCancel: nil)
        }, withCancel: nil)
    }
    


    func setupNavbarWithUser() {
        let titleView = TitleNavBarView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openDesignerProfile)))
        
        
        guard let designerId = task?.toId else {
            return
        }
            
        let ref = FIRDatabase.database().reference().child("designers").child(designerId)
         ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let imageUrl = (snapshot.value as? NSDictionary)!["photoUrl"] as? String {
                        self.designerPic = imageUrl
                        titleView.userPic.loadImageUsingCashWithUrlString(imageUrl)
                    }
                    
                    if let name = (snapshot.value as? NSDictionary)!["firstName"] as? String {
                     titleView.nameLabel.text = name
                    }
                }, withCancel: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: titleView)
    }
    

    
    var assets: [DKAsset]?
    
    func handleUploadTap() {
        let pickerController = DKImagePickerController()
        pickerController.didSelectAssets = { (assets: [DKAsset]) in

            for each in assets {
                each.fetchOriginalImage(false) {
                    (image: UIImage?, info: [AnyHashable: Any]?) in
                   
                    self.uploadToFirebaseStorageUsingImage(image!)
                }
            }
        }
        
        self.present(pickerController, animated: true, completion: nil)
    }
    
    
    
    fileprivate func uploadToFirebaseStorageUsingImage(_ image: UIImage) {
        let imageName = UUID().uuidString
        let ref = FIRStorage.storage().reference().child("message_image").child(imageName)
        
        if let uploadData = image.jpegData(.lowest) {
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Faild upload image:", error as Any!)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    print(imageUrl)
                    self.sendMessageWithImageUrl(imageUrl, image: image)
                }
                
            })
        }
    }
    
    
    let sendMessageController = SendMessageController()
    
    fileprivate func sendMessageWithImageUrl(_ imageUrl: String, image: UIImage) {
         let taskId = task?.taskId as String!
         let fromId = Digits.sharedInstance().session()?.userID as String!
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject, "taskId": taskId as AnyObject, "timestamp": timestamp as AnyObject, "fromId": fromId as AnyObject]
        
        
        self.sentMessages.append(String(imageUrl))
        self.messages.append(Message(dictionary: properties))
        
        DispatchQueue.main.async(execute: {
            self.collectionView?.reloadData()
        })
       
        self.sendMessageController.sendMessageWithProperties(properties, taskId: taskId!)
    }
    
    
    func handleSend() {
        guard let messageText = inputContainerView.messageField.text else {
            return
        }
        
        if messageText != "" {
            let taskId = task?.taskId as String!
           
            let fromId = Digits.sharedInstance().session()?.userID as String!
            
            let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))

            let dictionary: [String: AnyObject] = ["text": messageText as AnyObject, "taskId": taskId as AnyObject, "timestamp": timestamp, "fromId": fromId as AnyObject]
            self.sentMessages.append(String(messageText))
            
            self.messages.append(Message(dictionary: dictionary))
            
            
            DispatchQueue.main.async(execute: {
                self.collectionView?.reloadData()
            })
            
            let properties: [String: AnyObject] = ["text": messageText as AnyObject]
            self.sendMessageController.sendMessageWithProperties(properties, taskId: taskId!)
            
            inputContainerView.messageField.text = nil
        } 
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    

    var containerViewBottomAnchor: NSLayoutConstraint?
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }

    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    
    func setupKeyboardObservers() {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
                NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
//    func handleKeyboardDidShow() {
//        if messages.count >= 3 {
//            let indexPath = NSIndexPath(forItem: messages.count - 1, inSection: 0)
//            collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
//        }
//        
//    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleKeyboardWillShow(_ notification: Notification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        }) 
    }
    
    func handleKeyboardWillHide(_ notification: Notification) {
//        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        }) 
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
    
        setupCell(cell, message: message)

        
        // lets modify the bubble width somehow??
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            //fall in here if its an image message
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
            
        }
        
        if self.designerPic != nil {
           cell.profileImageView.loadImageUsingCashWithUrlString(self.designerPic!)
        }
        
        return cell
    }

    
    fileprivate func setupCell(_ cell: ChatMessageCell, message: Message) {
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCashWithUrlString(messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.textView.isHidden = true
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
            cell.textView.dataDetectorTypes = UIDataDetectorTypes.all
        }

        if message.fromId == Digits.sharedInstance().session()?.userID {
            //outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = true
            cell.bubleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            //incominug gray
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            cell.bubleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            //h1 / w1 = h2 / w2
            //solve for h1
            //h1 = h2 / w2 * w1
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
   
    
    func performZoomInForImageView(_ startingImageView: UIImageView) {
    
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        let zoomingImageView = ZoomingImageView(frame: startingFrame!)
    
        zoomingImageView.imageView.image = startingImageView.image
       
        zoomingImageView.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            inputContainerView.alpha = 1
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                
                
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: keyWindow.frame.height)
                
                zoomingImageView.imageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                 
                zoomingImageView.imageView.center = keyWindow.center
                
                }, completion: nil)
        }
    }
    
    
    func handleZoomOut(_ tapGesture: UITapGestureRecognizer ) {
        
        if let zoomOutImageView = tapGesture.view {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame  = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                }, completion: { (completed: Bool) in
                    zoomOutImageView.removeFromSuperview()
                    self.startingImageView?.isHidden = false
            })
        }
    }
 
    
}



class MyTapGesture: UITapGestureRecognizer {
    var message: Message?
    var status: String?
    var task: Task?
    var indexPath: IndexPath?
    var taskIndex: Int?
    var string: String?
    var anyobj: NSDictionary?
}
