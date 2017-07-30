//
//  ZSwiftMessages.swift
//  Pods
//
//  Created by Administrator on 26.06.17.
//

import Foundation

public typealias EventListener = (Event) -> Void
private let instance = Ronni()

public class Ronni {
    let kNotificationViewTag = 0404
    
    var isShowAnimationFinished = true
    
    var animInterval: TimeInterval = Animator.kNotificationMoveAnimationDuration
    var duration: Duration = .automatic
    var currPosition: Position = .top
    var newPosition: Position = .top
    
    public static var events: [EventListener] = []
    
    func show (_ navController: UINavigationController, view: UIView?, style: Style, message: Message?) {
        if let lastNotification = getLastNotification(navController: navController) {
            if !isShowAnimationFinished { return }
            
            hide(navController, view: lastNotification, complete: {
                self.show(navController, view: view, style: style, message: message)
            })
        } else {
            if !isShowAnimationFinished { return }
            isShowAnimationFinished = false
            
            currPosition = newPosition
            
            if let notificationView = view != nil ? view! : getNotificatonView(navController: navController, style: style, message: message, didButtonClick:  {
                self.notify(event: .didButtonClick)
                
            }) {
                setup(navController, view: notificationView)
                present(navController, view: notificationView)
            }
        }
    }

    func hide (_ navController: UINavigationController, view: UIView, duration: TimeInterval = Animator.kNotificationMoveAnimationDuration, delay: TimeInterval = 0.0, complete: @escaping () -> Void = {}) {
        self.notify(event: .willHide)
        
        Animator.move(out: true, view: view, position: currPosition, duration: animInterval, delay: delay, onFinished: {
            view.removeFromSuperview()
            
            self.animInterval = Animator.kNotificationMoveAnimationDuration
            self.notify(event: .didHide)
            
            complete()
        })
    }
    
    private func notify (event: Event) {
        Ronni.events.forEach { $0(event) }
    }
    
    private func setup (_ navController: UINavigationController, view: UIView) {
        if let visibleViewController = navController.visibleViewController {
            view.isHidden = true
            view.tag = kNotificationViewTag
        
            //add to the visible view controller
            visibleViewController.view.addSubview(view)
            visibleViewController.view.layoutIfNeeded()
            
            if let containerView = (view as? NotificationView)?.containerView {
                view.frame.origin.y = currPosition == .top ? -containerView.frame.size.height
                    : visibleViewController.view.bounds.maxY
                view.frame.size = containerView.frame.size
            } else {
                view.frame.origin.y = currPosition == .top ? -view.frame.size.height
                : visibleViewController.view.bounds.maxY
            }
        }
    }
    
    private func present(_ navController: UINavigationController, view: UIView) {
        Animator.move(out: false, view: view, position: currPosition, duration: animInterval, onFinished: {
            self.notify(event: .didShow)
            self.isShowAnimationFinished = true
            self.animInterval = Animator.kNotificationMoveAnimationDuration
            
            let durationInterval = self.getDurationInterval(duration: self.duration)
            if durationInterval != -1 {
                self.hide(navController, view: view, delay: durationInterval)
            }
        })
    }
}

extension Ronni {

    public static func show(to: UINavigationController, message: Message, style: Style, duration: Duration = .automatic, position: Position = .top, animTime: TimeInterval = Animator.kNotificationMoveAnimationDuration) {
        instance.animInterval = animTime
        instance.newPosition = position
        instance.duration = duration
        instance.show(to, view: nil, style: style, message: message)
    }
    
    public static func show(to: UINavigationController, message: Message, duration: Duration = .automatic, position: Position = .top, animTime: TimeInterval = Animator.kNotificationMoveAnimationDuration) {
        instance.animInterval = animTime
        instance.newPosition = position
        instance.duration = duration
        instance.show(to, view: nil, style: .success, message: message)
    }
    
    public static func show(to: UINavigationController, view: UIView, duration: Duration = .automatic, position: Position = .top, animTime: TimeInterval = Animator.kNotificationMoveAnimationDuration) {
        instance.animInterval = animTime
        instance.newPosition = position
        instance.duration = duration
        instance.show(to, view: view, style: .success, message: nil)
    }
    
    public static func show(to: UINavigationController, text: String, style: Style, duration: Duration = .automatic, position: Position = .top, animTime: TimeInterval = Animator.kNotificationMoveAnimationDuration) {
        let message = instance.getEmptyMessage(text: text)
        instance.animInterval = animTime
        instance.newPosition = position
        instance.duration = duration
        instance.show(to, view: nil, style: style, message: message)
    }
    
    public static func show(to: UINavigationController, text: String, style: Style, backgroundColor: UIColor, duration: Duration = .automatic, position: Position = .top, animTime: TimeInterval = Animator.kNotificationMoveAnimationDuration) {
        let message = instance.getEmptyMessage(text: text)
        message.backgroundColor = backgroundColor
        instance.animInterval = animTime
        instance.duration = duration
        instance.newPosition = position
        instance.show(to, view: nil, style: style, message: message)
    }
    
    public static func hide(from: UINavigationController, animTime: TimeInterval = Animator.kNotificationMoveAnimationDuration) {
        if let lastNotification = instance.getLastNotification(navController: from) {
            instance.animInterval = animTime
            instance.hide(from, view: lastNotification)
        }
    }

    public static func isShown(at: UINavigationController) -> Bool {
        return instance.getLastNotification(navController: at) != nil
    }
}
