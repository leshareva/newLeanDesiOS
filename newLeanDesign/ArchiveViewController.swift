//
//  TaskViewController.swift
//  leandesign
//
//  Created by Sladkikh Alexey on 9/11/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import DigitsKit
import Swiftstraints

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ArchiveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellId = "cellId"
    var tableView: UITableView  =  UITableView()
    var tasks = [Task]()
    var tasksDictionary = [String: Task]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize: CGRect = UIScreen.main.bounds
        tableView.frame         =   CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height - 70);
        tableView.delegate      =   self
        tableView.dataSource    =   self
        
        tableView.register(TaskCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsMultipleSelectionDuringEditing = true
        
        navigationController?.navigationBar.isTranslucent = false

        observeUserTasks()
        
        self.view.addSubview(tableView)
 
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Мои задачи"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TaskCell
        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.text
        
        let status = task.status
        if status == "archive" {
           cell.detailTextLabel?.text = "Задача сдана и оплачена"
            
        } else if status == "archiveRejected" {
            cell.detailTextLabel?.text = "Задача отменена"
            cell.detailTextLabel?.tintColor = .red
        }
        
        if let taskPrice = task.price {
             cell.timeLabel.text = "\(String(describing: taskPrice)) ₽"
        }
       
        cell.timeLabel.isHidden = true
        cell.notificationsLabel.isHidden = true

        if let taskImageUrl = task.imageUrl {
            cell.taskImageView.loadImageUsingCashWithUrlString(taskImageUrl)
        } else {
            cell.taskImageView.image = UIImage.gifWithName("spinner-duo")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        showChatControllerForUser(task)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    

    
    func observeUserTasks() {
        
        tasks.removeAll()
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
        
        guard let uid = Digits.sharedInstance().session()!.userID else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("tasks").queryOrdered(byChild: "fromId").queryEqual(toValue: uid)
            ref.observe(.childAdded, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                        let task = Task(dictionary: dictionary)
                        self.tasksDictionary[snapshot.key] = task
                }
                
                self.attemptReloadTable()
                
                }, withCancel: nil)
        
    }
    
    
    func showChatControllerForUser(_ task: Task) {
        let flowLayout = UICollectionViewFlowLayout()
        let completeViewController = CompleteViewController(collectionViewLayout: flowLayout)
        completeViewController.view.backgroundColor = UIColor.white
        completeViewController.task = task
        
        if let taskId = task.taskId {
            let ref = FIRDatabase.database().reference()
            ref.child("tasks").child(taskId).child("sources").observe(.childAdded, with: {(snapshot) in
                let fileKey = snapshot.key
                ref.child("files").child(fileKey).observe(.value, with: { (snapshot) in
                    guard let dictionary = snapshot.value as? [String : AnyObject] else {
                        return
                    }
                    completeViewController.sources.append(File(dictionary: dictionary))
                    DispatchQueue.main.async(execute: {
                        completeViewController.collectionView?.reloadData()
                    })
                }, withCancel: nil)
            }, withCancel: nil)
        }
        
        let navController = UINavigationController(rootViewController: completeViewController)
        present(navController, animated: true, completion: nil)
    }
    
    func showControllerForSetting(_ setting: Setting) {
        
        
        if setting.name == .License {
            let licenseViewController = LicenseViewController()
            licenseViewController.navigationItem.title = setting.name.rawValue
            navigationController?.pushViewController(licenseViewController, animated: true)
            
        } else if setting.name == .Archive {
            let archiveViewController = ArchiveViewController()
            archiveViewController.view.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            archiveViewController.navigationItem.title = setting.name.rawValue
            navigationController?.pushViewController(archiveViewController, animated: true)
            
        } else if setting.name == .Settings {
            let myProfileViewController = MyProfileViewController()
            myProfileViewController.view.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            myProfileViewController.navigationItem.title = setting.name.rawValue
            present(myProfileViewController, animated: true, completion: nil)
        } else {
            let dummySettingsViewController = UIViewController()
            dummySettingsViewController.view.backgroundColor = UIColor.white
            dummySettingsViewController.navigationItem.title = setting.name.rawValue
            navigationController?.navigationBar.tintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            navigationController?.pushViewController(dummySettingsViewController, animated: true)
        }
        
    }

    
    
    fileprivate func attemptReloadTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    func handleReloadTable() {
        self.tasks = Array(self.tasksDictionary.values)
        self.tasks.sort(by: { (task1, task2) -> Bool in
            return task1.start?.int32Value > task2.start?.int32Value
        })
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
        
    }
}
