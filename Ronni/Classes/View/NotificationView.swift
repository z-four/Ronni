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
    
    @IBOutlet weak var progressView: ProgressView?
    @IBOutlet var notificationViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var button: UIButton! 
       
    
    @IBOutlet weak var buttonLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var iconHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var textContainerLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var textContainerRightConstraint: NSLayoutConstraint!
  
    @IBAction func buttonTapped(_ sender: Any) {
        if let unwrappedButtonClick = didButtonClick {
            unwrappedButtonClick()
        }
    }
    
    var style: Style = .success
    var didButtonClick: (() -> Void)?
    
    class func viewFromNib(name: String, bundle: Bundle? = nil, filesOwner: AnyObject = NSNull.init()) throws -> NotificationView {
        let resolvedBundle: Bundle
        if let bundle = bundle { resolvedBundle = bundle }
        else {
            if Bundle.main.path(forResource: name, ofType: "nib") != nil {
                resolvedBundle = Bundle.main
            } else {
                resolvedBundle = Bundle.libraryBundle()
            }
        }
        let arrayOfViews = resolvedBundle.loadNibNamed(name, owner: filesOwner, options: nil) ?? []
        
        if arrayOfViews.count > 0 {
            let notficationView = arrayOfViews[0] as! NotificationView
            return notficationView
        }
        
        return NotificationView()
    }
    
    func configure (message: Message, style: Style) {
        self.style = style
        
        if style == .loading {
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
                let trailingConstraint = NSLayoutConstraint(item: textContainerView, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1, constant: -rightConstant)
            
                containerView.addConstraint(trailingConstraint)
            }
        }

        if let unwrappedBackgroundColor = message.backgroundColor {
            containerView.backgroundColor = unwrappedBackgroundColor
            self.backgroundColor = UIColor.clear
        }
    }
}
