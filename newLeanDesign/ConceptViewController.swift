//
//  ConceptViewController.swift
//  leandesign
//
//  Created by Sladkikh Alexey on 9/15/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints
import Firebase

class ConceptViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    let ref = FIRDatabase.database().reference()
    let customCellIdentifier = "customCellIdentifier"
 
    
    let buttonView = ButtonView()
    
    var task: Task? {
        didSet {
          
        }
    }
    
    var concepts = [Concept]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.registerClass(CustomCell.self, forCellWithReuseIdentifier: customCellIdentifier)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Обсудить", style: .Plain, target: self, action: #selector(closeView))
     
        self.buttonView.acceptTaskButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleApproveView)))
        
    }
    
    
    func closeView() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setupView() {
  
        self.view.addSubview(buttonView)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(buttonView.widthAnchor == self.view.widthAnchor,
                                 buttonView.bottomAnchor == self.view.bottomAnchor,
                                 buttonView.heightAnchor == 50)
        buttonView.acceptTaskButtonView.backgroundColor = UIColor(r: 109, g: 199, b: 82)
        buttonView.buttonLabel.text = "Согласовать"
    }
    

    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    
    
    var day = 0;
    var dayname = ["день", "дня", "дней"]
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(customCellIdentifier, forIndexPath: indexPath) as! CustomCell
        
       
        
        let concept = concepts[indexPath.item]
        
        if let imageUrl = concept.imgUrl {
            cell.imageView.loadImageUsingCashWithUrlString(imageUrl)
            cell.textView.hidden = true
            cell.priceLabel.hidden = true
            cell.timeLabel.hidden = true
            cell.myActivityIndicator.stopAnimating()
//            cell.imageWidthAnchor?.constant = s
            
        } else if let text = concept.text {
            cell.imageView.hidden = true
            cell.textView.hidden = false
            cell.priceLabel.hidden = true
            cell.textView.text = text
            let price = concept.price
            let time = concept.time
            cell.priceLabel.text = String(price!) + " ₽"
//            checkNumberOfDays(Int(time!))
//            cell.timeLabel.text = String(time!) + " " + String(dayname[day])
            if Int(time!) <= 3 {
                cell.timeLabel.text = "1 день"
            } else if Int(time!) > 3 && Int(time!) <= 6 {
                 cell.timeLabel.text = "2 дня"
            } else if Int(time!) > 6 && Int(time!) <= 9 {
                cell.timeLabel.text = "3 дня"
            }
            

        }
        return cell
    }
    
    
    
    func checkNumberOfDays(number: Int) -> Int {
        let b = number % 10
        let a = (number % 100 - b) / 10
        if (a == 0 || a > 2) {
            if (b == 0 || (b > 4 && b <= 9)) {
                day = 2
            } else if (b != 1) {
                day = 1
            } else { day = 0 }
        } else { day = 2 }
        return day
    }
    
   
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return concepts.count
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var height: CGFloat = 280
        
        let concept = concepts[indexPath.item]
        let width = UIScreen.mainScreen().bounds.width
        let screenWidth: CGFloat = view.frame.width
        
        if concept.imgUrl != nil {
            if let imageWidth = concept.imageWidth?.floatValue, imageHeight = concept.imageHeight?.floatValue {
                //h1 / w1 = h2 / w2
                //solve for h1
                //h1 = h2 / w2 * w1
                height = CGFloat(imageHeight / imageWidth * Float(screenWidth))
            }
        } else if concept.text != nil {
            height = view.frame.height
        }
        
        

        
        return CGSize(width: width, height: height)
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        setupView()
    }
    
    
    
    
    
    func handleApproveView() {
        if let taskId = task!.taskId {
            ref.child("tasks").child(taskId).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                var time : Int?
                let status = snapshot.value!["status"] as? String
                time = snapshot.value!["time"] as? Int
                if let price = snapshot.value!["price"] {
                    
                var newstatus = ""
                if status == "awarenessApprove" {
                    newstatus = "concept"
                    
                    
                        let alert = UIAlertController(title: "Стоимость работы — \(String(price!)) руб", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        alert.addAction(UIAlertAction(title: "Подтверждаю", style: .Default, handler: { (action: UIAlertAction!) in
                            self.navigationController?.popToRootViewControllerAnimated(true)
                            
                            self.sendApproveToDB(taskId, status: status!, newstatus: newstatus, time: time!)
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Отмена", style: .Default, handler: { (action: UIAlertAction!) in
                            
                            alert.dismissViewControllerAnimated(true, completion: nil)
    
                        }))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                   
                    
                    
                } else if status == "conceptApprove" {
                    newstatus = "design"
                    
                    let alert = UIAlertController(title: "Подтвердите", message: "После принятия черновика, вы не сможете вносить глобальные изменения в черновик", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: "Подтверждаю", style: .Default, handler: { (action: UIAlertAction!) in
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        
                        self.sendApproveToDB(taskId, status: status!, newstatus: newstatus, time: time!)
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Отмена", style: .Default, handler: { (action: UIAlertAction!) in
                        
                        alert.dismissViewControllerAnimated(true, completion: nil)
                        
                    }))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    
                } else if status == "designApprove" {
                    newstatus = "sources"
                    
                    let alert = UIAlertController(title: "Подтвердите", message: "После принятия чистовика вы не сможете вносить в него корректировки. Дизайнер будет готовить исходники.", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: "Подтверждаю", style: .Default, handler: { (action: UIAlertAction!) in
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        
                        self.sendApproveToDB(taskId, status: status!, newstatus: newstatus, time: time!)
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Отмена", style: .Default, handler: { (action: UIAlertAction!) in
                        
                        alert.dismissViewControllerAnimated(true, completion: nil)
                        
                    }))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
                    
                }
                
                }, withCancelBlock: nil)
            
        }
        
        
        
    }
    
    
    func sendApproveToDB(taskId: String, status: String, newstatus: String, time: Int) {
        let taskRef = self.ref.child("tasks").child(taskId)
        
        var days: Int?
        if Int(time) <= 3 {
            days = 1
        } else if Int(time) > 3 && Int(time) <= 6 {
            days = 2
        } else if Int(time) > 6 && Int(time) <= 9 {
            days = 3
        }
        
        taskRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            let startDate : NSNumber = Int(NSDate().timeIntervalSince1970)
            let calculatedDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: days!, toDate: NSDate(), options: NSCalendarOptions.init(rawValue: 0))
            
            let endDate : NSNumber = Int(calculatedDate!.timeIntervalSince1970)
            print(endDate)
            
            let values : [String: AnyObject] = ["status": newstatus, "start": startDate, "end": endDate]
            taskRef.updateChildValues(values) { (error, ref) in
                if error != nil {
                    print(error)
                    return
                }
                self.buttonView.buttonLabel.text = "Согласовано"
                self.buttonView.acceptTaskButtonView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
            }
            
            
            let statusLength = status.characters.count
            var step = ""
            
            if statusLength <= 7 {
                step = status
            } else {
                let index1 = status.endIndex.advancedBy(-7)
                step = status.substringToIndex(index1)
            }
            
            let awStatus : [String: AnyObject] = ["status": "accept"]
            taskRef.child(step).updateChildValues(awStatus, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err)
                    return
                }
            })
            
            let stepStatus : [String: AnyObject] = ["status": "none"]
            self.ref.child("tasks").child(taskId).child(newstatus).updateChildValues(stepStatus, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print(error)
                    return
                }
            })
            
            }, withCancelBlock: nil)
        
        
        
        self.buttonView.userInteractionEnabled = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
  
}









