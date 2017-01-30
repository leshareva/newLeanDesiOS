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
import FirebaseMessaging
import AVFoundation
import DigitsKit
import Swiftstraints
import Alamofire
import Toast_Swift


class TaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var activityIndicatorView: UIActivityIndicatorView!
    let cellId = "cellId"
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    
    var tableView: UITableView  =  UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    var tasks = [Task]()
    var user: User?
    var tasksDictionary = [String: Task]()
    
    let waitingAlertView = WaitingAlertView()

    let emptyTableView = EmptyTableView()
    let loaderView = UIView()
    let buttonView = ButtonView()
    var timer: Timer?
    
    
    let inboxView = UIView()
    var userName: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "point")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMore))
        navigationController?.navigationBar.isTranslucent = false
        self.view.backgroundColor = UIColor.white

        fetchUser()
        
        view.addSubview(tableView)
        buttonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openNewTaskView)))
        
        setupLoadingView()
        setupbuttonView()
        setupLogoView()
        setupTableView()
        
        
        let refreshedToken = FIRInstanceID.instanceID().token()
        if (refreshedToken != nil) {
            if let userId = Digits.sharedInstance().session()?.userID  {
                let clientsReference = FIRDatabase.database().reference().child("user-token").child(userId)
                clientsReference.updateChildValues([refreshedToken!: 1])
            } else {
                print("error: No Digits")
            }
        }
        
        
        guard let uid = Digits.sharedInstance().session()?.userID else {
            return
        }
        
        let ref = FIRDatabase.database().reference()
        ref.child("clients").child(uid).child("inbox").observe(.childAdded, with: {(snapshot) in
            
            if snapshot.value != nil {
                if let bill = (snapshot.value as! NSDictionary)["bill"], let stage = (snapshot.value as! NSDictionary)["stage"] as? String {
                    self.view.makeToast("Со счета списано \(String(describing: bill)) ₽ за \(stage)" )
                    ref.child("clients").child(uid).child("inbox").child(snapshot.key).removeValue()
                }
                
                
            }
            
        }, withCancel: nil)
        
        
    }

    
    
    
    func setupLogoView() {
        
        let supportIconView = SupportIconView()
        supportIconView.frame = CGRect(x: 0, y: 10, width: 30, height: 36)
        
        
        guard let uid = Digits.sharedInstance().session()?.userID else {
            print("No Digits ID")
            return
        }
        
        let ref = FIRDatabase.database().reference()
        ref.child("clients").child(uid).child("unread").observe( .value, with: {(snapshot) in
            if snapshot.hasChild("support") {
                supportIconView.bubble.isHidden = false
            } else {
                supportIconView.bubble.isHidden = true
            }
        }, withCancel: nil)
        
        
        supportIconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleOpenSupportChat)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: supportIconView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.buttonView.alpha = 0
        
        
        if (tasks.count == 0) {
            tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            
            activityIndicatorView.startAnimating()
            
            dispatchQueue.async {
                Thread.sleep(forTimeInterval: 3)
                
                OperationQueue.main.addOperation() {
                    
                    if (self.tasks.count == 0) {
                        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                        self.tableView.backgroundView = self.emptyTableView
                        self.activityIndicatorView.stopAnimating()
                    }
                    
                }
            }
            
        }
        
    }
    
    let tipView: TipView = {
        let tip = TipView()
        tip.translatesAutoresizingMaskIntoConstraints = false
        tip.label.text = "Что за дизайнеры?"
        return tip
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.buttonView.alpha = 1
            }, completion: nil)
  
    }
    
    
  
    
    func handlePay() {
        let amountViewController = AmountViewController()
        navigationController?.pushViewController(amountViewController, animated: true)
    }
 
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let companyView = CompanyView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
        companyView.backgroundColor = UIColor.white
        setupCompanyView(companyView: companyView)
        
        return companyView
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tasks.count == 0 {
            self.loaderView.isHidden = true
            tableView.separatorStyle = .none
            tableView.backgroundView?.isHidden = false
        } else {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView?.isHidden = true
        }
        
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TaskCell

        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.text
        cell.notificationsLabel.isHidden = true
        
        setupCell(task: task, cell: cell)

        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        openTaskDetail(task: task)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func openNewTaskView() {
        let newTaskController = NewTaskController()
        let navController = UINavigationController(rootViewController: newTaskController)
        self.present(navController, animated: true, completion: nil)
      
    }
    
 
    lazy var settingsLauncher: SettingsLauncher = {
        let launcher = SettingsLauncher()
        launcher.taskViewController = self
        return launcher
    }()
    
    func handleMore() {
        settingsLauncher.showSettings()
    }
    

    
    func handleLogout() {
        Digits.sharedInstance().logOut()
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.taskViewController = self
        present(loginController, animated: true, completion: nil)
    }
    
    
     func setupTableView() {
        let screenSize: CGRect = UIScreen.main.bounds
        tableView.frame         =   CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height - 70);
        tableView.delegate      =   self
        tableView.dataSource    =   self
        
        tableView.register(TaskCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsMultipleSelectionDuringEditing = true
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        tableView.backgroundView = activityIndicatorView
        
  
    }
    
    
    func setupbuttonView() {
        self.view.addSubview(self.buttonView)
        buttonView.buttonLabel.font = UIFont.systemFont(ofSize: 20.0)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(buttonView.widthAnchor == self.view.widthAnchor,
                                 buttonView.bottomAnchor == self.view.bottomAnchor,
                                 buttonView.heightAnchor == 70)
        buttonView.buttonLabel.text = "Добавить задачу"
    }
    

    
    func setupLoadingView() {
        self.view.addSubview(loaderView)

        let options : UIViewAnimationOptions =  [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat, UIViewAnimationOptions.curveEaseOut]
        
        loaderView.backgroundColor = UIColor(r: 0, g: 127, b: 255)
        loaderView.frame = CGRect(x: self.view.frame.width / 2, y: 0, width: 0, height: 10)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: options, animations: {
            self.loaderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 10)
            }, completion: nil)
    }
    
    
    func fetchUser() {
        tasks.removeAll()
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
       
        observeUserTasks()
        
    }
    

    
    func observeUserTasks() {
        self.loaderView.isHidden = false
        
        guard let uid = Digits.sharedInstance().session()!.userID else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("clients").child(uid).child("activeTasks")
        ref.observe(.childAdded, with: { (snapshot) in
            
                let taskId = snapshot.key
                let taskRef = FIRDatabase.database().reference().child("tasks").child(taskId)
                taskRef.queryOrdered(byChild: "time").observe(.value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let task = Task(dictionary: dictionary)
                        self.tasksDictionary[taskId] = task
                    }
                    
                    self.attemptReloadTable()
                    self.loaderView.isHidden = true
                }, withCancel: nil)
            
 
            }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snap) in
            self.tasksDictionary.removeValue(forKey: snap.key)
            self.attemptReloadTable()
            self.loaderView.isHidden = true
        }, withCancel: nil)
        
        
        
        
    }
    
    
    
    private func attemptReloadTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    
    func handleReloadTable() {
        self.tasks = Array(self.tasksDictionary.values)
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    
    func showChatControllerForUser(_ task: Task) {
        let chatController = ChatViewController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.task = task
        navigationController?.pushViewController(chatController, animated: true)
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
    
    
    func handleOpenSupportChat() {
        let supportViewController = SupportViewController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(supportViewController, animated: true)
    }
    

}
