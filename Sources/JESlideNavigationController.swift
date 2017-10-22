//
//  JESlideNavigationController.swift
//  JESlideMenu
//
//  Created by Jasmin Eilers on 20.10.17.
//  Copyright © 2017 Jasmin Eilers. All rights reserved.
//

import UIKit

internal class JESlideNavigationController: UINavigationController {

    weak var menuDelegate: JESlideMenuDelegate?
    internal var toggleButtonColor: UIColor?
    internal var barTitleColor: UIColor?
    internal var barTintColor: UIColor?

    override func viewDidLoad() {
        super.viewDidLoad()

        // disabled pop gesture for consistency
        self.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let tintColor = barTintColor {
            self.navigationBar.barTintColor = tintColor
        }
        if let barTitleColor = barTitleColor {
            self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: barTitleColor]
        }
        if let buttonColor = toggleButtonColor {
            self.navigationBar.tintColor = buttonColor
        }
    }

    internal func setBarButtonItemWith(image: UIImage?) {
        var buttonImage = UIImage()
        if let img = image {
            buttonImage = img
        } else {
            buttonImage = createHamburgerIconImage()
        }

        let bbi = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(toggle))
        bbi.tintColor = toggleButtonColor
        topViewController?.navigationItem.leftBarButtonItem = bbi
    }

    // draw hamburger icon
    private func createHamburgerIconImage() -> UIImage {
        var image = UIImage()

        // create graphics context
        let size = CGSize(width: 24, height: 24)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        UIGraphicsPushContext(context!)

        // draw hamburger icon
        let lineWidth: CGFloat = 2.0
        let lineLength: CGFloat = size.width
        let lineColor = toggleButtonColor != nil ? toggleButtonColor! : UIColor.black
        let numberOfLines = 3
        let gap = floor(size.height / CGFloat(numberOfLines + 1))

        // draw three lines
        for lineNumber in 1...numberOfLines {
            // lineWidth
            let linePath = UIBezierPath()
            linePath.lineWidth = lineWidth

            // start point of line
            linePath.move(to: CGPoint(
                x: 0,
                y: CGFloat(lineNumber) * gap))

            // end point of line
            linePath.addLine(to: CGPoint(
                x: lineLength,
                y: CGFloat(lineNumber) * gap))

            // line color
            lineColor.setStroke()

            // draw the line
            linePath.stroke()
        }

        // convert to UIImage
        let cgimage = context!.makeImage()
        image = UIImage(cgImage: cgimage!)

        // end graphics context
        UIGraphicsPopContext()
        UIGraphicsEndImageContext()

        return image
    }

    // call delegate
    @objc func toggle() {
        menuDelegate?.toggleMenu()
    }

}
