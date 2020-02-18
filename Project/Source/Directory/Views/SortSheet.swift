//
//  SortSheet.swift
//  Rekall
//
//  Created by Steve on 8/6/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

enum SortType:String, CaseIterable {
    case nearMe = "Near Me"
    case openNow = "Open Now"
    case recent = "Recently Added"
    case cancel = "Cancel"
}

protocol SortSheetDelegate: class {
    func sortActionTapped(sortType: SortType)
    func sortButtonTapped(alert: UIAlertController)
}

class SortSheet: NSObject {
    weak var delegate: SortSheetDelegate?
    lazy var sheet: UIAlertController = {
        return UIAlertController(
            title:nil, message:nil,
            preferredStyle: .actionSheet
        )
    }()
    
    override init() {
        super.init()
        addActions()
    }
    
    public func sortButton()->UIBarButtonItem {
        return UIBarButtonItem(
            title: "Sort", style: .plain,
            target: self, action: #selector(sortButtonTapped)
        )
    }
    
    @objc func sortButtonTapped() {
        delegate?.sortButtonTapped(alert:sheet)
    }
    
    private func addActions() {
        SortType.allCases.forEach { (sortType) in
            let action = UIAlertAction(
                title: sortType.rawValue,
                style: (sortType == .cancel) ? .cancel : .default,
                handler: { _ in
                    self.delegate?.sortActionTapped(sortType:sortType)
                }
            )
            self.sheet.addAction(action)
        }
    }
    
}
