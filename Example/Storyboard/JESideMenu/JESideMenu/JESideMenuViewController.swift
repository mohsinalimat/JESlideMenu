//
//  JESideMenuViewController.swift
//  JESlider
//
//  Created by JE on 29.05.15.
//  Copyright (c) 2015 JE. All rights reserved.
//

import UIKit

//MARK: - Extension for Toggle Button
extension UIViewController
{
    var sideMenuViewController: JESideMenuViewController? {
        get {
            return getSideViewController(self)
        }
    }
    
    // find recursively the SideMenuViewController
    private func getSideViewController(viewController: UIViewController) -> JESideMenuViewController?
    {
        if let parent = viewController.parentViewController
        {
            if let controller = parent as? JESideMenuViewController
            {
                return controller
            }
            return getSideViewController(parent)
        }
        return nil
    }
    
    //MARK: - Toggle Button Action
    @IBAction func toggleMenu()
    {
        self.sideMenuViewController?._toggleMenu()
    }
}


// MARK: - Menu Controller
class JESideMenuViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate
{
    @IBInspectable var contentViewStoryboardID: String?
    @IBInspectable var menuViewStoryboardID: String?
    
    var contentView: UIView!
    var menuView: UIVisualEffectView!
    var scrollView: JESideMenuScrollView!
    var invisibleView: UIView!
    var blurStyle: UIBlurEffectStyle = .Light
    var hasNavigationbar: Bool = false
    var isFirstStart: Bool = true
    let scrollViewWidth: CGFloat = 260.0
    
    var edgeGestureRecognizer: UIPanGestureRecognizer!
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    var zeroTopConstraint: NSLayoutConstraint!
    var landscapeTopConstraint: NSLayoutConstraint!
    var portraitTopConstraint: NSLayoutConstraint!
    
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
    
    //MARK: - Initial Setup
    func setup()
    {
        // init the menu
        // get the the blurStyle for the UIVisualEffectsView
        // in the scrollView
        var menuVC: JELeftSideMenuViewController?
        if let menuID = self.menuViewStoryboardID,
            menuViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(menuID) as? JELeftSideMenuViewController
        {
            self.blurStyle = menuViewController.lightMenu ? .Light : .Dark
            self.hasNavigationbar = menuViewController.hasNavigationbar
            menuVC = menuViewController
        }
        
        // contentView is the main view for the content
        self.contentView = UIView()
        self.contentView.backgroundColor = UIColor.clearColor()
        self.contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.contentView)
        
