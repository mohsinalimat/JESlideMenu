//
//  Extensions.swift
//  JESlideMenu
//
//  Created by Jasmin Eilers on 20.10.17.
//  Copyright © 2017 Jasmin Eilers. All rights reserved.
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
        let id = menuItems[indexPath.row]

        // only load other viewcontrollers
        if visibleViewControllerID != id {
            if let newController = viewcontrollerCache.object(forKey: id) {
                configureViewcontroller(newController, identifier: id)
            } else if let controller = self.storyboard?.instantiateViewController(withIdentifier: id as String) {

                // save in cache
                let cachedController = cacheViewcontroller(controller, forID: id)
                configureViewcontroller(cachedController, identifier: id)
            }
        }
    }

    private func configureViewcontroller(_ viewcontroller: UIViewController, identifier: NSString) {

        viewcontroller.title = NSLocalizedString(identifier as String, comment: "translated title")

        viewcontroller.view.frame = self.view.bounds
        menuNavigationController.setViewControllers([viewcontroller], animated: true)
        menuNavigationController.setBarButtonItemWith(image: buttonImage)
        visibleViewControllerID = identifier
    }

    // cache the new viewController and return reference
    private func cacheViewcontroller(_ viewcontroller: UIViewController,
                                     forID identifier: NSString) -> UIViewController {

        var newController: UIViewController!

        // get root controller in navigationcontroller
        if let navigation = viewcontroller as? UINavigationController,
            let root = navigation.topViewController {
                newController = root
        } else {
            newController = viewcontroller
        }

        // save in cache
        viewcontrollerCache.setObject(newController, forKey: identifier)

        return newController
    }

}

// print installed fonts
extension JESlideMenuController {

    // class methods to get the pre-installed fonts
    static func printInstalledFonts() {
        let familyNames = UIFont.familyNames
        var fonts = [String]()

        for family in familyNames {
            fonts += UIFont.fontNames(forFamilyName: family)
        }
        print(fonts)
    }

    static func printFontNames(familyName: String) {
        let familyNames = UIFont.familyNames
        var fonts = [String]()
        let filteredNames = familyNames.filter({$0.lowercased().contains(familyName.lowercased())})
        for familyName in filteredNames {
            fonts += UIFont.fontNames(forFamilyName: familyName)
        }
        print(fonts)
    }

}
