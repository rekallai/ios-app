//
//  ImageSliderDataSource.swift
//  Rekall
//
//  Created by Steve on 7/25/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol ImageSliderDelegate: class {
    func imageChanged(page: Int)
}

class ImageSliderDataSource: NSObject {
    weak var delegate: ImageSliderDelegate?
    var imageUrls = [URL]()
}

extension ImageSliderDataSource: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let imageUrl = imageUrls[indexPath.row]
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageSliderCell.identifier,
            for: indexPath
        ) as! ImageSliderCell
        cell.imageView?.af_setImage(withURL: imageUrl)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let current = Int(ceil(x/w))
        delegate?.imageChanged(page: current)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
}
