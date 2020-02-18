//
//  EmptyStateView.swift
//  Rekall
//
//  Created by Steve on 9/23/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class EmptyStateView: UIView {

    static let identifier = "EmptyStateView"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    static func loadNib()->EmptyStateView? {
        let viewNib = EmptyStateView.nib
        if let view = viewNib.instantiate(withOwner: nil, options: nil).first as? EmptyStateView {
            return view
        } else { return nil }
    }

}
