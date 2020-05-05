//
//  ProgressView.swift
//  Pods
//
//  Created by Z4
//  Copyright (c) 2017 Z4. All rights reserved.

import Foundation

@IBDesignable
public class ProgressView: UIView {
    private let lineWidth: CGFloat = 2.0
    
    private let animDuration: CFTimeInterval = 0.9
    private let animType = "transform.rotation"
    private let animKey = "rotationAnimation"
    
    public let progressLayer = CAShapeLayer()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createLayers()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        createLayers()
    }
    
    private func createLayers() {
        let centerPoint = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let startAngle = CGFloat(3 * Double.pi / 2)
        let endAngle = CGFloat(Double.pi)
        
        let progressLayer = getProgressLayer(centerPoint: centerPoint, startAngle: startAngle, endAngle: endAngle)
        
        layer.addSublayer(progressLayer)
    }
    
    private func getProgressLayer (centerPoint: CGPoint, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool = true, color: UIColor = UIColor.white) -> CAShapeLayer {
        
        progressLayer.path = UIBezierPath(arcCenter: centerPoint, radius: centerPoint.x - lineWidth, startAngle: startAngle, endAngle:endAngle, clockwise: clockwise).cgPath
        layer.backgroundColor = UIColor.clear.cgColor
        progressLayer.fillColor = nil
        progressLayer.lineWidth = lineWidth
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 1.0
        progressLayer.strokeColor = color.cgColor
        
        return progressLayer
    }
    
    public func setStrokeColor (color: UIColor) {
        progressLayer.strokeColor = color.cgColor
    }
    
    public func stop() {
        layer.removeAllAnimations()
    }
    
    public func start() {
        let animation = CABasicAnimation(keyPath: animType)
        animation.byValue = 2 * Double.pi
        animation.repeatCount = .infinity
        animation.duration = animDuration
        animation.isRemovedOnCompletion = false
        
        layer.add(animation, forKey: animKey)
    }
}
