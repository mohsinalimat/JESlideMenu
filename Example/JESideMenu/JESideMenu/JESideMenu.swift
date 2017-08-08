//
//  JESideMenu.swift
//  JESideMenu
//
//  Created by JE on 02.08.17.
//  Copyright © 2017 JE. All rights reserved.
//

import UIKit

protocol JESideMenuDelegate {
    func toggleMenu()
    func setViewControllerAtIndexPath(indexPath: IndexPath)
}

class JESideMenu: UIViewController, JESideMenuDelegate {
    
    // Menu Items can be set in storyboard or here
    var menuItems: [String]!
    var iconImages: [UIImage?]!
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
    @IBInspectable public var buttonColor: UIColor = UIColor.black
    @IBInspectable public var titleColor: UIColor?
    @IBInspectable public var barColor: UIColor?
    
    @IBInspectable public var headerImage: UIImage?
    @IBInspectable public var imageHeight: CGFloat = 30.0
    @IBInspectable public var centerHeader: Bool = false
    
    @IBInspectable public var iconHeight: CGFloat = 20.0
    @IBInspectable public var iconWidth: CGFloat = 20.0
    
    var textColor = UIColor.black
    var backgroundColor = UIColor.white
    
    var menuNavigationController: JESideNavigationController!
    var menuTableView: JESideMenuTableViewController!
    var invisibleView: UIView!
    var tapAreaView: UIView!
    
    var leadingConstraint: NSLayoutConstraint!
    var menuIsOpenConstant: CGFloat = 280.0
    var menuIsOpenAlpha: CGFloat = 0.5
    var isMenuOpen = false
    
    var visibleViewControllerID = ""
    
