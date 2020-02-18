//
//  OpenMapsSheet.swift
//  Rekall
//
//  Created by Steve on 8/20/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

enum OpenMapsType:String, CaseIterable {
    case openMaps = "Open in Maps"
    case cancel = "Cancel"
}

protocol OpenMapsSheetDelegate: class {
    func openMapsActionTapped(openMapsType:OpenMapsType)
}

class OpenMapsSheet: NSObject {
    weak var delegate: OpenMapsSheetDelegate?
    lazy var sheet: UIAlertController = {
        return UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    }()
    
    override init() {
        super.init()
        addActions()
    }
    
    private func addActions() {
        OpenMapsType.allCases.forEach { (openMapsType) in
            let action = UIAlertAction(
                title: openMapsType.rawValue,
                style: (openMapsType == .cancel) ? .cancel : .default,
                handler: { _ in
                    self.delegate?.openMapsActionTapped(openMapsType: openMapsType)
            }
            )
            self.sheet.addAction(action)
        }
    }

}
