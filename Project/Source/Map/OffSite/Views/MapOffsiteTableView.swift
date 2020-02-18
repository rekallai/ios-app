//
//  MapOffsiteTableView.swift
//  Rekall
//
//  Created by Steve on 8/19/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class MapOffsiteTableView: UITableView {

    override func awakeFromNib() {
        register(MapOffsiteMallOverview.nib, forHeaderFooterViewReuseIdentifier: MapOffsiteMallOverview.identifier)
        register(MapOffsiteHeaderView.nib, forHeaderFooterViewReuseIdentifier: MapOffsiteHeaderView.identifier)
        register(DirectionsCell.nib, forCellReuseIdentifier: DirectionsCell.identifier)
        register(DirectionsHeaderView.nib, forHeaderFooterViewReuseIdentifier: DirectionsHeaderView.identifier)
        estimatedRowHeight = 144
        rowHeight = UITableView.automaticDimension
        estimatedSectionHeaderHeight = 400
        sectionHeaderHeight = UITableView.automaticDimension
        contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
    }

}
