//
//  MapInstructionsPositionIndicator.swift
//  Rekall
//
//  Created by Ray Hunter on 13/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class DirectionsPositionIndicator: UIView {
        
    var state: Directions.WaypointState = .currentPosition {
        didSet {
            switch state {
            case .currentPosition:
                layer.borderWidth = 1
                innerView.backgroundColor = UIColor(named: "ButtonBackground")
            case .notVisited:
                layer.borderWidth = 0
                innerView.backgroundColor = .white
            case .visited:
                layer.borderWidth = 0
                innerView.backgroundColor = UIColor(named: "ButtonBackground")
            }
        }
    }
    
    let innerView = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(innerView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
        layer.cornerRadius = bounds.height / 2.0
        layer.borderColor = UIColor(named: "ButtonBackground")?.cgColor

        innerView.frame = CGRect(x: 4, y: 4, width: 13, height: 13)
        innerView.layer.cornerRadius = 13.0 / 2.0
        innerView.layer.borderWidth = 2.0
        innerView.layer.borderColor = UIColor(named: "ButtonBackground")?.cgColor
    }
}
