//
//  Ronni.swift
//  Pods
//
//  Created by Z4
//  Copyright (c) 2017 Z4. All rights reserved.
//

import Foundation

public typealias EventListener = (Event) -> Void
private let instance = Ronni()

public final class Ronni {
    private let viewTag = Int.max
    private let animAttrs = AnimAttrs()
    private let positionAttrs = PositionAttrs()
    
    public static var events: [EventListener] = []
    
    public final class AnimAttrs {
        public static let duration = 0.52
        static let delay = 0.1
        static let springDamping: CGFloat = 0.95
        static let springVelocity: CGFloat = 0.95
        
        var interval: TimeInterval = duration
        var waiting: Duration = .automatic
        var isFinished = true
        
        func toggle() { isFinished = !isFinished }
    }
    
    public final class PositionAttrs {
        var current: Position = .top
        var new: Position = .top
        
        func swap() { current = new }
    }
    
    /// Sets up the view and attach to visible UIViewController
    ///
    /// - Parameters:
    ///     - navController: The current navigation controller
    ///     - view: The view to be shown as message
    private func setup(_ navController: UINavigationController,
                       view: UIView) {
        
        // Get current visible UIViewConroller
        if let visibleVC = navController.visibleViewController {
            view.isHidden = true
            view.tag = viewTag
        
            // Add to the visible UIViewController
            visibleVC.view.addSubview(view)
            visibleVC.view.layoutIfNeeded()
  
            // Check if navigation bar is transculent to determinate correct y position
            let isTranslucent = navController.navigationBar.isTranslucent && visibleVC.edgesForExtendedLayout.rawValue > 0
            var properY: CGFloat = 0
            if isTranslucent {
                properY = navController.navigationBar.frame.maxY
                view.frame.origin.y = properY
            }
            
            // Sets up view size and y positon
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
    
    /// Returns message view that were attached to this UIViewController
    ///
    /// - Parameters:
    ///     - navController: The current navigation controller
    /// - Returns: The message view inside visible UIViewController
    private func lastNotification(navController: UINavigationController) -> UIView? {
        if let visibleViewController = navController.visibleViewController {
            let subviews = visibleViewController.view.subviews
            if let index = subviews.firstIndex(where: { $0.tag == viewTag }) {
                return subviews[index]
            }
        }
        return nil
    }
    
    /// Sets up the view and attach to visible UIViewController
    ///
    /// - Parameters:
    ///     - event: Event type that user should be notified of
    private func notify(event: Event) {
        Ronni.events.forEach { $0(event) }
    }
}

// MARK: - Show/hide
extension Ronni {
    
    /// Shows the message with specified style and content
    ///
    /// - Parameters:
    ///     - navController: The current navigation controller
    ///     - view: The view to be shown as message
    ///     - style: The view style
    ///     - message: The view content
    private func show(_ navController: UINavigationController,
                      view: UIView?,
                      style: Style,
                      message: Message?) {
        
        // Find the view inside visible UIViewController
        if let lastView = lastNotification(navController: navController) {
            hide(navController, view: lastView, complete: {
                self.show(navController, view: view, style: style, message: message)
            })
        } else {
            // Toggle animation state
            animAttrs.toggle()
            
            // Swap positions
            positionAttrs.swap()
            
            // If passed view is null then create and sryle the new one
            if let view = view == nil ? NotificationView.create(
                navController: navController,
                style: style,
                message: message,
                didButtonPressed:  { self.notify(event: .didButtonClick) }) : view! {
                
                // Sets up view and animate
                setup(navController, view: view)
                move(view: view,
                     position:  positionAttrs.current,
                     duration: animAttrs.interval,
                     delay: AnimAttrs.delay, onFinished: {
                        self.notify(event: .didShow)
                        self.animAttrs.toggle()
                        self.animAttrs.interval = AnimAttrs.duration
                        
                        // Hide notification after specific interval
                        let interval = self.durationInterval(duration: self.animAttrs.waiting)
                        if interval != -1 { self.hide(navController, view: view, delay: interval) }
                })
            }
        }
    }
    
    /// Hides the message with specified params
    ///
    /// - Parameters:
    ///     - navController: The current navigation controller
    ///     - view: The view to be shown as message
    ///     - duration: Animation duration
    ///     - delay: Animation delay
     ///    - complete: Complete closure
    private func hide(_ navController: UINavigationController,
                      view: UIView,
                      duration: TimeInterval = AnimAttrs.duration,
                      delay: TimeInterval = 0.0,
                      complete: @escaping () -> Void = {}) {
        
        // Notifies view gonna be hidden
        self.notify(event: .willHide)
        
        // Starts the animation
        move(view: view,
             position: positionAttrs.current,
             anim: .out,
             duration: duration,
             delay: delay,
             onFinished: {
                
            // Removes view from the superview
            view.removeFromSuperview()
            
            // Reset interaval and notify
            self.animAttrs.interval = AnimAttrs.duration
            self.notify(event: .didHide)
            complete()
        })
    }
}

// MARK: - Animation
extension Ronni {
    
    /// Returns correcnt duration interval
    ///
    /// - Parameters:
    ///     - duration: Duration type
    private func durationInterval(duration: Duration) -> TimeInterval {
        switch (duration) {
            case .automatic: return 2.0
            case .seconds(sec: let interval): return interval
            default: return -1
        }
    }

   /// Hides the message with specified params
   ///
   /// - Parameters:
   ///     - view: The view represents as a message
   ///     - position: Position in the screen
   ///     - anim: Animation direction
   ///     - duration: Animation duration
   ///     - delay: Animation delay
   ///     - complete: Complete closure
    private func move(view: UIView,
                      position: Position,
                      anim: Animation = .in,
                      duration: TimeInterval,
                      delay: TimeInterval,
                      onFinished: @escaping () -> Void) {
        
        // Gets current y position
        let currY = view.frame.origin.y
        
        
        // Gets current view height
        let currHeight = view.frame.size.height
        
        if anim != .out { view.isHidden = false }
        
        UIView.animate(withDuration: duration,
                       delay: delay,
                       usingSpringWithDamping: AnimAttrs.springDamping,
                       initialSpringVelocity: AnimAttrs.springVelocity,
                       options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction],
                       animations: {
                        
            // Calculate proper y position and animate view
            let bottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
            var y = position == .bottom ? (currY + currHeight + bottomInset) : (currY - currHeight)
            if anim != .out {
                y = position == .bottom ? (currY - currHeight - bottomInset) : (currY + currHeight)
            }
            view.frame.origin.y = y
            view.layoutIfNeeded()
            
        }, completion: { completed in onFinished() })
    }
}

extension Ronni {

