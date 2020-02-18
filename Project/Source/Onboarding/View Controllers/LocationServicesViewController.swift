//
//  LocationServicesViewController.swift
//  Rekall
//
//  Created by Steve on 10/3/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class LocationServicesViewController: UIViewController {
    @IBOutlet weak var introText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        introText.text = "Find your way around \(Environment.shared.projectName) quickly and easily with our wayfinding service"
    }
    
}
