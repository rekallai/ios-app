//
//  AccessibilityViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 11/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

enum AccessibilityCategory {
    case escalator
    case elevator
}


@available(iOS 13, *)
protocol AccessibilityDelegate: class {
    func userSwitchedTo(accessibilityCategory: AccessibilityCategory, sender: AccessibilityViewController)
    func continueTappedIn(sender: AccessibilityViewController)
}


@available(iOS 13, *)
class AccessibilityViewController: PersistentDrawerContentViewController {

    var route: Route? {
        didSet {
            updateTimeToElevator()
        }
    }
    
    weak var delegate: AccessibilityDelegate?
    
    @IBOutlet var subtitleLabel: UILabel?
    @IBOutlet var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collapsedSize = 260.0
        expandedSize = 260.0
        
        updateTimeToElevator()
    }
    
    
    @IBAction func continueButtonTapped(_ sender: RoundedButton) {
        delegate?.continueTappedIn(sender: self)
    }
    
    
    private func updateTimeToElevator() {
        guard let route = route else {
            subtitleLabel?.text = ""
            return
        }
        
        let walkingTime = Int(route.walkingTimeForSection(waypoint: 0))
        let transitType = route.usesElevators ? NSLocalizedString("elevator", comment: "Floor transit label") :
                                                NSLocalizedString("escalator", comment: "Floor transit label")

        subtitleLabel?.text = "\(walkingTime) min walk to the \(transitType)"
    }
}


@available(iOS 13, *)
extension AccessibilityViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return NSLocalizedString("Escalator",
                                     comment: "Picker accessibility label for routing")
        }
        
        return NSLocalizedString("Elevator",
                                 comment: "Picker accessibility label for routing")
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.userSwitchedTo(accessibilityCategory: row == 0 ? .escalator : .elevator,
                                 sender: self)
    }
}
