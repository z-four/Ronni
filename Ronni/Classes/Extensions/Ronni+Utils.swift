//
//  Ronni+Utils.swift
//
//  Created by Z4
//  Copyright (c) 2017 Z4. All rights reserved.

import Foundation

public enum Style: String {
    case success = "SuccessNotificationView"
    case error   = "ErrorNotificationView"
    case info    = "InfoNotificationView"
    case loading = "ProgressNotificationView"
    case toast   = "ToastNotificationView"
}

public enum Animation {
    case `in`
    case out
}

public enum Position {
    case top
    case bottom
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
