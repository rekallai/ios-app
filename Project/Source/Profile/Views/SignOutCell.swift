//
//  SignOutCell.swift
//  Rekall
//
//  Created by Ray Hunter on 28/10/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol SignOutCellDelegate: class {
    func versionLabelTapped(sender: SignOutCell)
}

class SignOutCell: UITableViewCell {

    weak var delegate: SignOutCellDelegate?
    
    @IBOutlet var versionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
                        
        guard let dictionary = Bundle.main.infoDictionary,
        let version = dictionary["CFBundleShortVersionString"] as? String,
        let build = dictionary["CFBundleVersion"] as? String else {
            versionLabel.isHidden = true
            return
        }
                
        versionLabel.text = "Version: \(version)-\(build)"
        
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(versionLabelTapped(tapGr:)))
        versionLabel.addGestureRecognizer(tapGr)
        versionLabel.isUserInteractionEnabled = true
    }
    
    
    @objc func versionLabelTapped(tapGr: UITapGestureRecognizer) {
        delegate?.versionLabelTapped(sender: self)
    }
}
