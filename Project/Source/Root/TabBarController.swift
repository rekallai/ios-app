//
//  TabBarController.swift
//  Rekall
//
//  Created by Ray Hunter on 06/12/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.items?[0].image = UIImage(named: "TabForYou")?
            .withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[1].image = UIImage(named: "TabAttractions")?
            .withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[2].image = UIImage(named: "TabMap")?
            .withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[3].image = UIImage(named: "TabSearch")?
            .withRenderingMode(.alwaysOriginal)
        
        guard let selectedTextColor = UIColor(named: "ButtonBackground") else { return }
        guard let items = self.tabBar.items else { return }
        
        (0..<items.count).forEach { i in
            items[i].setTitleTextAttributes([NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1)],
                                            for: .normal)
            items[i].setTitleTextAttributes([NSAttributedString.Key.foregroundColor : selectedTextColor],
                                            for: .selected)
        }
    }
}
