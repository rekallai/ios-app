//
//  TicketSliderDataSource.swift
//  Rekall
//
//  Created by Steve on 10/16/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol TicketSliderDelegate: class {
    func ticketChanged(page: Int)
}

class TicketSliderDataSource: NSObject {
    weak var delegate: TicketSliderDelegate?
    var tickets = [PurchasedTicket]()
    
    func qrImage(code: String)->UIImage? {
        let generator = QRGenerator(qr: code)
        return generator.image
    }
    
}

extension TicketSliderDataSource: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tickets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TicketSliderCell.identifier, for: indexPath) as! TicketSliderCell
        
        let ticket = tickets[indexPath.row]
        let count = ticket.quantity
        let name = (count > 1) ? "\(count) x \(ticket.name)" : ticket.name
        cell.nameLabel.text = name
        if let venue = Venue.load(id: ticket.venueId), let url = venue.imageUrls?.first {
            cell.imageView.setProxyImage(url: url)
        }
        if let qrImg = qrImage(code: ticket.issuedCode) {
            cell.qrImageView.image = qrImg
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let current = Int(ceil(x/w))
        delegate?.ticketChanged(page: current)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
}
