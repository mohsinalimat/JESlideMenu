//
//  JESlideMenu.swift
//  JESlideMenu
//
//  Created by Jasmin Eilers on 02.08.17.
//  Copyright © 2017 Jasmin Eilers. All rights reserved.
//

import UIKit

protocol JESlideMenuDelegate: class {
    func toggleMenu()
    func setViewControllerAtIndexPath(indexPath: IndexPath)
}

class JESlideMenuController: UIViewController {

    // Menu Items can be set in storyboard or here
    internal var menuItems: [NSString]!
    private var iconImages: [UIImage?]!

    @IBInspectable public var darkMode: Bool = false
    @IBInspectable public var lightStatusBar: Bool = false
    @IBInspectable public var menuItem1: NSString!
    @IBInspectable public var menuItem2: NSString!
    @IBInspectable public var menuItem3: NSString!
    @IBInspectable public var menuItem4: NSString!
    @IBInspectable public var menuItem5: NSString!
    @IBInspectable public var menuItem6: NSString!
    @IBInspectable public var menuItem7: NSString!
    @IBInspectable public var menuItem8: NSString!
    @IBInspectable public var menuItem9: NSString!
    @IBInspectable public var menuItem10: NSString!

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

    @IBInspectable public var headerText: String = ""
    @IBInspectable public var headerTextColor: UIColor = UIColor.black
    @IBInspectable public var headerFont: String = "AvenirNextCondensed-Bold"
    @IBInspectable public var headerFontSize: CGFloat = 28.0
    @IBInspectable public var headerBorder: Bool = false
    @IBInspectable public var centerHeader: Bool = false
    @IBInspectable public var headerImage: UIImage?
    @IBInspectable public var headerHeight: CGFloat = 40.0

    @IBInspectable public var iconHeight: CGFloat = 20.0
    @IBInspectable public var iconWidth: CGFloat = 20.0

    @IBInspectable public var paddingLeft: CGFloat = 22.0
    @IBInspectable public var paddingTopBottom: CGFloat = 16.0

    private var iconTextGap: CGFloat = 14.0

    @IBInspectable public var textFontName: String?
    @IBInspectable public var textSize: CGFloat = 17.0
    @IBInspectable public var textColor: UIColor = UIColor.black
    @IBInspectable public var backgroundColor: UIColor = UIColor.clear

    internal var menuNavigationController: JESlideNavigationController!
    private var menuTableView: JESlideMenuTableViewController!
    internal var tapAreaView: UIView!

    internal var leadingConstraint: NSLayoutConstraint!
    internal var menuIsOpenConstant: CGFloat = 0.0
    internal var menuIsOpenAlpha: CGFloat = 0.2
    internal var isMenuOpen = false

