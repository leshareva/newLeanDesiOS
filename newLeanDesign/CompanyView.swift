//
//  CompanyView.swift
//  leandesign
//
//  Created by Sladkikh Alexey on 9/12/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints
import EFCountingLabel

class CompanyView: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    let companyNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        return label
    }()
    
    let aboutPriceLabel: UILabel = {
        let label = UILabel()
        label.text = "СУММА НА СЧЕТУ"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 10.0)
        label.textColor = UIColor(r: 180, g: 180, b: 180)
        let attributedString = label.attributedText as! NSMutableAttributedString
        attributedString.addAttribute(NSKernAttributeName, value: 1.0, range: NSMakeRange(0, attributedString.length))
        label.attributedText = attributedString
        return label
    }()
    
    let payButton: UIView = {
       let btn = UIView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        let tv = UILabel()
        tv.text = "Пополнить"
        tv.font = UIFont.systemFont(ofSize: 14.0)
        tv.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(tv)
        btn.addConstraints(tv.centerYAnchor == btn.centerYAnchor, tv.centerXAnchor == btn.centerXAnchor)
        return btn
    }()
    
    var priceLabel: EFCountingLabel = {
        let label = EFCountingLabel()
        label.method = .linear
        label.format = "%d"
        
        label.attributedFormatBlock = {
            (value) in
            let highlight = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 20)]
            let normal = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 20)]
            
            let prefix = String(format: "%d", Int(value))
            let postfix = String(format: " ₽")
            
            let prefixAttr = NSMutableAttributedString(string: prefix, attributes: highlight)
            let postfixAttr = NSAttributedString(string: postfix, attributes: normal)
            
            prefixAttr.append(postfixAttr)
            return prefixAttr
        }
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let logoView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "logo_company")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 35
        view.layer.masksToBounds = true
        return view
    }()
    
    let separatorOne: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let iconConceptView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "drive")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var conceptButton: UILabel = {
        let label = UILabel()
        label.text = "Папка с макетами"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let separatorTwo: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    let titleTableLabel: UILabel = {
        let label = UILabel()
        label.text = "ЗАДАЧИ В РАБОТЕ"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 12.0)
        label.textColor = UIColor(r: 180, g: 180, b: 180)
        let attributedString = label.attributedText as! NSMutableAttributedString
        attributedString.addAttribute(NSKernAttributeName, value: 1.0, range: NSMakeRange(0, attributedString.length))
        label.attributedText = attributedString
        
        return label
    }()
    
    
    func setupViews() {

        
        self.addSubview(companyNameLabel)
//        self.addSubview(logoView)
        self.addSubview(aboutPriceLabel)
        self.addSubview(priceLabel)
        self.addSubview(separatorOne)
        self.addSubview(iconConceptView)
        self.addSubview(conceptButton)
        self.addSubview(separatorTwo)
        self.addSubview(titleTableLabel)
        self.addSubview(payButton)
        
//        self.addConstraints("H:|-16-[\(logoView)]-16-[\(companyNameLabel)]|")
//        self.addConstraints("V:|-16-[\(logoView)]", "V:|-16-[\(companyNameLabel)]-12-[\(aboutPriceLabel)]-4-[\(priceLabel)]-16-[\(separatorOne)]-8-[\(iconConceptView)]-8-[\(separatorTwo)]-24-[\(titleTableLabel)]-8-|")
        
        self.addConstraints("H:|-16-[\(companyNameLabel)]|")
        self.addConstraints("V:|-16-[\(companyNameLabel)]-8-[\(aboutPriceLabel)]-12-[\(priceLabel)]-16-[\(separatorOne)]-8-[\(iconConceptView)]-8-[\(separatorTwo)]-24-[\(titleTableLabel)]-8-|")
        self.addConstraints(
                            aboutPriceLabel.leftAnchor == companyNameLabel.leftAnchor,
                            priceLabel.leftAnchor == companyNameLabel.leftAnchor,
                            
                            separatorOne.heightAnchor == 1,
                            separatorOne.leftAnchor == companyNameLabel.leftAnchor,
                            separatorOne.rightAnchor == self.rightAnchor - 16,
                            
                            iconConceptView.heightAnchor == 28,
                            iconConceptView.widthAnchor == 28,
                            iconConceptView.leftAnchor == companyNameLabel.leftAnchor,
                            conceptButton.leftAnchor == iconConceptView.rightAnchor + 8,
                            conceptButton.centerYAnchor == iconConceptView.centerYAnchor,
                            
                            separatorTwo.heightAnchor == 1,
                            separatorTwo.leftAnchor == companyNameLabel.leftAnchor,
                            separatorTwo.rightAnchor == separatorOne.rightAnchor,
                            
                            titleTableLabel.leftAnchor == self.leftAnchor + 16,
                            payButton.leftAnchor == priceLabel.rightAnchor + 16,
                            payButton.centerYAnchor == priceLabel.centerYAnchor,
                            payButton.widthAnchor == 100,
                            payButton.heightAnchor == 25
            
        )
        
    }
    
    
    
    
    
}
