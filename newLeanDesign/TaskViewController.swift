//
//  TaskViewController.swift
//  leandesign
//
//  Created by Sladkikh Alexey on 9/11/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import AVFoundation
import DigitsKit
import Swiftstraints


class TaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellId = "cellId"
    var tableView: UITableView  =  UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
    var tasks = [Task]()
    var taskDictionary = [String: Task]()

    
    static let blueColor = UIColor(r: 48, g: 140, b: 229)
    
    
    lazy var addTaskButtonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openNewTaskView)))
        view.userInteractionEnabled = true
        view.backgroundColor = blueColor
        return view
    }()
    
    lazy var addButton: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    
    let addButtonLabel: UILabel = {
        let label = UILabel()
        label.text = "Добавить задачу"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.whiteColor()
        return label
    }()
    
    let emptyTableView = EmptyTableView()
    
    let testView: UIView = {
        let uv = UIView()
        uv.backgroundColor = UIColor.clearColor()
        uv.translatesAutoresizingMaskIntoConstraints = false
        
        
        let loaderView = UIImageView()
        loaderView.image = UIImage.gifWithName("loader")
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        uv.addSubview(loaderView)
        
        uv.addConstraints("H:|[\(loaderView)]|")
        uv.addConstraints("V:|[\(loaderView)]|")
        
        return uv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "point")?.imageWithRenderingMode(.AlwaysOriginal), style: .Plain, target: self, action: #selector(handleMore))
        
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        tableView.frame         =   CGRectMake(0, 0, 320, screenSize.height);
        tableView.delegate      =   self
        tableView.dataSource    =   self
        
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.backgroundView = emptyTableView
        
        
        navigationController?.navigationBar.translucent = false
       
        
        
        checkIfUserIsLoggedIn()
        
        self.view.addSubview(tableView)
        
        self.view.addSubview(testView)
        self.view.addConstraints(testView.widthAnchor == self.view.widthAnchor,
                                 testView.heightAnchor == 20,
                                 testView.topAnchor == self.view.topAnchor,
                                 testView.leftAnchor == self.view.leftAnchor)
        
        setupLogoView()
        setupAddTaskView()
    }
    
    func setupLogoView() {
        let logoView = UIImageView()
        logoView.frame = CGRect(x: 0, y: 0, width: 89, height: 29)
        logoView.image = UIImage(named: "logo")
   
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: logoView)

    }
    
    func setupAddTaskView() {
        
        self.view.addSubview(addTaskButtonView)
        addTaskButtonView.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
        addTaskButtonView.heightAnchor.constraintEqualToConstant(50).active = true
        addTaskButtonView.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        addTaskButtonView.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
        
        addTaskButtonView.addSubview(addButton)
        
        addButton.centerYAnchor.constraintEqualToAnchor(addTaskButtonView.centerYAnchor).active = true
        addButton.centerXAnchor.constraintEqualToAnchor(addTaskButtonView.centerXAnchor).active = true
        addButton.widthAnchor.constraintEqualToAnchor(addTaskButtonView.widthAnchor, constant: -26).active = true
        addButton.heightAnchor.constraintEqualToAnchor(addTaskButtonView.heightAnchor, constant: -16).active = true
        
        addButton.addSubview(addButtonLabel)
        addButton.addConstraints("V:|[\(addButtonLabel)]|")
        addButton.addConstraints(addButtonLabel.heightAnchor == addButton.heightAnchor, addButtonLabel.centerXAnchor == addButton.centerXAnchor)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.addTaskButtonView.alpha = 0
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.addTaskButtonView.alpha = 1
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let companyView = CompanyView(frame: CGRectMake(0, 0, tableView.frame.size.width, 60))
        companyView.backgroundColor = UIColor.whiteColor()
        
        if let companyNameFromCash = NSUserDefaults.standardUserDefaults().stringForKey("company") {
            companyView.companyNameLabel.text = companyNameFromCash
        }
        
        
        if let uid = Digits.sharedInstance().session()?.userID {
            let clientsRef = FIRDatabase.database().reference().child("clients")
            clientsRef.child(uid).observeEventType(.Value, withBlock: { (snapshot) in
                
                companyView.companyNameLabel.text = snapshot.value!["company"] as? String
                
                if let sum = snapshot.value!["sum"] as? NSNumber {
                    companyView.priceLabel.text = String(sum) + " ₽"
                }
                
                guard let folderUrl = snapshot.value!["folderUrl"] as? String else {
                    return
                }
                 NSUserDefaults.standardUserDefaults().setObject(folderUrl, forKey: "folderUrl")
                
                
                companyView.conceptButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openConceptFolder)))
                
                }, withCancelBlock: nil)
        } else {
            print("No DigitsID")
        }
        
        return companyView
    }
    
    func openConceptFolder() {
        
        if let folderUrlFromCash = NSUserDefaults.standardUserDefaults().stringForKey("folderUrl") {
           UIApplication.sharedApplication().openURL(NSURL(string: folderUrlFromCash)!)
        }
        
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tasks.count == 0 {
            tableView.separatorStyle = .None
            tableView.backgroundView?.hidden = false
        } else {
            tableView.separatorStyle = .SingleLine
            tableView.backgroundView?.hidden = true
        }
        
        return tasks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! UserCell
        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.text
        
        
        cell.notificationsLabel.hidden = true
        
        
        let taskRef = FIRDatabase.database().reference().child("tasks").child(task.taskId!)
        taskRef.observeEventType(.Value, withBlock: { (snapshot) in
            guard let status = snapshot.value!["status"] as? String else {
                return
            }
            
            if status == "none" {
                cell.detailTextLabel?.text = "Ищем дизайнера"
                
            } else if status == "awareness" {
                cell.detailTextLabel?.text = "Дизайнер разбирается в задаче"
                
            } else if status == "awarenessApprove" {
                cell.detailTextLabel?.text = "Согласуйте понимание задачи"
                
            } else if status == "concept" {
                cell.detailTextLabel?.text = "Дизайнер работает над черновиком"
                
            } else if status == "conceptApprove" {
                cell.detailTextLabel?.text = "Согласуйте черновик"
            } else if status == "design" {
                cell.detailTextLabel?.text = "Дизайнер работает над чистовиком"
            } else if status == "sources" {
                cell.detailTextLabel?.text = "Примите работу"
            } else if status == "done" {
                
            }
            
            
            if let taskImageUrl = snapshot.value!["imageUrl"] as? String {
                cell.taskImageView.loadImageUsingCashWithUrlString(taskImageUrl)
            } else {
                cell.taskImageView.image = UIImage.gifWithName("spinner-duo")
            }
            
            guard let minPrice = snapshot.value!["minPrice"] as? NSNumber else {
                return
            }
            
            guard let maxPrice = snapshot.value!["maxPrice"] as? NSNumber else {
                return
            }
            
            cell.timeLabel.text = String(minPrice) + " — " + String(maxPrice) + "₽"
            
            }, withCancelBlock: nil)
        
        let ref = FIRDatabase.database().reference().child("tasks").child(task.taskId!).child("messages")
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let status = snapshot.value!["status"] as? String
            if status == "toClient" {
                cell.notificationsLabel.hidden = false
            }
            }, withCancelBlock: nil)
        return cell
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let task = self.tasks[indexPath.row]
        
        let status = task.status! as String
        if status == "done" {
            let delete = UITableViewRowAction(style: .Default, title: "\u{267A}\n Delete") { action, index in
                print("more button tapped")
                
                self.tasks.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
            delete.backgroundColor = UIColor(r: 230, g: 230, b: 230)
            return [delete]
            
        } else {
            let nothing = UITableViewRowAction(style: .Default, title: "\u{267A}\n Delete") { action, index in
                print("more button tapped")
            }
            nothing.backgroundColor = UIColor(r: 230, g: 230, b: 230)
            
            return [nothing]
        }
        
    }
    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        let task = self.tasks[indexPath.row]
