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
import Swiftstraints

class NewTaskController: UIViewController {

    //    var taskListController: TasksListController?
    var taskViewController: TaskViewController?
    
    let textDescription: UITextView = {
        let td = UITextView()
        td.text = "Расскажите коротко о задаче. Дизайнер свяжется с вами и уточнит все детали."

        td.translatesAutoresizingMaskIntoConstraints = false
        td.backgroundColor = UIColor.clearColor()
        td.font = UIFont.systemFontOfSize(16)
        td.userInteractionEnabled = false
        td.editable = false
        return td
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
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.contentMode = .ScaleAspectFill
        return imageView
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
       
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .Plain, target: self, action: #selector(cancelNewTask))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Добавить", style: .Plain, target: self, action: #selector(addNewTask));
        
        setupInputForOrder()
        
    }

    
    func cancelNewTask() {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func setupInputForOrder() {

        view.addSubview(textDescription)
        view.addSubview(taskTextField)
        view.addSubview(attachImageView)
        
   
        view.addConstraints(
                            textDescription.heightAnchor == 132,
                            textDescription.rightAnchor == view.rightAnchor - 8,
                            textDescription.leftAnchor == view.leftAnchor + 8,
                            textDescription.topAnchor == view.topAnchor,
                            
                            taskTextField.topAnchor == textDescription.bottomAnchor,
                            taskTextField.leftAnchor == textDescription.leftAnchor,
                            taskTextField.rightAnchor == textDescription.rightAnchor,
                            taskTextField.heightAnchor == view.heightAnchor / 3,
                            
                            attachImageView.heightAnchor == 40,
                            attachImageView.widthAnchor == 40,
                            attachImageView.rightAnchor == taskTextField.rightAnchor,
                            attachImageView.bottomAnchor == taskTextField.bottomAnchor)
    }

    
    
}

