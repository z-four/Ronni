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
    let customViewXibName = "CustomView"
    
    let styles: [Style] = [.success, .error, .info]
    var navController: UINavigationController?
    
    var notificationPosition: Position = .top
    var curr = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initListeners()
    }
}

//MARK: - Click events
extension ViewController {
    
    @IBAction func pressedOnButton(_ button: UIButton) {
        if let navController = self.navigationController {
            switch button.tag {
            case 1:
                let text = "How are you getting on?"
                Ronni.show(to: navController, text: text, style: randStyle(), position: notificationPosition)
                break
                
            case 2:
                Ronni.show(to: navController, text: "Loading...", style: .loading, duration: .forever, position: notificationPosition)
                break
                
            case 3:
                Ronni.show(to: navController, text: "Lets go champ!", style: .toast, position: notificationPosition)
                break
                
            case 4:
                let message = Message()
                message.title = "Rocky"
                message.description = "The world ain't all sunshine and rainbows. It's a very mean and nasty place."
                Ronni.show(to: navController, message: message, style: randStyle(), position: notificationPosition)
                break
                
            case 5:
                let message = Message()
                message.title = "Captain America"
                message.description = "Captain America is a fictional character appearing in American comic books"
                message.backgroundColor = UIColor(hex: "4460A0")
                message.image = UIImage(named: "star")
                message.buttonText = "Hide"
                
                Ronni.show(to: navController, message: message, duration: .forever, position: notificationPosition)
                break
                
            case 6:
                let view = UINib(nibName: customViewXibName, bundle: Bundle.main).instantiate(withOwner: self, options: [:])[0]  as! CustomView
   
                view.frame.size.width = self.view.frame.size.width
                Ronni.show(to: navController, view: view, duration: .forever, position: notificationPosition)
                break
                
            default: break
            }
        }
    }
}

//MARK: - RightBarButton events
extension ViewController  {
    
    @IBAction func pressedOnHide(_ sender: Any) {
        if let navController = self.navigationController {
            Ronni.hide(from: navController, animTime: 0.52)
        }
    }
}

//MARK: - UISegmentControll events
extension ViewController  {
    func segmentSwitched (_ sender: UISegmentedControl) {
        notificationPosition = sender.selectedSegmentIndex == 0 ? .top : .bottom
    }
}

//MARK: - Other methods
extension ViewController {
    
    func initUI () {
        let segment: UISegmentedControl = UISegmentedControl(items: ["Top", "Bottom"])
        segment.sizeToFit()
        segment.tintColor = UIColor(hex: "5FB4A0")
        segment.selectedSegmentIndex = 0;
        segment.addTarget(self, action: #selector(segmentSwitched(_:)), for: .valueChanged)
        
        self.navigationItem.titleView = segment
        
        navigationItem.rightBarButtonItem?.action = #selector(pressedOnHide(_:))
    }
    
    func initListeners () {
        Ronni.events.append() { event in
            switch(event) {
                case .didHide:
                    print("did hide")
                break
                
                case .didButtonClick:
                    if let navController = self.navigationController {
                        Ronni.hide(from: navController)
                    }
                break
                
                default: break
            }
        }
    }
    
    func randStyle () -> Style {
        return styles[Int(arc4random_uniform(UInt32(styles.count)))]
    }
}
