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

class NoMoneyViewController: UIViewController {
    
    var sum: Int!
    
    let discriptionLabel: UILabel = {
        let tv = UILabel()
        tv.text = "На вашем счете"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = UIColor.white
        tv.textAlignment = .center
        tv.numberOfLines = 3
        return tv
    }()
    
    let priceLabel: UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = UIColor.white
        tv.font = UIFont.boldSystemFont(ofSize: 48.0)
        tv.textAlignment = .center
        return tv
    }()
    
    let aboutTextView: UITextView = {
        let tv = UITextView()
        tv.text = "Для заказа на счету должно быть минимум 1000₽"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = UIColor.white
        tv.backgroundColor = .clear
        tv.font = UIFont.systemFont(ofSize: 18.0)
        tv.isEditable = false
        return tv
    }()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = LeanColor.blueColor
        UINavigationBar.appearance().barTintColor = LeanColor.blueColor
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(handleCancel))
        
        priceLabel.text = String(self.sum) + " ₽"
        setupView()

        
    }
    
    func handleCancel() {
      dismiss(animated: true, completion: nil)
    }
    
    let buttonView = ButtonView()
    
    func setupView() {
  
        view.addSubview(priceLabel)
        view.addSubview(discriptionLabel)
        view.addSubview(aboutTextView)
       
        view.addConstraints("H:|-18-[\(discriptionLabel)]-18-|", "H:|-18-[\(priceLabel)]-18-|", "H:|-18-[\(aboutTextView)]-18-|")
        view.addConstraints("V:|-40-[\(discriptionLabel)]-10-[\(priceLabel)]-10-[\(aboutTextView)]")
        
        view.addConstraints(aboutTextView.heightAnchor == 300, priceLabel.heightAnchor == 80, discriptionLabel.heightAnchor == 20)
        
        view.addSubview(self.buttonView)
   
        
        view.addConstraints("V:[\(buttonView)]|")
        view.addConstraints("H:|[\(buttonView)]|")
        view.addConstraints(buttonView.heightAnchor == 50)
        
        buttonView.buttonLabel.text = "Пополнить счет"
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handlePay)))
        buttonView.acceptTaskButtonView.backgroundColor = UIColor(r: 109, g: 199, b: 82)
    }
    
    func handlePay() {
        let amountViewController = AmountViewController()
        navigationController?.pushViewController(amountViewController, animated: true)
    }
    
    
    
}
