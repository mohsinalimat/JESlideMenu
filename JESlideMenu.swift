//
//  JESlideMenu.swift
//  JESlideMenu
//
//  Created by JE on 02.08.17.
//  Copyright © 2017 JE. All rights reserved.
//

import UIKit

protocol JESlideMenuDelegate {
    func toggleMenu()
    func setViewControllerAtIndexPath(indexPath: IndexPath)
}

class JESlideMenu: UIViewController, JESlideMenuDelegate {
    
    // Menu Items can be set in storyboard or here
    private var menuItems: [String]!
    private var iconImages: [UIImage?]!
    
    @IBInspectable public var darkMode: Bool = false
    @IBInspectable public var lightStatusBar: Bool = false
    @IBInspectable public var menuItem1: String!
    @IBInspectable public var menuItem2: String!
    @IBInspectable public var menuItem3: String!
    @IBInspectable public var menuItem4: String!
    @IBInspectable public var menuItem5: String!
    @IBInspectable public var menuItem6: String!
    @IBInspectable public var menuItem7: String!
    @IBInspectable public var menuItem8: String!
    @IBInspectable public var menuItem9: String!
    @IBInspectable public var menuItem10: String!
    
    @IBInspectable public var iconImage1: UIImage!
    @IBInspectable public var iconImage2: UIImage!
    @IBInspectable public var iconImage3: UIImage!
    @IBInspectable public var iconImage4: UIImage!
    @IBInspectable public var iconImage5: UIImage!
    @IBInspectable public var iconImage6: UIImage!
    @IBInspectable public var iconImage7: UIImage!
    @IBInspectable public var iconImage8: UIImage!
    @IBInspectable public var iconImage9: UIImage!
    @IBInspectable public var iconImage10: UIImage!
    
    @IBInspectable public var buttonImage: UIImage?
    @IBInspectable public var buttonColor: UIColor?
    @IBInspectable public var titleColor: UIColor?
    @IBInspectable public var barColor: UIColor?
    
    @IBInspectable public var headerText: String?
    @IBInspectable public var headerTextColor: UIColor = UIColor.black
    @IBInspectable public var headerFont: String = "AvenirNextCondensed-Bold"
    @IBInspectable public var headerFontSize: CGFloat = 28.0
    @IBInspectable public var headerBorder: Bool = false
    @IBInspectable public var centerHeader: Bool = false
    @IBInspectable public var image: UIImage?
    @IBInspectable public var imageHeight: CGFloat = 30.0
    
    @IBInspectable public var iconHeight: CGFloat = 20.0
    @IBInspectable public var iconWidth: CGFloat = 20.0
    
    @IBInspectable public var paddingLeft: CGFloat = 22.0
    @IBInspectable public var paddingTopBottom: CGFloat = 16.0
    
    private var iconTextGap: CGFloat = 14.0
    
    @IBInspectable public var textFontName: String?
    @IBInspectable public var textSize: CGFloat = 17.0
    @IBInspectable public var textColor: UIColor = UIColor.black
    @IBInspectable public var backgroundColor: UIColor = UIColor.clear
    
    fileprivate var menuNavigationController: JESlideNavigationController!
    fileprivate var menuTableView: JESlideMenuTableViewController!
    private var tapAreaView: UIView!
    
    private var leadingConstraint: NSLayoutConstraint!
    private var menuIsOpenConstant: CGFloat = 0.0
    private var menuIsOpenAlpha: CGFloat = 0.2
    private var isMenuOpen = false
    
    private var visibleViewControllerID = ""
    
