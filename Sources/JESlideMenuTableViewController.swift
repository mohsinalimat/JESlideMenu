//
//  JESlideMenuTableViewController.swift
//  JESlideMenu
//
//  Created by Jasmin Eilers on 20.10.17.
//  Copyright © 2017 Jasmin Eilers. All rights reserved.
//

import UIKit

internal class JESlideMenuTableViewController: UITableViewController {

    private let identifier = "cell"
    private var menuItems = [NSString]()
    private var iconImages = [UIImage?]()
    private var iconHeight: CGFloat!
    private var iconWidth: CGFloat!
    private var textColor: UIColor!
    private var textFontName: String?
    private var textSize: CGFloat?
    private var backgroundColor: UIColor!
    private let headerTop: CGFloat = 26.0
    private let headerBottom: CGFloat = 10.0
    private var cellPadding: CGFloat = 0.0
    private var cellPaddingLeft: CGFloat = 0.0
    private var iconTextGap: CGFloat = 0.0

    weak var delegate: JESlideMenuDelegate?

    // adjust with logo-image for headerView and height
    init(configuration: MenuConfiguration) {
        super.init(style: .plain)

        menuItems = configuration.menuItemNames
        iconImages = configuration.iconImages
        iconHeight = configuration.iconHeight
        iconWidth = configuration.iconWidth
        cellPadding = configuration.cellPadding
        cellPaddingLeft = configuration.cellPaddingLeft
        iconTextGap = configuration.iconTextGap
        textColor = configuration.textColor
        textFontName = configuration.textFontName
        textSize = configuration.textSize
        backgroundColor = configuration.backgroundColor

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 54.0

        let headerConfig = HeaderConfiguration()
        headerConfig.image = configuration.headerImage
        headerConfig.text = configuration.headerText
        headerConfig.textColor = configuration.headerTextColor
        headerConfig.font = configuration.headerFont
        headerConfig.fontSize = configuration.headerFontSize
        headerConfig.height = configuration.headerHeight
        headerConfig.left = configuration.cellPaddingLeft
        headerConfig.withBorder = configuration.headerBorder
        headerConfig.centerHeader = configuration.centerHeader
        headerConfig.top = headerTop
        headerConfig.bottom = headerBottom

        tableView.tableHeaderView = createHeaderView(configuration: headerConfig)

        tableView.tableFooterView = UIView()
        tableView.separatorInset.left = iconWidth == 0.0 ? cellPaddingLeft : (cellPaddingLeft + iconWidth + iconTextGap)
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
        cell?.label.text = NSLocalizedString(text as String, comment: "translated menu text")
        cell?.label.textColor = textColor
        cell?.imageIcon.image = image
        cell?.setNeedsUpdateConstraints()

        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.setViewControllerAtIndexPath(indexPath: indexPath)
        delegate?.toggleMenu()
    }

    // table header view

    private func createHeaderView(configuration: HeaderConfiguration) -> UIView {
        let height = configuration.top + configuration.height + configuration.bottom
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: height))
        view.backgroundColor = UIColor.clear

        // autolayout
        if configuration.image != nil {
            let imageView = UIImageView()
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            imageView.image = configuration.image
            view.addSubview(imageView)

            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                               constant: configuration.left).isActive = true
            imageView.topAnchor.constraint(equalTo: view.topAnchor,
                                           constant: configuration.top).isActive = true
            if configuration.withBorder {
                imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                  constant: -configuration.bottom).isActive = true
            } else {
                imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            }

            // center header or set width to aspect ratio of height
            if configuration.centerHeader {
                imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                    constant: -configuration.left).isActive = true
            } else {
                let fittingWidth = imageView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).width
                let fittingHeight = imageView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
                let aspectRatio = round(fittingWidth/fittingHeight * 10.0) / 10.0

                let widthWithBorder = configuration.height * aspectRatio
                let widthWithoutBorder = (configuration.height + configuration.bottom) * aspectRatio
                let newWidth = configuration.withBorder ? widthWithBorder : widthWithoutBorder
                imageView.widthAnchor.constraint(equalToConstant: newWidth).isActive = true
            }
        }

        if configuration.withBorder {
            let bottomLine = UIView()
            bottomLine.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            bottomLine.alpha = 0.5
            bottomLine.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bottomLine)

            NSLayoutConstraint.activate([
                bottomLine.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                    constant: configuration.left),
                bottomLine.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                bottomLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                bottomLine.heightAnchor.constraint(equalToConstant: 1.0)
                ])
        }

        // only add text when there's no image
        if !configuration.text.isEmpty && configuration.image == nil {
            let label = UILabel()
            label.font = UIFont(name: configuration.font,
                                size: configuration.fontSize)
            label.text = NSLocalizedString(configuration.text, comment: "")
            label.textColor = textColor
            view.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false

            label.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                           constant: configuration.left).isActive = true
            if configuration.withBorder {
                label.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                              constant: -configuration.bottom).isActive = true
            } else {
                label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            }

            if configuration.centerHeader {   // center headline text
                label.textAlignment = .center
                label.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                constant: -configuration.left).isActive = true
            }
        }

        return view
    }
}
