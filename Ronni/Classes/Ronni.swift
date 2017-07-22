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
    let kNotificationViewTag = 1919
    
    var isShowImmediately = false
    var isHideImmediately = false
    var isShowAnimationFinished = true
    var duration: Duration = .automatic
    
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
            
            if let notificationView = view != nil ? view! : getNotificatonView(navController: navController, style: style, message: message, didButtonClick:  {
                self.notify(event: .didButtonClick)
                
            }) {
                setup(navController, view: notificationView)
                present(navController, view: notificationView)
            }
        }
    }

    func hide (_ navController: UINavigationController, view: UIView, durationInterval: TimeInterval = 0.0, complete: @escaping () -> Void = {}) {
        let duration = isHideImmediately ? 0 : Animator.kNotificationMoveAnimationDuration
        isHideImmediately = false
        self.notify(event: .willHide)
        
        Animator.move(out: true, view: view, duration: duration, delay: durationInterval, onFinished: {
            view.removeFromSuperview()
            
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
                view.frame.origin.y = -containerView.frame.size.height
                view.frame.size = containerView.frame.size
            } else {
                view.frame.origin.y = -view.frame.size.height
            }
        }
    }
    
    private func present(_ navController: UINavigationController, view: UIView) {
        let duration = isShowImmediately ? 0 : Animator.kNotificationMoveAnimationDuration
        isShowImmediately = false
        Animator.move(out: false, view: view, duration: duration, onFinished: {
            self.notify(event: .didShow)
            self.isShowAnimationFinished = true
            
            let durationInterval = self.getDurationInterval(duration: self.duration)
            if durationInterval != -1 {
                self.hide(navController, view: view, durationInterval: durationInterval)
            }
        })
    }
}

extension Ronni {

    public static func show(to: UINavigationController, message: Message, style: Style, duration: Duration = .automatic, immediately: Bool = false) {
        instance.isShowImmediately = immediately
        instance.duration = duration
        instance.show(to, view: nil, style: style, message: message)
    }
    
    public static func show(to: UINavigationController, message: Message, duration: Duration = .automatic, immediately: Bool = false) {
        instance.isShowImmediately = immediately
        instance.duration = duration
        instance.show(to, view: nil, style: .success, message: message)
    }
    
    public static func show(to: UINavigationController, view: UIView, duration: Duration = .automatic, immediately: Bool = false) {
        instance.isShowImmediately = immediately
        instance.duration = duration
        instance.show(to, view: view, style: .success, message: nil)
    }
    
    public static func show(to: UINavigationController, text: String, style: Style, duration: Duration = .automatic, immediately: Bool = false) {
        instance.isShowImmediately = immediately
        instance.duration = duration
        let message = instance.getEmptyMessage(text: text)
        instance.show(to, view: nil, style: style, message: message)
    }
    
    public static func show(to: UINavigationController, text: String, backgroundColor: UIColor, duration: Duration = .automatic, immediately: Bool = false) {
        instance.isShowImmediately = immediately
        instance.duration = duration
        let message = instance.getEmptyMessage(text: text)
        instance.show(to, view: nil, style: .success, message: message)
    }
    
    public static func hide(from: UINavigationController, immediately: Bool = false) {
        instance.isHideImmediately = immediately
        if let lastNotification = instance.getLastNotification(navController: from) {
            instance.hide(from, view: lastNotification)
        }
    }

    public static func isShown(at: UINavigationController) -> Bool {
        return instance.getLastNotification(navController: at) != nil
    }
}
