import UIKit
import Firebase
import DigitsKit
import DKImagePickerController
import Alamofire
import Cosmos
import Swiftstraints


extension TaskViewController {
    
    
    
    func setupCompanyView(companyView: CompanyView) {
        
      
        
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
            } else if status == "price" || status == "admin"{
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
                let priceWaitingViewController = PriceWaitingViewController()
                priceWaitingViewController.task = task
                priceWaitingViewController.titleView.text = "Готовим исходники"
                priceWaitingViewController.descriptionText.text = ""
                self.navigationController?.pushViewController(priceWaitingViewController, animated: true)
            } else if status == "sourcesApprove"{
                self.openSourcesView(task: task)
            } else {
//               self.showChatControllerForUser(task)
            }
        }, withCancel: nil)
    }
    
    
    func cancelTask(_ sender: MyTapGesture) {
        guard let taskId = sender.task?.taskId else {
            return
        }
        
        var parameters: Parameters = [
            "taskId": taskId
        ]
        
        
        Alamofire.request("\(Server.serverUrl)/tasks/remove",
            method: .post,
            parameters: parameters).responseJSON { response in
                
                if let result = response.result.value as? [String: Any] {
                    let success = result["success"] as! Bool
                    if success == true {
                        self.waitingAlertView.alpha = 0
                        self.tasksDictionary.removeValue(forKey: taskId)
                        self.attemptReloadTable()
                    }
   
                }
        }
        
        
    }
    
    
    
    func setupCell(task: Task, cell: TaskCell) {
        guard let uid = Digits.sharedInstance().session()?.userID, let taskId = task.taskId else {
            return
        }
        
        let taskRef = FIRDatabase.database().reference().child("tasks").child(taskId)
        taskRef.observe(.value, with: { (snapshot) in
             if let status = (snapshot.value as! NSDictionary)["status"] as? String {
                
                
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
                } else if status == "awarenessApprove" {
                    cell.detailTextLabel?.text = "Согласуйте понимание задачи"
                    cell.backgroundColor = LeanColor.acceptColor
                    cell.textLabel?.textColor = .white
                    cell.detailTextLabel?.textColor = .white
                } else if status == "price" || status == "admin"{
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
                    cell.detailTextLabel?.text = "Согласуйте черновик"
                    cell.backgroundColor = LeanColor.acceptColor
                    cell.textLabel?.backgroundColor = .clear
                    cell.textLabel?.textColor = .white
                    cell.detailTextLabel?.textColor = .white
                } else if status == "design" {
                    cell.detailTextLabel?.text = "Дизайнер работает над чистовиком"
                    cell.backgroundColor = .white
                    cell.textLabel?.textColor = .black
                    cell.detailTextLabel?.textColor = .black
                } else if status == "designApprove" {
                    cell.detailTextLabel?.text = "Согласуйте черновик"
                    cell.backgroundColor = LeanColor.acceptColor
                    cell.textLabel?.backgroundColor = .clear
                    cell.textLabel?.textColor = .white
                    cell.detailTextLabel?.textColor = .white
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
                
                if status != "none" {
                    
                    guard let designersId = task.toId else {
                        return
                    }
                    
                    let parameters: Parameters = [
                        "type": "designer",
                        "userId": designersId
                    ]
                    
                    Alamofire.request("\(Server.serverUrl)/users/get",
                        method: .post,
                        parameters: parameters).responseJSON { response in
                            
                            if let user = response.result.value as? [String: Any] {
                                if let userPhoto = user["photoUrl"] as? String {
                                    cell.taskImageView.loadImageUsingCashWithUrlString(String(userPhoto))
                                }
                            }
                    }
                    
                    
                   
                }
               
                
            }
            
            
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
    
    
    func openSourcesView(task: Task) {
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
                            self.myPromoView!.percent = "4"
                            let tappy = MyTapGesture(target: self, action: #selector(self.sharePromo(_:)))
                            tappy.string = code
                            self.myPromoView?.button.addGestureRecognizer(tappy)
                            self.myPromoView?.shareIcon.addGestureRecognizer(tappy)
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
