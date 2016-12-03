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

class SupportViewController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    let cashe = NSCache<AnyObject, AnyObject>()
    var designerPic: String?
    let adminId = "uzpW1sRJa0MNcU0mwL2pvLmHCsQ2"
    
    var messages = [Message]()
    var sentMessages = [String]()
    
    func observeMessages() {
      
        guard let uid = Digits.sharedInstance().session()!.userID else {
            return
        }
        
        let userMessagesRef = FIRDatabase.database().reference().child("support-messages").child(uid).child(adminId)
        userMessagesRef.queryLimited(toLast: 20).observe(.childAdded, with: { (snapshot) in
           
            
            let taskMessagesRef = FIRDatabase.database().reference().child("messages").child(snapshot.key)
            taskMessagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
               
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
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        collectionView?.contentInset = UIEdgeInsets(top: 48, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        
   
        
        setupKeyboardObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavbarWithUser()
        observeMessages()
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        let uploadImage = UIImageView()
        uploadImage.isUserInteractionEnabled = true
        uploadImage.image = UIImage(named: "addimage")
        uploadImage.translatesAutoresizingMaskIntoConstraints = false
        uploadImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        
        containerView.addSubview(uploadImage)
        uploadImage.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        uploadImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImage.widthAnchor.constraint(equalToConstant: 32).isActive = true
        uploadImage.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: UIControlState())
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        containerView.addSubview(sendButton)
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(self.messageField)
        self.messageField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.messageField.leftAnchor.constraint(equalTo: uploadImage.rightAnchor, constant: 8).isActive = true
        self.messageField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.messageField.heightAnchor.constraint(equalTo: containerView.heightAnchor, constant: -10).isActive = true
        
        let separator = UIView()
        separator.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(separator)
        
        separator.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separator.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        
        return containerView
        
    }()
    
    func setupNavbarWithUser() {
        let titleView = UIImageView()
        titleView.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        
        titleView.layer.cornerRadius = 18
        titleView.layer.masksToBounds = true
        titleView.isUserInteractionEnabled = true
        
            let ref = FIRDatabase.database().reference().child("clients").child(self.adminId)
            ref.observe(.value, with: { (snapshot) in
                if let imageUrl = (snapshot.value as? NSDictionary)!["photoUrl"] as? String {
                    self.designerPic = imageUrl
                    titleView.loadImageUsingCashWithUrlString(imageUrl)
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
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
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
        
        let fromId = Digits.sharedInstance().session()?.userID as String!
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject, "timestamp": timestamp as AnyObject, "fromId": fromId as AnyObject]
        
        self.sentMessages.append(String(imageUrl))
        self.messages.append(Message(dictionary: properties))
        
        DispatchQueue.main.async(execute: {
            self.collectionView?.reloadData()
        })
        
        self.sendMessageController.sendMessageToSupport(properties)
    }
    
    func handleSend() {
        guard let messageText = messageField.text else {
            return
        }
        
        if messageText != "" {
            
            let fromId = Digits.sharedInstance().session()?.userID as String!
            
            let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
            
            let dictionary: [String: AnyObject] = ["text": messageText as AnyObject, "timestamp": timestamp, "fromId": fromId as AnyObject]
            self.sentMessages.append(String(messageText))
            
            self.messages.append(Message(dictionary: dictionary))
            
            
            DispatchQueue.main.async(execute: {
                self.collectionView?.reloadData()
            })
            
            
            let properties: [String: AnyObject] = ["text": messageText as AnyObject]
            self.sendMessageController.sendMessageToSupport(properties)
            
            self.messageField.text = nil
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
        
        cell.supportLogController = self
        
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
        
        
        //        if let photoUrl = message.photoUrl {
        //            cell.profileImageView.loadImageUsingCashWithUrlString(photoUrl)
        //        }
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
    
    
    
    func setupInputComponents() {
        let containerView = UIView()
        
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: UIControlState())
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        containerView.addSubview(sendButton)
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(messageField)
        messageField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        messageField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        messageField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        messageField.heightAnchor.constraint(equalTo: containerView.heightAnchor, constant: -10).isActive = true
        
        let separator = UIView()
        separator.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(separator)
        
        separator.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separator.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
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

