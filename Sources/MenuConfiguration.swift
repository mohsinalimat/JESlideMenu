//
//  MenuConfiguration.swift
//  JESlideMenu
//
//  Created by Jasmin Eilers on 20.10.17.
//  Copyright © 2017 Jasmin Eilers. All rights reserved.
//

import UIKit

internal class MenuConfiguration {
    internal var menuItemNames = [NSString]()
    internal var iconImages = [UIImage?]()
    internal var headerText: String = ""
    internal var headerTextColor: UIColor?
    internal var headerFont = ""
    internal var headerFontSize: CGFloat = 0.0
    internal var headerImage: UIImage?
    internal var headerHeight: CGFloat = 0.0
    internal var headerBorder = false
    internal var cellPadding: CGFloat = 0.0
    internal var cellPaddingLeft: CGFloat = 0.0
    internal var iconTextGap: CGFloat = 0.0
    internal var iconHeight: CGFloat = 0.0
    internal var iconWidth: CGFloat = 0.0
    internal var textFontName: String?
    internal var textSize: CGFloat?
    internal var textColor = UIColor.black
    internal var backgroundColor = UIColor.clear
    internal var centerHeader = false
}
