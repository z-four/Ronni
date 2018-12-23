//
//  SuccessNotificationView.swift
//  Pods
//
//  Created by Administrator on 26.06.17.
//
//

import Foundation
import UIKit

public class NotificationView: UIView {
    
    @IBOutlet fileprivate weak var progressView: ProgressView?
    
    @IBOutlet fileprivate weak var icon: UIImageView!
    @IBOutlet fileprivate weak var iconHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var iconLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var descriptionLabel: UILabel!
    @IBOutlet fileprivate weak var textLabel: UILabel!
    @IBOutlet fileprivate weak var textContainerView: UIView!
    @IBOutlet fileprivate weak var containerView: UIView!
    @IBOutlet fileprivate weak var button: UIButton!
    
    var style: Style = .success
    var didButtonPressed: (() -> Void)?
    
    class func viewFromNib(name: String, bundle: Bundle? = nil) throws -> NotificationView {
        let currBundle: Bundle
        if let bundle = bundle { currBundle = bundle }
        else {
            currBundle = Bundle.main.path(forResource: name, ofType: "nib") != nil ? Bundle.main : Bundle(for: Ronni.self)
        }
        
        let arrayOfViews = currBundle.loadNibNamed(name, owner: NSNull(), options: nil) ?? []
        if arrayOfViews.count > 0 {
            let notficationView = arrayOfViews[0] as! NotificationView
            return notficationView
        }
        return NotificationView()
    }
}

// MARK: - Actions
extension NotificationView {
    @IBAction func buttonTapped(_ sender: Any) { didButtonPressed?() }
}

// MARK: - View creation
extension NotificationView {

    class func create(navController: UINavigationController, style: Style, message: Message?,
                         didButtonPressed: (() -> Void)? = nil) -> NotificationView? {
        do {
            let view = try NotificationView.viewFromNib(name: style.rawValue)
            view.frame.size.width = navController.navigationBar.frame.width
            view.frame.size.height = view.containerView.frame.size.height
            view.didButtonPressed = didButtonPressed
            
            if let progress = view.progressView { progress.start() }
            if let unwrappedMessage = message {
                view.configure(message: unwrappedMessage, style: style)
            }
            return view
            
        } catch { return nil }
    }
    
    class func empty(text: String) -> Message {
        let message = Message()
        message.isIconEnable = false
        message.title = text
        return message
    }
}

// MARK: - Configure
extension NotificationView {
    
    func rootView() -> UIView { return containerView }
    
    fileprivate func configure(message: Message, style: Style) {
        self.style = style
        
        if style == .toast {
            if let unwrappedBackgroundColor = message.backgroundColor {
                textContainerView.backgroundColor = unwrappedBackgroundColor
                self.backgroundColor = UIColor.clear
            }
            
            descriptionLabel.textColor = message.titleTextColor
            descriptionLabel.text = message.title
            return
            
        } else if style == .loading {
            if let unwrappedBackgroundColor = message.backgroundColor {
                containerView.backgroundColor = unwrappedBackgroundColor
                self.backgroundColor = UIColor.clear
            }
            
            descriptionLabel.textColor = message.titleTextColor
            descriptionLabel.text = message.title
            return
        }
        
        textLabel.textColor = message.titleTextColor
        descriptionLabel.textColor = message.descriptionTextColor
        
        if message.title != nil && message.description == nil {
            textLabel.text = message.description
            textLabel.font = UIFont.systemFont(ofSize: textLabel.font.pointSize - 1)
            descriptionLabel.text = message.title
            
            
        } else if message.title != nil && message.description != nil {
            textLabel.text = message.title
            descriptionLabel.text = message.description
            
        } else {
            textLabel.text = message.title
            descriptionLabel.text = message.description
        }
        
        if !message.isIconEnable {
            if !message.isButtonEnable {
                textLabel.textAlignment = .center
                descriptionLabel.textAlignment = .center
            }
            
            iconLeftConstraint.constant = 0
            iconHeightConstraint.constant = 0
            
        } else if let unwrappedImage = message.image, let unwrappedIcon = icon {
            unwrappedIcon.image = unwrappedImage
        }
        
        if let unwrappedButton = button  {
            if let unwrappedButtonBackgroundColor = message.buttonBackgroundColor {
                unwrappedButton.backgroundColor = unwrappedButtonBackgroundColor
                message.isButtonEnable = true
            }
            
            if let unwrappedButtonTextColor = message.buttonTextColor {
                unwrappedButton.setTitleColor(unwrappedButtonTextColor, for: .normal)
                message.isButtonEnable = true
            }
            
            if let unwrappedButtonTitle = message.buttonText {
                unwrappedButton.setTitle(unwrappedButtonTitle, for: .normal)
                message.isButtonEnable = true
            }
            
            unwrappedButton.isHidden = !message.isButtonEnable
            
            if !message.isButtonEnable {
                unwrappedButton.removeFromSuperview()
                
                let rightConstant: CGFloat = 8
                let trailingConstraint = NSLayoutConstraint(item: textContainerView,
                                                            attribute: .trailing,
                                                            relatedBy: .equal,
                                                            toItem: containerView,
                                                            attribute: .trailing,
                                                            multiplier: 1,
                                                            constant: -rightConstant)
                containerView.addConstraint(trailingConstraint)
            }
        }
        
        if let unwrappedBackgroundColor = message.backgroundColor {
            containerView.backgroundColor = unwrappedBackgroundColor
            self.backgroundColor = UIColor.clear
        }
    }
}
