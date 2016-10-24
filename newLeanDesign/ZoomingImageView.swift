//
//  ZoomingImageView.swift
//  newLeanDesign
//
//  Created by Sladkikh Alexey on 10/23/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints

class ZoomingImageView: UIView, UIScrollViewDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
  
    
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    func setupView() {
        imageView = UIImageView(frame: self.frame)
        
        scrollView = UIScrollView(frame: self.bounds)
        scrollView.backgroundColor = UIColor.clearColor()
        

        scrollView.contentSize = self.bounds.size
        
       
        
        scrollView.addSubview(imageView)
        addSubview(scrollView)
        
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = 1.0
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
