//
//  WelcomeViewController.swift
//  Rekall
//
//  Created by Steve on 10/2/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var welcomeText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        
        welcomeText.text = "Get a personalized experience \(Environment.shared.projectName) in just three steps"
    }
    
    @IBAction func laterButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
