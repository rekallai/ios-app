//
//  ProfileHeaderView.swift
//  Rekall
//
//  Created by Steve on 8/27/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class ProfileHeaderView: UITableViewHeaderFooterView {

    static let identifier = "ProfileHeaderView"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
}
