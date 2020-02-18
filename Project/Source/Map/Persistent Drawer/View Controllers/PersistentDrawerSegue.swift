//
//  PersistentDrawerSegue.swift
//  Rekall
//
//  Created by Ray Hunter on 20/08/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

@available(iOS 13, *)
class PersistentDrawerSegue: UIStoryboardSegue {
    override func perform() {
        guard let drawerVC = destination as? PersistentDrawerViewController,
              let drawerView = drawerVC.view else {
                print("ERROR: PersistentDrawerSegue did not have PersistentDrawerViewController as destination")
                return
        }

        source.addChild(drawerVC)
        source.view.addSubview(drawerView)
        drawerVC.didMove(toParent: source)
        
        drawerView.translatesAutoresizingMaskIntoConstraints = false
                        
        drawerView.leftAnchor.constraint(equalTo: source.view.leftAnchor).isActive = true
        drawerView.rightAnchor.constraint(equalTo: source.view.rightAnchor).isActive = true
    }
}
