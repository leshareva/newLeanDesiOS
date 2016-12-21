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
import Alamofire


class TaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellId = "cellId"
    var tableView: UITableView  =  UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    var tasks = [Task]()
    var user: User?
    var tasksDictionary = [String: Task]()
//    var beepSoundEffect: AVAudioPlayer!
    

    let emptyTableView = EmptyTableView()
    let loaderView = UIView()
    let buttonView = ButtonView()
    var timer: Timer?
    
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
        
    }
    
    func setupLogoView() {
        let logoView = UIImageView()
        logoView.frame = CGRect(x: 0, y: 10, width: 30, height: 36)
        logoView.image = UIImage(named: "support")
        logoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleOpenSupportChat)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: logoView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.buttonView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.buttonView.alpha = 1
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let companyView = CompanyView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
        companyView.backgroundColor = UIColor.white

        if let uid = Digits.sharedInstance().session()?.userID {
            let clientsRef = FIRDatabase.database().reference().child("clients")
            clientsRef.child(uid).observe(.value, with: { (snapshot) in
                
                companyView.companyNameLabel.text =  (snapshot.value as? NSDictionary)!["company"] as? String
                
                if let sum =  (snapshot.value as? NSDictionary)!["sum"] as? NSNumber {
                    companyView.priceLabel.text = String(describing: sum) + " ₽"
                }
                
                guard let conceptUrl =  (snapshot.value as? NSDictionary)!["conceptUrl"] as? String else {
                    return
                }
                
                 UserDefaults.standard.set(conceptUrl, forKey: "folder")
                
                companyView.conceptButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openConceptFolder)))
                
                }, withCancel: nil)
            
            companyView.payButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handlePay)))
            
        } else {
            print("No DigitsID")
        }
        
        return companyView
    }
    
    func handlePay() {
        let amountViewController = AmountViewController()
        navigationController?.pushViewController(amountViewController, animated: true)
    }
    
    
    func openConceptFolder() {
        if let folderUrlFromCash = UserDefaults.standard.string(forKey: "folder") {
//           UIApplication.shared.openURL(URL(string: folderUrlFromCash)!)
            let googleDriveViewController = GoogleDriveViewController()
            googleDriveViewController.folderUrl = folderUrlFromCash
            navigationController?.pushViewController(googleDriveViewController, animated: true)
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tasks.count == 0 {
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
        let taskId = task.taskId!
        
        let taskRef = FIRDatabase.database().reference().child("tasks").child(taskId)
        taskRef.observe(.value, with: { (snapshot) in
            guard let status = (snapshot.value as? NSDictionary)!["status"] as? String else {
                return
            }
            
            if status == "none" {
                cell.detailTextLabel?.text = "Подбираем дизайнера"
                cell.backgroundColor = .white
                cell.textLabel?.textColor = .black
                cell.detailTextLabel?.textColor = .black
            } else if status == "awareness" {
                cell.detailTextLabel?.text = "Дизайнер принял задачу"
                cell.backgroundColor = .white
                cell.textLabel?.textColor = .black
                cell.detailTextLabel?.textColor = .black
            } else if status == "awarenessApprove" {
                cell.detailTextLabel?.text = "Согласуйте понимание задачи"
                cell.notificationsLabel.isHidden = true
                cell.backgroundColor = LeanColor.acceptColor
                cell.textLabel?.backgroundColor = .clear
                cell.textLabel?.textColor = .white
                cell.detailTextLabel?.textColor = .white
            } else if status == "concept" {
                cell.detailTextLabel?.text = "Дизайнер работает над черновиком"
                cell.textLabel?.backgroundColor = .clear
                cell.backgroundColor = .white
                cell.textLabel?.textColor = .black
                cell.detailTextLabel?.textColor = .black
            } else if status == "conceptApprove" {
                cell.detailTextLabel?.text = "Согласуйте черновик"
                cell.textLabel?.backgroundColor = .clear
                cell.notificationsLabel.isHidden = true
                cell.backgroundColor = LeanColor.acceptColor
                cell.textLabel?.textColor = .white
                cell.detailTextLabel?.textColor = .white
            } else if status == "design" {
                cell.detailTextLabel?.text = "Дизайнер работает над чистовиком"
                cell.backgroundColor = .white
                cell.textLabel?.textColor = .black
                cell.detailTextLabel?.textColor = .black
            } else if status == "designApprove" {
                cell.detailTextLabel?.text = "Согласуйте чистовик"
                cell.notificationsLabel.isHidden = true
                cell.backgroundColor = LeanColor.acceptColor
                cell.textLabel?.textColor = .white
                cell.detailTextLabel?.textColor = .white
            } else if status == "sources" {
                cell.detailTextLabel?.text = "Дизайнер готовит исходники"
                cell.backgroundColor = .white
                cell.textLabel?.textColor = .black
                cell.detailTextLabel?.textColor = .black
                cell.notificationsLabel.isHidden = true
            } else if status == "done" {
                cell.detailTextLabel?.text = "Закройте задачу"
                cell.notificationsLabel.backgroundColor = LeanColor.acceptColor
                cell.notificationsLabel.isHidden = false
            }
            
            if let taskImageUrl = (snapshot.value as? NSDictionary)!["imageUrl"] as? String {
                cell.taskImageView.loadImageUsingCashWithUrlString(taskImageUrl)
            } else {
                cell.taskImageView.image = UIImage.gifWithName("spinner-duo")
            }

            
            }, withCancel: nil)
        
        
        let messageRef = FIRDatabase.database().reference().child("task-messages").child(task.taskId!)
        messageRef.observe(.childAdded, with: { (snapshot) in

            let ref = FIRDatabase.database().reference().child("messages").child(snapshot.key)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let status = (snapshot.value as? NSDictionary)!["status"] as? String
                if status == task.fromId {
                    cell.notificationsLabel.isHidden = false
                }
                }, withCancel: nil)
            
            
            }, withCancel: nil)
        
        
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    
    let waitingAlertView = WaitingAlertView()
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        
        
        guard let taskId = task.taskId else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("tasks").child(taskId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let status = dictionary["status"] as! String
         
            
            if status == "none" {
                if let keyWindow = UIApplication.shared.keyWindow {
                    self.waitingAlertView.alpha = 1
                    self.waitingAlertView.frame = keyWindow.frame
                    keyWindow.addSubview(self.waitingAlertView)
                    
                    self.waitingAlertView.textView.text = "«\(task.text!)»"
                    let tappy = MyTapGesture(target: self, action: #selector(self.cancelTask(_:)))
                    tappy.task = task
                    tappy.taskIndex = Int(indexPath.row)
                    self.waitingAlertView.cancelButton.addGestureRecognizer(tappy)
                    
                }
            } else {
                self.showChatControllerForUser(task)
            }
            
            
        }, withCancel: nil)
              
        
    }
    
    func cancelTask(_ sender: MyTapGesture) {
        guard let uid = Digits.sharedInstance().session()?.userID, let taskId = sender.task?.taskId else {
            return
        }
        
        let ref = FIRDatabase.database().reference()
        ref.child("active-tasks").child(uid).child(taskId).removeValue { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
        }
        
        let value: [String:AnyObject] = ["toId": "none" as AnyObject]
        ref.child("tasks").child(taskId).updateChildValues(value, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err!)
                return
            }
        })
        
        waitingAlertView.alpha = 0
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func openNewTaskView() {

        if let uid = Digits.sharedInstance().session()?.userID {
            let clientsRef = FIRDatabase.database().reference().child("clients").child(uid)
            clientsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let sum = (snapshot.value as? NSDictionary)!["sum"] as? Int {
                    if sum <= 100 {
                        let noMoneyViewController = NoMoneyViewController()
                        noMoneyViewController.sum = sum
                        let navController = UINavigationController(rootViewController: noMoneyViewController)
                        self.present(navController, animated: true, completion: nil)
                    } else {
                        let newTaskController = NewTaskController()
                        let navController = UINavigationController(rootViewController: newTaskController)
                        self.present(navController, animated: true, completion: nil)
                    }
                }
                
                }, withCancel: nil)
        }
        
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
        
        let ref = FIRDatabase.database().reference().child("active-tasks").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
                let taskId = snapshot.key
                let taskRef = FIRDatabase.database().reference().child("tasks").child(taskId)
                taskRef.queryOrdered(byChild: "time").observeSingleEvent(of: .value, with: { (snapshot) in
                    
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
//        self.tasks.sort(by: { (task1, task2) -> Bool in
//            return (task1.timestamp?.intValue)! > (task2.timestamp?.intValue)!
//        })
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