//        self.tasks.removeAtIndex(indexPath.row)
//        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//    }
    
  
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let task = tasks[indexPath.row]
        showChatControllerForUser(task)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 74
    }
    
    func openNewTaskView() {
        let newTaskController = NewTaskController()
        let navController = UINavigationController(rootViewController: newTaskController)
        presentViewController(navController, animated: true, completion: nil)
        
    }
    
    lazy var settingsLauncher: SettingsLauncher = {
        let launcher = SettingsLauncher()
        launcher.taskViewController = self
        return launcher
    }()
    
    func handleMore() {
        settingsLauncher.showSettings()
        
    }
    
    
    
    
    func checkIfUserIsLoggedIn() {
        let digits = Digits.sharedInstance()
        let digitsUid = digits.session()?.userID
        
        if digitsUid == nil {
            performSelector(#selector(handleLogout), withObject: nil, afterDelay: 0)
        } else {
            checkUserInBase()
        }
        
    }
    
    func handleLogout() {
        do {
            try FIRAuth.auth()?.signOut()
            try Digits.sharedInstance().logOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.taskViewController = self
        presentViewController(loginController, animated: true, completion: nil)
    }
    
    
    func checkUserInBase() {
        guard let userId = Digits.sharedInstance().session()?.userID, let phone = Digits.sharedInstance().session()?.phoneNumber   else {
            return
        }
        
        
        
        let ref = FIRDatabase.database().reference()
        let clientsReference = ref.child("clients")
        
        clientsReference.observeEventType(.Value, withBlock: { (snapshot) in
            
            if snapshot.hasChild(userId) {
                print("Знакомое лицо")
                
                clientsReference.child(userId).observeEventType(.Value, withBlock: { (snapshot) in
                    
                    if let name = snapshot.value!["name"] as? String {
                        NSUserDefaults.standardUserDefaults().setObject(name, forKey: "name")
                    }
                    
                    if let company = snapshot.value!["company"] as? String {
                        NSUserDefaults.standardUserDefaults().setObject(company, forKey: "company")
                    }
                    
                    }, withCancelBlock: nil)
                
                self.fetchUser()
       
            } else {
                print("Таких не знаем")
                
                let newClientViewController = NewClientViewController()
                let navController = UINavigationController(rootViewController: newClientViewController)
                self.presentViewController(navController, animated: true, completion: nil)
                
                let usersReference = ref.child("requests").child("clients").child(userId)
                let values: [String : String] = ["id": userId, "phone": phone, "state": "none"]
                
                usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if err != nil {
                        print(err)
                        return
                    }
                    
                })
                
            }
            
            }, withCancelBlock: nil)
    }
    
    
    
    func fetchUser() {
        tasks.removeAll()
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
        
        registerUserTokenInDB()
        observeUserTasks()
    }
    
    func registerUserTokenInDB(){
        
        guard let userId = Digits.sharedInstance().session()?.userID, let refreshedToken = FIRInstanceID.instanceID().token() else {
            return
        }
 
            let clientsReference = FIRDatabase.database().reference().child("user-token").child(userId)
            clientsReference.updateChildValues([refreshedToken: 1])
        
        
    }
    
    func observeUserTasks() {
        guard let uid = Digits.sharedInstance().session()!.userID else {
            return
        }
        self.testView.hidden = false
        let ref = FIRDatabase.database().reference().child("user-tasks").child(uid)
        ref.queryLimitedToLast(20).observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let taskId = snapshot.key
            let taskRef = FIRDatabase.database().reference().child("tasks").child(taskId)
            taskRef.queryOrderedByChild("timestamp").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let status = snapshot.value!["status"] as? String
                    if status == "done" {
                        print("Задача сдана")
                    } else {
                        let task = Task()
                        task.setValuesForKeysWithDictionary(dictionary)
                        self.tasks.append(task)
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadData()
                        })
                        self.testView.hidden = true
                    }
                    
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
        
        if setting.name == .Archive {
            //            handleLogout()
            let archiveViewController = ArchiveViewController()
            archiveViewController.view.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            archiveViewController.navigationItem.title = setting.name.rawValue
            navigationController?.pushViewController(archiveViewController, animated: true)
            
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
