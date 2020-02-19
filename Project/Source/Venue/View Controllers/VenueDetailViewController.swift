//
//  VenueDetailViewController.swift
//  Rekall
//
//  Created by Steve on 6/18/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import AlamofireImage
import SafariServices
import PassKit

class VenueDetailViewController: UIViewController {
    
    @IBOutlet var tableView: VenueDetailTableView?
    var timer: Timer?
    
    var updatable: CDUpdateMonitor<Venue>?

    var venue: Venue? {
        set {
            updatable = nil
            if let venue = newValue {
                updatable = CDUpdateMonitor(cdItem: venue) { [weak self] in
                    self?.tableView?.reloadData()
                }
            }
        }
        get {
            return updatable?.cdItem
        }
    }

    var nearbyVenue: Venue?
    var dataSource = VenueDetailDataSource()
    
    @IBAction func unwindWebView(unwindSegue: UIStoryboardSegue) { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never

        setUpTableView()
    }
    
    func setUpTableView() {
        tableView?.delegate = dataSource
        tableView?.dataSource = dataSource
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowVenueSegue" {
            if let vc = segue.destination as? VenueDetailViewController {
                vc.venue = nearbyVenue
            }
        }
    }
}
