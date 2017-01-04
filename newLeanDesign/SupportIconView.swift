//
//  supportIconView.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 1/4/17.
//  Copyright © 2017 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints

class SupportIconView: UIView {
    
    let iconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "support")
        return view
    }()
    
    let bubble: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       
        addSubview(iconView)
        addSubview(bubble)
        
        addConstraints("H:[\(iconView)]|")
        addConstraints("V:|[\(iconView)]")
        addConstraints(iconView.heightAnchor == 32,
                       iconView.widthAnchor == 26,
                       bubble.heightAnchor == 12,
                       bubble.widthAnchor == 12,
                       bubble.leftAnchor == iconView.leftAnchor - 6,
                       bubble.topAnchor == iconView.topAnchor
        )
        
        bubble.isHidden = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    
}
