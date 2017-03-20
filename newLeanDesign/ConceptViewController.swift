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
import Alamofire
import DigitsKit

class ConceptViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    let ref = FIRDatabase.database().reference()
    let customCellIdentifier = "customCellIdentifier"
    let buttonView = ButtonView()
    var task: Task?
    var concepts = [Concept]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ConceptCell.self, forCellWithReuseIdentifier: customCellIdentifier)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(closeView))
        
        self.buttonView.acceptTaskButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleApproveView)))
        
    }
    
    
    func setupView() {
  
        self.view.addSubview(buttonView)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(buttonView.widthAnchor == self.view.widthAnchor,
                                 buttonView.bottomAnchor == self.view.bottomAnchor,
                                 buttonView.heightAnchor == 50)
       
    }
    

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    

    var day = 0;
    var dayname = ["день", "дня", "дней"]

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! ConceptCell

        let concept = concepts[indexPath.item]
        buttonView.buttonLabel.text = "Принять"
        
        if let imageUrl = concept.imgUrl {    
            cell.imageView.loadImageUsingCashWithUrlString(imageUrl)
            cell.textView.isHidden = true
            cell.priceLabel.isHidden = true
            cell.timeLabel.isHidden = true
            cell.descriptView.isHidden = true
            
           
                let tappy = MyTapGesture(target: self, action: #selector(self.showShareButtons(_:)))
                let im = cell.imageView.image
                tappy.anyobj = ["image": im]
                cell.shareButton.addGestureRecognizer(tappy)
          
            
            
            
            buttonView.acceptTaskButtonView.backgroundColor = LeanColor.acceptColor
        }
        return cell
    }
    
 
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return concepts.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 280
        
        let concept = concepts[indexPath.item]
        let width = UIScreen.main.bounds.width
        let screenWidth: CGFloat = view.frame.width
        
        if concept.imgUrl != nil {
            if let imageWidth = concept.imageWidth?.floatValue, let imageHeight = concept.imageHeight?.floatValue {
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
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        setupView()
    }
    

    func handleApproveView() {

        if let taskId = task!.taskId {
            let taskRef:FIRDatabaseReference    = ref.child("tasks").child(taskId)
            let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
            let value: [String: AnyObject] = ["approveTime": timestamp]
            taskRef.child("awareness").updateChildValues(value, withCompletionBlock: { (err, ref) in
                if err != nil {
                   print(err as! NSError)
                    return
                }
            })
            
            taskRef.observeSingleEvent(of: .value, with: { (snapshot:FIRDataSnapshot) in
                var time : Int?
                let status = (snapshot.value as? NSDictionary)!["status"] as? String
                time =  (snapshot.value as? NSDictionary)!["time"] as? Int
                if let price = (snapshot.value as? NSDictionary)!["price"] as? Int {
                    
                    if let uid = Digits.sharedInstance().session()?.userID {
                        let clientRef = self.ref.child("clients").child(uid)
                        clientRef.observeSingleEvent(of: .value, with: { (snapshot) in
                            
                                self.showSuccessAlertView(status: status! as String, time: time! as Int, price: price as Int)
                        }, withCancel: nil)
                    }
                }
                
                }, withCancel: nil)
        }
    }
    
    
}


