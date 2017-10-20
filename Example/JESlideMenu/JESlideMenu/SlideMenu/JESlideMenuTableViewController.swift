//
//  JESlideMenuTableViewController.swift
//  JESlideMenu
//
//  Created by JE on 20.10.17.
//  Copyright © 2017 JE. All rights reserved.
//

import UIKit

class JESlideMenuTableViewController: UITableViewController {

    let identifier = "cell"
    var menuItems = [String]()
    var iconImages = [UIImage?]()
    var iconHeight: CGFloat!
    var iconWidth: CGFloat!
    var textColor: UIColor!
    var textFontName: String?
    var textSize: CGFloat?
    var backgroundColor: UIColor!
    var centerHeader = false
    let headerTop: CGFloat = 26.0
    let headerBottom: CGFloat = 10.0
    var cellPadding: CGFloat = 0.0
    var cellPaddingLeft: CGFloat = 0.0
    var iconTextGap: CGFloat = 0.0

    weak var menuDelegate: JESlideMenuDelegate?

    init(menuItems: [String], iconImages: [UIImage?]) {
        super.init(style: .plain)
        self.menuItems = menuItems
        self.iconImages = iconImages
    }

    // adjust with logo-image for headerView and height
    init(menuItems: [String],
         iconImages: [UIImage?],
         headerText: String?,
         headerTextColor: UIColor?,
         headerFont: String,
         headerFontSize: CGFloat,
         headerImage: UIImage?,
         headerHeight: CGFloat,
         headerBorder: Bool,
         cellPadding: CGFloat,
         cellPaddingLeft: CGFloat,
         iconTextGap: CGFloat,
         iconHeight: CGFloat,
         iconWidth: CGFloat,
         textFontName: String?,
         textSize: CGFloat?,
         textColor: UIColor,
         backgroundColor: UIColor,
         centerHeader: Bool) {
        super.init(style: .plain)
        self.menuItems = menuItems
        self.iconImages = iconImages
        self.iconHeight = iconHeight
        self.iconWidth = iconWidth
        self.cellPadding = cellPadding
        self.cellPaddingLeft = cellPaddingLeft
        self.iconTextGap = iconTextGap
        self.textColor = textColor
        self.textFontName = textFontName
        self.textSize = textSize
        self.backgroundColor = backgroundColor
        self.centerHeader = centerHeader
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 54.0

        self.tableView.tableHeaderView = createHeaderView(image: headerImage,
                                                          text: headerText,
                                                          textColor: headerTextColor,
                                                          font: headerFont,
                                                          fontSize:  headerFontSize,
                                                          height: headerHeight,
                                                          top: headerTop,
                                                          left: cellPaddingLeft,
                                                          bottom: headerBottom,
                                                          withBorder: headerBorder)
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorInset.left = iconWidth == 0.0 ? cellPaddingLeft : (cellPaddingLeft + iconWidth + iconTextGap)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.backgroundColor = backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(JESlideMenuTableViewCell.self,
                           forCellReuseIdentifier: identifier)
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                                 for: indexPath) as? JESlideMenuTableViewCell
        cell?.setIcon(height: iconHeight, andWidth: iconWidth)
        cell?.setCell(padding: cellPadding, leftPadding: cellPaddingLeft, andIconGap: iconTextGap)

        let text = menuItems[indexPath.row]
        let image = iconImages[indexPath.row]

        if  let name = textFontName,
            let size = textSize {
            cell?.label.font = UIFont(name: name, size: size)
        }
        cell?.label.text = NSLocalizedString(text, comment: "translated menu text")
        cell?.label.textColor = textColor
        cell?.imageIcon.image = image
        cell?.setNeedsUpdateConstraints()

        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        menuDelegate?.setViewControllerAtIndexPath(indexPath: indexPath)
        menuDelegate?.toggleMenu()
    }

    // table header view
    func createHeaderView(image: UIImage?,
                          text: String?,
                          textColor: UIColor?,
                          font: String,
                          fontSize: CGFloat,
                          height: CGFloat,
                          top: CGFloat,
                          left: CGFloat,
                          bottom: CGFloat,
                          withBorder: Bool) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: (top + height + bottom)))
        view.backgroundColor = UIColor.clear

        // autolayout
        if image != nil {
            let imageView = UIImageView()
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            imageView.image = image
            view.addSubview(imageView)

            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: left).isActive = true
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: top).isActive = true
            if withBorder {
                imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottom).isActive = true
            } else {
                imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            }

            if centerHeader {   // center header or set width to aspect ratio of height
                imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -left).isActive = true
            } else {
                let fittingWidth = imageView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).width
                let fittingHeight = imageView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
                let aspectRatio = round(fittingWidth/fittingHeight * 10.0) / 10.0
                let newWidth = withBorder ? height * aspectRatio : (height + bottom) * aspectRatio
                imageView.widthAnchor.constraint(equalToConstant: newWidth).isActive = true
            }
        }

        if withBorder {
            let bottomLine = UIView()
            bottomLine.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            bottomLine.alpha = 0.5
            bottomLine.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bottomLine)

            NSLayoutConstraint.activate([
                bottomLine.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: left),
                bottomLine.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                bottomLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                bottomLine.heightAnchor.constraint(equalToConstant: 1.0)
                ])
        }

        // only add text when there's no image
        if text != nil && image == nil {
            let label = UILabel()
            label.font = UIFont(name: font, size: fontSize)
            label.text = NSLocalizedString(text!, comment: "")
            label.textColor = textColor
            view.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false

            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: left).isActive = true
            if withBorder {
                label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottom).isActive = true
            } else {
                label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            }
            if centerHeader {   // center headline text
                label.textAlignment = .center
                label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -left).isActive = true
            }
        }

        return view
    }
}
