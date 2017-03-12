//
//  ConceptCell.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 12/23/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//


import UIKit
import Swiftstraints

class ConceptCell: UICollectionViewCell, UIScrollViewDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    var conceptViewController: ConceptViewController?
    
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var imageWidthAnchor: NSLayoutConstraint?
    
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "Какой-то текст"
        tv.font = UIFont.systemFont(ofSize: 18)
        tv.isEditable = false
        return tv
    }()
    
    let priceLabel: UILabel = {
        let ul = UILabel()
        ul.translatesAutoresizingMaskIntoConstraints = false
        ul.font = UIFont.systemFont(ofSize: 32)
        return ul
    }()
    
    let timeLabel: UILabel = {
        let ul = UILabel()
        ul.translatesAutoresizingMaskIntoConstraints = false
        ul.font = UIFont.systemFont(ofSize: 32)
        return ul
    }()
    
    let descriptView: UIView = {
        let uv = UIView()
        uv.backgroundColor = UIColor(r: 239, g: 239, b: 239)
        uv.translatesAutoresizingMaskIntoConstraints = false
        return uv
    }()
    
    let descriptLabel: UITextView = {
        let td = UITextView()
        td.text = "Изучите понимание задачи. Если дизайнер что-то не так понял, обсудите с ним. По нашему опыту, согласованное понимание ускоряет выполнение задачи"
        td.translatesAutoresizingMaskIntoConstraints = false
        td.backgroundColor = UIColor.clear
        td.font = UIFont.systemFont(ofSize: 14)
        td.textColor = UIColor(r: 125, g: 125, b: 125)
        td.isUserInteractionEnabled = false
        td.isEditable = false
        return td
    }()
    
    
    lazy var shareIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "share")?.maskWithColor(color: .white)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var closeButton: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.image = UIImage(named: "close")?.maskWithColor(color: .white)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    func setupView() {
        backgroundColor = UIColor.black
        addSubview(imageView)
        addSubview(shareIcon)
        
        
        
        addSubview(textView)
        addSubview(descriptView)
        
        addConstraints("H:|[\(descriptView)]|", "H:|-16-[\(textView)]-16-|","H:[\(shareIcon)]-16-|")
        addConstraints("V:|[\(descriptView)]-8-[\(textView)]", "V:|-10-[\(shareIcon)]")
        
        addConstraints(imageView.leftAnchor == self.leftAnchor,
                       imageView.topAnchor == self.topAnchor,
                       imageView.widthAnchor == self.widthAnchor,
                       imageView.heightAnchor == self.heightAnchor,
                       textView.heightAnchor == self.heightAnchor - 160,
                       descriptView.heightAnchor == 110,
                       shareIcon.widthAnchor == 25,
                       shareIcon.heightAnchor == 25
        )
        
        descriptView.addSubview(descriptLabel)
        descriptView.addConstraints("H:|-16-[\(descriptLabel)]-16-|")
        descriptView.addConstraints("V:|-8-[\(descriptLabel)]-8-|")
    }
    
    
    
    func handleZoomTap(_ tapGesture: UITapGestureRecognizer) {
        
        //Pro Tip: don't perform a lot of custom logic inside of a view class
        if let imageView = tapGesture.view as? UIImageView {
            performZoomInForImageView(imageView)
            
        }
    }
    
    
    
    
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    func performZoomInForImageView(_ startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        let zoomingImageView = ZoomingImageView(frame: startingFrame!)
        
        zoomingImageView.imageView.image = startingImageView.image
        
        zoomingImageView.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.backgroundColor = .black
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: keyWindow.frame.height)
                zoomingImageView.imageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.imageView.center = keyWindow.center
                
            }, completion: nil)
        }
    }
    
    
    
    
    func handleZoomOut(_ tapGesture: UITapGestureRecognizer ) {
        
        if let zoomOutImageView = tapGesture.view {
            
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame  = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                //                self.inputContainerView.alpha = 1
            }, completion: { (completed: Bool) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
