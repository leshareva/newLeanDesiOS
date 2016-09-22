//
//  NewTaskController.swift
//  leandesign
//
//  Created by Sladkikh Alexey on 8/9/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Firebase
import DigitsKit


class NewTaskController: UIViewController {
    
    
    //    var taskListController: TasksListController?
    var taskViewController: TaskViewController?
    
    let textDescription: UITextView = {
        let td = UITextView()
        td.text = "Расскажите о своей задаче. Она сразу попадет к дизайнеру"
        td.textColor = UIColor.whiteColor()
        td.translatesAutoresizingMaskIntoConstraints = false
        td.backgroundColor = UIColor.clearColor()
        td.font = UIFont.systemFontOfSize(18)
        return td
    }()
    
    let adviceTextView: UITextView = {
        let td = UITextView()
        td.text = "Фото и другие материалы вы сможете добавить после"
        td.textColor = UIColor.whiteColor()
        td.translatesAutoresizingMaskIntoConstraints = false
        td.backgroundColor = UIColor.clearColor()
        td.font = UIFont.systemFontOfSize(14)
        return td
        
    }()
    
    let inputForOrder: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    //поле имя
    let taskTextField: UITextView = {
        let tf = UITextView()
        tf.selectable = true
        tf.font = UIFont.systemFontOfSize(18, weight: UIFontWeightThin)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.becomeFirstResponder()
        return tf
    }()
    
    lazy var attachImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "attach")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectAttachImageView)))
        imageView.userInteractionEnabled = true
        return imageView
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 48, g: 140, b: 229)
        view.addSubview(inputForOrder)
        view.addSubview(textDescription)
        view.addSubview(adviceTextView)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .Plain, target: self, action: #selector(cancelNewTask))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Добавить", style: .Plain, target: self, action: #selector(addNewTask));
        
        setupInputForOrder()
        
    }
    
    
    
    func cancelNewTask() {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setupInputForOrder() {
        textDescription.leftAnchor.constraintEqualToAnchor(view.leftAnchor, constant: 8).active = true
        textDescription.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 76).active = true
        textDescription.rightAnchor.constraintEqualToAnchor(view.rightAnchor, constant: 16).active = true
        textDescription.heightAnchor.constraintEqualToConstant(60).active = true
        
        //x, y, width, height
        inputForOrder.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        inputForOrder.topAnchor.constraintEqualToAnchor(textDescription.bottomAnchor, constant: 10).active = true
        inputForOrder.widthAnchor.constraintEqualToAnchor(view.widthAnchor, constant: -25).active = true
        inputForOrder.heightAnchor.constraintEqualToConstant(150).active = true
        
        adviceTextView.leftAnchor.constraintEqualToAnchor(view.leftAnchor, constant: 8).active = true
        adviceTextView.topAnchor.constraintEqualToAnchor(inputForOrder.bottomAnchor, constant: 4).active = true
        adviceTextView.rightAnchor.constraintEqualToAnchor(view.rightAnchor, constant: 16).active = true
        adviceTextView.heightAnchor.constraintEqualToConstant(24).active = true
        
        inputForOrder.addSubview(taskTextField)
        
        
        taskTextField.leftAnchor.constraintEqualToAnchor(inputForOrder.leftAnchor, constant: 8).active = true
        taskTextField.topAnchor.constraintEqualToAnchor(inputForOrder.topAnchor, constant: -60).active = true
        taskTextField.rightAnchor.constraintEqualToAnchor(inputForOrder.rightAnchor, constant: -8).active = true
        taskTextField.heightAnchor.constraintEqualToAnchor(inputForOrder.heightAnchor, constant: 32).active = true
        
        view.addSubview(attachImageView)
        attachImageView.rightAnchor.constraintEqualToAnchor(inputForOrder.rightAnchor, constant: -15).active = true
        attachImageView.bottomAnchor.constraintEqualToAnchor(inputForOrder.bottomAnchor, constant: -15).active = true
        attachImageView.widthAnchor.constraintEqualToConstant(25).active = true
        attachImageView.heightAnchor.constraintEqualToConstant(25).active = true
        
    }
    
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    
}

