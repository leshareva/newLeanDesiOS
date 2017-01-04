//
//  SourceTitle.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 12/30/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints

class SourceTitle: UIView {
    
    
    lazy var closeButton: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "close")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
  
    let awarenessText: UITextView = {
        let tv = UITextView()
        tv.text = "Исходники всегда хранятся в карточке задачи в архивe"
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.textAlignment = .center
        tv.font = UIFont.systemFont(ofSize: 18.0)
        tv.isEditable = false
        tv.isSelectable = false
        return tv
    }()
    
    var title: UITextView = {
        let tv = UITextView()
        tv.text = "Задача сдана"
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.textAlignment = .center
        tv.font = UIFont.boldSystemFont(ofSize: 24.0)
        tv.isEditable = false
        tv.isSelectable = false
        return tv
    }()

    
    var priceLabel: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.textAlignment = .right
        tv.font = UIFont.boldSystemFont(ofSize: 24.0)
        tv.isEditable = false
        tv.isSelectable = false
        return tv
    }()
    
    let userImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage.gifWithName("spinner-duo")
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 25
        iv.clipsToBounds = true
        return iv
    }()
    
    var userNameLabel: UITextView = {
        let tv = UITextView()
        tv.text = "Алексей"
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .black
        tv.textAlignment = .left
        tv.font = UIFont.boldSystemFont(ofSize: 18.0)
        tv.isEditable = false
        tv.isSelectable = false
        return tv
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(title)
        self.addSubview(awarenessText)
        self.addSubview(closeButton)
        self.addSubview(priceLabel)
        self.addSubview(userImageView)
        self.addSubview(userNameLabel)
        
        self.addConstraints("V:|-45-[\(title)][\(awarenessText)]-30-[\(priceLabel)]")
        self.addConstraints("H:|-16-[\(title)]-16-|","H:|-16-[\(awarenessText)]-16-|", "H:|-16-[\(userImageView)][\(priceLabel)]-16-|",
        "H:|-74-[\(userNameLabel)]|")
        self.addConstraints(title.heightAnchor == 40,
                            priceLabel.heightAnchor == 50,
                            priceLabel.widthAnchor == self.widthAnchor / 4,
                            awarenessText.heightAnchor == 50,
                            userImageView.topAnchor == priceLabel.topAnchor,
                            userImageView.heightAnchor == 50,
                            userImageView.widthAnchor == 50,
                            userNameLabel.heightAnchor == 50,
                            userNameLabel.topAnchor == priceLabel.topAnchor
                            )
        
        
        self.addConstraints("V:|-20-[\(closeButton)]")
        self.addConstraints("H:|-20-[\(closeButton)]")
        self.addConstraints(closeButton.heightAnchor == 30,
                            closeButton.widthAnchor == 30
                            )
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
}
