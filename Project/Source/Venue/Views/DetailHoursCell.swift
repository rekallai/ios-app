//
//  DetailHoursCell.swift
//  Rekall
//
//  Created by Steve on 7/22/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol DetailHoursCellDelegate: class {
    func tappedDetailHours(cell: DetailHoursCell)
}

class DetailHoursCell: UITableViewCell {
    
    static let identifier = "DetailHoursCell"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    weak var delegate: DetailHoursCellDelegate?
    var isCellExpanded:Bool?

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var showButton: UIButton?
    @IBOutlet weak var stack: UIStackView?
    
    func set(openingHours: OpeningHours?, isExpanded: Bool) {
        isCellExpanded = isExpanded
        var buttonTitle = ""
        if let openingHours = openingHours {
            if isExpanded {
                addStacks(openingHours.allDayHours())
                buttonTitle = NSLocalizedString("Show Today", comment: "Button title")
            } else {
                addLabels([openingHours.fullTimeToday(), openingHours.openClosed()])
                buttonTitle = NSLocalizedString("Show All", comment: "Button title")
            }
            showButton?.setTitle(buttonTitle, for: .normal)
        }
    }
    
    @IBAction func showButtonTapped(_ sender: Any) {
        delegate?.tappedDetailHours(cell:self)
    }
    
    public func addLabels(_ items: [String]) {
        items.forEach { (item) in
            stack?.addArrangedSubview(UILabel.create(item, isSemi: false))
        }
    }
    
    public func addStacks(_ items: [(String,String)]) {
        for (index,value) in items.enumerated() {
            let (name, time) = value
            let isSemi = index == 0 ? true : false
            let hoursStack = createStack(
                left: name, right: time, isSemi: isSemi
            )
            stack?.addArrangedSubview(hoursStack)
        }
    }
    
    public func clearStack() {
        stack?.arrangedSubviews.forEach({ (view) in
            view.removeFromSuperview()
        })
    }
    
    public func updateOpenClosed(isOpen: Bool) {
        let isExpanded = isCellExpanded ?? false
        let stackSize = stack?.arrangedSubviews.count ?? 0
        if (stackSize >= 2 && !isExpanded) {
            if let hoursLabel = stack?.arrangedSubviews[1] as? UILabel {
                let openClosed = isOpen ? "Open Now" : "Closed"
                hoursLabel.text = NSLocalizedString(openClosed, comment: "Label title")
            }
        }
    }
    
    private func createStack(left: String,right: String,isSemi: Bool)->UIStackView {
        let leftLabel = UILabel.create(left, isSemi: isSemi)
        leftLabel.textAlignment = .left
        let rightLabel = UILabel.create(right, isSemi: isSemi)
        rightLabel.textAlignment = .right
        let stack = UIStackView(arrangedSubviews: [leftLabel,rightLabel])
        stack.axis = .horizontal
        stack.distribution = .fill
        return stack
    }
    
    internal override func prepareForReuse() {
        clearStack()
    }
    
    override func awakeFromNib() {
        selectionStyle = .none
    }
    
}
