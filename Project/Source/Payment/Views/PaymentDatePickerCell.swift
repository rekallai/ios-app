//
//  PaymentDatePickerCell.swift
//  Rekall
//
//  Created by Ray Hunter on 29/07/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class PaymentDatePickerCell: UITableViewCell {

    @IBOutlet var datePicker: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.minimumDate = Date()
        datePicker.timeZone = TimeZone(identifier: "UTC")
    }
}
