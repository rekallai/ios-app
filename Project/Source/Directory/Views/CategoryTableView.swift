//
//  CategoryTableView.swift
//  Rekall
//
//  Created by Steve on 8/2/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class CategoryTableView: UITableView {

    override func awakeFromNib() {
        super.awakeFromNib()
        register(
            CategoryHeaderView.nib,
            forHeaderFooterViewReuseIdentifier:CategoryHeaderView.identifier
        )
        register(
            CategoryVenueCell.nib,
            forCellReuseIdentifier: CategoryVenueCell.identifier
        )
        estimatedRowHeight = 144
        rowHeight = UITableView.automaticDimension
        estimatedSectionHeaderHeight = 400
        sectionHeaderHeight = UITableView.automaticDimension
    }

}
