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
    var attachCounter = 0
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
//        imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var attachButton: UIImageView = {
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
    
   
    lazy var priceView: UIView = {
        let uv = UIView()
        uv.translatesAutoresizingMaskIntoConstraints = false
        uv.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        return uv
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
        view.addSubview(separator)
        view.addSubview(priceView)
   
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
                            taskTextField.heightAnchor == view.heightAnchor / 3
                            )
    }
    
    
    lazy var fixOnKeysView: UIView = {
        let uv = UIView()
        uv.frame = CGRect(x: 0, y: 0, width: 150, height: 66)
        return uv
    }()
    
    lazy var tipView: TipView = {
        let tipView = TipView()
        tipView.translatesAutoresizingMaskIntoConstraints = false
        return tipView
    }()
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    override var inputAccessoryView: UIView? {
        get {
            
            fixOnKeysView.addSubview(tipView)
            fixOnKeysView.addSubview(attachImageView)
            fixOnKeysView.addSubview(attachButton)
            fixOnKeysView.addConstraints("H:|-10-[\(tipView)]-10-[\(attachImageView)]-10-[\(attachButton)]-10-|")
            fixOnKeysView.addConstraints("V:[\(tipView)]-26-|", "V:|-10-[\(attachImageView)]-16-|", "V:|-10-[\(attachButton)]-16-|")
            
            fixOnKeysView.addConstraints(
                tipView.heightAnchor == 33,
                attachImageView.heightAnchor == 40,
                                          attachImageView.widthAnchor == 40,
                                          attachButton.widthAnchor == 40,
                                          attachButton.heightAnchor == 40)
      
            
            tipView.alpha = 0
            
            if UserDefaults.standard.bool(forKey: "HowMuchReaded") {
                self.tipView.alpha = 0
                
                
                if UserDefaults.standard.bool(forKey: "HowTaskingReaded") {
                   self.tipView.alpha = 0
                } else {
                   
                        self.tipView.label.text = "Как ставить задачу?"
                        self.tipView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleAboutTasks)))
                        self.tipView.alpha = 1
                }
                
            } else {
                     self.tipView.label.text = "Сколько стоит?"
                     self.tipView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleAboutPrice)))
                     self.tipView.alpha = 1
            }
            
             return fixOnKeysView
        }
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    func handleKeyboardWillShow(_ notification: Notification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func handleKeyboardWillHide(_ notification: Notification) {
        
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    
    
}

