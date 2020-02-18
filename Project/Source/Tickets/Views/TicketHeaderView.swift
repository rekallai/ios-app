//
//  TicketHeaderView.swift
//  Rekall
//
//  Created by Steve on 9/11/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol TicketHeaderViewDelegate: class {
    func tappedPassButton()
    func sliderChanged(ticket: PurchasedTicket)
}

class TicketHeaderView: UITableViewHeaderFooterView {

    static let identifier = "TicketHeaderView"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    weak var delegate: TicketHeaderViewDelegate?
    let pass = PassButton()
    var dataSource = TicketSliderDataSource()

    @IBOutlet weak var collectionView: TicketSliderCollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var stack: UIStackView!
    
    var order: PurchasedOrder? {
        didSet {
            if let order = order {
                let tickets = order.tickets ?? []
                dataSource.tickets = tickets
                pageControl.numberOfPages = tickets.count
                collectionView.isUserInteractionEnabled = (tickets.count > 1)
            }
        }
    }
    var venue: Venue? {
        didSet {
            if let venue = venue {
                titleLabel.text = venue.name
                descriptionLabel.text = venue.itemDescription
            }
        }
    }
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        let page = CGFloat(sender.currentPage)
        var rect = collectionView.frame
        rect.origin.x = frame.size.width * page
        rect.origin.y = 0
        collectionView.scrollRectToVisible(rect, animated: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addPassButton()
        dataSource.delegate = self
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
    }
    
    func addPassButton() {
        pass.delegate = self
        stack.addArrangedSubview(pass.create())
    }
    
}

extension TicketHeaderView: TicketSliderDelegate {
    
    func ticketChanged(page: Int) {
        pageControl.currentPage = page
        if dataSource.tickets.count > page {
            let ticket = dataSource.tickets[page]
            delegate?.sliderChanged(ticket: ticket)
        }
    }
    
}

extension TicketHeaderView: PassButtonDelegate {
    
    func passButtonTapped() {
        delegate?.tappedPassButton()
    }
    
}
