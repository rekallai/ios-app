//
//  TopLevelContainerViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 17/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

//
//  Navigation controller at the root of each tab
//
class TopLevelContainerViewController: UINavigationController {
    
    @IBInspectable var targetStoryboard: String?
    @IBInspectable var allowPopToRoot: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let sbName = targetStoryboard else {
            print("ERROR: No storyboard set!")
            return
        }
        
        let sb = UIStoryboard(name: sbName, bundle: nil)
        guard let vc = sb.instantiateInitialViewController() else {
            print("ERROR: Failed to instantiate VC from SB")
            return
        }
        
        self.viewControllers = [vc]
    }

    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if allowPopToRoot {
            return super.popToRootViewController(animated: animated)
        }
        
        return nil
    }
}
