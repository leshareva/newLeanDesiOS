//
//  EmptyTableView.swift
//  newLeanDesign
//
//  Created by Sladkikh Alexey on 9/23/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints

class EmptyTableView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    let emptyImageView: UIImageView = {
       let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "empty-table")
        return iv
    }()
    
    let emptyTextView: UITextView = {
        let tl = UITextView()
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.text = "Создайте задачу, а то вдруг дизайнеры скучают"
        tl.font = UIFont.systemFont(ofSize: 14)
        tl.textColor = UIColor(r: 180, g: 180, b: 180)
        tl.textAlignment = .center
        tl.isEditable = false
        return tl
    }()
    
 
    
    func setupView() {
        self.backgroundColor = UIColor.white
        
        self.addSubview(emptyImageView)
        self.addSubview(emptyTextView)
        
        
        
        
        self.addConstraints(emptyImageView.centerYAnchor == self.centerYAnchor + 20,
                            emptyImageView.centerXAnchor == self.centerXAnchor,
                            emptyImageView.heightAnchor == 150,
                            emptyImageView.widthAnchor == 150,
                            emptyTextView.centerXAnchor == self.centerXAnchor,
                            emptyTextView.topAnchor == emptyImageView.bottomAnchor - 10,
                            emptyTextView.widthAnchor == self.widthAnchor - 40,
                            emptyTextView.heightAnchor == 50
                            )
        
        
        
        
        
        
    }
    
  
    
}
