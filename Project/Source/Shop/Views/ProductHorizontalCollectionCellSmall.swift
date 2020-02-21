//
//  ProductsHorizontalCollectionCell.swift
//  Rekall
//
//  Created by Ray Hunter on 13/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol ProductHorizontalCollectionDelegate: class {
    func userTapped(product: Product, sender: UITableViewCell)
}

class ProductHorizontalCollectionCellSmall: UITableViewCell {
    
    static let identifier = "ProductHorizontalCollectionCellSmall"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    weak var delegate: ProductHorizontalCollectionDelegate?
    
    var viewModel: ProductsViewModel? {
        willSet {
            viewModel?.delegate = nil
        }
        didSet {
            collectionView?.reloadData()
            viewModel?.delegate = self
        }
    }
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView?
    @IBOutlet weak var seperatorLine: UIView!
    @IBOutlet var separatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet var separatorLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var separatorTrailingConstraint: NSLayoutConstraint!
    
    var thickSeparator = true {
        didSet {
            separatorHeightConstraint.constant = thickSeparator ? 1.0 : 0.5
            separatorLeadingConstraint.constant = thickSeparator ? 15 : 20
            separatorTrailingConstraint.constant = thickSeparator ? 15 : 0
            seperatorLine.backgroundColor = thickSeparator ? #colorLiteral(red: 0.8765067458, green: 0.876527369, blue: 0.8765162826, alpha: 1) : UIColor(named: "DefaultUnitFill")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        if let fl = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = UIScreen.main.bounds.width * (313.0 / 375.0)
            let height = width * (120.0 / 313.0)
            fl.itemSize = CGSize(width: width, height: height)
        }
        
        collectionView?.register(ProductHorizontalCellSmall.nib,
                                 forCellWithReuseIdentifier: ProductHorizontalCellSmall.identifier)
    }

}

extension ProductHorizontalCollectionCellSmall: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfItems ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let dataItem = viewModel?.product(at: indexPath.item)
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductHorizontalCellSmall.identifier,
                                                            for: indexPath) as? ProductHorizontalCellSmall else {
                                                                fatalError("ProductsHorizontalCollectionCell failed to dequeue cell")
        }
        
        cell.dataItem = dataItem
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let dataItem = viewModel?.product(at: indexPath.item) else { return }
        delegate?.userTapped(product: dataItem, sender: self)
    }
}

extension ProductHorizontalCollectionCellSmall: CollectionViewCoreDataItemUpdate {
    
}
