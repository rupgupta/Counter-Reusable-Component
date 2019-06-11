//
//  ProgressAnimationController.swift
//  Counter Reusable Component
//
//  Created by Gupta, Rupali (US - Bengaluru) on 01/06/19.
//  Copyright © 2019 Gupta, Rupali (US - Bengaluru). All rights reserved.
//

import Foundation
import UIKit
extension CGFloat {
    /// method to convert the angle from degrees to radians
    ///
    /// - Returns: angle degrees in radians
    func toRadians() -> CGFloat {
        return self * .pi / 180.0
    }
}
class ProgressCircularAnimation {
    
    //MARK: - Properties
    var frameWidth : CGFloat = 0.0
    var frameHeight : CGFloat = 0.0
    var centerPoint : CGPoint = CGPoint(x: 0, y: 0)
    var arcWidth: CGFloat = 0.0
    
    var degreePerSecond : CGFloat = 0.0
    var startAngle : CGFloat = 0.0
    var endAngle : CGFloat = 0.0
    
     //MARK: - Properties with Observers

    
    /// As soon as the view to animate is updated, the frames & angles are set up at point for initial set ups
    var viewToAnimate:UIView = UIView() {
        didSet {
            self.frameWidth = self.viewToAnimate.frame.width
            self.frameHeight = self.viewToAnimate.frame.height
            self.startAngle = 270.0
            self.endAngle = self.startAngle
            self.centerPoint = CGPoint(x: frameWidth/2, y: frameHeight/2)
        }
    }
    
    /// as soon as seconds for the time are updated, sets the degrees to animate every second
    var forSeconds : CGFloat = 0.0 {
        didSet {
            if forSeconds > 0 {
                self.degreePerSecond = CGFloat(360.0/forSeconds)
            }
        }
    }
    //MARK: - Initial Setup Methods
    
    /// sets up the animation controller initially
    ///
    /// - Parameters:
    ///   - forSeconds: the time duration for timer animation
    ///   - forView: the view to perform animation on
    ///   - arcWidth: the width of the arc to be shown in animation
    func initialSetUp(forSeconds:CGFloat, forView: UIView, arcWidth:CGFloat) {
        self.forSeconds = forSeconds
        self.viewToAnimate = forView
        self.arcWidth = arcWidth
    }
    
     //MARK: - Add Progress Without Animation
    
    /// adds the circle depicting completed progress timer
    func addCompleteProgressView() {
        self.startAngle = 270.0
        self.endAngle = 269.99
        self.addProgressBar(withAnimation: false)
    }
    
    /// used when neet to update the animation in elapsed time
    ///
    /// - Parameter secondsReached: elapsed time to update the timer till
    func addProgressWithoutAnimation(secondsReached:CGFloat) {
        self.updateAnglesWith(secondsReached: secondsReached)
        self.addProgressBar(withAnimation: false)
    }
    
    /// updates the start & end angles as per elapsed time
    ///
    /// - Parameter secondsReached: elapsed time to update the timer till
    func updateAnglesWith(secondsReached:CGFloat) {
        self.startAngle = 270.0
        self.endAngle = 270.0
        self.endAngle += self.degreePerSecond*(secondsReached)
        if self.endAngle >= 360.0 {
            self.endAngle -= 360.0
        }
    }
   
    //MARK: - Custom Animation Logic Methods
    
    /// performs the normal animation on view by first calculating the angle movements required & then animating with Bezierpath
    func animate() {
        self.calculateAngles()
        self.addProgressBar()
    }
    
   
    /// Calculates the angle to move upto in a second
    private func calculateAngles() {
        self.endAngle += self.degreePerSecond
        if self.endAngle >= 360.0 {
            self.endAngle -= 360.0
        }
    }
  
    
    /// Draws a bezier path for given start and end angle with or without animation
    ///
    /// - Parameter withAnimation: decides weather to animate the arc or not
    private func addProgressBar(withAnimation:Bool = true) {
       
         let circlePath = UIBezierPath(arcCenter: self.centerPoint, radius: self.frameWidth/2 - self.arcWidth/2, startAngle: self.startAngle.toRadians(), endAngle: self.endAngle.toRadians(), clockwise: true)
        let shapeLayer: CAShapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.strokeColor = UIColor.init(red: 63.0/255.0, green: 82.0/255.0, blue: 115.0/255.0, alpha: 1.0).cgColor
        shapeLayer.lineWidth = self.arcWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        self.viewToAnimate.layer.addSublayer(shapeLayer)
        
        if withAnimation {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 1.0
            animation.fromValue = 0.0
            animation.toValue = 1.0
            shapeLayer.add(animation, forKey: "strokeEnd")
        }
        self.startAngle = self.endAngle
    }
}
