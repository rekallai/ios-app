//
//  NavigateButtonViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 12/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

@available(iOS 13, *)
protocol NavigateButtonDelegate: class {
    func navigateButtonTappedIn(sender: NavigateButtonViewController)
}

@available(iOS 13, *)
class NavigateButtonViewController: PersistentDrawerContentViewController {

    weak var delegate: NavigateButtonDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        expandedSize = 110.0
        collapsedSize = 110.0
    }

    @IBAction func navigateTapped(_ sender: RoundedButton) {
        delegate?.navigateButtonTappedIn(sender: self)
    }
}
