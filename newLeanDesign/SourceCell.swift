//
//  SourceCell.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 12/30/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints

class SourceCell: UITableViewCell {

    
    let extensionImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    let thumbImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.layer.cornerRadius = 25
        iv.clipsToBounds = true
        return iv
    }()
    
    let linkImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "link")
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(extensionImageView)
        addSubview(linkImageView)
        addSubview(thumbImageView)
        
        extensionImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        extensionImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        extensionImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        extensionImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        addConstraints(linkImageView.centerYAnchor == self.centerYAnchor,
                       linkImageView.widthAnchor == 20,
                       linkImageView.heightAnchor == 20,
                       linkImageView.rightAnchor == self.rightAnchor - 32)
        
        thumbImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        thumbImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        thumbImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        thumbImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 70, y: textLabel!.frame.origin.y - 2, width: self.frame.width - 84, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 66, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        textLabel?.numberOfLines = 1
        textLabel?.font = UIFont.systemFont(ofSize: 16)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
