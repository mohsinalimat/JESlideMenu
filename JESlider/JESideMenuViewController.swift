//
//  JESideMenuViewController.swift
//  JESlider
//
//  Created by JE on 29.05.15.
//  Copyright (c) 2015 JE. All rights reserved.
//

import UIKit

extension UIViewController
{
    var sideMenuViewController: JESideMenuViewController? {
        get {
            return getSideViewController(self)
        }
    }
    
    // find recursively the SideMenuViewController
    private func getSideViewController(viewController: UIViewController) -> JESideMenuViewController? {
        if let parent = viewController.parentViewController {
            if parent is JESideMenuViewController {
                return parent as? JESideMenuViewController
            }else {
                return getSideViewController(parent)
            }
        }
        return nil
    }
    
    //MARK: - To Do toggle
    @IBAction func showLeftMenuViewController() {
        
        //sideMenuViewController?._presentLeftMenuViewController()
        
    }
    
    func hideLeftMenuViewController()
    {
        //
    }
}


// New Main Class
class JESideMenuViewController: UIViewController
{
    @IBInspectable var contentViewStoryboardID: String?
    @IBInspectable var menuViewStoryboardID: String?
    
    var contentView: UIView!
    var menuView: UIVisualEffectView!
    var scrollView: JESideMenuScrollView!
    var blurStyle: UIBlurEffectStyle = .Light
    
    // in front is the main ViewController
    // adds the contentViewController as a child
    var contentViewController: UIViewController? {
        willSet {
            setupContentViewController(newValue, inView: contentView)
        }
        didSet {
            if let controller = oldValue
            {
                hideContentController(controller)
            }
        }
    }
    
    // slider menu ViewController on the left
    var menuViewController: UIViewController? {
        willSet {
            setupMenuViewController(newValue, inView: menuView)
        }
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // configures the views
        // sets the constraints
        self.setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup()
    {
        // load menu and blurStyle
        var menuVC: JELeftSideMenuViewController?
        if let menuID = self.menuViewStoryboardID,
            menuViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(menuID) as? JELeftSideMenuViewController
        {
            self.blurStyle = menuViewController.lightMenu ? .Light : .Dark
            menuVC = menuViewController
        }
        
        // contentView is the main view for the content
        self.contentView = UIView()
        self.contentView.backgroundColor = UIColor.clearColor()
        self.contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.contentView)
        
        // setup the constraints
        // the contentView fills whole the screen
        let view = ["view": self.contentView]
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: nil, metrics: nil, views: view))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: nil, metrics: nil, views: view))
        
        // navigation drawer scrollView
        // side menu
        self.scrollView = JESideMenuScrollView()
        self.scrollView.blurStyle = self.blurStyle
        self.scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.scrollView)
        
        // get the reference for the containerView
        self.menuView = self.scrollView.containerView
        
        // set the constraints on the scrollView
        let views = ["scrollView": self.scrollView]
        
        // reasonable width for iPhone 5/6 & iPad
        let metrics = ["width": 260.0]
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView(width)]", options: nil, metrics: metrics, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: nil, metrics: nil, views: views))
        
        // set the constraints within the scrollView
        self.scrollView.setConstraints()
        
        //
        // init Content
        //
        if let contentID = self.contentViewStoryboardID
        {
            self.contentViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(contentID) as? UIViewController
        }
        
        // actually set menu
        if let menu = menuVC
        {
            self.menuViewController = menu
        }
    }
    
    // MARK: Container ViewController
    
    // add the first content to the container
    func setupContentViewController(contentController: UIViewController?, inView view: UIView)
    {
        if let content = contentController
        {
            self.addChildViewController(content)
            content.view.setTranslatesAutoresizingMaskIntoConstraints(false)
            view.addSubview(content.view)
            content.didMoveToParentViewController(self)
            
            let views = ["view": content.view]
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: nil, metrics: nil, views: views))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: nil, metrics: nil, views: views))
        }
    }
    
    // add the Menu to the visualEffectsView
    func setupMenuViewController(menuController: UIViewController?, inView view: UIVisualEffectView)
    {
        if let menu = menuController
        {
            self.addChildViewController(menu)
            menu.view.setTranslatesAutoresizingMaskIntoConstraints(false)
            view.contentView.addSubview(menu.view)
            menu.didMoveToParentViewController(self)
            
            let views = ["view": menu.view]
            let metrics = ["left": 60]
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-left-[view]|", options: nil, metrics: metrics, views: views))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: nil, metrics: nil, views: views))
        }
    }
    
    
    // remove the content from container
    func hideContentController(content: UIViewController)
    {
        content.willMoveToParentViewController(nil)
        content.view.removeFromSuperview()
        content.removeFromParentViewController()
    }
    
    // hide the menu on start and when rotated
    override func viewDidLayoutSubviews()
    {
        self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: 0), animated: false)
    }
}

