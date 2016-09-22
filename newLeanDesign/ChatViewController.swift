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

class ChatViewController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    let cashe = NSCache()
    
    var task: Task? {
        didSet {
            observeMessages()
        }
    }
    
    var user: User? {
        didSet {
            
        }
    }
    
    var messages = [Message]()
    
    
    func observeMessages() {
        guard let taskId = self.task?.taskId else {
            return
        }
        
        let taskMessagesRef = FIRDatabase.database().reference().child("tasks").child(taskId).child("messages")
        taskMessagesRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let status = snapshot.value!["status"] as? String
            if status == "toClient" {
                let key = snapshot.key
                let values : [String: AnyObject] = ["status": "read"]
                taskMessagesRef.child(key).updateChildValues(values) { (error, ref) in
                    if error != nil {
                        print(error)
                        return
                    }
                }
            }
            
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            self.messages.append(Message(dictionary: dictionary))
            
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView?.reloadData()
                
                //scroll to the last index
                let indexPath = NSIndexPath(forItem: self.messages.count-1, inSection: 0)
                self.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
                
            })
            }, withCancelBlock: nil)
        
    }
    
    
    lazy var messageField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.registerClass(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .Interactive
        
        setupNavbarWithUser()
        
        //        setupKeyboardObservers()
    }
    
    
    func setupNavbarWithUser() {
        let titleView = UIImageView()
        titleView.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        
        
        titleView.layer.cornerRadius = 18
        titleView.layer.masksToBounds = true
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openDesignerProfile)))
        titleView.userInteractionEnabled = true
        
        if let imageUrl = task!.imageUrl {
            titleView.loadImageUsingCashWithUrlString(imageUrl)
        }
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: titleView)
    }
    
    func openDesignerProfile() {
        let userProfileViewController = UserProfileViewController()
        userProfileViewController.task = task
        userProfileViewController.view.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
    
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.whiteColor()
        
        let uploadImage = UIImageView()
        uploadImage.userInteractionEnabled = true
        uploadImage.image = UIImage(named: "addimage")
        uploadImage.translatesAutoresizingMaskIntoConstraints = false
        uploadImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        
        containerView.addSubview(uploadImage)
        uploadImage.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor, constant: 8).active = true
        uploadImage.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        uploadImage.widthAnchor.constraintEqualToConstant(32).active = true
        uploadImage.heightAnchor.constraintEqualToConstant(32).active = true
        
        let sendButton = UIButton(type: .System)
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), forControlEvents: .TouchUpInside)
        
        containerView.addSubview(sendButton)
        sendButton.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        sendButton.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        sendButton.widthAnchor.constraintEqualToConstant(80).active = true
        sendButton.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor).active = true
        
        
        
        
        containerView.addSubview(self.messageField)
        self.messageField.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        self.messageField.leftAnchor.constraintEqualToAnchor(uploadImage.rightAnchor, constant: 8).active = true
        self.messageField.rightAnchor.constraintEqualToAnchor(sendButton.leftAnchor).active = true
        self.messageField.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor, constant: -10).active = true
        
        let separator = UIView()
        separator.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(separator)
        
        separator.bottomAnchor.constraintEqualToAnchor(containerView.topAnchor).active = true
        separator.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        separator.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        separator.heightAnchor.constraintEqualToConstant(0.5).active = true
        
        
        return containerView
        
    }()
    
    var assets: [DKAsset]?
    
    func handleUploadTap() {
        let pickerController = DKImagePickerController()
        
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
            
            for each in assets {
                each.fetchOriginalImage(false) {
                    (image: UIImage?, info: [NSObject : AnyObject]?) in
                    let imageData: NSData = UIImagePNGRepresentation(image!)!
                    self.uploadToFirebaseStorageUsingImage(image!)
                }
            }
            
        }
        
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage) {
        let imageName = NSUUID().UUIDString
        let ref = FIRStorage.storage().reference().child("message_image").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Faild upload image:", error)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    print(imageUrl)
                    self.sendMessageWithImageUrl(imageUrl, image: image)
                }
                
            })
        }
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        let properties: [String: AnyObject] = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height]
        
        sendMessageWithProperties(properties)
    }
    
    func handleSend() {
        guard let messageText = messageField.text else {
            return
        }
        let properties: [String: AnyObject] = ["text": messageText]
        sendMessageWithProperties(properties)
    }
    
    private func sendMessageWithProperties(properties: [String: AnyObject]) {
        let taskId = task?.taskId as String!
        let ref = FIRDatabase.database().reference().child("tasks").child(taskId).child("messages")
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
            
            self.messageField.text = nil
            
        }
    }
    
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    
    func setupKeyboardObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        //
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = NSIndexPath(forItem: messages.count - 1, inSection: 0)
            collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        }
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func handleKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animateWithDuration(keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        containerViewBottomAnchor?.constant = 0
        UIView.animateWithDuration(keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        
        let tappy = MyTapGesture(target: self, action: #selector(self.handleAwareness(_:)))
        
        setupCell(cell, message: message)
        
        
        
        // lets modify the bubble width somehow??
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text).width + 32
            cell.textView.hidden = false
       
        } else if let awareness = message.awareness {
           cell.textView.hidden = false
            cell.textView.userInteractionEnabled = true
            checkTaskStatus(cell)
            cell.textView.addGestureRecognizer(tappy)
            tappy.message = message
        } else if let concept = message.concept {
            cell.textView.hidden = false
            cell.textView.userInteractionEnabled = true
            cell.textView.addGestureRecognizer(tappy)
            checkTaskStatus(cell)
            tappy.message = message
        } else if message.imageUrl != nil {
            //fall in here if its an image message
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.hidden = true
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        }
        
        if let photoUrl = message.photoUrl {
            cell.profileImageView.loadImageUsingCashWithUrlString(photoUrl)
        }
        return cell
    }
    
    
    func checkTaskStatus(cell: ChatMessageCell) {
        let taskId = task?.taskId
        let ref = FIRDatabase.database().reference().child("tasks").child(taskId!)
        ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            guard let status = snapshot.value!["status"] as? String else {
                return
            }
            
            let statusLength = status.characters.count
            var child = ""
            if statusLength <= 7 {
                return
            } else {
                let index1 = status.endIndex.advancedBy(-7)
                child = status.substringToIndex(index1)
            }
            ref.child(child).observeEventType(.Value, withBlock: { (snapshot) in
                guard let status = snapshot.value!["status"] as? String else {
                    return
                }
                
                if status == "none" {
                    cell.bubbleView.backgroundColor = UIColor(r: 203, g: 255, b: 128)
                } else {
                    cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
                }
                
                }, withCancelBlock: nil)
            
            
            
            }, withCancelBlock: nil)
    }
    
    
    func handleAwareness(sender : MyTapGesture) {
        if sender.message?.awareness != nil {
            let awarenessViewController = AwarenessViewController()
            awarenessViewController.view.backgroundColor = UIColor.whiteColor()
            awarenessViewController.task = task
            awarenessViewController.message = sender.message!
            awarenessViewController.setupView(sender.message!)
            navigationController?.pushViewController(awarenessViewController, animated: true)
        } else if sender.message?.concept != nil {
            let flowLayout = UICollectionViewFlowLayout()
            let conceptViewController = ConceptViewController(collectionViewLayout: flowLayout)
            conceptViewController.view.backgroundColor = UIColor.whiteColor()
            conceptViewController.task = task
            navigationController?.pushViewController(conceptViewController, animated: true)
        }
        
    }
    
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCashWithUrlString(messageImageUrl)
            cell.messageImageView.hidden = false
            cell.bubbleView.backgroundColor = UIColor.clearColor()
        } else if let awareness = message.awareness {
            cell.textView.text = awareness
        } else if let concept = message.concept {
            cell.textView.text = concept
        } else {
            cell.messageImageView.hidden = true
        }
        
        if message.fromId == Digits.sharedInstance().session()?.userID {
            //outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.whiteColor()
            cell.profileImageView.hidden = true
            cell.bubleViewRightAnchor?.active = true
            cell.bubbleViewLeftAnchor?.active = false
        } else {
            //incominug gray
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.blackColor()
            cell.profileImageView.hidden = false
            cell.bubleViewRightAnchor?.active = false
            cell.bubbleViewLeftAnchor?.active = true
        }
    }
    
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text).height + 14
        } else if let imageWidth = message.imageWidth?.floatValue, imageHeight = message.imageHeight?.floatValue {
            //h1 / w1 = h2 / w2
            //solve for h1
            //h1 = h2 / w2 * w1
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        let width = UIScreen.mainScreen().bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.UsesFontLeading.union(.UsesLineFragmentOrigin)
        return NSString(string: text).boundingRectWithSize(size, options: options, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(16)], context: nil)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    
    func setupInputComponents() {
        let containerView = UIView()
        
        containerView.backgroundColor = UIColor.whiteColor()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        
        containerView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        containerView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        containerView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        containerView.heightAnchor.constraintEqualToConstant(40).active = true
        
        let sendButton = UIButton(type: .System)
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), forControlEvents: .TouchUpInside)
        
        containerView.addSubview(sendButton)
        sendButton.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        sendButton.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        sendButton.widthAnchor.constraintEqualToConstant(80).active = true
        sendButton.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor).active = true
        
        containerView.addSubview(messageField)
        messageField.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        messageField.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor, constant: 8).active = true
        messageField.rightAnchor.constraintEqualToAnchor(sendButton.leftAnchor).active = true
        messageField.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor, constant: -10).active = true
        
        let separator = UIView()
        separator.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(separator)
        
        separator.bottomAnchor.constraintEqualToAnchor(containerView.topAnchor).active = true
        separator.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        separator.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        separator.heightAnchor.constraintEqualToConstant(0.5).active = true
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    func performZoomInForImageView(startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.hidden = true
        
        startingFrame = startingImageView.superview?.convertRect(startingImageView.frame, toView: nil)
        let zoomingImageView = UIImageView(frame: startingFrame!)
        
        zoomingImageView.image = startingImageView.image
        zoomingImageView.userInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        if let keyWindow = UIApplication.sharedApplication().keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.blackColor()
            blackBackgroundView?.alpha = 0
            inputContainerView.alpha = 1
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {
                //math?
                
                // h2 / w1 = h1 / w1
                //h2 = h1 / w1 * w1
                self.blackBackgroundView!.alpha = 1
                self.inputContainerView.alpha = 0
                
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                }, completion: nil)
            
            
        }
    }
    
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer ) {
        
        if let zoomOutImageView = tapGesture.view {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {
                zoomOutImageView.frame  = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                }, completion: { (completed: Bool) in
                    zoomOutImageView.removeFromSuperview()
                    self.startingImageView?.hidden = false
            })
        }
    }
    
    
}

class MyTapGesture: UITapGestureRecognizer {
    var message = Message?()
    var tasks = Task?()
}