    var edgeGestureRecognizer: UIPanGestureRecognizer!
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    var startPoint = CGPoint(x: 0, y: 0)
    var edgeLocation = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMenuItems()
        setupIconImages()
        if menuItems.count != 0 {
            setupMenuTableViewWithItems(menuItems: menuItems,
                                        iconImages: iconImages)
            setupNavigationController()
            setupInvisibleView()
            
            setupGestureRecognizer()
        }
    }
    
    // MARK: - Setup Menu and NavigationController
    // create array for all Storyboard IDs
    func setupMenuItems() {
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
    
    func setupIconImages() {
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
            if count == 0 && iconWidth == 20.0 {
                iconWidth = 0.0     // no icons -> discard imageWidth
            }
        }
    }
    
    // menu tableViewController added to view and add autolayout
    func setupMenuTableViewWithItems(menuItems: [String], iconImages: [UIImage?]) {
        if darkMode {
            textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        }
        
        menuTableView = JESideMenuTableViewController(menuItems: menuItems,
                                                      iconImages: iconImages,
                                                      headerImage: headerImage,
                                                      headerHeight: imageHeight,
                                                      iconHeight: iconHeight,
                                                      iconWidth: iconWidth,
                                                      textColor: textColor,
                                                      backgroundColor: backgroundColor,
                                                      centerHeader: centerHeader)
        menuTableView.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menuTableView.view)
        
        // set delegate for switching viewControllers
        menuTableView.menuDelegate = self
        
        // add fullscreen autolayout
        menuTableView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        menuTableView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        menuTableView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        menuTableView.view.widthAnchor.constraint(equalToConstant: (menuIsOpenConstant + 2.0)).isActive = true
    }
    
    // access navigationbar
    func setupNavigationController() {
        if menuItems != nil {
            // get the first item & instantiate as rootViewController
            if  let identifier = menuItems.first,
                let homeController = instantiateViewControllerFromIdentifier(identifier: identifier) {
                
                homeController.title = NSLocalizedString(identifier, comment: "translated title")
                menuNavigationController = JESideNavigationController(rootViewController: homeController)
                menuNavigationController.automaticallyAdjustsScrollViewInsets = true
                visibleViewControllerID = identifier
                
                menuNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(menuNavigationController.view)
                
                // customize navigationbar (color)
                menuNavigationController.toggleButtonColor = buttonColor
                menuNavigationController.barTitleColor = titleColor
                menuNavigationController.barTintColor = barColor
                menuNavigationController.setBarButtonItemWith(image: buttonImage)
                
                // set delegate for toggle action
                menuNavigationController.menuDelegate = self
                
                // add autolayout for Animation
                menuNavigationController.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
                menuNavigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                menuNavigationController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                leadingConstraint = menuNavigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor)
                leadingConstraint.isActive = true
                
                // border on the left
                let border = UIView()
                border.backgroundColor = UIColor.black
                border.alpha = 0.3
                
                view.addSubview(border)
                border.translatesAutoresizingMaskIntoConstraints = false
                
                border.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
                border.heightAnchor.constraint(equalTo: menuNavigationController.view.heightAnchor).isActive = true
                border.trailingAnchor.constraint(equalTo: menuNavigationController.view.leadingAnchor).isActive = true
                border.centerYAnchor.constraint(equalTo: menuNavigationController.view.centerYAnchor).isActive = true
            }
        }
    }
    
    // gray out navigationController
    func setupInvisibleView() {
        invisibleView = UIView()
        invisibleView.backgroundColor = UIColor.gray
        invisibleView.alpha = 0.0
        
        invisibleView.translatesAutoresizingMaskIntoConstraints = false
        menuNavigationController.view.addSubview(invisibleView)
        
        // autolayout
        invisibleView.leadingAnchor.constraint(equalTo: menuNavigationController.view.leadingAnchor).isActive = true
        invisibleView.topAnchor.constraint(equalTo: menuNavigationController.view.topAnchor).isActive = true
        invisibleView.trailingAnchor.constraint(equalTo: menuNavigationController.view.trailingAnchor).isActive = true
        invisibleView.bottomAnchor.constraint(equalTo: menuNavigationController.view.bottomAnchor).isActive = true
    }
    
    // pan & tap gesture recognizer for the slider
    func setupGestureRecognizer() {
        let gestureAreaView = UIView()
        gestureAreaView.backgroundColor = UIColor.clear
        menuNavigationController.view.addSubview(gestureAreaView)
        gestureAreaView.translatesAutoresizingMaskIntoConstraints = false
        
        let tapAreaView = UIView()
        tapAreaView.alpha = 0.0
        tapAreaView.backgroundColor = UIColor.clear
        menuNavigationController.view.addSubview(tapAreaView)
        tapAreaView.translatesAutoresizingMaskIntoConstraints = false

        let topConstant: CGFloat = 60.0
        
        // autolayout
        gestureAreaView.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
        gestureAreaView.topAnchor.constraint(equalTo: menuNavigationController.view.topAnchor, constant: topConstant).isActive = true
        gestureAreaView.leadingAnchor.constraint(equalTo: menuNavigationController.view.leadingAnchor).isActive = true
        gestureAreaView.bottomAnchor.constraint(equalTo: menuNavigationController.view.bottomAnchor).isActive = true
        
        tapAreaView.leadingAnchor.constraint(equalTo: gestureAreaView.trailingAnchor).isActive = true
        tapAreaView.topAnchor.constraint(equalTo: menuNavigationController.view.topAnchor).isActive = true
        tapAreaView.trailingAnchor.constraint(equalTo: menuNavigationController.view.trailingAnchor).isActive = true
        tapAreaView.bottomAnchor.constraint(equalTo: menuNavigationController.view.bottomAnchor).isActive = true

        edgeGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(edgePanGestureRecognized(recognizer:)))
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized(recognizer:)))
        gestureAreaView.addGestureRecognizer(edgeGestureRecognizer)
        tapAreaView.addGestureRecognizer(tapGestureRecognizer)
        self.tapAreaView = tapAreaView
    }
    
    // instantiate viewcontroller from storyboard and set the title
    func instantiateViewControllerFromIdentifier(identifier: String) -> UIViewController? {
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
                            self.invisibleView.alpha = alpha
                            self.tapAreaView.alpha = alpha
                            self.leadingConstraint.constant = constant
                            self.view.layoutIfNeeded()
        },
                       completion:{(finished) in
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
    // add bounce behaviour!
    func edgePanGestureRecognized(recognizer: UIPanGestureRecognizer) {
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
                self.invisibleView.alpha = alpha
            }
        case .ended:
            animateOpenCloseGesture(recognizer: recognizer)
        default:
            print("default")
        }
    }
    
    // close menu when it's open
    func tapGestureRecognized(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if isMenuOpen {
                toggleMenu()
            }
        default:
            print("default")
        }
    }
    
    func animateOpenCloseGesture(recognizer: UIPanGestureRecognizer) {
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
}

