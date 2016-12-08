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

    var taskViewController: TaskViewController?
    
    let textDescription: UITextView = {
        let td = UITextView()
        td.text = "Расскажите коротко о задаче. Дизайнер свяжется с вами и уточнит детали."
        td.translatesAutoresizingMaskIntoConstraints = false
        td.backgroundColor = UIColor.clear
        td.font = UIFont.systemFont(ofSize: 16)
        td.isUserInteractionEnabled = false
        td.isEditable = false
        return td
    }()
    
    let separator: UIView = {
       let uv = UIView()
        uv.translatesAutoresizingMaskIntoConstraints = false
        uv.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        return uv
    }()
    
    //поле имя
    let taskTextField: UITextView = {
        let tf = UITextView()
        tf.isSelectable = true
        tf.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightThin)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.becomeFirstResponder()
        return tf
    }()
    
    lazy var attachImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "attach")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectAttachImageView)))
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(cancelNewTask))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Добавить", style: .plain, target: self, action: #selector(addNewTask));
        
        setupInputForOrder()
    }

    
    func cancelNewTask() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    
    func setupInputForOrder() {

        view.addSubview(textDescription)
        view.addSubview(taskTextField)
        view.addSubview(attachImageView)
        view.addSubview(separator)
        
   
        view.addConstraints(
                            textDescription.heightAnchor == 132,
                            textDescription.rightAnchor == view.rightAnchor - 8,
                            textDescription.leftAnchor == view.leftAnchor + 8,
                            textDescription.topAnchor == view.topAnchor,
                            
                            separator.heightAnchor == 1,
                            separator.leftAnchor == textDescription.leftAnchor,
                            separator.rightAnchor == textDescription.rightAnchor,
                            separator.topAnchor == textDescription.bottomAnchor + 8,
                            
                            taskTextField.topAnchor == textDescription.bottomAnchor + 8,
                            taskTextField.leftAnchor == textDescription.leftAnchor,
                            taskTextField.rightAnchor == textDescription.rightAnchor,
                            taskTextField.heightAnchor == view.heightAnchor / 3,
                            
                            attachImageView.heightAnchor == 40,
                            attachImageView.widthAnchor == 40,
                            attachImageView.rightAnchor == taskTextField.rightAnchor,
                            attachImageView.bottomAnchor == taskTextField.bottomAnchor - 20)
    } 
    
}

