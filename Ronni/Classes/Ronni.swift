//
//  Ronni.swift
//  Pods
//
//  Created by Z4
//

import Foundation

public typealias EventListener = (Event) -> Void
private let instance = Ronni()

public final class Ronni {
    fileprivate let viewTag = Int.max
    fileprivate let animAttrs = AnimAttrs()
    fileprivate let positionAttrs = PositionAttrs()
    
    public static var events: [EventListener] = []
    
    fileprivate final class AnimAttrs {
        static let duration = 0.52
        static let delay = 0.1
        static let springDamping: CGFloat = 0.95
        static let springVelocity: CGFloat = 0.95
        
        var interval: TimeInterval = duration
        var waiting: Duration = .automatic
        var isFinished = true
        
        func toggle() { isFinished = !isFinished }
    }
    
    fileprivate final class PositionAttrs {
        var current: Position = .top
        var new: Position = .top
        
        func swap() { current = new }
    }
    
    fileprivate func setup(_ navController: UINavigationController, view: UIView) {
        if let visibleVC = navController.visibleViewController {
            view.isHidden = true
            view.tag = viewTag
        
            //add to the visible view controller
            visibleVC.view.addSubview(view)
            visibleVC.view.layoutIfNeeded()
  
            //check of navigation bar is transculent to determinate proper y position
            let isTranslucent = navController.navigationBar.isTranslucent && visibleVC.edgesForExtendedLayout.rawValue > 0
            var properY: CGFloat = 0
            if isTranslucent {
                properY = navController.navigationBar.frame.maxY
                view.frame.origin.y = properY
            }
            
            //setup view size and y positon
            if let containerView = (view as? NotificationView)?.rootView() {
                view.frame.origin.y = positionAttrs.current == .top ? (properY - containerView.frame.size.height)
                    : visibleVC.view.bounds.maxY
                view.frame.size = containerView.frame.size
            } else {
                view.frame.origin.y = positionAttrs.current == .top ? -view.frame.size.height
                    : visibleVC.view.bounds.maxY
            }
        }
    }
    
    fileprivate func lastNotification(navController: UINavigationController) -> UIView? {
        if let visibleViewController = navController.visibleViewController {
            let subviews = visibleViewController.view.subviews
            if let index = subviews.index(where: { $0.tag == viewTag }) {
                return subviews[index]
            }
        }
        return nil
    }
    
    fileprivate func notify(event: Event) {
        Ronni.events.forEach { $0(event) }
    }
}

// MARK: - Show/hide
extension Ronni {
    
    fileprivate func show(_ navController: UINavigationController, view: UIView?, style: Style, message: Message?) {
        if let lastView = lastNotification(navController: navController) {
            hide(navController, view: lastView, complete: {
                self.show(navController, view: view, style: style, message: message)
            })
        } else {
            animAttrs.toggle()
            positionAttrs.swap()
            
            if let view = view == nil ? NotificationView.create(navController: navController,
                style: style,
                message: message,
                didButtonPressed:  { self.notify(event: .didButtonClick) }) : view! {
                
                //setup view and animate
                setup(navController, view: view)
                move(view: view,
                     position:  positionAttrs.current,
                     duration: animAttrs.interval,
                     delay: AnimAttrs.delay, onFinished: {
                        self.notify(event: .didShow)
                        self.animAttrs.toggle()
                        self.animAttrs.interval = AnimAttrs.duration
                        
                        //hide notification after specific interval
                        let interval = self.durationInterval(duration: self.animAttrs.waiting)
                        if interval != -1 { self.hide(navController, view: view, delay: interval) }
                })
            }
        }
    }
    
