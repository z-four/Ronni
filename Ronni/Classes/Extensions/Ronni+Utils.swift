//
//  LibraryUtils.swift
//
//  Created by Z4.
//

import Foundation

public enum Style: String {
    case success = "SuccessNotificationView"
    case error   = "ErrorNotificationView"
    case info    = "InfoNotificationView"
    case loading = "ProgressNotificationView"
}

public enum Duration {
    case automatic
    case forever
    case seconds(sec: TimeInterval)
}

public enum Event {
    case willShow
    case didShow
    case willHide
    case didHide
    case didButtonClick
}

public class Message {
    public init () {}
    
    public var backgroundColor: UIColor?
    
    public var buttonText: String?
    public var buttonBackgroundColor: UIColor?
    public var buttonTextColor: UIColor?
    
    public var title: String?
    public var description: String?
    public var titleTextColor = UIColor.white
    public var descriptionTextColor = UIColor.white
    
    public var image: UIImage?
    
    var isButtonEnable = false
    var isIconEnable = true
}

extension Ronni {

    func getLastNotification (navController: UINavigationController) -> UIView? {
        if let visibleViewController = navController.visibleViewController {
            let subviews = visibleViewController.view.subviews
            if let index = subviews.index(where: { $0.tag == kNotificationViewTag }) {
                return subviews[index]
            }
        }
        return nil
    }
    
    func getDurationInterval (duration: Duration) -> TimeInterval {
        switch (duration) {
            case .automatic: return 2.0
            case .seconds(sec: let interval): return interval
            default: return -1
        }
    }
    
    func getNotificatonView (navController: UINavigationController, style: Style, message: Message?, didButtonClick: (() -> Void)? = nil) -> NotificationView? {
        do {
            let view = try NotificationView.viewFromNib(name: style.rawValue)
            view.frame.size.width = navController.navigationBar.frame.width
            view.frame.size.height =  view.containerView.frame.size.height
            view.didButtonClick = didButtonClick
            
            if let progress = view.progressView { progress.start() }
            if let unwrappedMessage = message {
                view.configure(message: unwrappedMessage, style: style)
            }
            return view
                
        } catch { return nil }
    }
    
    func getEmptyMessage (text: String) -> Message {
        let message = Message()
        message.isIconEnable = false
        message.title = text
        
        return message
    }
}
