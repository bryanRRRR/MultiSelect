//
//  GZTNavigationViewController.swift
//  WorkSpace
//
//  Created by 生生 on 2017/8/10.
//  Copyright © 2017年 生生. All rights reserved.
//

import UIKit

class GZTNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let navBar = UINavigationBar.appearance()
        navBar.barTintColor = UIColor.clear
        navBar.barTintColor = UIColor.white
        navBar.tintColor = UIColor.white
        self.navigationBar.isTranslucent = false
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
            self.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate;
        }
        
        super.pushViewController(viewController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
