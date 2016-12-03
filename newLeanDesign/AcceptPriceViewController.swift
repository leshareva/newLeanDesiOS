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

class AcceptPriceViewController: UIViewController {

    var task: Task?
    var time: Int?
    
    let titleLabel: UITextView = {
       let tl = UITextView()
        tl.text = "Стоимость заказа"
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.font = UIFont.boldSystemFont(ofSize: 24.0)
        tl.isEditable = false
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
        tv.text = "Стоимость задачи определяется исходя из трудозатрат дизайнера"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.textAlignment = .center
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
        btn.setTitle("Цена не подходит", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return btn
    }()
    
    let cancelText: UITextView = {
       let tv = UITextView()
        tv.text = "Если цена вам не подходит, задача отменяется и попадает в архив"
        tv.font = UIFont.systemFont(ofSize: 12.0)
        tv.textColor = .lightGray
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textAlignment = .center
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    func handleCancel() {
        guard let taskId = task?.taskId else {
            return
        }
        let ref = FIRDatabase.database().reference()
        let value: [String: AnyObject] = ["status": "reject" as AnyObject]
        ref.child("tasks").child(taskId).updateChildValues(value, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error as! NSError)
                return
            }
        })

        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
 
    }
    
    
    
    func handleAccept() {
        guard let taskId = task?.taskId else {
            return
        }
        
        var days: Int?
        if Int(time!) <= 3 {
            days = 1
        } else if Int(time!) > 3 && Int(time!) <= 6 {
            days = 2
        } else if Int(time!) > 6 && Int(time!) <= 9 {
            days = 3
        }
        
        let newstatus = "concept"
        let ref = FIRDatabase.database().reference()
        let taskRef = ref.child("tasks").child(taskId)
        
        let startDate = NSNumber(value: Int(Date().timeIntervalSince1970))
        let calculatedDate = (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: days!, to: Date(), options: NSCalendar.Options.init(rawValue: 0))
        
        let endDate = NSNumber(value: Int(calculatedDate!.timeIntervalSince1970))
        
        
        let values : [String: AnyObject] = ["status": newstatus as AnyObject, "start": startDate as AnyObject, "end": endDate as AnyObject]

        taskRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
        })
        
        
        let awStatus : [String: AnyObject] = ["status": "accept" as AnyObject]
        taskRef.child("awareness").updateChildValues(awStatus, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err as! NSError)
                return
            }
        })
        
        let stepStatus : [String: AnyObject] = ["status": "none" as AnyObject]
        taskRef.child(newstatus).updateChildValues(stepStatus, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error as! NSError)
                return
            }
        })
        
        guard let price = task?.price else {
            return
        }
        
        let bill = Double(price) * Double(0.1)
        let conceptViewController = ConceptViewController()
        conceptViewController.sendBill(bill: Int(bill))
        
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
       
    }
  
    
    
    func setupView() {
        view.addSubview(titleLabel)
        view.addSubview(priceLabel)
        view.addSubview(aboutTextView)
        view.addSubview(acceptButton)
        view.addSubview(cancelButton)
        view.addSubview(cancelText)
        
        guard let price = task?.price else {
            return
        }
        
        priceLabel.text = "\(String(describing: price)) ₽"
        
        view.addConstraints("H:|[\(titleLabel)]|", "H:|[\(priceLabel)]|", "H:|[\(aboutTextView)]|", "H:|-10-[\(acceptButton)]-10-|", "H:|-10-[\(cancelButton)]-10-|", "H:|-10-[\(cancelText)]-10-|")
        view.addConstraints("V:|-140-[\(titleLabel)]-2-[\(priceLabel)]-10-[\(aboutTextView)]")
        view.addConstraints("V:[\(acceptButton)]-10-[\(cancelButton)]-10-[\(cancelText)]-10-|")
        view.addConstraints(titleLabel.heightAnchor == 40, priceLabel.heightAnchor == 80, aboutTextView.heightAnchor == 100, acceptButton.heightAnchor == 50, cancelButton.heightAnchor == 50, cancelText.heightAnchor == 80)
    }
    
    
    
    
}
