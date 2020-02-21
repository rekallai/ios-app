//
//  EnvironmentViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 29/11/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class EnvironmentViewController: UIViewController {

    @IBOutlet var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch AppEnvironment.shared.currentPlatform {
        case .build:
            segmentedControl.selectedSegmentIndex = 0
        case .staging:
            segmentedControl.selectedSegmentIndex = 1
        case .production:
            segmentedControl.selectedSegmentIndex = 2
        }
    }
    

    @IBAction func applyTapped(_ sender: UIButton) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            AppEnvironment.shared.currentPlatform = .build
        case 1:
            AppEnvironment.shared.currentPlatform = .staging
        case 2:
            AppEnvironment.shared.currentPlatform = .production
        default:
            break
        }
        
        if let rvc = UIApplication.shared.keyWindow?.rootViewController as? RootViewController {
            rvc.showMainUI()
        }
    }
    
}