// MARK: - Menu Controller

class JESideMenuTableViewController: UITableViewController {
    
    let identifier = "cell"
    var menuItems = [String]()
    var iconImages = [UIImage?]()
    var iconHeight: CGFloat!
    var iconWidth: CGFloat!
    var textColor: UIColor!
    var backgroundColor: UIColor!
    var centerHeader = false
    
    var menuDelegate: JESideMenuDelegate?
    
    // adjust with logo-image for headerView and height
    init(menuItems: [String],
         iconImages: [UIImage?],
         headerImage: UIImage?,
         headerHeight: CGFloat,
         iconHeight: CGFloat,
         iconWidth: CGFloat,
         textColor: UIColor,
         backgroundColor: UIColor,
         centerHeader: Bool) {
        super.init(style: .plain)
        self.menuItems = menuItems
        self.iconImages = iconImages
        self.iconHeight = iconHeight
        self.iconWidth = iconWidth
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.centerHeader = centerHeader
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 54.0
        
        self.tableView.tableHeaderView = createHeaderView(image: headerImage, height: headerHeight)
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorInset.left = (18 + iconWidth + 14)
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
        tableView.register(JESideMenuTableViewCell.self,
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
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? JESideMenuTableViewCell
        cell?.setIcon(height: iconHeight, andWidth: iconWidth)
        
        let text = menuItems[indexPath.row]
        let image = iconImages[indexPath.row]
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
    func createHeaderView(image: UIImage?, height: CGFloat) -> UIView {
        let topConstant: CGFloat = 26.0
        let bottomConstant: CGFloat = 6.0
        let left: CGFloat = (18.0 + iconWidth + 14.0)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: (topConstant + height + bottomConstant)))
        let imageView = UIImageView()
        
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.image = image
        view.addSubview(imageView)
        view.backgroundColor = UIColor.clear
        
        // autolayout
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: left).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: topConstant).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomConstant).isActive = true
        if centerHeader {
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -left).isActive = true
        }
        
        return view
    }
}

// MARK: - Navigation Controller

class JESideNavigationController: UINavigationController {
    
    var menuDelegate: JESideMenuDelegate?
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
            self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: barTitleColor]
            self.navigationBar.tintColor = barTitleColor
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
    func toggle() {
        menuDelegate?.toggleMenu()
    }
}

// MARK: - 

class JESideMenuTableViewCell: UITableViewCell {
    
    var label = UILabel()
    var imageIcon = UIImageView()
    var imageHeight: CGFloat = 0.0
    var imageWidth: CGFloat = 0.0
    var didSetupConstraints = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // textStyle, color, font
        imageIcon.contentMode = .scaleAspectFit

        contentView.addSubview(label)
        contentView.addSubview(imageIcon)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setIcon(height: CGFloat, andWidth: CGFloat) {
        imageHeight = height
        imageWidth = andWidth
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        if !didSetupConstraints {
            didSetupConstraints = true
            
            label.translatesAutoresizingMaskIntoConstraints = false
            imageIcon.translatesAutoresizingMaskIntoConstraints = false
            
            // autolayout of imageIcon
            imageIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18).isActive = true
            imageIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            imageIcon.heightAnchor.constraint(equalToConstant: imageHeight).isActive = true
            imageIcon.widthAnchor.constraint(equalToConstant: imageWidth).isActive = true
            
            // autolayout label
            label.leadingAnchor.constraint(equalTo: imageIcon.trailingAnchor, constant: 14).isActive = true
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14).isActive = true
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        }
    }
}
