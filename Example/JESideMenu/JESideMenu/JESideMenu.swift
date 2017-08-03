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
    func showViewControllerAtIndexPath(indexPath: IndexPath)
}

class JESideMenu: UIViewController, JESideMenuDelegate {
    
    // Menu Items can be set in storyboard or here
    // MARK: add localization for menuItems later!
    var menuItems: [String]!
    @IBInspectable public var menuItem1: String!
    @IBInspectable public var menuItem2: String!
    @IBInspectable public var menuItem3: String!
    
    var menuNavigationController: JESideNavigationController!
    var menuTableView: JESideMenuTableViewController!
    var invisibleView: UIView!
    
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
        setupMenuTableViewWithItems(menuItems: menuItems)
        setupNavigationController()
        setupInvisibleView()
        
        setupGestureRecognizer()
    }
    
    // MARK: - Setup Menu and NavigationController
    // create array for all Storyboard IDs
    func setupMenuItems() {
        if menuItems == nil {
            menuItems = [String]()
            let items = [menuItem1, menuItem2, menuItem3]
            
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
                menuNavigationController = JESideNavigationController(rootViewController: homeController)
                menuNavigationController.automaticallyAdjustsScrollViewInsets = true
                visibleViewControllerID = identifier
                
                menuNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(menuNavigationController.view)
                
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
        invisibleView.backgroundColor = UIColor.white
        invisibleView.alpha = 0.0
        
        invisibleView.translatesAutoresizingMaskIntoConstraints = false
        menuNavigationController.view.addSubview(invisibleView)
        
        // autolayout
        invisibleView.leadingAnchor.constraint(equalTo: menuNavigationController.view.leadingAnchor).isActive = true
        invisibleView.topAnchor.constraint(equalTo: menuNavigationController.view.topAnchor, constant: 64).isActive = true
        invisibleView.trailingAnchor.constraint(equalTo: menuNavigationController.view.trailingAnchor).isActive = true
        invisibleView.bottomAnchor.constraint(equalTo: menuNavigationController.view.bottomAnchor).isActive = true
    }
    
    func setupGestureRecognizer() {
        let gestureAreaView = UIView()
        gestureAreaView.alpha = 0.1
        //gestureAreaView.backgroundColor = UIColor.white
        menuNavigationController.view.addSubview(gestureAreaView)
        gestureAreaView.translatesAutoresizingMaskIntoConstraints = false
        
        // autolayout
        gestureAreaView.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
        gestureAreaView.topAnchor.constraint(equalTo: menuNavigationController.view.topAnchor, constant: 60).isActive = true
        gestureAreaView.leadingAnchor.constraint(equalTo: menuNavigationController.view.leadingAnchor).isActive = true
        gestureAreaView.bottomAnchor.constraint(equalTo: menuNavigationController.view.bottomAnchor).isActive = true
        
        edgeGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(edgePanGestureRecognized(recognizer:)))
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized(recognizer:)))
        gestureAreaView.addGestureRecognizer(edgeGestureRecognizer)
        menuNavigationController.view.addGestureRecognizer(tapGestureRecognizer)
        
        //menuNavigationController.view.addGestureRecognizer(edgeGestureRecognizer)
        //menuNavigationController.view.addGestureRecognizer(tapGestureRecognizer)
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
            controller.title = identifier
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
                            self.leadingConstraint.constant = constant
                            self.view.layoutIfNeeded()
        },
                       completion:{(finished) in
                            self.isMenuOpen = !self.isMenuOpen
        })

    }
    
    // set viewController in navigationController
    func showViewControllerAtIndexPath(indexPath: IndexPath) {
        let identifier = menuItems[indexPath.row]
        
        if visibleViewControllerID != identifier {
            // load view controller(s)
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: identifier) {
                controller.title = identifier
                controller.automaticallyAdjustsScrollViewInsets = true
                // if controller is UINavigationController {} //fetch children
                menuNavigationController.setViewControllers([controller], animated: false)
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
        let threshold: CGFloat = 40.0
        print(velocity.x)
        
        // menu was closed
        if !isMenuOpen && velocity.x > 0 {
            toggleMenu()
        } else if !isMenuOpen && velocity.x < 0 {
            isMenuOpen = true
            toggleMenu()
        } else if isMenuOpen && velocity.x > 0 {
            isMenuOpen = false
            toggleMenu()
        } else {
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
        
        cell.textLabel?.text = menuItems[indexPath.row]
        
        return cell
    }
    
    // type of cell
    // enum -> Profil cell or MenuItem
    func configureCell(cell: UITableViewCell, row: Int) {
    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        menuDelegate?.showViewControllerAtIndexPath(indexPath: indexPath)
        menuDelegate?.toggleMenu()
    }
    
    // delegate methods
    // selected row at indexPath
    
    // tableview style
    
    // MARK: - toggle animation
}

// MARK: -

class JESideNavigationController: UINavigationController {
    
    var menuDelegate: JESideMenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // override left barbuttonitem  with hamburger toggle button
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

// MARK: - Extensions

@objc
enum LayoutAnchorType: Int {
    case top = 1
    case leading
    case trailing
    case bottom
    case centerX
    case centerY
    case left
    case right
}

extension NSLayoutAnchor {
    func constraintEqualToAnchor(anchor: NSLayoutAnchor!, constant:CGFloat, identifier: LayoutAnchorType) -> NSLayoutConstraint {
        let constraint = self.constraint(equalTo: anchor, constant: constant)
        constraint.identifier = String(identifier.rawValue)
        return constraint
    }
}

extension UIView {
    func constraint(withIdentifier: LayoutAnchorType) -> NSLayoutConstraint? {
        let id = String(withIdentifier.rawValue)
        return self.constraints.filter{ $0.identifier == id }.first
    }
}