    private var startPoint = CGPoint(x: 0, y: 0)
    private var edgeLocation = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        calculateMenuConstant()
        setupMenuItems()
        setupIconImages()
        if menuItems.count != 0 {
            setupMenuTableViewWithItems(menuItems: menuItems,
                                        iconImages: iconImages)
            setupNavigationController()
            setupGestureRecognizer()
        }
    }
    
    // calculate the menu width for iPhone/iPad
    private func calculateMenuConstant() {
        let width = self.view.bounds.width
        let adjustedWidth: CGFloat = (width * 0.8)
        menuIsOpenConstant = adjustedWidth > 280.0 ? 280.0 : adjustedWidth
    }
    
    // MARK: - Setup Menu and NavigationController
    // create array for all Storyboard IDs
    private func setupMenuItems() {
        if menuItems == nil {
            menuItems = [String]()
            let items = [menuItem1,
                         menuItem2,
                         menuItem3,
                         menuItem4,
                         menuItem5,
                         menuItem6,
                         menuItem7,
                         menuItem8,
                         menuItem9,
                         menuItem10]
            
            for item in items {
                if let i = item {
                    menuItems.append(i)
                }
            }
        }
    }
    
    private func setupIconImages() {
        if iconImages == nil {
            iconImages = [iconImage1,
                          iconImage2,
                          iconImage3,
                          iconImage4,
                          iconImage5,
                          iconImage6,
                          iconImage7,
                          iconImage8,
                          iconImage9,
                          iconImage10,
            ]
            let count = iconImages.filter({$0 != nil}).count
            
            // no icons -> discard imageWidth
            if count == 0 {
                iconWidth = 0.0
            }
        }
    }
    
    // menu tableViewController added to view and add autolayout
    private func setupMenuTableViewWithItems(menuItems: [String], iconImages: [UIImage?]) {
        if darkMode {
            textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        }
        // system blue for all buttons by default
        buttonColor = buttonColor == nil ? view.tintColor : buttonColor
        
        menuTableView = JESlideMenuTableViewController(menuItems: menuItems,
                                                       iconImages: iconImages,
                                                       headerText: headerText,
                                                       headerTextColor: headerTextColor,
                                                       headerFont: headerFont,
                                                       headerFontSize: headerFontSize,
                                                       headerImage: image,
                                                       headerHeight: imageHeight,
                                                       headerBorder: headerBorder,
                                                       cellPadding: paddingTopBottom,
                                                       cellPaddingLeft: paddingLeft,
                                                       iconTextGap: iconTextGap,
                                                       iconHeight: iconHeight,
                                                       iconWidth: iconWidth,
                                                       textFontName: textFontName,
                                                       textSize: textSize,
                                                       textColor: textColor,
                                                       backgroundColor: backgroundColor,
                                                       centerHeader: centerHeader)
        menuTableView.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(menuTableView)
        view.addSubview(menuTableView.view)
        
        // set delegate for switching viewControllers
        menuTableView.menuDelegate = self
        
        // add fullscreen autolayout
        NSLayoutConstraint.activate([
            menuTableView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuTableView.view.topAnchor.constraint(equalTo: view.topAnchor),
            menuTableView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            menuTableView.view.widthAnchor.constraint(equalToConstant: (menuIsOpenConstant + 2.0))
            ])
        
        menuTableView.didMove(toParentViewController: self)
    }
    
    // access navigationbar
    private func setupNavigationController() {
        if menuItems != nil {
            // get the first item & instantiate as rootViewController
            if  let identifier = menuItems.first,
                let homeController = instantiateViewControllerFromIdentifier(identifier: identifier) {
                
                homeController.title = NSLocalizedString(identifier, comment: "translated title")
                menuNavigationController = JESlideNavigationController(rootViewController: homeController)
                menuNavigationController.automaticallyAdjustsScrollViewInsets = true
                menuNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
                visibleViewControllerID = identifier
                
                self.addChildViewController(menuNavigationController)
                view.addSubview(menuNavigationController.view)
                
                // customize navigationbar (color)
                menuNavigationController.toggleButtonColor = buttonColor
                menuNavigationController.barTitleColor = titleColor
                menuNavigationController.barTintColor = barColor
                menuNavigationController.setBarButtonItemWith(image: buttonImage)
                
                // set delegate for toggle action
                menuNavigationController.menuDelegate = self
                
                // add autolayout for Animation
                leadingConstraint = menuNavigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor)
                
                NSLayoutConstraint.activate([
                    menuNavigationController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
                    menuNavigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    menuNavigationController.view.topAnchor.constraint(equalTo: view.topAnchor),
                    leadingConstraint
                    ])
                
                // border on the left
                let border = UIView()
                border.backgroundColor = UIColor.black
                border.alpha = 0.3
                
                view.addSubview(border)
                border.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    border.widthAnchor.constraint(equalToConstant: 1.0),
                    border.heightAnchor.constraint(equalTo: menuNavigationController.view.heightAnchor),
                    border.trailingAnchor.constraint(equalTo: menuNavigationController.view.leadingAnchor),
                    border.centerYAnchor.constraint(equalTo: menuNavigationController.view.centerYAnchor)
                    ])
                
                menuNavigationController.didMove(toParentViewController: self)
            }
        }
    }

    // pan & tap gesture recognizer for the slider
    private func setupGestureRecognizer() {
        let swipeGestureAreaView = UIView()
        swipeGestureAreaView.backgroundColor = UIColor.clear
        swipeGestureAreaView.translatesAutoresizingMaskIntoConstraints = false
        menuNavigationController.view.addSubview(swipeGestureAreaView)
        
        let tapAreaView = UIView()
        tapAreaView.alpha = 0.0
        tapAreaView.backgroundColor = UIColor.black
        tapAreaView.translatesAutoresizingMaskIntoConstraints = false
        menuNavigationController.view.addSubview(tapAreaView)

        let topConstant: CGFloat = 60.0
        
        // autolayout
        NSLayoutConstraint.activate([
            swipeGestureAreaView.widthAnchor.constraint(equalToConstant: 22.0),
            swipeGestureAreaView.topAnchor.constraint(equalTo: menuNavigationController.view.topAnchor, constant: topConstant),
            swipeGestureAreaView.leadingAnchor.constraint(equalTo: menuNavigationController.view.leadingAnchor),
            swipeGestureAreaView.bottomAnchor.constraint(equalTo: menuNavigationController.view.bottomAnchor),
            tapAreaView.leadingAnchor.constraint(equalTo: menuNavigationController.view.leadingAnchor),
            tapAreaView.topAnchor.constraint(equalTo: menuNavigationController.view.topAnchor),
            tapAreaView.trailingAnchor.constraint(equalTo: menuNavigationController.view.trailingAnchor),
            tapAreaView.bottomAnchor.constraint(equalTo: menuNavigationController.view.bottomAnchor)
            ])

        let edgeGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(edgePanGestureRecognized(recognizer:)))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized(recognizer:)))
        let swipeGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(edgePanGestureRecognized(recognizer:)))
        
        swipeGestureAreaView.addGestureRecognizer(edgeGestureRecognizer)
        tapAreaView.addGestureRecognizer(tapGestureRecognizer)
        tapAreaView.addGestureRecognizer(swipeGestureRecognizer)

        self.tapAreaView = tapAreaView
    }
    
    // instantiate viewcontroller from storyboard and set the title
    private func instantiateViewControllerFromIdentifier(identifier: String) -> UIViewController? {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: identifier) {
            if let navigation = controller as? UINavigationController,
                let root = navigation.topViewController {
                    return root
            }
            return controller
        }
        return nil
    }
    
    // toggle the menu
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
                       completion:{ finished in
                            self.isMenuOpen = !self.isMenuOpen
        })
    }
    
    // set viewController in navigationController
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
    
    // open and close menu
    @objc func edgePanGestureRecognized(recognizer: UIPanGestureRecognizer) {
        let currentPoint = recognizer.location(in: view)
        switch recognizer.state {
        case .began:
            startPoint = currentPoint
            edgeLocation.x = self.leadingConstraint.constant
        case .changed:
            let difference = round(currentPoint.x - startPoint.x)
            let newConstant = round(edgeLocation.x + difference)
            if newConstant >= 0 && newConstant <= menuIsOpenConstant {
                self.leadingConstraint.constant = round(edgeLocation.x + difference)
                let alpha = round(round(edgeLocation.x + difference) / menuIsOpenConstant * menuIsOpenAlpha * 10.0) / 10.0 // min: 0.0 max: 0.5
                self.tapAreaView.alpha = alpha
            }
        case .ended:
            animateOpenCloseGesture(recognizer: recognizer)
        default:
            print("default")
        }
    }
    
    // close menu when it's open
    @objc func tapGestureRecognized(recognizer: UITapGestureRecognizer) {
        
        if isMenuOpen {
            switch recognizer.state {
            case .ended:
                toggleMenu()
            default:
                print("default")
            }
        }
    }
    
    private func animateOpenCloseGesture(recognizer: UIPanGestureRecognizer) {
        let velocity = recognizer.velocity(in: view)
        let locationX = self.leadingConstraint.constant
        let percent:CGFloat = 0.4 * menuIsOpenConstant
        
        // menu was closed
        if !isMenuOpen && velocity.x < 100.0 && locationX < percent { // close when opened too slowly
            isMenuOpen = true
            toggleMenu()
        } else if !isMenuOpen && velocity.x > 0 {   // open it
            toggleMenu()
        } else if !isMenuOpen && velocity.x < 0 {   // close it
            isMenuOpen = true
            toggleMenu()
        } else if isMenuOpen && velocity.x > 0 {    // open it
            isMenuOpen = false
            toggleMenu()
        } else {                                // close it
            isMenuOpen = true
            toggleMenu()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if lightStatusBar {
            return .lightContent
        }
        return .default
    }
    
    // forward rotation notification
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        menuNavigationController.willTransition(to: newCollection, with: coordinator)
    }
    
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

