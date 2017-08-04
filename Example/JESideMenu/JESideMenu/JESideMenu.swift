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
    // MARK: add localization for menuItems later!
    var menuItems: [String]!
    @IBInspectable public var menuItem1: String!
    @IBInspectable public var menuItem2: String!
    @IBInspectable public var menuItem3: String!
    @IBInspectable public var menuItem4: String!
    @IBInspectable public var menuItem5: String!
    @IBInspectable public var menuItem6: String!
    
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
        if menuItems.count != 0 {
            setupMenuTableViewWithItems(menuItems: menuItems)
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
            let items = [menuItem1, menuItem2, menuItem3, menuItem4, menuItem5, menuItem6]
            
            for item in items {
                if let i = item {
                    menuItems.append(i)
                }
            }
        }
    }
    
    // menu tableViewController added to view and add autolayout
    func setupMenuTableViewWithItems(menuItems: [String]) {
        menuTableView = JESideMenuTableViewController(menuItems: menuItems)
        menuTableView.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menuTableView.view)
        
        // set delegate for switching viewControllers
        menuTableView.menuDelegate = self
        
        // add fullscreen autolayout
        addConstraintsToView(view: menuTableView.view)
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
                menuNavigationController.setBarButtonItem()
                
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
    
    // fullscreen autolayout constraints via layout anchors
    func addConstraintsToView(view: UIView) {
        view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
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
                menuNavigationController.setBarButtonItem()
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
        
        // menu was closed
        if !isMenuOpen && velocity.x > 0 {   // open it
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
}

// MARK: -

class JESideMenuTableViewController: UITableViewController {
    
    let identifier = "cell"
    var menuItems = [String]()
    
    var menuDelegate: JESideMenuDelegate?
    
    init(menuItems: [String]) {
        super.init(style: .plain)
        self.menuItems = menuItems
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.reloadData()
    }
    
    // MARK: - DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        let text = menuItems[indexPath.row]
        cell.textLabel?.text = NSLocalizedString(text, comment: "translated menu text")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //menuDelegate?.showViewControllerAtIndexPath(indexPath: indexPath)
        menuDelegate?.setViewControllerAtIndexPath(indexPath: indexPath)
        menuDelegate?.toggleMenu()
    }
}

// MARK: -

class JESideNavigationController: UINavigationController {
    
    var menuDelegate: JESideMenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disabled pop gesture for consistency
        self.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func setBarButtonItem() {
        let image = createHamburgerIconImage()
        topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(toggle))
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
        let lineWidth: CGFloat = 1.0
        let lineLength: CGFloat = size.width
        let lineColor = UIColor.black
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
    
    // MARK: override container view controller methods
    
    // call delegate
    func toggle() {
        menuDelegate?.toggleMenu()
    }
}