    /// Shows message with specified params
    ///
    /// - Parameters:
    ///     - to: The current UINavigationController
    ///     - message: Message to be shown
    ///     - style: Message style
    ///     - duration: Duration type
    ///     - position: Message position
    ///     - animType: Duration interval
    public static func show(to: UINavigationController,
                            message: Message,
                            style: Style,
                            duration: Duration = .automatic,
                            position: Position = .top,
                            animTime: TimeInterval = AnimAttrs.duration) {
        
        instance.animAttrs.interval = animTime
        instance.positionAttrs.new = position
        instance.animAttrs.waiting = duration
        instance.show(to, view: nil, style: style, message: message)
    }
    
    /// Shows message with specified params
    ///
    /// - Parameters:
    ///     - to: The current UINavigationController
    ///     - message: Message to be shown
    ///     - duration: Duration type
    ///     - position: Message position
    ///     - animType: Duration interval
    public static func show(to: UINavigationController,
                            message: Message,
                            duration: Duration = .automatic,
                            position: Position = .top,
                            animTime: TimeInterval = AnimAttrs.duration) {
        
        instance.animAttrs.interval = animTime
        instance.positionAttrs.new  = position
        instance.animAttrs.waiting = duration
        instance.show(to, view: nil, style: .success, message: message)
    }
    
    /// Shows message with specified params
    ///
    /// - Parameters:
    ///     - to: The current UINavigationController
    ///     - view: View to be shown
    ///     - duration: Duration type
    ///     - position: Message position
    ///     - animType: Duration interval
    public static func show(to: UINavigationController,
                            view: UIView,
                            duration: Duration = .automatic,
                            position: Position = .top,
                            animTime: TimeInterval = AnimAttrs.duration) {
        
        instance.animAttrs.interval = animTime
        instance.positionAttrs.new = position
        instance.animAttrs.waiting = duration
        instance.show(to, view: view, style: .success, message: nil)
    }
    
    /// Shows message with specified params
    ///
    /// - Parameters:
    ///     - to: The current UINavigationController
    ///     - text: Message text
    ///     - style: Message style
    ///     - duration: Duration type
    ///     - position: Message position
    ///     - animType: Duration interval
    public static func show(to: UINavigationController,
                            text: String,
                            style: Style,
                            duration: Duration = .automatic,
                            position: Position = .top,
                            animTime: TimeInterval = AnimAttrs.duration) {
        
        let message = NotificationView.empty(text: text)
        instance.animAttrs.interval = animTime
        instance.positionAttrs.new  = position
        instance.animAttrs.waiting = duration
        instance.show(to, view: nil, style: style, message: message)
    }
    
    /// Shows message with specified params
    ///
    /// - Parameters:
    ///     - to: The current UINavigationController
    ///     - text: Message text
    ///     - style: Message style
    ///     - backgroundColor: Message backgound color
    ///     - duration: Duration type
    ///     - position: Message position
    ///     - animType: Duration interval
    public static func show(to: UINavigationController,
                            text: String,
                            style: Style,
                            backgroundColor: UIColor,
                            duration: Duration = .automatic,
                            position: Position = .top,
                            animTime: TimeInterval = AnimAttrs.duration) {
        
        let message = NotificationView.empty(text: text)
        message.backgroundColor = backgroundColor
        instance.animAttrs.interval = animTime
        instance.positionAttrs.new = position
        instance.animAttrs.waiting = duration
        instance.show(to, view: nil, style: style, message: message)
    }
    
    /// Removes message from the screen
    ///
    /// - Parameters:
    ///     - from: The current UINavigationController
    ///     - animType: Duration interval
    public static func hide(from: UINavigationController,
                            animTime: TimeInterval = AnimAttrs.duration) {
        
        if let lastNotification = instance.lastNotification(navController: from) {
            instance.animAttrs.interval = animTime
            instance.hide(from, view: lastNotification)
        }
    }

    /// Checks if message has shown
    ///
    /// - Parameters:
    ///     - at: The current UINavigationController
    /// - Returns: Boolean that says is message has shown or not
    public static func isShown(at: UINavigationController) -> Bool {
        return instance.lastNotification(navController: at) != nil
    }
}
