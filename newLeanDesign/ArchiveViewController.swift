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
    var taskDictionary = [String: Task]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize: CGRect = UIScreen.main.bounds
        tableView.frame         =   CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height);
        tableView.delegate      =   self
        tableView.dataSource    =   self
        
        tableView.register(TaskCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsMultipleSelectionDuringEditing = true
        
        navigationController?.navigationBar.isTranslucent = false
        
        fetchUser()
        
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
        if status == "done" {
           cell.detailTextLabel?.text = "Задача сдана и оплачена"
            
        } else if status == "archiveRejected" {
            cell.detailTextLabel?.text = "Задача отменена"
            cell.detailTextLabel?.tintColor = .red
        }
        
        let taskPrice = Int(task.price!)
        cell.timeLabel.text = "\(String(describing: taskPrice)) ₽"
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
    
    
    
    func fetchUser() {
        tasks.removeAll()
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
        observeUserTasks()
    }
    
    
    func observeUserTasks() {
        guard let uid = Digits.sharedInstance().session()!.userID else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-tasks").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let taskId = snapshot.key
            let taskRef = FIRDatabase.database().reference().child("tasks").child(taskId)
            taskRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                 
                        let task = Task()
                        task.setValuesForKeys(dictionary)
                        self.tasks.append(task)
                        self.tasks = self.tasks.reversed()
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                }
                
                }, withCancel: nil)
            }, withCancel: nil)
        
    }
    
    
    
    
    
    func showChatControllerForUser(_ task: Task) {
        let chatController = ChatViewController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.task = task
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    func showControllerForSetting(_ setting: Setting) {
        
        if setting.name == .Exit {
            //            handleLogout()
            let archiveViewController = ArchiveViewController()
            archiveViewController.view.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            archiveViewController.navigationItem.title = setting.name.rawValue
            present(archiveViewController, animated: true, completion: nil)
            
        } else if setting.name == .Settings {
            let profileViewController = ProfileViewController()
            profileViewController.view.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            profileViewController.navigationItem.title = setting.name.rawValue
            present(profileViewController, animated: true, completion: nil)
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
        self.tasks = Array(self.taskDictionary.values)
        self.tasks.sort(by: { (task1, task2) -> Bool in
            return task1.start?.int32Value > task2.start?.int32Value
        })
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
        
    }
}
