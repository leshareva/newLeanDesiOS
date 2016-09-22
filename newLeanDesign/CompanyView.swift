//
//  CompanyView.swift
//  leandesign
//
//  Created by Sladkikh Alexey on 9/12/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints

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
        label.font = UIFont.boldSystemFontOfSize(16.0)
        return label
    }()
    
    let aboutPriceLabel: UILabel = {
        let label = UILabel()
        label.text = "ВЫПОЛНЕНО РАБОТ НА"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFontOfSize(10.0)
        label.textColor = UIColor(r: 180, g: 180, b: 180)
        let attributedString = label.attributedText as! NSMutableAttributedString
        attributedString.addAttribute(NSKernAttributeName, value: 1.0, range: NSMakeRange(0, attributedString.length))
        label.attributedText = attributedString
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
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
        view.image = UIImage(named: "psd")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var conceptButton: UILabel = {
        let label = UILabel()
        label.text = "Дизайн-макеты"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openConcept)))
        label.userInteractionEnabled = true
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
        label.font = UIFont.boldSystemFontOfSize(12.0)
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
        
        
//        self.addConstraints("H:|-16-[\(logoView)]-16-[\(companyNameLabel)]|")
//        self.addConstraints("V:|-16-[\(logoView)]", "V:|-16-[\(companyNameLabel)]-12-[\(aboutPriceLabel)]-4-[\(priceLabel)]-16-[\(separatorOne)]-8-[\(iconConceptView)]-8-[\(separatorTwo)]-24-[\(titleTableLabel)]-8-|")
        
        self.addConstraints("H:|-16-[\(companyNameLabel)]|")
        self.addConstraints("V:|-16-[\(companyNameLabel)]-12-[\(aboutPriceLabel)]-4-[\(priceLabel)]-16-[\(separatorOne)]-8-[\(iconConceptView)]-8-[\(separatorTwo)]-24-[\(titleTableLabel)]-8-|")
        self.addConstraints(
                            aboutPriceLabel.leftAnchor == companyNameLabel.leftAnchor,
                            priceLabel.leftAnchor == companyNameLabel.leftAnchor,
                            
                            separatorOne.heightAnchor == 1,
                            separatorOne.leftAnchor == companyNameLabel.leftAnchor,
                            separatorOne.rightAnchor == self.rightAnchor - 16,
                            
                            iconConceptView.heightAnchor == 36,
                            iconConceptView.widthAnchor == 36,
                            iconConceptView.leftAnchor == companyNameLabel.leftAnchor,
                            conceptButton.leftAnchor == iconConceptView.rightAnchor + 8,
                            conceptButton.centerYAnchor == iconConceptView.centerYAnchor,
                            
                            separatorTwo.heightAnchor == 1,
                            separatorTwo.leftAnchor == companyNameLabel.leftAnchor,
                            separatorTwo.rightAnchor == separatorOne.rightAnchor,
                            
                            titleTableLabel.leftAnchor == self.leftAnchor + 16
            
        )
        
    }
    
    func openConcept() {
        
    }
    
    
    
}
