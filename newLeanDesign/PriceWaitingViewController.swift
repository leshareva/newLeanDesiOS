//
//  PriceWaitingViewController.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 12/19/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints
import Firebase

class PriceWaitingViewController: UIViewController {
    
    var task: Task?
    var phone: String?
    
    let userPic: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "ava")
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 70
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    
    lazy var nameTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.textAlignment = .center
        tv.font = UIFont.systemFont(ofSize: 20.0)
        tv.isEditable = false
        tv.isSelectable = false
        return tv
    }()
    
    let titleView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.text = "Еще чуть-чуть и назовем стоимость"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.textAlignment = .center
        tv.font = UIFont.systemFont(ofSize: 24.0)
        tv.isEditable = false
        tv.isSelectable = false
        return tv
    }()
    
    let descriptionText: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.text = "Мы собрали всю необходимую информацию и подготовим оценку"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.textAlignment = .center
        tv.font = UIFont.systemFont(ofSize: 16.0)
        tv.isEditable = false
        tv.isSelectable = false
        return tv
    }()
    
    lazy var callButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .white
        btn.setTitleColor( .black, for: .normal)
        btn.setTitle("Позвонить", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
//        btn.layer.borderWidth = 1
//        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.addTarget(self, action: #selector(handleCall), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadDesignerInfo()
    }
    
    func setupView() {
        view.backgroundColor = .white
        view.addSubview(userPic)
        view.addSubview(titleView)
        view.addSubview(descriptionText)
        view.addSubview(callButton)
        view.addSubview(nameTextView)
        
        view.addConstraints("V:|-40-[\(userPic)]-10-[\(nameTextView)]-10-[\(titleView)]-20-[\(descriptionText)]", "V:[\(callButton)]-10-|")
        view.addConstraints("H:|-16-[\(titleView)]-16-|", "H:|-16-[\(descriptionText)]-16-|", "H:|-16-[\(callButton)]-16-|", "H:|-16-[\(nameTextView)]-16-|")
        view.addConstraints(titleView.heightAnchor == 100,
                            descriptionText.heightAnchor == 120,
                            userPic.widthAnchor == 140,
                            userPic.heightAnchor == 140,
                            userPic.centerXAnchor == view.centerXAnchor,
                            callButton.heightAnchor == 50,
                            nameTextView.heightAnchor == 50
        )
 
    }
    
    func loadDesignerInfo() {
        let ref = FIRDatabase.database().reference()
        guard let designerId = task?.toId else {
            return
        }
        
        ref.child("designers").child(designerId).observeSingleEvent(of: .value, with: {(snapshot) in
         
            guard let photoUrl = (snapshot.value as! NSDictionary)["photoUrl"] else {
                return
            }
            
            guard let number = (snapshot.value as! NSDictionary)["phone"] else {
                return
            }
            
            guard let name = (snapshot.value as! NSDictionary)["firstName"] as? String else {
                return
            }
            
            self.phone = String(describing: number)
            self.nameTextView.text = name
            
            print(photoUrl)
            self.userPic.loadImageUsingCashWithUrlString(photoUrl as! String)
            
            
        }, withCancel: nil)
        
    }
    
    func handleCall() {
        guard let userPhone = phone else {
            return
        }
        guard let number = URL(string: "telprompt://" + userPhone) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(number, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(number)
        }
        
    }
    
}
