//
//  UITableView+Empty.swift
//  Rekall
//
//  Created by Steve on 9/23/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

extension UITableView {
    
    func empty(title: String, message: String, icon: UIImage? = nil) {
        if let view = EmptyStateView.loadNib() {
            if let icon = icon {
                view.iconImageView.image = icon
            } else {
                view.iconImageView.isHidden = true
            }
            view.titleLabel.text = title
            view.bodyLabel.text = message
            backgroundView = view
        }
    }
    
}
