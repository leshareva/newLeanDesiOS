//
//  PricesViewController.swift
//  LinDesign
//
//  Created by Sladkikh Alexey on 3/1/17.
//  Copyright © 2017 LeshaReva. All rights reserved.
//

import UIKit
import Firebase
import DigitsKit
import Swiftstraints

class PricesViewController: UIViewController {

    
    var image: UIImageView = {
        let iv = UIImageView()
        iv.loadImageUsingCashWithUrlString("http://leandesign.pro/assets/images/all-works.png")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    var titleView: UITextView = {
       let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.textColor = .white
        tv.font = UIFont.systemFont(ofSize: 20.0)
        tv.backgroundColor = .clear
        return tv
    }()
    
    lazy var closeButton: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "close")
        imageView.image =  image?.maskWithColor(color: UIColor.white)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handelCancel)))
        imageView.isUserInteractionEnabled = true
        imageView.tintColor = .white
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var bgView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        bgView.image = UIImage(named: "cosmobg")
        view.addSubview(bgView)
        
        view.addSubview(image)
         view.addSubview(titleView)
        view.addSubview(closeButton)
        
        
        
        view.addConstraints("H:|[\(image)]|", "H:|-20-[\(closeButton)]")
        view.addConstraints("V:|-40-[\(closeButton)]")
        
        
        view.addConstraints("H:|-20-[\(titleView)]-20-|")
        view.addConstraints(image.centerYAnchor == view.centerYAnchor - 90,
            titleView.heightAnchor == 200, titleView.topAnchor == image.bottomAnchor - 140, closeButton.heightAnchor == 30, closeButton.widthAnchor == 30)
        
        titleView.attributedText = attributedText()
    }

    
    func attributedText()->NSAttributedString{
        let string = "Точную цену мы покажем\nдо начала работ\nПросто добавьте задачу" as NSString
        
        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 18.0), NSForegroundColorAttributeName : UIColor.white])
        
        let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 24.0), NSForegroundColorAttributeName : UIColor.white]
        
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: "Точную цену мы покажем\nдо начала работ"))
        
        
        return attributedString
    }

    
    func handelCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
