//
//  UIControls.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 12/1/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints

class UIControls {
    
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
        
        lazy var field: UITextField = {
            let tf = UITextField()
            tf.translatesAutoresizingMaskIntoConstraints = false
            tf.font = UIFont.systemFont(ofSize: 16)
            tf.textColor = .black
            tf.textAlignment = .left
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
            input.addConstraints("H:|-16-[\(label)]-5-[\(field)]-5-|")
            input.addConstraints("V:|[\(label)]|", "V:|[\(field)]|")
            input.addConstraints(label.widthAnchor == 120)
           
        }
        
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    class SectionCell: UIView {
        
        let input: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(r: 250, g: 250, b: 250)
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        let label: UILabel = {
            let tf = UILabel()
            tf.translatesAutoresizingMaskIntoConstraints = false
            tf.font = UIFont.systemFont(ofSize: 16)
            tf.textColor = UIColor(r: 28, g: 125, b: 215)
            return tf
        }()
    
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(input)
            addConstraints("H:|[\(input)]|")
            addConstraints("V:|[\(input)]|")
            
            input.addSubview(label)
           
            input.addConstraints("H:|-16-[\(label)]-16-|")
            input.addConstraints("V:|[\(label)]|")
            
        }
        
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    
 
}
