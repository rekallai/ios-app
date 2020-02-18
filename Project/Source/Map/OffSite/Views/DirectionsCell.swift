//
//  DirectionsCell.swift
//  Rekall
//
//  Created by Steve on 8/20/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol DirectionsCellDelegate: class {
    func tappedDirection(cell: DirectionsCell)
}

class DirectionsCell: UITableViewCell {

    static let identifier = "DirectionsCell"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    weak var delegate: DirectionsCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var button: RoundedButton!
    
    @IBAction func buttonTapped(_ sender: Any) {
        delegate?.tappedDirection(cell: self)
    }
    
}
