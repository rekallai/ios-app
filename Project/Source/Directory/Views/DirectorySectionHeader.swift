//
//  DirectorySectionHeader.swift
//  Rekall
//
//  Created by Steve on 8/1/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class DirectorySectionHeader: UICollectionReusableView {
    static let identifier = "DirectorySectionHeader"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
}
