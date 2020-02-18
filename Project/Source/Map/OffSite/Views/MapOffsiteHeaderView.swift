//
//  MapOffsiteHeaderView.swift
//  Rekall
//
//  Created by Steve on 8/19/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol MapOffsiteHeaderViewDelegate: class {
    func mapImageViewTapped(sender:MapOffsiteHeaderView)
}

class MapOffsiteHeaderView: UITableViewHeaderFooterView {
    weak var delegate:MapOffsiteHeaderViewDelegate?
    
    static let identifier = "MapOffsiteHeaderView"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet weak var imageView: RoundedImageView!

    override func awakeFromNib() {
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tap)
    }
    
    @objc func imageTapped() {
        delegate?.mapImageViewTapped(sender: self)
    }
    
}
