//
//  Extensions.swift
//  JESlideMenu
//
//  Created by JE on 20.10.17.
//  Copyright © 2017 JE. All rights reserved.
//

import UIKit

extension JESlideMenuController: JESlideMenuDelegate {
    
    func toggleMenu() {
        var constant: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        if !isMenuOpen {
            constant = menuIsOpenConstant
            alpha = menuIsOpenAlpha
        }
        // animate the change
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.tapAreaView.alpha = alpha
                        self.leadingConstraint.constant = constant
                        self.view.layoutIfNeeded()
        },
                       completion: { _ in
                        self.isMenuOpen = !self.isMenuOpen
        })
    }
    
    func setViewControllerAtIndexPath(indexPath: IndexPath) {
        let identifier = menuItems[indexPath.row]
        var newController = UIViewController()
        
        if visibleViewControllerID != identifier {
            // load view controller(s)
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: identifier) {
                if let navi = controller as? UINavigationController {
                    if let root = navi.topViewController {
                        newController = root
                    }
                } else {
                    newController = controller
                }
                
                newController.title = NSLocalizedString(identifier, comment: "translated title")
                newController.automaticallyAdjustsScrollViewInsets = true
                menuNavigationController.setViewControllers([newController], animated: true)
                menuNavigationController.setBarButtonItemWith(image: buttonImage)
                visibleViewControllerID = identifier
            }
        }
    }
    
}
