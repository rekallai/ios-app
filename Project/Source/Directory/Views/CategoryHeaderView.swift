//
//  CategoryHeaderView.swift
//  Rekall
//
//  Created by Steve on 8/1/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class CategoryHeaderView: UITableViewHeaderFooterView {

    static let identifier = "CategoryHeaderView"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!

}
