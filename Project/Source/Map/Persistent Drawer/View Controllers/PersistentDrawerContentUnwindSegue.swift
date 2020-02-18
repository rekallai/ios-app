//
//  PersistentDrawerContentUnwindSegue.swift
//  Rekall
//
//  Created by Ray Hunter on 05/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

@available(iOS 13, *)
class PersistentDrawerContentUnwindSegue: UIStoryboardSegue {

    override func perform() {

        guard let drawerRootVC = destination as? PersistentDrawerViewController else {
            print("ERROR: destination was not PersistentDrawerContentViewController")
            return
        }
        
        if identifier == "UnwindToDrawerRoot" {
            while drawerRootVC.children.count > 2 {
                let toSkipOverVC = drawerRootVC.children[drawerRootVC.children.count - 1]
                toSkipOverVC.willMove(toParent: nil)
                toSkipOverVC.view.removeFromSuperview()
                toSkipOverVC.removeFromParent()                
            }
        }
        
        let toRemove = drawerRootVC.children[drawerRootVC.children.count - 1]
        
        if drawerRootVC.children.count >= 2,
           let previous = drawerRootVC.children[drawerRootVC.children.count - 2] as? PersistentDrawerContentViewController {
            drawerRootVC.setDrawer(collapsedSize: previous.collapsedSize,
                                   expandedSize: previous.expandedSize,
                                   animated: false)
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            toRemove.view.alpha = 0.0
            
            if let sv = drawerRootVC.view.superview {
                sv.layoutIfNeeded()
            }
        }) { finished in
            toRemove.willMove(toParent: nil)
            toRemove.view.removeFromSuperview()
            toRemove.removeFromParent()
        }
    }
}
