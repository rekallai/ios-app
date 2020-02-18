//
//  RoundedButton.swift
//  Rekall
//
//  Created by Steve on 8/20/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 8.0
        layer.borderWidth = 1.0
        layer.borderColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
    }

}
