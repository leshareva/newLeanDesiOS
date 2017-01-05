import UIKit
import Firebase
import DigitsKit
import DKImagePickerController
import Alamofire
import Cosmos


extension TaskViewController {
    
    
    
    func setupCompanyView(companyView: CompanyView) {
        
        let oldSum = UserDefaults.standard.integer(forKey: "sum")
        
        if let uid = Digits.sharedInstance().session()?.userID {
            let clientsRef = FIRDatabase.database().reference().child("clients")
            clientsRef.child(uid).observe(.value, with: { (snapshot) in
                
                companyView.companyNameLabel.text =  (snapshot.value as? NSDictionary)!["company"] as? String
                
                if let sum =  (snapshot.value as? NSDictionary)!["sum"] as? Int {
                    
                        print("oldSum ", oldSum)
                        print(sum)
    
                        companyView.priceLabel.countFrom(CGFloat(oldSum), to: CGFloat(sum), withDuration: 0.6)
                    
                        var timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateSum), userInfo: nil, repeats: false);
                    
                }
                
                guard let folderId =  (snapshot.value as? NSDictionary)!["conceptUrl"] as? String else {
                    return
                }
                
                UserDefaults.standard.set("https://drive.google.com/drive/folders/\(folderId)", forKey: "folder")
                
                companyView.conceptButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openConceptFolder)))
                
            }, withCancel: nil)
            
            companyView.payButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handlePay)))
            
        } else {
            print("No DigitsID")
        }
    }
    
    func updateSum() {
        if let uid = Digits.sharedInstance().session()?.userID {
            let clientsRef = FIRDatabase.database().reference().child("clients")
            clientsRef.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let sum =  (snapshot.value as? NSDictionary)!["sum"] as? Int {
                    UserDefaults.standard.set(sum, forKey: "sum")
                }
            }, withCancel: nil)
        }
    }
    
    func openTaskDetail(task: Task) {
        
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
                    self.waitingAlertView.cancelButton.addGestureRecognizer(tappy)
                }
            } else if status == "awareness" {

                let unreadRef = FIRDatabase.database().reference().child("task-messages")
                unreadRef.observe( .value, with: { (snapshot) in
                    if snapshot.hasChild(taskId) {
                        self.showChatControllerForUser(task)
                    } else {
                        let waitingAwarenessViewController = WaitingAwarenessViewController()
                        waitingAwarenessViewController.task = task
                        self.navigationController?.pushViewController(waitingAwarenessViewController, animated: true)
                    }
                }, withCancel: nil)
  
            } else if status == "awarenessApprove"{
                
                ref.child("awareness").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let awarenessStatus = (snapshot.value as! NSDictionary)["status"] as? String {
                        if awarenessStatus == "discuss" {
                            self.showChatControllerForUser(task)
                        } else {
                            let awarenessViewController = AwarenessViewController()
                            awarenessViewController.task = task
                            let navController = UINavigationController(rootViewController: awarenessViewController)
                            self.present(navController, animated: true, completion: nil)
                        }
                    }
                }, withCancel: nil)
                
            } else if status == "price" {
                let priceWaitingViewController = PriceWaitingViewController()
                self.navigationController?.pushViewController(priceWaitingViewController, animated: true)
            } else if status == "priceApprove"{
                let acceptPriceViewController = AcceptPriceViewController()
                acceptPriceViewController.task = task
                let navController = UINavigationController(rootViewController: acceptPriceViewController)
                self.present(navController, animated: true, completion: nil)
            } else if status == "conceptApprove" {
                ref.child("concept").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let conceptStatus = (snapshot.value as! NSDictionary)["status"] as? String {
                        if conceptStatus == "discuss" {
                            self.showChatControllerForUser(task)
                        } else {
                            self.openStepInfo(status: "concept", task: task)
                        }
                    }
                }, withCancel: nil)
                
               
            } else if status == "designApprove"{
                ref.child("design").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let designStatus = (snapshot.value as! NSDictionary)["status"] as? String {
                        if designStatus == "discuss" {
                            self.showChatControllerForUser(task)
                        } else {
                            self.openStepInfo(status: "design", task: task)
                        }
                    }
                }, withCancel: nil)
            } else if status == "sources"{
                self.showChatControllerForUser(task)
            } else if status == "sourcesApprove"{
                let completeViewController = CompleteViewController()
                completeViewController.task = task
                self.present(completeViewController, animated: true, completion: nil)
            } else {
               self.showChatControllerForUser(task)
            }
        }, withCancel: nil)
    }
    
    
    func cancelTask(_ sender: MyTapGesture) {
        guard let uid = Digits.sharedInstance().session()?.userID, let taskId = sender.task?.taskId else {
            return
        }
        
        
        var parameters: Parameters = [
            "subject": "reject",
            "taskId": taskId,
            "userId": uid
        ]
        
        Alamofire.request("\(Server.serverUrl)/tasks",
            method: .post,
            parameters: parameters)
        
        waitingAlertView.alpha = 0
    }
    
    
    
    func setupCell(task: Task, cell: TaskCell) {
        guard let uid = Digits.sharedInstance().session()?.userID, let taskId = task.taskId else {
            return
        }
        
        let taskRef = FIRDatabase.database().reference().child("tasks").child(taskId)
        taskRef.observe(.value, with: { (snapshot) in
            guard let status = (snapshot.value as? NSDictionary)!["status"] as? String else {
                return
            }
 
            cell.detailTextLabel?.backgroundColor = .clear
            cell.textLabel?.backgroundColor = .clear
 
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
                
                
                
//                guard let designerId = (snapshot.value as? NSDictionary)!["toId"] as? String else {
//                    return
//                }
//                let userRef = FIRDatabase.database().reference().child("designers").child(designerId)
//                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
//                    if let name = (snapshot.value as? NSDictionary)!["firstName"] as? String {
//                    
//                   
//
//                    }
//                })
                
            } else if status == "awarenessApprove" {
                
                if let awareness: [String: String] = (snapshot.value as? NSDictionary)!["awareness"] as? NSDictionary as! [String : String]? {
                    if awareness["status"] == "discuss" {
                        cell.detailTextLabel?.text = "Дизайнер разбирается в задаче"
                        cell.backgroundColor = .white
                        cell.textLabel?.textColor = .black
                        cell.detailTextLabel?.textColor = .black
                    } else if awareness["status"] == "unread" {
                        cell.detailTextLabel?.text = "Изучите как дизайнер понял задачу"
                        cell.backgroundColor = LeanColor.acceptColor
                        cell.textLabel?.textColor = .white
                        cell.detailTextLabel?.textColor = .white
                    } else if awareness["status"] == "read" {
                        cell.detailTextLabel?.text = "Согласуйте понимание задачи"
                        cell.backgroundColor = LeanColor.acceptColor
                        cell.textLabel?.textColor = .white
                        cell.detailTextLabel?.textColor = .white
                    }
                }
                
            } else if status == "price" {
                cell.detailTextLabel?.text = "Готовим оценку"
                cell.backgroundColor = .white
                cell.textLabel?.textColor = .black
                cell.detailTextLabel?.textColor = .black
            } else if status == "priceApprove" {
                cell.detailTextLabel?.text = "Согласуйте оцеку"
                cell.backgroundColor = LeanColor.acceptColor
                cell.textLabel?.backgroundColor = .clear
                cell.textLabel?.textColor = .white
                cell.detailTextLabel?.textColor = .white
            } else if status == "concept" {
                cell.detailTextLabel?.text = "Дизайнер работает над черновиком"
                cell.backgroundColor = .white
                cell.textLabel?.textColor = .black
                cell.detailTextLabel?.textColor = .black
            } else if status == "conceptApprove" {
                  
                if let concept: [String: AnyObject] = (snapshot.value as? NSDictionary)!["concept"] as? NSDictionary as! [String : AnyObject]? {
                    if concept["status"] as! String == "discuss" {
                        cell.detailTextLabel?.text = "Согласуйте черновик"
                        cell.backgroundColor = .white
                        cell.textLabel?.textColor = .black
                        cell.detailTextLabel?.textColor = .black
                    } else {
                        cell.detailTextLabel?.text = "Согласование черновика"
                        cell.backgroundColor = LeanColor.acceptColor
                        cell.textLabel?.textColor = .white
                        cell.detailTextLabel?.textColor = .white
                    }
                }
                
            } else if status == "design" {
                cell.detailTextLabel?.text = "Дизайнер работает над чистовиком"
                cell.backgroundColor = .white
                cell.textLabel?.textColor = .black
                cell.detailTextLabel?.textColor = .black
            } else if status == "designApprove" {
                
                if let design: [String: AnyObject] = (snapshot.value as? NSDictionary)!["design"] as? NSDictionary as! [String : AnyObject]? {
                    if design["status"] as! String == "discuss" {
                        cell.detailTextLabel?.text = "Согласуйте черновик"
                        cell.backgroundColor = .white
                        cell.textLabel?.textColor = .black
                        cell.detailTextLabel?.textColor = .black
                    } else {
                        cell.detailTextLabel?.text = "Согласование чистовика"
                        cell.backgroundColor = LeanColor.acceptColor
                        cell.textLabel?.textColor = .white
                        cell.detailTextLabel?.textColor = .white
                    }
                }
                
               
            } else if status == "sources" {
                cell.detailTextLabel?.text = "Дизайнер готовит исходники"
                cell.backgroundColor = .white
                cell.textLabel?.textColor = .black
                cell.detailTextLabel?.textColor = .black
            } else if status == "sourcesApprove" {
                cell.detailTextLabel?.text = "Задача закрыта. Исходники в вашей папке"
                cell.backgroundColor = LeanColor.acceptColor
                cell.textLabel?.textColor = .white
                cell.detailTextLabel?.textColor = .white
            } else if status == "done" {
                cell.detailTextLabel?.text = "Закройте задачу"
            }
            
            if let taskImageUrl = (snapshot.value as? NSDictionary)!["imageUrl"] as? String {
                cell.taskImageView.loadImageUsingCashWithUrlString(taskImageUrl)
            } else {
                cell.taskImageView.image = UIImage.gifWithName("spinner-duo")
            }
            
            let unreadRef = FIRDatabase.database().reference().child("clients").child(uid).child("unread").child(taskId)
            unreadRef.observe(.childAdded, with: { (snapshot) in
                if ((snapshot.value) != nil) {
                    cell.notificationsLabel.isHidden = false
                    cell.notificationsLabel.backgroundColor = LeanColor.acceptColor
                } else {
                    cell.notificationsLabel.isHidden = true
                }
            }, withCancel: nil)
            
            
        }, withCancel: nil)
        
        
        
    }
    
    
    func openConceptFolder() {
        if let folderUrlFromCash = UserDefaults.standard.string(forKey: "folder") {
            let googleDriveViewController = GoogleDriveViewController()
            googleDriveViewController.folderUrl = folderUrlFromCash
            navigationController?.pushViewController(googleDriveViewController, animated: true)
            
        }
        
    }
    
    func openStepInfo(status: String, task: Task) {
        let flowLayout = UICollectionViewFlowLayout()
        let conceptViewController = ConceptViewController(collectionViewLayout: flowLayout)
        conceptViewController.view.backgroundColor = UIColor.white
        conceptViewController.task = task
        
        if let taskId = task.taskId {
            let ref = FIRDatabase.database().reference().child("tasks").child(taskId).child(status)
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
    
    
    func openTip() {
        let whoViewController = WhoViewController()
        navigationController?.pushViewController(whoViewController, animated: true)
    }
    
}
