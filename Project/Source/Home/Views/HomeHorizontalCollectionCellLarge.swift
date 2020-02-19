//
//  VenuesHorizontalCollectionCell.swift
//  Rekall
//
//  Created by Ray Hunter on 13/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol HomeHorizontalCollectionDelegate: class {
    func userTapped(dataItem: DataItem, sender: UITableViewCell)
}

class HomeHorizontalCollectionCellLarge: UITableViewCell {
    
    static let identifier = "HomeHorizontalCollectionCellLarge"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    weak var delegate: HomeHorizontalCollectionDelegate?
    
    var viewModel: DataItemProvider? {
        willSet {
            viewModel?.delegate = nil
        }
        didSet {
            collectionView?.reloadData()
            viewModel?.delegate = self
        }
    }
    
    enum LayoutStyle {
        case allBigItems
        case twoSmallOneBig
    }
    
    var layoutStyle = LayoutStyle.allBigItems
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView?
    @IBOutlet var separatorView: UIView!
    @IBOutlet var separatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet var separatorLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var separatorTrailingConstraint: NSLayoutConstraint!

    static let DESIGN_SCREEN_WIDTH: CGFloat = 375.0
    static let DESIGN_CELL_WIDTH: CGFloat = 335.0
    static let DESIGN_LARGE_CELL_HEIGHT: CGFloat = 262.0
    static let DESIGN_SMALL_CELL_HEIGHT: CGFloat = 120.0
    
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    
    private var largeItemCellSize = CGSize(width: 50, height: 50)
    private var smallItemCellSize = CGSize(width: 50, height: 50)
    
    var thickSeparator = true {
        didSet {
            separatorHeightConstraint.constant = thickSeparator ? 1.0 : 0.5
            separatorLeadingConstraint.constant = thickSeparator ? 15 : 20
            separatorTrailingConstraint.constant = thickSeparator ? 15 : 0
            separatorView.backgroundColor = thickSeparator ? #colorLiteral(red: 0.8765067458, green: 0.876527369, blue: 0.8765162826, alpha: 1) : UIColor(named: "DefaultUnitFill")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let width = UIScreen.main.bounds.width * (Self.DESIGN_CELL_WIDTH / Self.DESIGN_SCREEN_WIDTH)
        let largeHeight = width * (Self.DESIGN_LARGE_CELL_HEIGHT / width)
        largeItemCellSize = CGSize(width: width, height: largeHeight)
        
        let smallHeight = width * (Self.DESIGN_SMALL_CELL_HEIGHT / width)
        smallItemCellSize = CGSize(width: width, height: smallHeight)
        
        let largestRequiredHeight = largeHeight > smallHeight * 2 ? largeHeight : smallHeight * 2
        collectionViewHeight!.constant = largestRequiredHeight + 1
        
        collectionView?.register(HomeHorizontalCellLarge.nib,
                                 forCellWithReuseIdentifier: HomeHorizontalCellLarge.identifier)
        collectionView?.register(HomeHorizontalCellSmall.nib,
                                 forCellWithReuseIdentifier: HomeHorizontalCellSmall.identifier)
    }
}

extension HomeHorizontalCollectionCellLarge: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch layoutStyle {
        case .allBigItems:
            return largeItemCellSize
        case .twoSmallOneBig:
            return (indexPath.item % 3) == 2 ? largeItemCellSize : smallItemCellSize
        }
    }
}

extension HomeHorizontalCollectionCellLarge: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfItems ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let dataItem = viewModel?.item(at: indexPath.item)
        
        if layoutStyle == .allBigItems || (indexPath.item % 3) == 2 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeHorizontalCellLarge.identifier,
                                                                for: indexPath) as? HomeHorizontalCellLarge else {
                                                                    fatalError("VenuesHorizontalCollectionCell failed to dequeue cell")
            }
            
            cell.dataItem = dataItem
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeHorizontalCellSmall.identifier,
                                                            for: indexPath) as? HomeHorizontalCellSmall else {
                                                                fatalError("VenuesHorizontalCollectionCell failed to dequeue cell")
        }
        
        cell.dataItem = dataItem
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let dataItem = viewModel?.item(at: indexPath.item) else { return }
        delegate?.userTapped(dataItem: dataItem, sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if (viewModel?.numberOfItems ?? 0) >= 2 {
            return UIEdgeInsets(top: 0, left: 15.0, bottom: 0, right: 15.0)
        } else {
            let gap = (collectionView.frame.width - largeItemCellSize.width) / 2.0
            return UIEdgeInsets(top: 0, left: gap, bottom: 0, right: gap)
        }
    }
}

extension HomeHorizontalCollectionCellLarge: CollectionViewCoreDataItemUpdate{
    
}
