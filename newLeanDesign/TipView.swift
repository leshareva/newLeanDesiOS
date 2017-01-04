//
//  TipView.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 12/29/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints

class TipView: UIView {
    
    let bubble: UIView = {
        let uv = UIView()
        uv.translatesAutoresizingMaskIntoConstraints = false
//        uv.backgroundColor = UIColor(r: 32, g: 129, b: 251)
        uv.backgroundColor = .black
        uv.isUserInteractionEnabled = true
        uv.layer.masksToBounds = true
        uv.layer.cornerRadius = 20
        return uv
    }()
    
    
    let questionMark: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "?"
        label.textColor = .white
        return label
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = .white
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView() {
        addSubview(bubble)
        addConstraints("H:|[\(bubble)]|")
        addConstraints("V:|[\(bubble)]|")
        bubble.addSubview(label)
        bubble.addSubview(questionMark)
        
        addConstraints("H:|-20-[\(questionMark)]-5-[\(label)]-10-|")
        addConstraints(label.heightAnchor == 16,
                          label.centerYAnchor == self.centerYAnchor,
                          questionMark.centerYAnchor == self.centerYAnchor,
                          questionMark.heightAnchor == 16,
                          questionMark.widthAnchor == 16
        )

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
