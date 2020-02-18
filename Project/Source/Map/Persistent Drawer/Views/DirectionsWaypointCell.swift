//
//  DirectionsWaypointCell.swift
//  Rekall
//
//  Created by Ray Hunter on 13/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class DirectionsWaypointCell: UITableViewCell {

    static let identifier = "DirectionsWaypointCell"
    
    @IBOutlet var positionIndicator: DirectionsPositionIndicator!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    func setStartFloor(floor: Int) {
        titleLabel.text = NSLocalizedString("Starting Point", comment: "Route start title")
        let floorString = stringForFloor(floor: floor)

        subtitleLabel.text = NSLocalizedString("\(floorString) floor",
                                               comment: "Floor label")
    }
    
    func setDirectionItem(direction: Direction) {
        titleLabel.text = direction.stringRepresentation()
        let floorStr = stringForFloor(floor: direction.floor)
        subtitleLabel.text = NSLocalizedString("\(floorStr) floor", comment: "Floor label string")
    }
    
    func setFloorTransition(elevator: Bool, targetFloor: Int) {
        titleLabel.text = elevator ? NSLocalizedString("Elevator", comment: "Floor transit label") :
                                     NSLocalizedString("Escalator", comment: "Floor transit label")
        
        let targetFloor = stringForFloor(floor: targetFloor)
        
        let transitType = elevator ? NSLocalizedString("elevator", comment: "Floor transit label") :
                                     NSLocalizedString("escalator", comment: "Floor transit label")
        
        subtitleLabel.text = NSLocalizedString("Take the \(transitType) to the \(targetFloor) floor",
                                               comment: "Floor transit label")
    }
    
    func setEnd(floor: Int, venueName: String) {
        titleLabel.text = venueName
        
        let floorString = stringForFloor(floor: floor)
        subtitleLabel.text = NSLocalizedString("\(floorString) floor",
                                               comment: "Floor label")
    }
    
    private func stringForFloor(floor: Int) -> String {
        switch floor {
        case 0:
            return NSLocalizedString("ground", comment: "Floor label")
        case 1:
            return NSLocalizedString("1st", comment: "Floor label")
        case 2:
            return NSLocalizedString("2nd", comment: "Floor label")
        case 3:
            return NSLocalizedString("3rd", comment: "Floor label")
        default:
            return NSLocalizedString("\(floor)th", comment: "Floor label")
        }
    }
}