        // invisible view
        self.invisibleView = UIView()
        self.invisibleView.backgroundColor = UIColor.clearColor()
        self.invisibleView.alpha = 0.0
        self.invisibleView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.invisibleView)
        
        // navigation drawer scrollView
        // side menu
        self.scrollView = JESideMenuScrollView()
        self.scrollView.blurStyle = self.blurStyle
        self.scrollView.delegate = self
        self.scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.scrollView)
        
        // get the reference for the containerView
        self.menuView = self.scrollView.containerView
        
        // set constraints for content & scrollview
        self.setupConstraints()
        
        // set the constraints within the scrollView
        self.scrollView.setConstraints()
        
        // add Pan Gesture
        self.edgeGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panGestureRecognized:")
        self.edgeGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(self.edgeGestureRecognizer)
        
        // add tap Gesture
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapGestureRecognized:")
        self.invisibleView.addGestureRecognizer(self.tapGestureRecognizer)
        
        // move pan gesture recognizer from scrollview to menuView/visualEffectView
        self.menuView.addGestureRecognizer(self.scrollView.panGestureRecognizer)

        // init Content & add ChildViewController
        if let contentID = self.contentViewStoryboardID
        {
            self.contentViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(contentID) as? UIViewController
        }
        
        // set the menu after
        // scrollView has been setup
        if let menu = menuVC
        {
            self.menuViewController = menu
        }
    }
    
    func setupConstraints()
    {
        // setup the constraints
        // the contentView fills whole the screen
        let views = ["contentView": self.contentView, "scrollView": self.scrollView, "invisibleView": self.invisibleView]
        
        // reasonable width for iPhone 5/6 & iPad
        let metrics = ["width": self.scrollViewWidth]
        
        // add constraints
        // contentView is full screen
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView]|", options: nil, metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView]|", options: nil, metrics: nil, views: views))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[invisibleView]|", options: nil, metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[invisibleView(==scrollView)]|", options: nil, metrics: nil, views: views))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView(width)]", options: nil, metrics: metrics, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[scrollView]|", options: nil, metrics: nil, views: views))
        
        // top constraint for scrollView
        // standard constraint
        // side menu covers completely the screen
        self.zeroTopConstraint = NSLayoutConstraint(
            item: self.scrollView,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0,
            constant: 0.0)
        self.view.addConstraint(self.zeroTopConstraint)
        self.zeroTopConstraint.active = false
        
        
        // top constraint for portait
        // if menu runs under navigationbar
        self.portraitTopConstraint = NSLayoutConstraint(
            item: self.scrollView,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0,
            constant: 64.0)
        self.view.addConstraint(self.portraitTopConstraint)
        self.portraitTopConstraint.active = false
        
        
        // top constraint for landscape
        // changes for landscape
        self.landscapeTopConstraint = NSLayoutConstraint(
            item: self.scrollView,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0,
            constant: 32.0)
        self.view.addConstraint(self.landscapeTopConstraint)
        self.landscapeTopConstraint.active = false
        
        //
        // activate constraints for navigationbar
        //
        if self.hasNavigationbar
        {
            // iPhone landscape
            if self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact
            {
                self.landscapeTopConstraint.active = true
            }
            else
            {
                self.portraitTopConstraint.active = true
            }
        }
        else
        {
            self.zeroTopConstraint.active = true
        }
    }
    
    // MARK: - Container ViewController Methods
    
    // add the first content to the container
    func setupContentViewController(contentController: UIViewController?, inView view: UIView)
    {
        if let content = contentController
        {
            // add child viewController
            self.addChildViewController(content)
            content.view.setTranslatesAutoresizingMaskIntoConstraints(false)
            content.view.alpha = 0.0
            view.addSubview(content.view)
            content.didMoveToParentViewController(self)
            
            // fullscreen
            let views = ["view": content.view]
            view.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:|[view]|",
                    options: nil,
                    metrics: nil,
                    views: views
                ))
            view.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|[view]|",
                    options: nil,
                    metrics: nil,
                    views: views
                ))
            
            // fade in animation
            UIView.animateWithDuration(
                0.25,
                delay: 0.0,
                options: .CurveEaseInOut,
                animations: {
                    content.view.alpha = 1.0
                },
                completion: nil
            )
        }
    }
    
    // add the Menu to the visualEffectsView
    func setupMenuViewController(menuController: UIViewController?,
        inView view: UIVisualEffectView)
    {
        if let menu = menuController
        {
            self.addChildViewController(menu)
            menu.view.setTranslatesAutoresizingMaskIntoConstraints(false)
            view.contentView.addSubview(menu.view)
            menu.didMoveToParentViewController(self)
            
            let top = self.hasNavigationbar ? 18 : 70
            
            let views = ["view": menu.view]
            let metrics = ["top": top, "left": 60]
            view.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:|-left-[view]|",
                    options: nil,
                    metrics: metrics,
                    views: views))
            view.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|-top-[view]|",
                    options: nil,
                    metrics: metrics,
                    views: views))
        }
    }
    
    
    // remove the content from container
    func hideContentController(content: UIViewController)
    {
        content.willMoveToParentViewController(nil)
        content.view.removeFromSuperview()
        content.removeFromParentViewController()
    }
    
    
    // Toggle
    func _toggleMenu()
    {
        self.scrollView.toggleMenu()
    }
    
    
    //MARK: - UIGestureRecognizer Delegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
        shouldReceiveTouch touch: UITouch) -> Bool
    {
        let point = touch.locationInView(gestureRecognizer.view)
        if point.x < 20 && point.y > 64
        {
            return true
        }
        return false
    }
    
    func panGestureRecognized(pan: UIPanGestureRecognizer)
    {
        let point = pan.translationInView(pan.view!)
        
        if pan.state == UIGestureRecognizerState.Began
        {
            // 
        }
        else if pan.state == UIGestureRecognizerState.Changed
        {
            self.scrollView.contentOffset.x = self.scrollViewWidth - point.x
        }
        else if pan.state == UIGestureRecognizerState.Ended
        {
            self.scrollView.setContentOffset(CGPoint(x: 0.0, y: 0), animated: true)
        }
    }
    
    func tapGestureRecognized(tap: UITapGestureRecognizer)
    {
        if self.scrollView.contentOffset.x <= 0.0
        {
            self.scrollView.toggleMenu()
        }
    }
    
    
    //MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if scrollView.contentOffset.x <= 0.0
        {
            // show
            // menu is visible
            // To-Do userinteraction disabled
            if let scroll = scrollView as? JESideMenuScrollView
            {
                scroll.toggleDropShadow(menuVisible: true)
                self.invisibleView.alpha = 1.0
            }
        }
        else if scrollView.contentOffset.x >= scrollView.bounds.width
        {
            // Hide
            // menu is hidden
            if let scroll = scrollView as? JESideMenuScrollView
            {
                scroll.toggleDropShadow(menuVisible: false)
                self.invisibleView.alpha = 0.0
            }
        }
    }
    

    //MARK: - Rotation
    // navigationbar get's smaller on iPhone in landscape mode
    override func willTransitionToTraitCollection(newCollection: UITraitCollection,
        withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)
    {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        
        if self.hasNavigationbar
        {
            self.portraitTopConstraint.active = false
            self.landscapeTopConstraint.active = false
            
            // iPhone landscape
            if newCollection.verticalSizeClass == .Compact
            {
                self.landscapeTopConstraint.active = true
            }
            else
            {
                self.portraitTopConstraint.active = true
            }
            
            coordinator.animateAlongsideTransition(
                {(context: UIViewControllerTransitionCoordinatorContext!) in
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }

    
    //MARK: - viewDidLayoutSubviews, Hide Menu on Load
    // hide the menu on start and when rotated
    override func viewDidLayoutSubviews()
    {
        if isFirstStart
        {
            // width of the scrollView
            self.scrollView.setContentOffset(CGPoint(x: self.scrollViewWidth, y: 0), animated: false)
            self.isFirstStart = false
        }
    }
}

// MARK: - Side Menu ScrollView

class JESideMenuScrollView: UIScrollView
{
    var containerView = UIVisualEffectView()
    var blurStyle: UIBlurEffectStyle = .Light {
        willSet {
            self.containerView = UIVisualEffectView(effect: UIBlurEffect(style: newValue))
            
            // drop shadow
            self.containerView.layer.shadowColor = UIColor.blackColor().CGColor
            self.containerView.layer.shadowOffset = CGSize(width: 1.0, height: 4.0)
            self.containerView.layer.shadowOpacity = 0.0
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
    
    // configure contentView, container/visualEffectView & constraints
    func setConstraints()
    {
        // the contentView defines the content size
        // of the scrollView
        var contentView = UIView()
        contentView.backgroundColor = UIColor.clearColor()
        contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(contentView)
        
        // containerView will later contain the
        // drawer menu
        self.containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
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
    

    // Hittest
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView?
    {
        let hitview = super.hitTest(point, withEvent: event)
        
        if hitview == self.containerView.superview
        {
            return nil
        }
        return hitview
    }
    
    // toggle the menu
    func toggleMenu()
    {
        if self.contentOffset.x > 0
        {
            self.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
        }
        else
        {
            self.setContentOffset(CGPoint(x: self.bounds.width, y: 0), animated: true)
        }
    }
    
    func toggleDropShadow(menuVisible visible:Bool)
    {
        var opacity: Float = visible ? 0.5 : 0.0
        
        self.containerView.layer.shadowOpacity = opacity
    }
}


// MARK: - Side Menu TableView Controller
// The Left Side Menu
class JELeftSideMenuViewController: UIViewController
{
    //MARK: IBInspectables
    @IBInspectable var lightMenu: Bool = true
    @IBInspectable var hasNavigationbar: Bool = false
    
    // Please note:
    // menuPoints == storyboardIDs
    @IBInspectable var menuPoint1: String?
    @IBInspectable var menuPoint2: String?
    @IBInspectable var menuPoint3: String?
    @IBInspectable var menuPoint4: String?
    @IBInspectable var menuPoint5: String?
    @IBInspectable var menuPoint6: String?
    
    @IBInspectable var menuIcon1: UIImage?
    @IBInspectable var menuIcon2: UIImage?
    @IBInspectable var menuIcon3: UIImage?
    @IBInspectable var menuIcon4: UIImage?
    @IBInspectable var menuIcon5: UIImage?
    @IBInspectable var menuIcon6: UIImage?
    
    //MARK: - Insert your menu points here:
    //MARK: if you don't insert them via the storyboard
    var titles = [String]()
    var icons = [UIImage?]()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.opaque = false
        tableView.backgroundColor = UIColor.clearColor()
        tableView.backgroundView = nil
        tableView.bounces = false
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return tableView
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        self.view.addSubview(tableView)
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|", options: nil, metrics: nil, views: ["tableView": self.tableView]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options: nil, metrics: nil, views: ["tableView": self.tableView]))
        
        self.initTitles()
        self.initIcons()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // enter your menuPoints in the storyboard
    // or directly in code
    // fill the titles array above with your menu points
    // the storyboardIDs must be equal to the menu points!
    func initTitles()
    {
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
    }
    
    // choose your icons in the storyboard
    // this adds the images corresponding to
    // the titles to the icon array
    func initIcons()
    {
        if self.icons.count == 0
        {
            var menuIcons = [menuIcon1, menuIcon2, menuIcon3, menuIcon4, menuIcon5, menuIcon6]
            
            for menuIcon in menuIcons
            {
                self.icons.append(menuIcon)
            }
        }
    }
}


//MARK: - JELeftSideMenu TableView DataSource/Delegate Extension

extension JELeftSideMenuViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
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
        
        // set image
        if self.icons.count > indexPath.row
        {
            if let image = icons[indexPath.row]
            {
                cell.imageView?.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            }
        }
        
        // adjust the text & image color to
        // the visualEffectView (light/dark)
        if lightMenu
        {
            cell.textLabel?.textColor = UIColor.darkGrayColor()
            cell.imageView?.tintColor = UIColor.darkGrayColor()
        }
        else
        {
            cell.textLabel?.textColor = UIColor.lightGrayColor()
            cell.imageView?.tintColor = UIColor.lightGrayColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // Please note:
        // The titles/menu points must be the same as the StoryboardIDs!
        // this will raise an exception if your menu points aren't equal to your StoryboardIDs
        sideMenuViewController?.contentViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(self.titles[indexPath.row]) as? UIViewController
        sideMenuViewController?._toggleMenu()
    }
}


