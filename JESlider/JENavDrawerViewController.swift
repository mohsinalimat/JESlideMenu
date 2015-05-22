//
//  JEContainerViewController.swift
//  JESlider
//
//  Created by Jasmin on 20/05/15.
//  Copyright (c) 2015 JE. All rights reserved.
//

import UIKit

enum SlideOutState
{
    case NavBarShowing
    case NavBarHidden
}

@objc protocol JENavDrawerViewControllerDelegate
{
    func revealToggle()
}

class JENavDrawerChildViewController: UIViewController
{
    weak var delegate: JENavDrawerViewControllerDelegate?
}

class JENavDrawerViewController: UIViewController
{
    // in front is the main ViewController
    var frontViewController: UIViewController!
    
    // slider menu ViewController on the left
    var navViewController: UIViewController!
    
    var frontContainerView: UIView!
    var navContainerView: UIVisualEffectView!
    
    var scrollView: JENavDrawerScrollView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // configures the views
        // sets the constraints
        self.setup()
        
        // push viewController
        self.pushNavViewController()
        self.pushFrontViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup()
    {
        // frontContainerView is the main view for the content
        self.frontContainerView = UIView()
        self.frontContainerView.backgroundColor = UIColor.clearColor()
        self.frontContainerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.frontContainerView)
        
        // setup the constraints
        // the frontView fills the screen
        let view = ["view": self.frontContainerView]
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: nil, metrics: nil, views: view))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: nil, metrics: nil, views: view))
        
        
        // navigation drawer scrollView
        self.scrollView = JENavDrawerScrollView()
        self.scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.scrollView)
        
        // get the reference for the containerView
        self.navContainerView = self.scrollView.containerView
        
        // set the constraints on the scrollView
        let views = ["scrollView": self.scrollView]
        
        // reasonable width for iPhone 5/6 & iPad
        let metrics = ["width": 260.0]
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView(width)]", options: nil, metrics: metrics, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: nil, metrics: nil, views: views))
        
        // set the constraints within the scrollView
        self.scrollView.setConstraints()
    }
    
    // push
    func pushNavViewController()
    {
        performSegueWithIdentifier("je_nav", sender: nil)
    }
    
    func pushFrontViewController()
    {
        performSegueWithIdentifier("je_start", sender: nil)
    }
    
    
    // MARK: Container ViewController
    
    // add the first content to the container
    func displayContentController(content: UIViewController, inContainer containerView: UIView)
    {
        self.addChildViewController(content)
        content.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        containerView.addSubview(content.view)
        content.didMoveToParentViewController(self)
        
        let views = ["view": content.view]
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: nil, metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: nil, metrics: nil, views: views))
    }
    
    // add the navMenu to the visualEffectsView
    func displayContentController(content: UIViewController, inNavContainer navView: UIVisualEffectView)
    {
        self.addChildViewController(content)
        content.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        content.view.backgroundColor = UIColor.clearColor()
        navView.contentView.addSubview(content.view)
        content.didMoveToParentViewController(self)
        
        let views = ["view": content.view]
        navView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-60-[view]|", options: nil, metrics: nil, views: views))
        navView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: nil, metrics: nil, views: views))
    }
    
    // remove the content from container
    func hideContentController(content: UIViewController)
    {
        content.willMoveToParentViewController(nil)
        content.view.removeFromSuperview()
        content.removeFromParentViewController()
    }
    
    // replace the content within the container
    func cycleFromViewController(oldVC: UIViewController, toViewController newVC: UIViewController)
    {
        oldVC.willMoveToParentViewController(nil)
        
        self.addChildViewController(newVC)
        newVC.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(newVC.view)
        
        let views = ["view": newVC.view]
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: nil, metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: nil, metrics: nil, views: views))
        
        UIView.animateWithDuration(0.25,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: { finished in
                oldVC.removeFromParentViewController()
                newVC.didMoveToParentViewController(self)
        })
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        
        if segue.identifier == "je_nav"
        {
            if let des = segue.destinationViewController as? UIViewController
            {
                self.displayContentController(des, inNavContainer: self.navContainerView)
                self.navViewController = des
            }
        }
        else if segue.identifier == "je_start"
        {
            if let des = segue.destinationViewController as? UIViewController
            {
                self.displayContentController(des, inContainer: self.frontContainerView)
                self.frontViewController = des
            }
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: 0), animated: false)
    }
}


// MARK: - UIStoryboardSegue

class JEContainerViewControllerSegue: UIStoryboardSegue
{
    override func perform()
    {
        
    }
}


// MARK: - Navigation Drawer ScrollView

class JENavDrawerScrollView: UIScrollView
{
    var containerView: UIVisualEffectView!
    
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
        
        // dark visualEffectView
        self.containerView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        
        // drop shadow
        self.containerView.layer.shadowColor = UIColor.blackColor().CGColor
        self.containerView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.containerView.layer.shadowOpacity = 0.5
        self.containerView.layer.shadowRadius = 4.0
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
        let views = ["content": contentView, "container": containerView, "superview": superview]
        let metrics = ["left": -60.0]
        
        // constraints for contentView
        // equal height to superview
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[content(==superview)]|",
            options: nil,
            metrics: nil,
            views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[content]|",
            options: nil,
            metrics: nil,
            views: views))
        
        // width of the contentView is
        // twice the width of the scrollview
        self.addConstraint(NSLayoutConstraint(
            item: contentView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Width,
            multiplier: 2.0,
            constant: 0))
        
        // container has the height of the scrollview
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[container]|",
            options: nil,
            metrics: nil,
            views: views))
        
        // container has a negative distance
        // at the left side which is the size of
        // the gap.
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-(left)-[container]",
            options: nil,
            metrics: metrics,
            views: views))
        
        // container has the width of the screen
        self.addConstraint(NSLayoutConstraint(
            item: containerView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Width,
            multiplier: 1.0,
            constant: 60.0))
    }

    
    func showDrawer()
    {
        self.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
    }
    
    func hideDrawer()
    {
        self.setContentOffset(CGPoint(x: self.bounds.width, y: 0), animated: true)
    }
}

/*
class JENavDrawerTableViewController: UITableViewController
{
    //
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 0
    }
}
*/





