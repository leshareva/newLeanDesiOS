//
//  StepsView.swift
//  newLeanDesign
//
//  Created by Sladkikh Alexey on 9/23/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints

class StepsView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    static let activeColor = UIColor(r: 237, g: 186, b: 10)
    static let activeTextColor = UIColor.whiteColor()
    static let doneColor = UIColor(r: 239, g: 213, b: 41)
    static let doneTextColor = UIColor(r: 208, g: 163, b: 8)
    
    let stepOne: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let alertView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.redColor()
        return view
    }()
    
    let alertTextView: UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "Согласуйте результаты этапа"
        tv.font = UIFont.systemFontOfSize(12.0)
        tv.textColor = UIColor.whiteColor()
        return tv
    }()
    
    let textOne: UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "Понимание"
        tv.font = UIFont.systemFontOfSize(12.0)
        tv.textColor = UIColor(r: 170, g: 170, b: 170)
        return tv
    }()
    
    let stepTwo: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let textTwo: UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "Черновик"
        tv.font = UIFont.systemFontOfSize(12.0)
        tv.textColor = UIColor(r: 170, g: 170, b: 170)
        return tv
    }()
    
    let stepThree: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let textThree: UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "Чистовик"
        tv.font = UIFont.systemFontOfSize(12.0)
        tv.textColor = UIColor(r: 170, g: 170, b: 170)
        return tv
    }()
    
    let stepFour: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let textFour: UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "Исходник"
        tv.font = UIFont.systemFontOfSize(12.0)
        tv.textColor = UIColor(r: 170, g: 170, b: 170)
        return tv
    }()
    
    func setupView() {
        self.backgroundColor = UIColor(r: 238, g: 238, b: 238)
        
        self.addSubview(stepOne)
        self.addSubview(stepTwo)
        self.addSubview(stepThree)
        self.addSubview(stepFour)
        
       
        self.addConstraints("H:|[\(stepOne)][\(stepTwo)][\(stepThree)][\(stepFour)]")
        self.addConstraints("V:|[\(stepOne)]|", "V:|[\(stepTwo)]|", "V:|[\(stepThree)]|", "V:|[\(stepFour)]|")
        self.addConstraints(stepOne.widthAnchor == self.widthAnchor / 4,
                       stepTwo.widthAnchor == self.widthAnchor / 4,
                       stepThree.widthAnchor == self.widthAnchor / 4,
                       stepFour.widthAnchor == self.widthAnchor / 4
                       )
        
        
        self.addSubview(textOne)
        self.addSubview(textTwo)
        self.addSubview(textThree)
        self.addSubview(textFour)
        
        self.addConstraints(
                            textOne.centerXAnchor == stepOne.centerXAnchor,
                            textOne.centerYAnchor == self.centerYAnchor,
                            textTwo.centerXAnchor == stepTwo.centerXAnchor,
                            textTwo.centerYAnchor == self.centerYAnchor,
                            textThree.centerXAnchor == stepThree.centerXAnchor,
                            textThree.centerYAnchor == self.centerYAnchor,
                            textFour.centerXAnchor == stepFour.centerXAnchor,
                            textFour.centerYAnchor == self.centerYAnchor
        )
        
        
        self.addSubview(alertView)
        alertView.addSubview(alertTextView)
        self.addConstraints("H:|[\(alertView)]|")
        self.addConstraints("V:|[\(alertView)]")
        self.addConstraints(alertView.heightAnchor == self.heightAnchor)
        
        alertView.addConstraints(alertTextView.centerXAnchor == alertView.centerXAnchor,
                            alertTextView.centerYAnchor == alertView.centerYAnchor)
        
        self.alertView.hidden = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


