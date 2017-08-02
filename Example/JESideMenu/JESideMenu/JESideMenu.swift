//
//  JESideMenu.swift
//  JESideMenu
//
//  Created by JE on 02.08.17.
//  Copyright © 2017 JE. All rights reserved.
//

import UIKit

class JESideMenu: UIViewController {
    
    // Menu Items can be set in storyboard or here
    // MARK: add localization for menuItems later!
    var menuItems: [String]!
    @IBInspectable public var menuItem1: String!
    @IBInspectable public var menuItem2: String!
    @IBInspectable public var menuItem3: String!
    
    var menuNavigationController: JESideNavigationController!
    var menuTableView: JESideMenuTableViewController!
    var invisibleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMenuItems()
        setupMenuTableViewWithItems(menuItems: menuItems)
        setupNavigationController()
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
    
    // menu tableViewController to view and add autolayout
    func setupMenuTableViewWithItems(menuItems: [String]) {
        menuTableView = JESideMenuTableViewController(menuItems: menuItems)
        menuTableView.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menuTableView.view)
        
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
                
                menuNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(menuNavigationController.view)
                
                // add fullscreen autolayout
                addConstraintsToView(view: menuNavigationController.view)
                //menuNavigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.0).isActive = true
            }
        }
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
        var controller: UIViewController?
        if let c = self.storyboard?.instantiateViewController(withIdentifier: identifier) {
            controller = c
            controller?.title = identifier
        }
        return controller
    }
}

// MARK: -

class JESideMenuTableViewController: UITableViewController {
    
    let identifier = "cell"
    var menuItems = [String]()
    
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
    
    // delegate methods
    // selected row at indexPath
    
    // tableview style
    
    // MARK: - toggle animation
}

// MARK: -

class JESideNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        print("toggle :D")
    }
}

