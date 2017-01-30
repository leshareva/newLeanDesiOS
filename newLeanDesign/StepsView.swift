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
    
    static let activeColor = UIColor(r: 0, g: 127, b: 255)
    static let activeTextColor = UIColor.black
    static let doneColor = UIColor(r: 192, g: 203, b: 214)
    static let doneTextColor = UIColor.lightGray
    
    static let greenColor = UIColor(r: 109, g: 199, b: 82)
    
    let container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    
    let stepOne: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let textOne: UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "Понимание"
        tv.font = UIFont.systemFont(ofSize: 12.0)
        tv.textColor = UIColor.lightGray
        tv.textAlignment = .center
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
        tv.font = UIFont.systemFont(ofSize: 12.0)
        tv.textColor = UIColor.lightGray
        tv.textAlignment = .center
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
        tv.font = UIFont.systemFont(ofSize: 12.0)
        tv.textColor = UIColor.lightGray
        tv.textAlignment = .center
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
        tv.font = UIFont.systemFont(ofSize: 12.0)
        tv.textColor = UIColor.lightGray
        tv.textAlignment = .center
        return tv
    }()
    
    let progressbar: UIView = {
       let uv = UIView()
        uv.translatesAutoresizingMaskIntoConstraints = false
        uv.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        return uv
    }()
    
    let progressWidth: UIView = {
        let uv = UIView()
        uv.translatesAutoresizingMaskIntoConstraints = false
        uv.backgroundColor = LeanColor.blueColor
        return uv
    }()
    
    
    var progressWidthAnchor: NSLayoutConstraint?
    
    func setupView() {
        backgroundColor = .white
        
        addSubview(container)
        addSubview(progressbar)
        container.addSubview(textOne)
        container.addSubview(textTwo)
        container.addSubview(textThree)
        container.addSubview(textFour)
        
        addConstraints("H:|-16-[\(container)]-16-|")
        addConstraints("H:|-16-[\(progressbar)]-16-|")
        addConstraints("V:|[\(container)][\(progressbar)]")
        addConstraints(container.heightAnchor == 40, progressbar.heightAnchor == 2)
        
        container.addConstraints("H:|[\(textOne)][\(textTwo)][\(textThree)][\(textFour)]")
        
        container.addConstraints(
            textOne.centerYAnchor == container.centerYAnchor,
            textOne.widthAnchor == container.widthAnchor / 4,
            textTwo.centerYAnchor == container.centerYAnchor,
            textTwo.widthAnchor == container.widthAnchor / 4,
            textThree.centerYAnchor == container.centerYAnchor,
            textThree.widthAnchor == container.widthAnchor / 4,
            textFour.centerYAnchor == container.centerYAnchor,
            textFour.widthAnchor == container.widthAnchor / 4
        )
        
        
        progressbar.addSubview(progressWidth)
        
        progressbar.addConstraints("V:|[\(progressWidth)]|")
        progressbar.addConstraints("H:|[\(progressWidth)]")
        
        progressWidthAnchor = progressWidth.widthAnchor.constraint(equalToConstant: 200)
        progressWidthAnchor?.isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


