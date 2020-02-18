//
//  VenueDetailTableView.swift
//  Rekall
//
//  Created by Steve on 7/18/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class VenueDetailTableView: UITableView {

    override func awakeFromNib() {
        backgroundColor = UIColor(named: "WhiteBlack")!
        register(VenueHeaderView.nib, forHeaderFooterViewReuseIdentifier: VenueHeaderView.identifier)
        register(YourTicketsHeaderCell.nib, forCellReuseIdentifier: YourTicketsHeaderCell.identifier)
        register(YourTicketsCell.nib, forCellReuseIdentifier: YourTicketsCell.identifier)
        register(DetailPointCell.nib, forCellReuseIdentifier: DetailPointCell.identifier)
        register(DetailHoursCell.nib, forCellReuseIdentifier: DetailHoursCell.identifier)
        register(DetailLinkCell.nib, forCellReuseIdentifier: DetailLinkCell.identifier)
        register(DetailContactCell.nib, forCellReuseIdentifier: DetailContactCell.identifier)
        register(HomeHorizontalCollectionCellSmall.nib, forCellReuseIdentifier: HomeHorizontalCollectionCellSmall.identifier)
        register(HomeHorizontalCollectionCellLarge.nib, forCellReuseIdentifier: HomeHorizontalCollectionCellLarge.identifier)
        estimatedRowHeight = 64
        rowHeight = UITableView.automaticDimension
        sectionHeaderHeight = UITableView.automaticDimension
        separatorStyle = .none
    }
    
}
