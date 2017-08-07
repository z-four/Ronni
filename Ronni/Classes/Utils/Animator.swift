//
//  AnimationUtils.swift
//  Pods
//
//  Created by Administrator on 27.06.17.
//
//

import Foundation
import UIKit

class Animator {
    static let kNotificationMoveAnimationDuration = 0.52
    static let kNotificationMoveAnimationDelay = 0.1
    static let kNotificationMoveAnimationSpringDamping: CGFloat = 0.95
    static let kNotificationMoveAnimationSepingVelocity: CGFloat = 0.95
    
    static func move(out: Bool, view: UIView, position: Position, duration: TimeInterval = kNotificationMoveAnimationDuration, delay: TimeInterval = kNotificationMoveAnimationDelay, onFinished: @escaping () -> Void) {
        let currY = view.frame.origin.y
        let currHeight = view.frame.size.height
        
        if !out { view.isHidden = false }
        
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: kNotificationMoveAnimationSpringDamping, initialSpringVelocity: kNotificationMoveAnimationSepingVelocity, options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction], animations: {
            var y = position == .bottom ? (currY + currHeight) : (currY - currHeight)
            if !out {
                y = position == .bottom ? (currY - currHeight) : (currY + currHeight)
            }
            view.frame.origin.y = y
            view.layoutIfNeeded()

        }, completion: { completed in onFinished() })
    }
}
