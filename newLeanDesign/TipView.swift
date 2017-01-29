//
//  TipView.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 12/29/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Swiftstraints

class TipView: UIView {
    
    let bubble: UIView = {
        let uv = UIView()
        uv.translatesAutoresizingMaskIntoConstraints = false
        uv.backgroundColor = LeanColor.blueColor
        uv.isUserInteractionEnabled = true
        uv.layer.masksToBounds = true
        uv.layer.cornerRadius = 2
        return uv
    }()
    
    
    let questionMark: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "?"
        label.textColor = LeanColor.blueColor
        return label
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = LeanColor.blueColor
        return label
    }()
    
    let shapeLayer = CAShapeLayer()
    var timer: Timer?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    
    
    
    var leftConstraints: NSLayoutConstraint?
    
    
    func setupView() {

        addSubview(bubble)
        addConstraints(bubble.heightAnchor == 4, bubble.widthAnchor == 4, bubble.rightAnchor == self.rightAnchor - 28, bubble.topAnchor == self.topAnchor - 1)
        
        addSubview(label)
        addSubview(questionMark)
        
        addConstraints("H:|-18-[\(questionMark)]-5-[\(label)]-10-|")
        addConstraints(label.heightAnchor == 16,
                          label.centerYAnchor == self.centerYAnchor,
                          questionMark.centerYAnchor == self.centerYAnchor,
                          questionMark.heightAnchor == 16,
                          questionMark.widthAnchor == 16
        )
        
        
        questionMark.alpha = 0
        label.alpha = 0
        
        
       
        
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1.20, target: self, selector: #selector(self.attemptAnimation), userInfo: nil, repeats: false)

    }
    
    
    
    func attemptAnimation() {
        
        shapeLayer.path = applePath.cgPath
        
        shapeLayer.strokeColor = LeanColor.blueColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.lineCap = kCALineCapRound
        
        self.layer.addSublayer(shapeLayer)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        animation.fromValue = 0.0
        animation.byValue = 1.0
        animation.duration = 0.8
        
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        shapeLayer.add(animation, forKey: "drawLineAnimation")
        
        UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.label.alpha = 1
            self.questionMark.alpha = 1
        }, completion: nil)
        
    }
    
    
    var applePath: UIBezierPath{
        return drawCanvas1(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 33))
    }
 
    
    func drawCanvas1(frame: CGRect) -> UIBezierPath {
        let rectanglePath = UIBezierPath()
        rectanglePath.move(to: CGPoint(x: frame.maxX - 22.5, y: frame.minY + 1))
        rectanglePath.addLine(to: CGPoint(x: frame.maxX - 20.34, y: frame.minY + 1))
        rectanglePath.addCurve(to: CGPoint(x: frame.maxX - 12.09, y: frame.minY + 2.02), controlPoint1: CGPoint(x: frame.maxX - 18.58, y: frame.minY + 1), controlPoint2: CGPoint(x: frame.maxX - 15.17, y: frame.minY + 1))
        rectanglePath.addLine(to: CGPoint(x: frame.maxX - 11.5, y: frame.minY + 2.16))
        rectanglePath.addCurve(to: CGPoint(x: frame.maxX - 2, y: frame.minY + 15.73), controlPoint1: CGPoint(x: frame.maxX - 5.8, y: frame.minY + 4.24), controlPoint2: CGPoint(x: frame.maxX - 2, y: frame.minY + 9.66))
        rectanglePath.addCurve(to: CGPoint(x: frame.maxX - 2, y: frame.minY + 16.5), controlPoint1: CGPoint(x: frame.maxX - 2, y: frame.minY + 16.5), controlPoint2: CGPoint(x: frame.maxX - 2, y: frame.minY + 16.5))
        rectanglePath.addLine(to: CGPoint(x: frame.maxX - 2, y: frame.minY + 16.5))
        rectanglePath.addLine(to: CGPoint(x: frame.maxX - 2, y: frame.minY + 16.5))
        rectanglePath.addLine(to: CGPoint(x: frame.maxX - 2, y: frame.minY + 17.27))
        rectanglePath.addCurve(to: CGPoint(x: frame.maxX - 11.5, y: frame.minY + 30.84), controlPoint1: CGPoint(x: frame.maxX - 2, y: frame.minY + 23.34), controlPoint2: CGPoint(x: frame.maxX - 5.8, y: frame.minY + 28.76))
        rectanglePath.addCurve(to: CGPoint(x: frame.maxX - 25.4, y: frame.minY + 32), controlPoint1: CGPoint(x: frame.maxX - 15.17, y: frame.minY + 32), controlPoint2: CGPoint(x: frame.maxX - 18.58, y: frame.minY + 32))
        rectanglePath.addLine(to: CGPoint(x: frame.minX + 19.34, y: frame.minY + 32))
        rectanglePath.addCurve(to: CGPoint(x: frame.minX + 11.09, y: frame.minY + 30.98), controlPoint1: CGPoint(x: frame.minX + 17.58, y: frame.minY + 32), controlPoint2: CGPoint(x: frame.minX + 14.17, y: frame.minY + 32))
        rectanglePath.addLine(to: CGPoint(x: frame.minX + 10.5, y: frame.minY + 30.84))
        rectanglePath.addCurve(to: CGPoint(x: frame.minX + 1, y: frame.minY + 17.27), controlPoint1: CGPoint(x: frame.minX + 4.8, y: frame.minY + 28.76), controlPoint2: CGPoint(x: frame.minX + 1, y: frame.minY + 23.34))
        rectanglePath.addCurve(to: CGPoint(x: frame.minX + 1, y: frame.minY + 16.5), controlPoint1: CGPoint(x: frame.minX + 1, y: frame.minY + 16.5), controlPoint2: CGPoint(x: frame.minX + 1, y: frame.minY + 16.5))
        rectanglePath.addLine(to: CGPoint(x: frame.minX + 1, y: frame.minY + 16.5))
        rectanglePath.addLine(to: CGPoint(x: frame.minX + 1, y: frame.minY + 16.5))
        rectanglePath.addLine(to: CGPoint(x: frame.minX + 1, y: frame.minY + 15.72))
        rectanglePath.addCurve(to: CGPoint(x: frame.minX + 10.5, y: frame.minY + 2.16), controlPoint1: CGPoint(x: frame.minX + 1, y: frame.minY + 9.66), controlPoint2: CGPoint(x: frame.minX + 4.8, y: frame.minY + 4.24))
        rectanglePath.addCurve(to: CGPoint(x: frame.minX + 24.4, y: frame.minY + 1), controlPoint1: CGPoint(x: frame.minX + 14.17, y: frame.minY + 1), controlPoint2: CGPoint(x: frame.minX + 17.58, y: frame.minY + 1))
        rectanglePath.addLine(to: CGPoint(x: frame.minX + 19.34, y: frame.minY + 1))
        rectanglePath.addLine(to: CGPoint(x: frame.minX + 21.34, y: frame.minY + 1))
        rectanglePath.addLine(to: CGPoint(x: frame.maxX - 38, y: frame.minY + 1))
        return rectanglePath
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
