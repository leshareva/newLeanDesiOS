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

class ArchiveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellId = "cellId"
    var tableView: UITableView  =  UITableView()
    var tasks = [Task]()
    var taskDictionary = [String: Task]()
    
    var beepSoundEffect: AVAudioPlayer!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        tableView.frame         =   CGRectMake(0, 0, 320, screenSize.height);
        tableView.delegate      =   self
        tableView.dataSource    =   self
        
        tableView.registerClass(TaskCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsMultipleSelectionDuringEditing = true
        
        navigationController?.navigationBar.translucent = false
        
        fetchUser()
        
        self.view.addSubview(tableView)
        
        
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Мои задачи"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! TaskCell
        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.text
        cell.detailTextLabel?.text = task.status
        cell.timeLabel.text = String(task.price!)
        cell.notificationsLabel.hidden = true
        
        if let taskImageUrl = task.imageUrl {
            cell.taskImageView.loadImageUsingCashWithUrlString(taskImageUrl)
        } else {
            cell.taskImageView.image = UIImage.gifWithName("spinner-duo")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let task = tasks[indexPath.row]
        showChatControllerForUser(task)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    
    
    
    func fetchUser() {
        tasks.removeAll()
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
        observeUserTasks()
    }
    
    
    func observeUserTasks() {
        guard let uid = Digits.sharedInstance().session()!.userID else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-tasks").child(uid)
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let taskId = snapshot.key
            let taskRef = FIRDatabase.database().reference().child("tasks").child(taskId)
            taskRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    guard let status = snapshot.value!["status"] as? String else {
                        return
                    }
                        let task = Task()
                        task.setValuesForKeysWithDictionary(dictionary)
                        self.tasks.append(task)
                        self.tasks = self.tasks.reverse()
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadData()
                        })
                }
                
                }, withCancelBlock: nil)
            }, withCancelBlock: nil)
        
    }
    
    
    
    
    
    func showChatControllerForUser(task: Task) {
        let chatController = ChatViewController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.task = task
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    func showControllerForSetting(setting: Setting) {
        
        if setting.name == .Exit {
            //            handleLogout()
            let archiveViewController = ArchiveViewController()
            archiveViewController.view.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            archiveViewController.navigationItem.title = setting.name.rawValue
            presentViewController(archiveViewController, animated: true, completion: nil)
            
        } else if setting.name == .Settings {
            let profileViewController = ProfileViewController()
            profileViewController.view.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            profileViewController.navigationItem.title = setting.name.rawValue
            presentViewController(profileViewController, animated: true, completion: nil)
        } else {
            let dummySettingsViewController = UIViewController()
            dummySettingsViewController.view.backgroundColor = UIColor.whiteColor()
            dummySettingsViewController.navigationItem.title = setting.name.rawValue
            navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
            navigationController?.pushViewController(dummySettingsViewController, animated: true)
        }
        
    }
    
    
    private func attemptReloadTable() {
        self.timer?.invalidate()
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: NSTimer?
    
    func handleReloadTable() {
        self.tasks = Array(self.taskDictionary.values)
        self.tasks.sortInPlace({ (task1, task2) -> Bool in
            return task1.start?.intValue > task2.start?.intValue
        })
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
        
    }
}
