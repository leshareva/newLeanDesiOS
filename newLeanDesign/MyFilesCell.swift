//
//  MyFileCell.swift
//  Лин
//
//  Created by Sladkikh Alexey on 1/28/17.
//  Copyright © 2017 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints

class MyFilesCell: UICollectionViewCell {
    
    let extesionsImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        iv.clipsToBounds = true
        return iv
    }()
    
    let thumbImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.clipsToBounds = true
        return iv
    }()
    
    let nameLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textAlignment = .center
        return label
    }()
    
    
    
    var myFilesViewController: MyFilesViewController?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        self.addSubview(thumbImageView)
        self.addSubview(nameLabel)
        self.addConstraints("H:|[\(thumbImageView)]|", "H:|[\(nameLabel)]|")
        self.addConstraints("V:|[\(thumbImageView)][\(nameLabel)]|")
        self.addSubview(extesionsImageView)
        self.addConstraints(extesionsImageView.heightAnchor == 45,
                            extesionsImageView.widthAnchor == 50,
                            extesionsImageView.centerXAnchor == self.centerXAnchor,
                            extesionsImageView.centerYAnchor == self.centerYAnchor,
                            nameLabel.heightAnchor == 20)

    }
    
    
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

