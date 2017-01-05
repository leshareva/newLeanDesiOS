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
//        imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
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
            fixOnKeysView.addConstraints("H:|-16-[\(tipView)]-10-[\(attachImageView)]-10-|")
            fixOnKeysView.addConstraints("V:|-10-[\(tipView)]-16-|", "V:|-10-[\(attachImageView)]-16-|")
            tipView.alpha = 0
            tipView.bubble.backgroundColor = UIColor(r: 88, g: 165, b: 24)

            fixOnKeysView.addConstraints( attachImageView.heightAnchor == 40,
            attachImageView.widthAnchor == 40)
            
            if UserDefaults.standard.bool(forKey: "HowMuchReaded") {
                self.tipView.alpha = 0
                
                
                if UserDefaults.standard.bool(forKey: "HowTaskingReaded") {
                   self.tipView.alpha = 0
                } else {
                    UIView.animate(withDuration: 0.5, delay: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                        self.tipView.label.text = "В каком формате ставить задачу?"
                        self.tipView.bubble.backgroundColor = UIColor(r: 239, g: 148, b: 34)
                        self.tipView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleAboutTasks)))
                        self.tipView.alpha = 1
                    }, completion: nil)
                }
                
            } else {
                UIView.animate(withDuration: 0.5, delay: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                     self.tipView.label.text = "Сколько стоит дизайн в Лине?"
                    self.tipView.bubble.backgroundColor = UIColor(r: 123, g: 195, b: 64)
                     self.tipView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleAboutPrice)))
                     self.tipView.alpha = 1
                }, completion: nil)
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

