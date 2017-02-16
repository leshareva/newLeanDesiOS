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
        containerView.backgroundColor = .white
        view.addSubview(containerView)
        
        let buttonView = ButtonView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        view.addSubview(buttonView)
        
        
        let screenSize = self.view.frame.size.width - 32
        
        let taskId = task?.taskId
        let ref = FIRDatabase.database().reference().child("tasks").child(taskId!)
        ref.observe(.value, with: { (snapshot) in
            let status = (snapshot.value as? NSDictionary)!["status"] as! String
            
            let tappy = MyTapGesture(target: self, action: #selector(self.openStepInfo(_:)))
            if status == "awareness" {
                containerView.progressWidthAnchor?.constant = (screenSize / 4) / 2
                containerView.textOne.textColor = StepsView.activeTextColor
                buttonView.isHidden = true
            } else if status == "awarenessApprove" {
                containerView.progressWidthAnchor?.constant = screenSize / 4
                let awareness = (snapshot.value as? NSDictionary)!["awareness"] as AnyObject
                
                if awareness["status"] as! String == "discuss" {
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
                containerView.textOne.textColor = StepsView.activeTextColor
            } else if status == "concept" {
                containerView.progressWidthAnchor?.constant = (screenSize / 4) + ((screenSize / 4) / 2)
                containerView.textOne.textColor = StepsView.doneTextColor
                containerView.textTwo.textColor = StepsView.activeTextColor
                buttonView.isHidden = true
            } else if status == "conceptApprove" {
                containerView.progressWidthAnchor?.constant = (screenSize / 4) * 2
                guard let concept = (snapshot.value as! NSDictionary)["concept"] as? AnyObject else {
                    return
                }
                guard let conceptStatus = concept["status"] else {
                    return
                }
                
                buttonView.isHidden = false
                buttonView.alertButton.isHidden = false
                buttonView.alertButton.addGestureRecognizer(tappy)
                tappy.status = "concept"
                
                if conceptStatus as! String == "discuss" {
                   buttonView.alertTextView.text = "Посмотреть черновик"
                } else {
                    buttonView.alertTextView.text = "Согласуйте черновик"
                }
                
            } else if status == "design" {
                containerView.progressWidthAnchor?.constant = ((screenSize / 4) * 2) + ((screenSize / 4) / 2)
                containerView.textOne.textColor = StepsView.doneTextColor
                containerView.textTwo.textColor = StepsView.doneTextColor
                containerView.textThree.textColor = StepsView.activeTextColor
                buttonView.isHidden = true
            } else if status == "designApprove" {
                containerView.progressWidthAnchor?.constant = (screenSize / 4) * 3
                guard let design = (snapshot.value as! NSDictionary)["design"] as? AnyObject else {
                    return
                }
                guard let desStatus = design["status"] else {
                    return
                }
                buttonView.isHidden = false
                
                buttonView.alertButton.isHidden = false
                buttonView.alertButton.addGestureRecognizer(tappy)
                tappy.status = "design"
                
                if desStatus as! String == "discuss" {
                    buttonView.alertTextView.text = "Посмотреть чистовик"
                } else {
                    buttonView.alertTextView.text = "Согласуйте чистовик"
                }
                
            } else if status == "sources" {
                containerView.progressWidthAnchor?.constant = ((screenSize / 4) * 3) + ((screenSize / 4) / 2)
                containerView.textOne.textColor = StepsView.doneTextColor
                containerView.textTwo.textColor = StepsView.doneTextColor
                containerView.textThree.textColor = StepsView.doneTextColor
                containerView.textFour.textColor = StepsView.activeTextColor
                buttonView.isHidden = true
            } else if status == "done" {
                containerView.progressWidthAnchor?.constant = screenSize
                buttonView.isHidden = false
                buttonView.alertTextView.text = "Задача закрыта. Примите исходники"
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
        completeViewController.task = self.task
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
