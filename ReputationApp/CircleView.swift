//
//  CircleView.swift
//  ReputationApp
//
//  Created by Omar Torres on 12/10/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import GLKit

class CircleView: UIView {
    
    var circleLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        // Use UIBezierPath as an easy way to create the CGPath for the layer.
        // The path should be the entire circle.
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: (frame.size.width - 5) / 2, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat((M_PI * 2.0) - M_PI_2), clockwise: true)
        
        // Setup the CAShapeLayer with the path, colors, and line width
        circleLayer = CAShapeLayer()
        circleLayer.lineCap = kCALineCapRound
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.red.cgColor
        circleLayer.lineWidth = 5
        
        // Don't draw the circle initially
        circleLayer.strokeEnd = 0.0
        
        // Add the circleLayer to the view's layer's sublayers
        layer.addSublayer(circleLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pauseAnimation() {
        let pausedTime: CFTimeInterval = circleLayer.convertTime(CACurrentMediaTime(), from: nil)
        circleLayer.speed = 0.0
        circleLayer.timeOffset = pausedTime
    }
    
    var animation = CABasicAnimation()
    
    func animateCircle(duration: TimeInterval) {
        
        // We want to animate the strokeEnd property of the circleLayer
        animation = CABasicAnimation(keyPath: "strokeEnd")
        
        // Set the animation duration appropriately
        animation.duration = duration
        
        // Animate from 0 (no circle) to 1 (full circle)
        animation.fromValue = 0
        animation.toValue = 1
        
        // Do a linear animation (i.e. the speed of the animation stays the same)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        // Set the circleLayer's strokeEnd property to 1.0 now so that it's the
        // right value when the animation ends.
        circleLayer.strokeEnd = 1.0
        
        // Do the actual animation
        circleLayer.add(animation, forKey: "animateCircle")
        
    }
    
    
}
