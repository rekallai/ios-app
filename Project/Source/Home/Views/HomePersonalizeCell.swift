//
//  HomePersonalizeCellTableViewCell.swift
//  Rekall
//
//  Created by Ray Hunter on 03/07/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class HomePersonalizeCell: UITableViewCell {

    @IBOutlet var personalizeButton: UIButton!
    @IBOutlet weak var introText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        personalizeButton.backgroundColor = UIColor.clear
        personalizeButton.layer.borderColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        personalizeButton.layer.borderWidth = 1.0
        personalizeButton.layer.cornerRadius = 8.0
        introText.text = "Follow your favorite topics to improve your experience at \(Environment.shared.projectName)"
        
        
    }
}
