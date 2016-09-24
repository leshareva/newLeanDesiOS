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
    
    
    let acceptView = AcceptView()
    
    var task: Task? {
        didSet {
            observeConcept()
        }
    }
    
    var concepts = [Concept]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.registerClass(CustomCell.self, forCellWithReuseIdentifier: customCellIdentifier)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Закрыть", style: .Plain, target: self, action: #selector(closeView))
     
        self.acceptView.acceptTaskButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.acceptConcept)))
    }
    
    
    func closeView() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setupView() {
  
        self.view.addSubview(acceptView)
        acceptView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(acceptView.widthAnchor == self.view.widthAnchor,
                                 acceptView.bottomAnchor == self.view.bottomAnchor,
                                 acceptView.heightAnchor == 50)
        
    }
    
    func observeConcept() {
       
    }
    
    
    func acceptConcept() {
        
        if let taskId = task!.taskId {
            let taskRef = ref.child("tasks").child(taskId)
            
            taskRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                let status = snapshot.value!["status"] as? String
                let time = snapshot.value!["time"] as? Int
                
                var newstatus = ""
                if status == "awarenessApprove" {
                    newstatus = "concept"
                } else if status == "conceptApprove" {
                    newstatus = "design"
                } else if status == "designApprove" {
                    newstatus = "sources"
                }
                
                let startDate : NSNumber = Int(NSDate().timeIntervalSince1970)
                let calculatedDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: time!, toDate: NSDate(), options: NSCalendarOptions.init(rawValue: 0))
                
                let endDate : NSNumber = Int(calculatedDate!.timeIntervalSince1970)
                print(endDate)
                
                let values : [String: AnyObject] = ["status": newstatus, "start": startDate, "end": endDate]
                taskRef.updateChildValues(values) { (error, ref) in
                    if error != nil {
                        print(error)
                        return
                    }
                    self.acceptView.acceptedLabel.text = "Согласовано"
                    self.acceptView.acceptTaskButtonView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
                }
                
                
                let statusLength = status!.characters.count
                var step = ""
                
                if statusLength <= 7 {
                    step = status!
                } else {
                    let index1 = status!.endIndex.advancedBy(-7)
                    step = status!.substringToIndex(index1)
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
            
                self.acceptView.userInteractionEnabled = false
                dismissViewControllerAnimated(true, completion: nil)
            
            
        }
        
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
        } else if let text = concept.text {
            cell.imageView.hidden = true
            cell.textView.hidden = false
            cell.priceLabel.hidden = false
            cell.textView.text = text
            let price = concept.price
            let time = concept.time
            cell.priceLabel.text = String(price!) + " ₽"
 
            checkNumberOfDays(Int(time!))
            cell.timeLabel.text = String(time!) + " " + String(dayname[day])

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
        let concept = concepts[indexPath.item]
        var height: CGFloat = 80
        if concept.imgUrl != nil {
            height = 200
        } else if concept.text != nil {
            height = view.frame.height
        }
        return CGSizeMake(view.frame.width, height)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        setupView()
    }
    
}

class CustomCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .ScaleAspectFit
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
        ul.text = "Цена"
        ul.translatesAutoresizingMaskIntoConstraints = false
        ul.font = UIFont.systemFontOfSize(32)
        return ul
    }()
    
    let timeLabel: UILabel = {
        let ul = UILabel()
        ul.text = "Цена"
        ul.translatesAutoresizingMaskIntoConstraints = false
        ul.font = UIFont.systemFontOfSize(32)
        return ul
    }()
    
    func setupView() {
        backgroundColor = UIColor.whiteColor()
        addSubview(imageView)
        addSubview(textView)
        addConstraints(imageView.leftAnchor == self.leftAnchor,
                       imageView.widthAnchor == self.widthAnchor,
                       imageView.topAnchor == self.topAnchor,
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
        
         addSubview(timeLabel)
        addConstraints(timeLabel.leftAnchor == priceLabel.rightAnchor,
                        timeLabel.topAnchor == priceLabel.topAnchor,
                       timeLabel.widthAnchor == self.widthAnchor / 2,
                       timeLabel.heightAnchor == 40
                       )

        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
