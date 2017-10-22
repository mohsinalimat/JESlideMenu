//
//  JESlideMenuTableViewCell.swift
//  JESlideMenu
//
//  Created by Jasmin Eilers on 20.10.17.
//  Copyright © 2017 Jasmin Eilers. All rights reserved.
//

import UIKit

internal class JESlideMenuTableViewCell: UITableViewCell {

    internal var label = UILabel()
    internal var imageIcon = UIImageView()
    private var imageHeight: CGFloat = 0.0
    private var imageWidth: CGFloat = 0.0
    private var didSetupConstraints = false
    private var cellPadding: CGFloat = 0.0
    private var cellPaddingLeft: CGFloat = 0.0
    private var iconTextGap: CGFloat = 0.0

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // textStyle, color, font
        imageIcon.contentMode = .scaleAspectFit
        imageIcon.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear

        // tableview cell contentView
        contentView.addSubview(label)
        contentView.addSubview(imageIcon)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func setIcon(height: CGFloat, andWidth: CGFloat) {
        imageHeight = height
        imageWidth = andWidth
    }

    internal func setCell(padding: CGFloat, leftPadding: CGFloat, andIconGap: CGFloat) {
        cellPaddingLeft = leftPadding
        cellPadding = padding
        iconTextGap = andIconGap
    }

    override func updateConstraints() {
        super.updateConstraints()
        if !didSetupConstraints {
            didSetupConstraints = true

            label.translatesAutoresizingMaskIntoConstraints = false
            imageIcon.translatesAutoresizingMaskIntoConstraints = false

            // autolayout of imageIcon
            NSLayoutConstraint.activate([
                imageIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: cellPaddingLeft),
                imageIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                imageIcon.heightAnchor.constraint(equalToConstant: imageHeight),
                imageIcon.widthAnchor.constraint(equalToConstant: imageWidth)
                ])

            // autolayout label
            if imageWidth == 0.0 {
                label.leadingAnchor.constraint(equalTo: imageIcon.trailingAnchor).isActive = true
            } else {
                label.leadingAnchor.constraint(equalTo: imageIcon.trailingAnchor, constant: iconTextGap).isActive = true
            }

            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: cellPadding),
                label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -cellPadding),
                label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -cellPadding)
                ])
        }
    }
}