    internal var visibleViewControllerID: NSString = ""
    internal var viewcontrollerCache = NSCache<NSString, UIViewController>()

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
            menuItems = [NSString]()
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
                          iconImage10
            ]
            let count = iconImages.filter({$0 != nil}).count

            // no icons -> discard imageWidth
            if count == 0 {
                iconWidth = 0.0
            }
        }
    }

    // menu tableViewController added to view and add autolayout
    private func setupMenuTableViewWithItems(menuItems: [NSString], iconImages: [UIImage?]) {
        if darkMode {
            textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        }
        // system blue for all buttons by default
        buttonColor = buttonColor == nil ? view.tintColor : buttonColor

        let menuConfig = createMenuConfiguration(menuItemNames: menuItems, iconImages: iconImages)
        menuTableView = JESlideMenuTableViewController(configuration: menuConfig)

        menuTableView.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(menuTableView)
        view.addSubview(menuTableView.view)

        // set delegate for switching viewControllers
        menuTableView.delegate = self

        // add fullscreen autolayout
        NSLayoutConstraint.activate([
            menuTableView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuTableView.view.topAnchor.constraint(equalTo: view.topAnchor),
            menuTableView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            menuTableView.view.widthAnchor.constraint(equalToConstant: (menuIsOpenConstant + 2.0))
            ])

        menuTableView.didMove(toParentViewController: self)
    }

    // configure menu tableView controller
    private func createMenuConfiguration(menuItemNames: [NSString],
                                         iconImages: [UIImage?]) -> MenuConfiguration {

        let menuConfig = MenuConfiguration()

        menuConfig.menuItemNames = menuItemNames
        menuConfig.iconImages = iconImages
        menuConfig.headerText = headerText
        menuConfig.headerTextColor = headerTextColor
        menuConfig.headerFont = headerFont
        menuConfig.headerFontSize = headerFontSize
        menuConfig.headerImage = headerImage
        menuConfig.headerHeight = headerHeight
        menuConfig.headerBorder = headerBorder
        menuConfig.cellPadding = paddingTopBottom
        menuConfig.cellPaddingLeft = paddingLeft
        menuConfig.iconTextGap = iconTextGap
        menuConfig.iconHeight = iconHeight
        menuConfig.iconWidth = iconWidth
        menuConfig.textFontName = textFontName
        menuConfig.textSize = textSize
        menuConfig.textColor = textColor
        menuConfig.backgroundColor = backgroundColor
        menuConfig.centerHeader = centerHeader

        return menuConfig
    }

    // access navigationbar
    private func setupNavigationController() {
        if menuItems != nil {
            // get the first item & instantiate as rootViewController
            if  let identifier = menuItems.first,
                let homeController = instantiateViewControllerFromIdentifier(identifier: identifier) {

                homeController.title = NSLocalizedString(identifier as String, comment: "translated title")
                menuNavigationController = JESlideNavigationController(rootViewController: homeController)
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
            swipeGestureAreaView.topAnchor.constraint(equalTo: menuNavigationController.view.topAnchor,
                                                      constant: topConstant),
            swipeGestureAreaView.leadingAnchor.constraint(equalTo: menuNavigationController.view.leadingAnchor),
            swipeGestureAreaView.bottomAnchor.constraint(equalTo: menuNavigationController.view.bottomAnchor),
            tapAreaView.leadingAnchor.constraint(equalTo: menuNavigationController.view.leadingAnchor),
            tapAreaView.topAnchor.constraint(equalTo: menuNavigationController.view.topAnchor),
            tapAreaView.trailingAnchor.constraint(equalTo: menuNavigationController.view.trailingAnchor),
            tapAreaView.bottomAnchor.constraint(equalTo: menuNavigationController.view.bottomAnchor)
            ])

        let edgeGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                           action: #selector(edgePanGestureRecognized(recognizer:)))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(tapGestureRecognized(recognizer:)))
        let swipeGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                            action: #selector(edgePanGestureRecognized(recognizer:)))

        swipeGestureAreaView.addGestureRecognizer(edgeGestureRecognizer)
        tapAreaView.addGestureRecognizer(tapGestureRecognizer)
        tapAreaView.addGestureRecognizer(swipeGestureRecognizer)

        self.tapAreaView = tapAreaView
    }

    // instantiate viewcontroller from storyboard and set the title
    private func instantiateViewControllerFromIdentifier(identifier: NSString) -> UIViewController? {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: identifier as String) {
            if let navigation = controller as? UINavigationController,
                let root = navigation.topViewController {
                    viewcontrollerCache.setObject(root, forKey: identifier)
                    return root
            }
            viewcontrollerCache.setObject(controller, forKey: identifier)
            return controller
        }
        return nil
    }

    // open and close menu
    @objc private func edgePanGestureRecognized(recognizer: UIPanGestureRecognizer) {
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

                // min: 0.0 max: 0.5
                let alpha = round(round(edgeLocation.x + difference) /
                    menuIsOpenConstant * menuIsOpenAlpha * 10.0) / 10.0
                self.tapAreaView.alpha = alpha
            }
        case .ended:
            animateOpenCloseGesture(recognizer: recognizer)
        default:
            print("default")
        }
    }

    // close menu when it's open
    @objc private func tapGestureRecognized(recognizer: UITapGestureRecognizer) {

        switch recognizer.state {
        case .ended:
            toggleMenu()
        default:
            print("default")
        }
    }

    private func animateOpenCloseGesture(recognizer: UIPanGestureRecognizer) {
        let velocity = recognizer.velocity(in: view)
        let locationX = self.leadingConstraint.constant
        let percent: CGFloat = 0.4 * menuIsOpenConstant

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
    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        menuNavigationController.willTransition(to: newCollection, with: coordinator)
    }

}
