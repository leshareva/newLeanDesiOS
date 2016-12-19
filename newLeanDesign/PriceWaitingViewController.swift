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
    
    let titleView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.text = "Еще чуть-чуть и мы назовем стоимость"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.textAlignment = .center
        tv.font = UIFont.systemFont(ofSize: 28.0)
        tv.isEditable = false
        tv.isSelectable = false
        return tv
    }()
    
    let descriptionText: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.text = "Мы собрали всю необходимую инфомрацию и подготовим оценку"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.textAlignment = .center
        tv.font = UIFont.systemFont(ofSize: 16.0)
        tv.isEditable = false
        tv.isSelectable = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        view.backgroundColor = .white
        view.addSubview(titleView)
        view.addSubview(descriptionText)
        
        view.addConstraints("V:|-40-[\(titleView)]-20-[\(descriptionText)]")
        view.addConstraints("H:|-16-[\(titleView)]-16-|", "H:|-16-[\(descriptionText)]-16-|")
        view.addConstraints(titleView.heightAnchor == 100,
                            descriptionText.heightAnchor == 120
        )

        
    }
    
}
