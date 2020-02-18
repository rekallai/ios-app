//
//  ProfileTableView.swift
//  Rekall
//
//  Created by Steve on 8/27/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class ProfileTableView: UITableView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        register(ProfileHeaderView.nib, forHeaderFooterViewReuseIdentifier: ProfileHeaderView.identifier)
        rowHeight = 60
        estimatedSectionHeaderHeight = 400
        sectionHeaderHeight = UITableView.automaticDimension
    }

}
