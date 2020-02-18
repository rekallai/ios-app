//
//  AmenityDetailsViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 06/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import MapKit

@available(iOS 13, *)
protocol AmenityDetailsDelegate: class {
    func navigateTappedIn(sender: AnnotationDetailsViewController)
    func occupantTappedIn(sender: AnnotationDetailsViewController)
}

@available(iOS 13, *)
class AnnotationDetailsViewController: PersistentDrawerContentViewController {
    
    weak var delegate: AmenityDetailsDelegate?

    @IBOutlet var imageView: ProxyImageView?
    @IBOutlet var amenityTitleLabel: UILabel?
    @IBOutlet var amenitySubtitleLabel: UILabel?
    @IBOutlet var chevronImageView: UIImageView?
    @IBOutlet var navigateButton: RoundedButton!
    
    var annotation: AnnotationMetadata? {
        didSet{
            updateAmenityDetails()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if Defines.navigationEnabled {
            collapsedSize = 173.0
            expandedSize = 173.0
            navigateButton.isHidden = false
        } else {
            collapsedSize = 173.0 - 85.0
            expandedSize = 173.0 - 85.0
            navigateButton.isHidden = true
        }
        
        updateAmenityDetails()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let iv = imageView {
            iv.layer.cornerRadius = iv.bounds.size.height / 2.0
        }
    }
    
    private func updateAmenityDetails() {
        guard let annotation = annotation else { return }
        amenityTitleLabel?.text = annotation.title
        amenitySubtitleLabel?.text = Distance.shared.distanceStringFromUserTo(location2d: annotation.coordinate)
        
        imageView?.image = annotation.localImageName != nil ? UIImage(named: annotation.localImageName!) : nil
        if let remoteImage = annotation.remoteImage {
            imageView?.setProxyImage(url: remoteImage)
        }
        
        chevronImageView?.isHidden = !annotation.canShowVenueDetailsScreen
    }

    @IBAction func navigateButtonTapped(_ sender: RoundedButton) {
        delegate?.navigateTappedIn(sender: self)
    }
    
    @IBAction func containerViewTapped(_ sender: UITapGestureRecognizer) {
        guard let annotation = annotation, annotation.isOccupant else { return }
        delegate?.occupantTappedIn(sender: self)
    }
}
