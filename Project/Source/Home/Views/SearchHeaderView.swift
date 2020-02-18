//
//  SearchHeaderView.swift
//  Rekall
//
//  Created by Steve on 9/11/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class SearchHeaderView: UITableViewHeaderFooterView {

    static let identifier = "SearchHeaderView"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet var headerTitleLabel: UILabel!
}
