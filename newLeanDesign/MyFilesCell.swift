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
    
    let thumbImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.clipsToBounds = true
        return iv
    }()
    
    
    
    var myFilesViewController: MyFilesViewController?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(r: 245, g: 245, b: 245)
        

        self.addSubview(thumbImageView)
        
//        self.addConstraints(thumbImageView.heightAnchor == 60,
//                            thumbImageView.widthAnchor == 60,
//                            thumbImageView.centerXAnchor == self.centerXAnchor,
//                            thumbImageView.centerYAnchor == self.centerYAnchor)
        

    }
    
    
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

