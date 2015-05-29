//
//  ViewController.swift
//  JESlider
//
//  Created by Jasmin on 20/05/15.
//  Copyright (c) 2015 JE. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var scrollView = JESideMenuScrollView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.scrollView)
        
        let views = ["scrollView": self.scrollView]
        let metrics = ["width": 260.0]

        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView(width)]", options: nil, metrics: metrics, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: nil, metrics: nil, views: views))
        
        self.scrollView.setConstraints()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func viewDidLayoutSubviews()
    {
        self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: 0), animated: false)
    }
}

