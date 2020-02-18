//
//  TicketDetailTableView.swift
//  Rekall
//
//  Created by Steve on 9/11/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class TicketDetailTableView: UITableView {

    override func awakeFromNib() {
        backgroundColor = UIColor(named: "WhiteBlack")
        register(TicketHeaderView.nib, forHeaderFooterViewReuseIdentifier: TicketHeaderView.identifier)
        register(TicketDetailCell.nib, forCellReuseIdentifier: TicketDetailCell.identifier)
        register(DetailPointCell.nib, forCellReuseIdentifier: DetailPointCell.identifier)
        register(DetailLinkCell.nib, forCellReuseIdentifier: DetailLinkCell.identifier)
        register(DetailHoursCell.nib, forCellReuseIdentifier: DetailHoursCell.identifier)
        estimatedRowHeight = 64
        rowHeight = UITableView.automaticDimension
        sectionHeaderHeight = UITableView.automaticDimension
        separatorStyle = .none
    }
    
}
