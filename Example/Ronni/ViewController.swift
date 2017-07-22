//
//  ViewController.swift
//  PROJECT
//
//  Created by PROJECT_OWNER on TODAYS_DATE.
//  Copyright (c) TODAYS_YEAR PROJECT_OWNER. All rights reserved.
//

import UIKit
import Ronni

class ViewController: UIViewController {
    let kCustomViewXibName = "CustomView"
    
    let styles: [Style] = [.success, .error, .info, .loading]
    var navController: UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initListeners()
    }
}

//MARK: - Actions
extension ViewController {
    
    @IBAction func pressedOnButton(_ button: UIButton) {
        if let navController = self.navigationController {
            switch button.tag {
            case 1 :
                let style =  getRandStyle()
                let text = style == .loading ? "Loading" : "How are you getting on?"
                Ronni.show(to: navController, text: text, style: style)
                break
                
            case 2 :
                let message = Message()
                message.title = "Just prefect"
                message.description = "Hi man"
                Ronni.show(to: navController, message: message, style: getRandStyle(withLoading: false))
                break
                
            case 3 :
                let message = Message()
                message.title = "Custom message"
                message.description = "With description"
                message.backgroundColor = UIColor(hex: "4460A0")
                message.image = UIImage(named: "star")
                message.buttonText = "Hide"
                
                Ronni.show(to: navController, message: message, duration: .forever)
                break
                
            case 4 :
                let view = UINib(nibName: kCustomViewXibName, bundle: Bundle.main).instantiate(withOwner: self, options: [:])[0]  as! CustomView
   
                Ronni.show(to: navController, view: view, duration: .forever)
                break
                
            default: break
            }
        }
    }
}

//MARK: - Other methods
extension ViewController {
    
    func initListeners () {
        Ronni.events.append() { event in
            if case .didHide = event { print("did hide") }
            if case Event.didButtonClick = event {
                Ronni.hide(from: self.navigationController!)
            }
        }
    }
    
    func getRandStyle (withLoading: Bool = true) -> Style {
        let stylesCount = withLoading ? styles.count : styles.count - 1
        return styles[Int(arc4random_uniform(UInt32(stylesCount)))]
    }
}
