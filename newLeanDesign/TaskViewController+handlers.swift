import UIKit
import Firebase
import DigitsKit
import DKImagePickerController
import Alamofire
import Cosmos
import Swiftstraints


extension TaskViewController {
    
    
    
    func setupCompanyView(companyView: CompanyView) {
        
        if tasks.count == 0 {
            companyView.titleTableLabel.isHidden = true
        } else {
            companyView.titleTableLabel.isHidden = false
        }
        
        
        let oldSum = UserDefaults.standard.integer(forKey: "sum")
        
        if let uid = Digits.sharedInstance().session()?.userID {
            let clientsRef = FIRDatabase.database().reference().child("clients")
            clientsRef.child(uid).observe(.value, with: { (snapshot) in
                
                guard let company = (snapshot.value as? NSDictionary)!["company"] as? String else {
                    print("no company name")
                    return
                }
                
                
                if company.characters.count <= 1 {
                    companyView.companyNameLabel.text = (snapshot.value as? NSDictionary)!["firstName"] as? String
                } else {
                   companyView.companyNameLabel.text = company
                }

                
                if let sum =  (snapshot.value as? NSDictionary)!["sum"] as? Int {
                        companyView.priceLabel.countFrom(CGFloat(oldSum), to: CGFloat(sum), withDuration: 0.6)
                    
                        var timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateSum), userInfo: nil, repeats: false);
                    
                }
                
//                guard let folderId =  (snapshot.value as? NSDictionary)!["conceptUrl"] as? String else {
//                    return
//                }
//                
//                UserDefaults.standard.set("https://drive.google.com/drive/folders/\(folderId)", forKey: "folder")
                
//                companyView.conceptContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openConceptFolder)))
                
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
                let waitingAwarenessViewController = WaitingAwarenessViewController()
                waitingAwarenessViewController.task = task
                self.navigationController?.pushViewController(waitingAwarenessViewController, animated: true)
            } else if status == "awarenessApprove"{
                let awarenessViewController = AwarenessViewController()
                awarenessViewController.task = task
                let navController = UINavigationController(rootViewController: awarenessViewController)
                self.present(navController, animated: true, completion: nil)
            } else if status == "price" {
                let priceWaitingViewController = PriceWaitingViewController()
                priceWaitingViewController.task = task
                self.navigationController?.pushViewController(priceWaitingViewController, animated: true)
            } else if status == "priceApprove"{
                let acceptPriceViewController = AcceptPriceViewController()
                acceptPriceViewController.task = task
                let navController = UINavigationController(rootViewController: acceptPriceViewController)
                self.present(navController, animated: true, completion: nil)
            } else if status == "concept" {
                let priceWaitingViewController = PriceWaitingViewController()
                priceWaitingViewController.task = task
                priceWaitingViewController.titleView.text = "Дизайнер работает над черновиком"
                priceWaitingViewController.descriptionText.text = ""
                self.navigationController?.pushViewController(priceWaitingViewController, animated: true)
            } else if status == "conceptApprove" {
                self.openStepInfo(status: "concept", task: task)
            } else if status == "design" {
                let priceWaitingViewController = PriceWaitingViewController()
                priceWaitingViewController.titleView.text = "Дизайнер работает над чистовиком"
                priceWaitingViewController.task = task
                priceWaitingViewController.descriptionText.text = ""
                self.navigationController?.pushViewController(priceWaitingViewController, animated: true)
            } else if status == "designApprove"{
                self.openStepInfo(status: "design", task: task)
            } else if status == "sources"{
              
            } else if status == "sourcesApprove"{
                let completeViewController = CompleteViewController()
                completeViewController.task = task
                self.present(completeViewController, animated: true, completion: nil)
            } else {
//               self.showChatControllerForUser(task)
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
                DispatchQueue.main.async {
                    cell.taskImageView.loadImageUsingCashWithUrlString(taskImageUrl)
                }
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
        let flowLayout = UICollectionViewFlowLayout()
        let myFilesViewController = MyFilesViewController()
        navigationController?.pushViewController(myFilesViewController, animated: true)
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
    
    
    func handlePromo() {
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            
            keyWindow.addSubview(blackBackgroundView!)
            
            self.myPromoView = MyPromoView(frame: CGRect(x: 10, y: -210, width: self.view.frame.size.width - 20, height: 210))
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 0.7
                
                self.myPromoView?.frame = CGRect(x: 10, y: 120, width: self.view.frame.size.width - 20, height: 210)
                
                keyWindow.addSubview(self.myPromoView!)
                
                if let uid = Digits.sharedInstance().session()?.userID {
                    let clientsRef = FIRDatabase.database().reference().child("clients")
                    clientsRef.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let code = (snapshot.value as! NSDictionary)["code"] as? String {
                            print("this is my promo \(code)" )
                            self.myPromoView!.buttonLabel.text = code
                            
                            let tappy = MyTapGesture(target: self, action: #selector(self.sharePromo(_:)))
                            tappy.string = code
                            self.myPromoView?.button.addGestureRecognizer(tappy)
                        }
                    }, withCancel: nil)
                }

                self.blackBackgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handlePromoDissmiss)))
                
            }, completion: nil)
        }
    }
    
    
    func handlePromoDissmiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackBackgroundView?.alpha = 0
            self.myPromoView?.frame = CGRect(x: 10, y: -260, width: self.view.frame.size.width - 20, height: 210)
        }, completion: nil)
    }
    
    func setupPromoView() {
//        self.promoButton.frame = CGRect(x: 20, y: -10, width: self.view.frame.size.width - 40, height: 40)
        
        self.view.addSubview(self.promoButton)
        
        self.view.addConstraints("H:|-10-[\(self.promoButton)]-10-|")
        self.view.addConstraints(self.promoButton.heightAnchor == 47, self.promoButton.topAnchor == self.view.topAnchor - 5)
        self.promoButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePromo)))
        
        
        self.promoButton.addSubview(self.promoLabel)
        self.promoButton.addConstraints("H:|[\(self.promoLabel)]|")
        self.promoButton.addConstraints("V:|-3-[\(self.promoLabel)]|")
        
    }
    
    
    
    
    
    
    func sharePromo(_ sender : MyTapGesture) {
        
        handlePromoDissmiss()
        
        let code = sender.string

        let message = "Зарегистрируйся в Лин Дизайне с моим промо кодом: \(code!) и получи 500руб на первый заказ. http://leandesign.pro"
        
        let shareItems:Array = [message]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
        self.present(activityViewController, animated: true, completion: nil)

    }
    
}
