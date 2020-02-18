//
//  CategoryViewController.swift
//  Rekall
//
//  Created by Steve on 8/1/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {

    @IBOutlet weak var tableView: CategoryTableView!
    let dataSource = CategoryDataSource()
    var category:Category? {
        didSet {
            dataSource.delegate = self
            dataSource.category = category
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }

}

extension CategoryViewController: CategoryDataSourceDelegate {
    
    func dataSourceUpdated() {
        tableView.reloadData()
    }
    
    func didSelect(venue: Venue) {
        if let vc = UIStoryboard.venueDetail() {
            vc.venue = venue
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func venueFavorited(indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}