    fileprivate func hide(_ navController: UINavigationController, view: UIView,
              duration: TimeInterval = AnimAttrs.duration, delay: TimeInterval = 0.0,
              complete: @escaping () -> Void = {}) {
        self.notify(event: .willHide)
        
        move(view: view, position: positionAttrs.current, anim: .out, duration: duration, delay: delay, onFinished: {
            view.removeFromSuperview()
            
            //reset interaval and notify
            self.animAttrs.interval = AnimAttrs.duration
            self.notify(event: .didHide)
            complete()
        })
    }
}

// MARK: - Animation
extension Ronni {
    
    fileprivate func durationInterval(duration: Duration) -> TimeInterval {
        switch (duration) {
            case .automatic: return 2.0
            case .seconds(sec: let interval): return interval
            default: return -1
        }
    }

    fileprivate func move(view: UIView, position: Position, anim: Animation = .in,
                          duration: TimeInterval, delay: TimeInterval,
                          onFinished: @escaping () -> Void) {
        let currY = view.frame.origin.y
        let currHeight = view.frame.size.height
        
        if anim != .out { view.isHidden = false }
        
        UIView.animate(withDuration: duration,
                       delay: delay,
                       usingSpringWithDamping: AnimAttrs.springDamping,
                       initialSpringVelocity: AnimAttrs.springVelocity,
                       options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction],
                       animations: {
                        
            //detect proper y to animate
            var y = position == .bottom ? (currY + currHeight) : (currY - currHeight)
            if anim != .out {
                y = position == .bottom ? (currY - currHeight) : (currY + currHeight)
            }
            view.frame.origin.y = y
            view.layoutIfNeeded()
            
        }, completion: { completed in onFinished() })
    }
}

extension Ronni {

    public static func show(to: UINavigationController, message: Message, style: Style, duration: Duration = .automatic,
                            position: Position = .top, animTime: TimeInterval = AnimAttrs.duration) {
        instance.animAttrs.interval = animTime
        instance.positionAttrs.new = position
        instance.animAttrs.waiting = duration
        instance.show(to, view: nil, style: style, message: message)
    }
    
    public static func show(to: UINavigationController, message: Message, duration: Duration = .automatic,
                            position: Position = .top, animTime: TimeInterval = AnimAttrs.duration) {
        instance.animAttrs.interval = animTime
        instance.positionAttrs.new  = position
        instance.animAttrs.waiting = duration
        instance.show(to, view: nil, style: .success, message: message)
    }
    
    public static func show(to: UINavigationController, view: UIView, duration: Duration = .automatic,
                            position: Position = .top, animTime: TimeInterval = AnimAttrs.duration) {
        instance.animAttrs.interval = animTime
        instance.positionAttrs.new = position
        instance.animAttrs.waiting = duration
        instance.show(to, view: view, style: .success, message: nil)
    }
    
    public static func show(to: UINavigationController, text: String, style: Style, duration: Duration = .automatic,
                            position: Position = .top, animTime: TimeInterval = AnimAttrs.duration) {
        let message = NotificationView.empty(text: text)
        instance.animAttrs.interval = animTime
        instance.positionAttrs.new  = position
        instance.animAttrs.waiting = duration
        instance.show(to, view: nil, style: style, message: message)
    }
    
    public static func show(to: UINavigationController, text: String, style: Style, backgroundColor: UIColor, duration: Duration = .automatic,
                            position: Position = .top, animTime: TimeInterval = AnimAttrs.duration) {
        let message = NotificationView.empty(text: text)
        message.backgroundColor = backgroundColor
        instance.animAttrs.interval = animTime
        instance.positionAttrs.new = position
        instance.animAttrs.waiting = duration
        instance.show(to, view: nil, style: style, message: message)
    }
    
    public static func hide(from: UINavigationController, animTime: TimeInterval = AnimAttrs.duration) {
        if let lastNotification = instance.lastNotification(navController: from) {
            instance.animAttrs.interval = animTime
            instance.hide(from, view: lastNotification)
        }
    }

    public static func isShown(at: UINavigationController) -> Bool {
        return instance.lastNotification(navController: at) != nil
    }
}
