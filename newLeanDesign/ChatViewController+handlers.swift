//
//  ChatViewController+handlers.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 12/14/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Firebase
import DigitsKit
import DKImagePickerController
import Alamofire
import Cosmos

extension ChatViewController {


    func setupStepsView() {
        
        let containerView = StepsView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        view.addSubview(containerView)
        
        let buttonView = ButtonView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        view.addSubview(buttonView)
        
        let taskId = task?.taskId
        let ref = FIRDatabase.database().reference().child("tasks").child(taskId!)
        ref.observe(.value, with: { (snapshot) in
            let status = (snapshot.value as? NSDictionary)!["status"] as! String
            
            let tappy = MyTapGesture(target: self, action: #selector(self.openStepInfo(_:)))
            if status == "none" {
                buttonView.alertButton.isHidden = false
                buttonView.alertButton.backgroundColor = StepsView.activeColor
                buttonView.alertTextView.text = "Мы подбираем дизайнера"
            } else  if status == "awareness" {
                containerView.stepOne.backgroundColor = StepsView.activeColor
                containerView.textOne.textColor = StepsView.activeTextColor
                buttonView.isHidden = true
            } else if status == "awarenessApprove" {
                var awareness = (snapshot.value as? NSDictionary)!["awareness"] as? AnyObject
                
                if awareness!["status"] as! String == "discuss" {
                    buttonView.isHidden = true
                } else {
                    buttonView.alertTextView.text = "Согласуйте понимание задачи"
                    buttonView.alertButton.isHidden = false
                    buttonView.isHidden = false
                    buttonView.alertButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openAwarenessView)))
                    tappy.status = "awareness"
                }
                
            } else if status == "price"{
                buttonView.isHidden = true
                containerView.stepOne.backgroundColor = StepsView.activeColor
                containerView.textOne.textColor = StepsView.activeTextColor
            } else if status == "concept" {
                containerView.stepOne.backgroundColor = StepsView.doneColor
                containerView.textOne.textColor = StepsView.doneTextColor
                containerView.stepTwo.backgroundColor = StepsView.activeColor
                containerView.textTwo.textColor = StepsView.activeTextColor
                buttonView.isHidden = true
            } else if status == "conceptApprove" {
                
                guard var concept = (snapshot.value as? NSDictionary)!["concept"] as? AnyObject else {
                    return
                }
                guard let conceptStatus = concept["status"] else {
                    return
                }
                
                if conceptStatus as! String == "discuss" {
                    buttonView.isHidden = true
                } else {
                    buttonView.isHidden = false
                    buttonView.alertButton.isHidden = false
                    buttonView.alertTextView.text = "Согласуйте черновик"
                    buttonView.alertButton.addGestureRecognizer(tappy)
                    tappy.status = "concept"
                }
                
            } else if status == "design" {
                containerView.stepOne.backgroundColor = StepsView.doneColor
                containerView.textOne.textColor = StepsView.doneTextColor
                containerView.stepTwo.backgroundColor = StepsView.doneColor
                containerView.textTwo.textColor = StepsView.doneTextColor
                containerView.stepThree.backgroundColor = StepsView.activeColor
                containerView.textThree.textColor = StepsView.activeTextColor
                buttonView.isHidden = true
            } else if status == "designApprove" {
                
                guard var design = (snapshot.value as? NSDictionary)!["design"] as? AnyObject else {
                    return
                }
                guard let desStatus = design["status"] else {
                    return
                }
                
                if desStatus as! String == "discuss" {
                    buttonView.isHidden = true
                } else {
                    buttonView.isHidden = false
                    buttonView.alertTextView.text = "Согласуйте чистовик"
                    buttonView.alertButton.isHidden = false
                    buttonView.alertButton.addGestureRecognizer(tappy)
                    tappy.status = "design"
                }
                
            } else if status == "sources" {
                containerView.stepOne.backgroundColor = StepsView.doneColor
                containerView.textOne.textColor = StepsView.doneTextColor
                containerView.stepTwo.backgroundColor = StepsView.doneColor
                containerView.textTwo.textColor = StepsView.doneTextColor
                containerView.stepThree.backgroundColor = StepsView.doneColor
                containerView.textThree.textColor = StepsView.doneTextColor
                containerView.stepFour.backgroundColor = StepsView.activeColor
                containerView.textFour.textColor = StepsView.activeTextColor
                buttonView.isHidden = true
            } else if status == "done" {
                buttonView.isHidden = false
                buttonView.alertTextView.text = "Задача закрыта, исходники лежат в вашей папке"
                buttonView.alertButton.isHidden = false
            } else if status == "archiveRejected" {
                buttonView.isHidden = false
                buttonView.alertTextView.text = "Вы отменили задачу"
            } else if status == "archive" {
                buttonView.isHidden = false
                buttonView.alertTextView.text = "Посмотреть файлы задачи"
                buttonView.alertButton.isHidden = false
                buttonView.alertButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openTaskResult)))
            }
        }, withCancel: nil)
        
    }
    
    
    
    
    func openAwarenessView() {
        let awarenessViewController = AwarenessViewController()
        awarenessViewController.task = task
        let navController = UINavigationController(rootViewController: awarenessViewController)
        self.present(navController, animated: true, completion: nil)
    }
    
    func openTaskResult() {
        let completeViewController = CompleteViewController()
        completeViewController.archiveButton.isHidden = true
        self.present(completeViewController, animated: true, completion: nil)
    }
    
    
    
    func openStepInfo(_ sender : MyTapGesture) {
        let status = sender.status
        
        let flowLayout = UICollectionViewFlowLayout()
        let conceptViewController = ConceptViewController(collectionViewLayout: flowLayout)
        conceptViewController.view.backgroundColor = UIColor.white
        conceptViewController.task = task
        
        if let taskId = self.task?.taskId {
            let ref = FIRDatabase.database().reference().child("tasks").child(taskId).child(status!)
            ref.observe(.childAdded, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject] else {
                    return
                }
                
                conceptViewController.concepts.append(Concept(dictionary: dictionary))
                DispatchQueue.main.async(execute: {
                    conceptViewController.collectionView?.reloadData()
                })
                
            }, withCancel: nil)
            
        }
        
        let navController = UINavigationController(rootViewController: conceptViewController)
        present(navController, animated: true, completion: nil)
        
    }

    
    func openDesignerProfile() {
        let userProfileViewController = UserProfileViewController()
        userProfileViewController.userId = task?.toId
        userProfileViewController.view.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
    
    
}
