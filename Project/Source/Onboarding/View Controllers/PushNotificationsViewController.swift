//
//  PushNotificationsViewController.swift
//  Rekall
//
//  Created by Steve on 10/3/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class PushNotificationsViewController: UIViewController {
    @IBOutlet weak var introText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        introText.text = "\(Environment.shared.projectName) uses notifications to let you know about offers, promotions and events that may interest you"
    }
}
