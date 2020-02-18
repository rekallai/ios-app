//
//  YourTicketsCell.swift
//  Rekall
//
//  Created by Ray Hunter on 01/08/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import AlamofireImage

protocol YourTicketsCellDelegate: class {
    func tapped(cell:YourTicketsCell)
}

class YourTicketsCell: UITableViewCell {

    static let identifier = "YourTicketsCell"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    weak var delegate: YourTicketsCellDelegate?
    
    var order: PurchasedOrder? {
        didSet {
            ticketImageView.image = nil
            
            if let imageUrl = order?.imageUrls?.first {
                ticketImageView.setProxyImage(url: imageUrl)
            }
            mainTitleLabel.text = order?.name
            if let startsAt = order?.startsAt {
                dateLabel.text = DateFormatter.shortDayMonthDateGmt.string(from: startsAt)
            } else {
                dateLabel.text = nil
            }
            ticketDetailLabel.text = order?.tagline
        }
    }
    
    @IBOutlet var ticketImageView: ProxyImageView!
    @IBOutlet var mainTitleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var ticketDetailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ticketImageView.layer.cornerRadius = 8.0
        setUpTapGesture()
    }
    
    private func setUpTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tap)
    }
    
    @objc func cellTapped() {
        delegate?.tapped(cell: self)
    }
}