// MARK: - Menu Controller

private class JESlideMenuTableViewController: UITableViewController {
    
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
    
    var menuDelegate: JESlideMenuDelegate?
    
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? JESlideMenuTableViewCell
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

// MARK: - Navigation Controller

private class JESlideNavigationController: UINavigationController {
    
    var menuDelegate: JESlideMenuDelegate?
    var toggleButtonColor: UIColor?
    var barTitleColor: UIColor?
    var barTintColor: UIColor?
    
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
    
    func setBarButtonItemWith(image: UIImage?) {
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
    func createHamburgerIconImage() -> UIImage {
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

// MARK: - 

private class JESlideMenuTableViewCell: UITableViewCell {
    
    var label = UILabel()
    var imageIcon = UIImageView()
    var imageHeight: CGFloat = 0.0
    var imageWidth: CGFloat = 0.0
    var didSetupConstraints = false
    var cellPadding: CGFloat = 0.0
    var cellPaddingLeft: CGFloat = 0.0
    var iconTextGap: CGFloat = 0.0
    
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
    
    func setIcon(height: CGFloat, andWidth: CGFloat) {
        imageHeight = height
        imageWidth = andWidth
    }
    
    func setCell(padding: CGFloat, leftPadding: CGFloat, andIconGap: CGFloat) {
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
