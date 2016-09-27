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
    var user: User?
    
    static let blueColor = UIColor(r: 48, g: 140, b: 229)
    

    let emptyTableView = EmptyTableView()
    let loaderView = UIView()
    let buttonView = ButtonView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "point")?.imageWithRenderingMode(.AlwaysOriginal), style: .Plain, target: self, action: #selector(handleMore))
        navigationController?.navigationBar.translucent = false
     
        
        checkIfUserIsLoggedIn()
        setupLogoView()
        setupTableView()
//        registerUserTokenInDB()
    }
    
    func setupLogoView() {
        let logoView = UIImageView()
        logoView.frame = CGRect(x: 0, y: 0, width: 89, height: 29)
        logoView.image = UIImage(named: "logo")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: logoView)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.buttonView.alpha = 0
       
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.buttonView.alpha = 1
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let companyView = CompanyView(frame: CGRectMake(0, 0, tableView.frame.size.width, 60))
        companyView.backgroundColor = UIColor.whiteColor()

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
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! TaskCell
        
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
            } 

            if let taskImageUrl = snapshot.value!["imageUrl"] as? String {
                cell.taskImageView.loadImageUsingCashWithUrlString(taskImageUrl)
            } else {
                cell.taskImageView.image = UIImage.gifWithName("spinner-duo")
            }

            
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
    
    
    func openNewClientView() {
        let newClientViewController = NewClientViewController()
        let navigationController = UINavigationController(rootViewController: newClientViewController)
        self.presentViewController(navigationController, animated: true, completion: nil)
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
        guard let userId = Digits.sharedInstance().session()?.userID else {
            return
        }
        
        setupLoadingView()

        let ref = FIRDatabase.database().reference()
        let clientsReference = ref.child("clients")
        
        clientsReference.observeEventType(.Value, withBlock: { (snapshot) in
            if snapshot.hasChild(userId) {
                self.fetchUser()
                
                
                self.view.addSubview(self.tableView)
                
                self.buttonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openNewTaskView)))
            } else {
                
                self.view.addSubview(self.emptyTableView)
                self.buttonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openNewClientView)))
                
            }
            
           self.setupbuttonView()
            
        }, withCancelBlock: nil)
    }
    
    func setupTableView() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        tableView.frame         =   CGRectMake(0, 0, 320, screenSize.height);
        tableView.delegate      =   self
        tableView.dataSource    =   self
        
        tableView.registerClass(TaskCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.backgroundView = emptyTableView
    }
    
    func setupbuttonView() {
        self.view.addSubview(self.buttonView)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(buttonView.widthAnchor == self.view.widthAnchor,
                                 buttonView.bottomAnchor == self.view.bottomAnchor,
                                 buttonView.heightAnchor == 50)
        buttonView.buttonLabel.text = "Добавить задачу"
    }
    

    
    func setupLoadingView() {
        self.view.addSubview(loaderView)

        let options : UIViewAnimationOptions =  [UIViewAnimationOptions.Autoreverse, UIViewAnimationOptions.Repeat, UIViewAnimationOptions.CurveEaseOut]
        
        loaderView.backgroundColor = UIColor(r: 48, g: 140, b: 229)
        loaderView.frame = CGRect(x: self.view.frame.width / 2, y: 0, width: 0, height: 10)
        
        UIView.animateWithDuration(1.0, delay: 0.0, options: options, animations: {
            self.loaderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 10)
            }, completion: nil)
    }
    
    
    func fetchUser() {
        tasks.removeAll()
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
       
        observeUserTasks()
        registerUserTokenInDB()
    }
    
    
    
    func registerUserTokenInDB(){
        
//        guard let userId = Digits.sharedInstance().session()?.userID else {
//            return
//        }
//      
//        let defaults = NSUserDefaults.standardUserDefaults()
//        if let userToken = defaults.stringForKey("userToken") {
//            let clientsReference = FIRDatabase.database().reference().child("user-token").child(userId)
//            clientsReference.updateChildValues([userToken: 1])
//        }
    }
    
    
    
    func observeUserTasks() {
        self.loaderView.hidden = false
        
        guard let uid = Digits.sharedInstance().session()!.userID else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("active-tasks").child(uid)
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
                let taskId = snapshot.key
                let taskRef = FIRDatabase.database().reference().child("tasks").child(taskId)
                taskRef.queryOrderedByChild("time").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    
                        if let dictionary = snapshot.value as? [String: AnyObject] {
                            let status = snapshot.value!["status"] as? String
                                let task = Task()
                                task.setValuesForKeysWithDictionary(dictionary)
                                self.tasks.append(task)
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.tableView.reloadData()
                                })
                                self.loaderView.hidden = true
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
    

}
