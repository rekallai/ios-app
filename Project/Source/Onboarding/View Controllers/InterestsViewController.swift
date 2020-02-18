//
//  InterestsViewController.swift
//  Rekall
//
//  Created by Steve on 10/3/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class InterestsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let dataSource = InterestsDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        title = NSLocalizedString("My Interests", comment: "Title")
        dataSource.delegate = self
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        dataSource.loadData()
    }

}

extension InterestsViewController: InterestsDataSourceDelegate {
    
    func dataSourceDidUpdate() {
        collectionView.reloadData()
    }
    
    func didSelect(ip: IndexPath) {
        collectionView.reloadItems(at: [ip])
    }
    
}
