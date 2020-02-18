//
//  DirectoryDataSource.swift
//  Rekall
//
//  Created by Steve on 8/2/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol DirectoryDataSourceDelegate: class {
    func dataSourceUpdated()
    func didSelect(category: Category)
}

class DirectoryDataSource: NSObject {
    weak var delegate: DirectoryDataSourceDelegate?
    
    private var dataLoadFailed = false
    
    var categoryViewModel = CategoryViewModel(
        api: ADApi.shared.api, store: ADApi.shared.store
    )

    override init() {
        super.init()
        categoryViewModel.onUpdateSuccess = { [weak self] in
            self?.dataLoadFailed = false
            self?.delegate?.dataSourceUpdated()
        }
        categoryViewModel.onUpdateFailure = { [weak self] errorStr in
            self?.dataLoadFailed = true
        }
    }
    
    func loadData(onlyIfPreviouslyFailed: Bool) {
        guard onlyIfPreviouslyFailed else {
            categoryViewModel.loadCategories()
            return
        }
        
        if dataLoadFailed { categoryViewModel.loadCategories() }
    }
    
}

extension DirectoryDataSource: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryViewModel.numberOfItems(
            section: section
        )
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categoryViewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DirectoryCategoryCell.identifier, for: indexPath
            ) as! DirectoryCategoryCell
        
        cell.category = categoryViewModel.category(at: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let section = categoryViewModel.section(at: indexPath)
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: DirectorySectionHeader.identifier,
            for:indexPath
        ) as! DirectorySectionHeader
            
        header.titleLabel.text = section.title
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cvSize = collectionView.bounds.size.width - 30
        let cellWidth = cvSize/2
        // smaller screens need extra height to account for overflow
        let cellHeight = (cvSize > 300.0) ? cvSize/3 : cellWidth
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        let selectedCategory = categoryViewModel.category(
            at: indexPath
        )
        delegate?.didSelect(category: selectedCategory)
        
        return true
    }
}