class CustomCell: UICollectionViewCell, UIScrollViewDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    var conceptViewController: ConceptViewController?
    
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var imageWidthAnchor: NSLayoutConstraint?
    
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .ScaleAspectFit
        iv.userInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return iv
    }()
    
    let textView: UITextView = {
       let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "Какой-то текст"
        tv.font = UIFont.systemFontOfSize(16)
        tv.editable = false
        return tv
    }()
    
    let priceLabel: UILabel = {
       let ul = UILabel()
        ul.translatesAutoresizingMaskIntoConstraints = false
        ul.font = UIFont.systemFontOfSize(32)
        return ul
    }()
    
    let timeLabel: UILabel = {
        let ul = UILabel()
        ul.translatesAutoresizingMaskIntoConstraints = false
        ul.font = UIFont.systemFontOfSize(32)
        return ul
    }()
    
 
    
    func setupView() {
        backgroundColor = UIColor.whiteColor()
        addSubview(imageView)
        addSubview(textView)
        addConstraints(imageView.leftAnchor == self.leftAnchor,
                       imageView.topAnchor == self.topAnchor,
                       imageView.widthAnchor == self.widthAnchor,
                       imageView.heightAnchor == self.heightAnchor,
                       textView.leftAnchor == self.leftAnchor + 8,
                       textView.widthAnchor == self.widthAnchor - 16,
                       textView.topAnchor == self.topAnchor,
                       textView.heightAnchor == self.heightAnchor - 160
        )
        
        addSubview(priceLabel)
        addConstraints( priceLabel.leftAnchor == self.leftAnchor + 16,
                        priceLabel.topAnchor == textView.bottomAnchor,
                       priceLabel.widthAnchor == self.widthAnchor / 2,
                       priceLabel.heightAnchor == 40
        )
        
//        imageWidthAnchor = imageView.widthAnchor.constraintEqualToConstant(200)
//        imageWidthAnchor?.active = true
        
        
         addSubview(timeLabel)
        addConstraints(timeLabel.leftAnchor == priceLabel.rightAnchor,
                        timeLabel.topAnchor == priceLabel.topAnchor,
                       timeLabel.widthAnchor == self.widthAnchor / 2,
                       timeLabel.heightAnchor == 40
                       )
        imageView.addSubview(myActivityIndicator)
        
        myActivityIndicator.center = imageView.center
        myActivityIndicator.hidesWhenStopped = true
        myActivityIndicator.startAnimating()
        
        
        
    }
    
    
    
    func handleZoomTap(tapGesture: UITapGestureRecognizer) {
       
        //Pro Tip: don't perform a lot of custom logic inside of a view class
        if let imageView = tapGesture.view as? UIImageView {
           performZoomInForImageView(imageView)
            
        }
    }
    
    
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    
    func performZoomInForImageView(startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.hidden = true
        
        startingFrame = startingImageView.superview?.convertRect(startingImageView.frame, toView: nil)
        let zoomingImageView = ZoomingImageView(frame: startingFrame!)
        
        zoomingImageView.imageView.image = startingImageView.image
        
        zoomingImageView.scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        zoomingImageView.userInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.sharedApplication().keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.blackColor()
            blackBackgroundView?.alpha = 0
            
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1

                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: keyWindow.frame.height)
                
                zoomingImageView.imageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.imageView.center = keyWindow.center
                
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
                //                self.inputContainerView.alpha = 1
                }, completion: { (completed: Bool) in
                    zoomOutImageView.removeFromSuperview()
                    self.startingImageView?.hidden = false
            })
        }
    }
    
 

   
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
