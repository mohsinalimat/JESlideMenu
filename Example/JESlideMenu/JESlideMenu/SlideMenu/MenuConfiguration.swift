//
//  MenuConfiguration.swift
//  JESlideMenu
//
//  Created by JE on 20.10.17.
//  Copyright © 2017 JE. All rights reserved.
//

import UIKit

class MenuConfiguration {
    var menuItemNames = [NSString]()
    var iconImages = [UIImage?]()
    var headerText: String = ""
    var headerTextColor: UIColor?
    var headerFont = ""
    var headerFontSize: CGFloat = 0.0
    var headerImage: UIImage?
    var headerHeight: CGFloat = 0.0
    var headerBorder = false
    var cellPadding: CGFloat = 0.0
    var cellPaddingLeft: CGFloat = 0.0
    var iconTextGap: CGFloat = 0.0
    var iconHeight: CGFloat = 0.0
    var iconWidth: CGFloat = 0.0
    var textFontName: String?
    var textSize: CGFloat?
    var textColor = UIColor.black
    var backgroundColor = UIColor.clear
    var centerHeader = false
}
