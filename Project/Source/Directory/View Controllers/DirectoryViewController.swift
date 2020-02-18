//
//  DirectoryViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 03/07/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class DirectoryViewController: TopLevelSearchViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let dataSource = DirectoryDataSource()
    var selectedCategory:Category?

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.delegate = self
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        dataSource.loadData(onlyIfPreviouslyFailed: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CategorySegue" {
            if let vc = segue.destination as? CategoryViewController {
                vc.category = selectedCategory
            }
        }
    }
    
}

extension DirectoryViewController: DirectoryDataSourceDelegate {
    func dataSourceUpdated() {
        collectionView.reloadData()
    }
    
    func didSelect(category: Category) {
        selectedCategory = category
    }
}
