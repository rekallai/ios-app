//
//  PersistentDrawerContentSegue.swift
//  Rekall
//
//  Created by Ray Hunter on 04/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

@available(iOS 13, *)
class PersistentDrawerContentSegue: UIStoryboardSegue {
    override func perform() {
        guard let drawerVC = source as? PersistentDrawerViewController,
              let drawerContentView = drawerVC.contentView,
              let contentVC = destination as? PersistentDrawerContentViewController else {
                print("ERROR: PersistentDrawerContentSegue did not have PersistentDrawerViewController as source")
                return
        }
                
        source.addChild(contentVC)
        source.view.addSubview(contentVC.view)
        contentVC.didMove(toParent: source)
        contentVC.view.translatesAutoresizingMaskIntoConstraints = false
                        
        contentVC.view.leftAnchor.constraint(equalTo: drawerContentView.leftAnchor).isActive = true
        contentVC.view.rightAnchor.constraint(equalTo: drawerContentView.rightAnchor).isActive = true
        contentVC.view.topAnchor.constraint(equalTo: drawerContentView.topAnchor).isActive = true
        contentVC.view.heightAnchor.constraint(equalToConstant: contentVC.expandedSize).isActive = true
        
        contentVC.view.alpha = 0.0
        UIView.animate(withDuration: 0.3) {
            drawerVC.setDrawer(collapsedSize: contentVC.collapsedSize,
                               expandedSize: contentVC.expandedSize,
                               animated: false)

            contentVC.view.alpha = 1.0
            
            if let sv = drawerVC.view.superview {
                sv.layoutIfNeeded()
            }
        }
    }
}