// MARK: - Navigation Drawer ScrollView

class JESideMenuScrollView: UIScrollView
{
    var containerView: UIVisualEffectView!
    var blurStyle: UIBlurEffectStyle = .Light {
        willSet {
            self.containerView = UIVisualEffectView(effect: UIBlurEffect(style: newValue))
            
            // drop shadow
            self.containerView.layer.shadowColor = UIColor.blackColor().CGColor
            self.containerView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
            self.containerView.layer.shadowOpacity = 0.5
            self.containerView.layer.shadowRadius = 4.0
        }
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.setup()
    }
    
    // configure the scrollView
    func setup()
    {
        self.backgroundColor = UIColor.clearColor()
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.pagingEnabled = true
        
        // that the drop shadow won't be cut off
        self.clipsToBounds = false
        self.decelerationRate = UIScrollViewDecelerationRateFast
        
        // decides about the blurStyle
        self.blurStyle = .Light
    }
    
    // configure the constraints
    func setConstraints()
    {
        // the contentView defines the content size
        // of the scrollView
        let contentView = UIView()
        contentView.backgroundColor = UIColor.clearColor()
        contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(contentView)
        
        // containerView will later contain the
        // drawer menu
        containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(containerView)
        
        // superview is self == scrollView
        // scrollview is 60 pt smaller/narrower than screen
        let superview = contentView.superview!
        let views = [
            "content": contentView,
            "container": containerView,
            "superview": superview
        ]
        let metrics = [
            "left": -60.0
        ]
        
        // constraints for contentView
        // equal height to superview
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[content(==superview)]|",
            options: nil,
            metrics: nil,
            views: views
            ))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[content]|",
            options: nil,
            metrics: nil,
            views: views
            ))
        
        // width of the contentView is
        // twice the width of the scrollview
        // 2 pages, paging enabled
        self.addConstraint(NSLayoutConstraint(
            item: contentView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Width,
            multiplier: 2.0,
            constant: 0
            ))
        
        // container has the height of the scrollview
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[container]|",
            options: nil,
            metrics: nil,
            views: views
            ))
        
        // container has a negative distance
        // at the left side which is the size of
        // the gap.
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-(left)-[container]",
            options: nil,
            metrics: metrics,
            views: views
            ))
        
        // container has the width of the screen + 60
        // container is shifted by 60 to the left
        self.addConstraint(NSLayoutConstraint(
            item: containerView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Width,
            multiplier: 1.0,
            constant: 60.0
            ))
    }
    
    /*
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView?
    {
    // To Do
    }
    */
    
    func showDrawer()
    {
        self.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
    }
    
    func hideDrawer()
    {
        self.setContentOffset(CGPoint(x: self.bounds.width, y: 0), animated: true)
    }
}



// The Left Side Menu
class JELeftSideMenuViewController: UIViewController
{
    @IBInspectable var lightMenu: Bool = true
    
    @IBInspectable var menuPoint1: String?
    @IBInspectable var menuPoint2: String?
    @IBInspectable var menuPoint3: String?
    @IBInspectable var menuPoint4: String?
    @IBInspectable var menuPoint5: String?
    @IBInspectable var menuPoint6: String?
    
    var titles = [String]()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.frame = CGRectMake(20, (self.view.frame.size.height - 54 * 5) / 2.0, self.view.frame.size.width, 54 * 5)
        tableView.autoresizingMask = .FlexibleTopMargin | .FlexibleBottomMargin | .FlexibleWidth
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.opaque = false
        tableView.backgroundColor = UIColor.clearColor()
        tableView.backgroundView = nil
        tableView.bounces = false
        return tableView
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clearColor()
        view.addSubview(tableView)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// TableView DataSource & Delegate
extension JELeftSideMenuViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // enter your menuPoints in the storyboard
        // or directly in code
        // fill the titles array above with your menu points
        if self.titles.count == 0
        {
            var menuPoints = [menuPoint1, menuPoint2, menuPoint3, menuPoint4, menuPoint5, menuPoint6]
            
            for menuPoint in menuPoints
            {
                if let mp = menuPoint
                {
                    self.titles.append(mp)
                }
            }
        }
        
        return self.titles.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 54
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.text = titles[indexPath.row]
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 21)
        
        if lightMenu
        {
            cell.textLabel?.textColor = UIColor.darkGrayColor()
        }
        else
        {
            cell.textLabel?.textColor = UIColor.lightGrayColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // Please note:
        // The titles/menu points should be the same as the StoryboardIDs!
        sideMenuViewController?.contentViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(self.titles[indexPath.row]) as? UIViewController
    }
}


