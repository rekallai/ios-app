//
//  AmenitiesListViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 04/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import MapKit


@available(iOS 13, *)
protocol AnnotationsListDelegate: class {
    func mapItemSelected(mapItem: MKAnnotation, sender: AnnotationsListViewController)
}


@available(iOS 13, *)
class AnnotationsListViewController: PersistentDrawerContentViewController {

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView?
    weak var delegate: AnnotationsListDelegate?
    
    struct ListItem {
        let title: String?
        let subTitle: String?
        let mapItem: MKAnnotation?
        let distance: CLLocationDistance
    }
    
    var section: WhatsNearbyViewController.Section?
    var listItems = [ListItem]() {
        didSet {
            tableView?.reloadData()
        }
    }
            
    override func awakeFromNib() {
        super.awakeFromNib()
        collapsedSize = 197.0
        expandedSize = 350.0
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch section {
        case .restrooms:
            iconImageView.image = UIImage(named: "MapsNearbyRestrooms")
            titleLabel.text = NSLocalizedString("Restrooms at \(Environment.shared.projectName)", comment: "List title")
        case .service:
            iconImageView.image = UIImage(named: "MapsNearbyConcierge")
            titleLabel.text = NSLocalizedString("Information at \(Environment.shared.projectName)", comment: "List title")
        case .favorites:
            iconImageView.image = UIImage(named: "MapsNearbyFavorites")
            titleLabel.text = NSLocalizedString("Your favorites at \(Environment.shared.projectName)", comment: "List title")
        default:
            titleLabel.text = ""
        }
    }
}


@available(iOS 13, *)
extension AnnotationsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AmenityCell") as! AmenityCell
        let amenityWithDistance = listItems[indexPath.row]
        cell.amenityTitleLabel.text = amenityWithDistance.title
        cell.amenitySubtitleLabel.text = Distance.distanceStringForMeters(distanceInMeters: amenityWithDistance.distance)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mapItem = listItems[indexPath.row].mapItem {
            delegate?.mapItemSelected(mapItem: mapItem, sender: self)
        }
    }
}
