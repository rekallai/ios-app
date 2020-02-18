//
//  InterestsDataSource.swift
//  Rekall
//
//  Created by Steve on 10/4/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol InterestsDataSourceDelegate: class {
    func dataSourceDidUpdate()
    func didSelect(ip: IndexPath)
}

class InterestsDataSource: NSObject {
    weak var delegate: InterestsDataSourceDelegate?
    
    let userViewModel = UserViewModel.shared
    let viewModel = InterestTopicViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    var insets = UIEdgeInsets(top: 48.0, left: 8.0, bottom: 48.0, right: 8.0)
    
    override init() {
        super.init()
        viewModel.onUpdateSuccess = { [weak self] in
            self?.delegate?.dataSourceDidUpdate()
        }
    }
    
    func loadData() {
        viewModel.searchInterestTopics()
    }
    
}

extension InterestsDataSource: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let interest = viewModel.interestTopic(at: indexPath.row)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InterestCell.identifier, for: indexPath) as! InterestCell
        
        let name = interest.name ?? ""
        let isLiked = userViewModel.isLiked(name)
        cell.titleLabel.text = interest.name
        cell.setIsLiked(isLiked)
        if let img = UIImage(named: name.capitalized) {
            cell.iconImageView.image = img
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cvWidth = collectionView.bounds.width
        let itemCount: CGFloat = (cvWidth > 320.0) ? 3.0 : 2.0
        let spacing: CGFloat = 8.0
        
        let totalSpacing = (insets.top + insets.bottom) + ((itemCount - 1.0) * spacing)
        let cellHeight = ((collectionView.bounds.height - totalSpacing)/itemCount)
        let cellWidth = cvWidth/2.33
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        let interest = viewModel.interestTopic(
            at: indexPath.row
        )
        userViewModel.updateInterest(interest.name ?? "")
        delegate?.didSelect(ip: indexPath)
        
        return true
    }
}
