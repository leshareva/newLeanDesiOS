//
//  UIControls.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 12/1/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints

class UIControl {
    
    class TextField: UIView {
        
        
        let input: UIView = {
            let view = UIView()
            view.backgroundColor = .white
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        let label: UILabel = {
            let tf = UILabel()
            tf.translatesAutoresizingMaskIntoConstraints = false
            tf.font = UIFont.systemFont(ofSize: 16)
            tf.textColor = UIColor(r: 180, g: 180, b: 180)
            return tf
        }()
        
        let field: UITextView = {
            let tf = UITextView()
            tf.translatesAutoresizingMaskIntoConstraints = false
            tf.font = UIFont.systemFont(ofSize: 16)
            tf.textColor = .black
            tf.isEditable = true
            return tf
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(input)
            addConstraints("H:|[\(input)]|")
            addConstraints("V:|[\(input)]|")
            
            input.addSubview(label)
            input.addSubview(field)
            input.addConstraints("H:|-5-[\(label)]-5-[\(field)]|")
            input.addConstraints(label.centerYAnchor == input.centerYAnchor,
                                 label.heightAnchor == 20,
                                 field.centerYAnchor == input.centerYAnchor,
                                 field.heightAnchor == 20
                                 )
        }
        
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    
}
