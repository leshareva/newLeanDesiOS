//
//  AcceptPriceViewController.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 11/30/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Firebase
import Swiftstraints
import Alamofire
import DigitsKit
import Toast_Swift

class AcceptPriceViewController: UIViewController {

    var task: Task?
    
    let titleLabel: UILabel = {
       let tl = UILabel()
        tl.text = "Стоимость заказа"
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.font = UIFont.boldSystemFont(ofSize: 16.0)
        tl.textColor = .black
        tl.textAlignment = .center
        return tl
    }()
    
    let priceLabel: UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.font = UIFont.boldSystemFont(ofSize: 64.0)
        tv.textAlignment = .center
        return tv
    }()
    
    let aboutTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .lightGray
        tv.textAlignment = .left
        tv.backgroundColor = .clear
        tv.font = UIFont.systemFont(ofSize: 12.0)
        tv.isEditable = false
        return tv
    }()
    
    let priceTitle: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.font = UIFont.boldSystemFont(ofSize: 16.0)
        tv.textAlignment = .left
        tv.isEditable = false
        return tv
    }()

    let labelsList: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.textAlignment = .left
        tv.backgroundColor = .clear
        tv.font = UIFont.systemFont(ofSize: 16.0)
        tv.isEditable = false
        return tv
    }()
    
    let priceList: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.textAlignment = .left
        tv.backgroundColor = .clear
        tv.font = UIFont.systemFont(ofSize: 16.0)
        tv.isEditable = false
        return tv
    }()
    
    lazy var acceptButton: UIButton = {
       let btn = UIButton()
        btn.backgroundColor = UIColor(r: 0, g: 127, b: 255)
        btn.setTitle("Принимаю", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
        return btn
    }()
    
    lazy var cancelButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .white
        btn.setTitleColor( .black, for: .normal)
        btn.setTitle("Отменить задачу", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return btn
    }()
    
    let cancelText: UITextView = {
       let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 12.0)
        tv.textColor = .lightGray
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textAlignment = .center
        tv.isEditable = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(handleDismiss))
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    
    func handleCancel() {
        
        let alert = UIAlertController(title: "Отменить задачу?", message: "Задача будет помещена в архив. С вашего счета мы ничего не спишем", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Отменить", style: .default, handler: { (action: UIAlertAction!) in
            self.navigationController?.popToRootViewController(animated: true)
            self.sendRejectTask()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Назад", style: .default, handler: { (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)

        
        
    }
    
    func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func sendRejectTask() {
        guard let taskId = task?.taskId, let designerId = task?.toId else {
            return
        }
        
        let parameters: Parameters = [
            "taskId": taskId,
            "status": "reject"
        ]
        
        Alamofire.request("\(Server.serverUrl)/tasks/update",
            method: .post,
            parameters: parameters)
        
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        
        TaskMethods.sendPush(message: "Клиент отменил задачу", toId: designerId, taskId: taskId)
        
        
    }
    
    
    
    func handleAccept() {

        guard let taskId = task?.taskId, let price = task?.price, let userId = Digits.sharedInstance().session()?.userID, let designerId = task?.toId else {
            return
        }
        
        
        let tinkoffViewController = TinkoffViewController()
        tinkoffViewController.amount = Int(price)
        
        let navController = UINavigationController(rootViewController: tinkoffViewController)
        self.navigationController?.present(navController, animated: true, completion: nil)
        
//        let ref = FIRDatabase.database().reference()
//        ref.child("clients").child(userId).observeSingleEvent(of: .value, with: {(snapshot) in
//            if let sum = (snapshot.value as! NSDictionary)["sum"] as? Int {
//                if sum < Int(price) {
//                    let noMoneyViewController = NoMoneyViewController()
//                    noMoneyViewController.sum = sum
//                    noMoneyViewController.price = price as Int!
//                    self.navigationController?.pushViewController(noMoneyViewController, animated: true)
//                } else {
//                    let parameters: Parameters = [
//                        "taskId": taskId
//                    ]
//                    
//                    Alamofire.request("\(Server.serverUrl)/workdone",
//                        method: .post,
//                        parameters: parameters).responseJSON { response in
//                            
//                            if let result = response.result.value as? [String: Any] {
//                               print(result)
//                                self.view.makeToast("This is a piece of toast")
//                            }
//                    }
//
//                    
//                    TaskMethods.sendPush(message: "Клиент согласовал понимание задачи", toId: designerId, taskId: taskId)
//                    self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
//                }
//            }
//        }, withCancel: nil)
        
        

    }
    
    
    func setupView() {
        view.addSubview(titleLabel)
        view.addSubview(priceLabel)
        
        
        view.addSubview(acceptButton)
        view.addSubview(cancelButton)
        view.addSubview(cancelText)
        
        
        guard let taskId = task?.taskId else {
            return
        }
        let ref = FIRDatabase.database().reference()
        let taskRef = ref.child("tasks").child(taskId)
        taskRef.observeSingleEvent(of: .value, with: {(snapshot) in
            guard let price = (snapshot.value as! NSDictionary)["price"] as? Int else {
                return
            }
            
            self.priceLabel.text = "\(String(describing: lroundf(Float(price)))) ₽"
//            let awarenessPrice = Double(price) * 0.10
//            let conceptPrice = Double(price) * 0.50
//            let designPrice = Double(price) * 0.40
//            self.labelsList.text = "Понимание задачи\nЧерновик\nЧистовик"
//            self.priceList.text = "\(String(lroundf(Float(awarenessPrice))))₽\n\(String(lroundf(Float(conceptPrice))))₽\n\(String(lroundf(Float(designPrice))))₽"
//            self.priceTitle.text = "Деньги снимаются поэтапно"
            self.cancelText.text = "Если цена вам не подходит, задача отменится и попадет в архив."
            
        })
        
        view.addSubview(labelsList)
        view.addSubview(priceList)
        view.addSubview(priceTitle)
        
        view.addConstraints(
            priceTitle.topAnchor == priceLabel.bottomAnchor + 20,
            priceTitle.leftAnchor == view.leftAnchor + 20,
            priceTitle.widthAnchor == view.widthAnchor - 20,
            priceTitle.heightAnchor == 30,
            labelsList.topAnchor == priceTitle.bottomAnchor,
            labelsList.heightAnchor == 90,
            labelsList.widthAnchor == view.widthAnchor / 2,
            labelsList.leftAnchor == view.leftAnchor + 20,
            priceList.topAnchor == labelsList.topAnchor,
            priceList.widthAnchor == view.widthAnchor / 2,
            priceList.leftAnchor == labelsList.rightAnchor + 20,
            priceList.heightAnchor == 90
        )
        
        
        view.addConstraints("H:|[\(titleLabel)]|", "H:|[\(priceLabel)]|", "H:|-10-[\(acceptButton)]-10-|", "H:|-10-[\(cancelButton)]-10-|", "H:|-16-[\(cancelText)]-16-|")
        view.addConstraints("V:|-90-[\(titleLabel)]-2-[\(priceLabel)]")
        view.addConstraints("V:[\(acceptButton)]-10-[\(cancelButton)]-10-[\(cancelText)]-10-|")
        view.addConstraints(titleLabel.heightAnchor == 20, priceLabel.heightAnchor == 80, acceptButton.heightAnchor == 50, cancelButton.heightAnchor == 50, cancelText.heightAnchor == 60)
    }
   
    
   
    
}

