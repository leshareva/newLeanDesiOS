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
    var price: Int!
    
    let discriptionLabel: UILabel = {
        let tl = UILabel()
        tl.text = "На вашем счете"
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.font = UIFont.boldSystemFont(ofSize: 24.0)
        tl.textColor = .black
        tl.textAlignment = .center
        return tl
    }()
    
    let priceLabel: UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .red
        tv.font = UIFont.boldSystemFont(ofSize: 64.0)
        tv.textAlignment = .center
        return tv
    }()
    
    let aboutTextView: UITextView = {
        let tv = UITextView()
        
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.backgroundColor = .clear
        tv.font = UIFont.systemFont(ofSize: 18.0)
        tv.isEditable = false
        tv.textAlignment = .center
        return tv
    }()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        UINavigationBar.appearance().barTintColor = LeanColor.blueColor
        navigationController?.navigationBar.isTranslucent = false
        
        priceLabel.text = String(self.sum) + " ₽"
        aboutTextView.text = "Пополните счет на " + String(self.price) + " ₽, чтобы задача пошла в работу"
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
        buttonView.acceptTaskButtonView.backgroundColor = LeanColor.acceptColor
    }
    
    func handlePay() {
        let amountViewController = AmountViewController()
       self.navigationController?.pushViewController(amountViewController, animated: true)
    }
    
    
    
}
