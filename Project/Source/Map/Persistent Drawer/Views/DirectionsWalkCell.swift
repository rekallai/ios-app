//
//  DirectionsWalkCell.swift
//  Rekall
//
//  Created by Ray Hunter on 13/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class DirectionsWalkCell: UITableViewCell {

    static let identifier = "DirectionsWalkCell"
    
    var walkTime = 0 {
        didSet {
            if walkTime < 1 { walkTime = 1 }
            walkTimeLabel.text = NSLocalizedString("\(walkTime) min walk",
                                                   comment: "Route walking time")
        }
    }
    
    @IBOutlet var walkTimeLabel: UILabel!
}
