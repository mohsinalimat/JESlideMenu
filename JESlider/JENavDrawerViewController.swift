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
    case LeftPanelShowing
    case NoPanelShowing
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
    var leftViewController: UIViewController!
    
    var frontContainerView: UIView!
    var leftContainerView: UIView!
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Container ViewController
    
    // add the first content to the container
    func displayContentController(content: UIViewController)
    {
        self.addChildViewController(content)
        content.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(content.view)
        content.didMoveToParentViewController(self)
        
        let views = ["view": content.view]
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: nil, metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: nil, metrics: nil, views: views))
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: UIStoryboardSegue

class JEContainerViewControllerSegue: UIStoryboardSegue
{
    override func perform()
    {
        
    }
}
